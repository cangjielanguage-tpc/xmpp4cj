package xmpp4cj.modular

public class C2sConnection <: AbstractXMPPConnection {
    static let LOGGER = getGlobalLogger("C2sConnConfig")

    let outgoingElementsQueue = ArrayBlockingQueueWithShutdown<TopLevelStreamElement>(100, true)

    var activeTransport: ?C2sTransport = None

    let connectionStateMachineListeners: ConcurrentLinkedList<ConnectionStateMachineListener> = ConcurrentLinkedList()

    var featuresReceived: Bool = false

    protected var streamResumed: Bool = false

    // 依赖this构建 使用预占位符 实际已在init中保证初始化
    private var currentStateVertex: GraphVertex<State> = unsafe { zeroValue<GraphVertex<State>>() }

    var walkFromDisconnectToAuthenticated: ?ArrayList<State> = None

    private let configuration: C2sConnectionConfiguration

    // 依赖this构建 使用预占位符 实际已在init中保证初始化
    var connectionInternal: C2sConnectionInternal = unsafe { zeroValue<C2sConnectionInternal>() }

    private let connectionModules: Map<ClassId, C2sConnectionModule> = HashMap()

    let transports: Map<ClassId, C2sTransport> = HashMap()

    /**
     * This is one of those cases where the field is modified by one thread and read by another. We currently use
     * CopyOnWriteArrayList but should potentially use a VarHandle once Xmpp supports them.
     */
    let inputOutputFilters: ConcurrentLinkedList<XmppInputOutputFilter> = ConcurrentLinkedList()

    var previousInputOutputFilters: ?ArrayList<XmppInputOutputFilter> = None

    public init(configuration: C2sConnectionConfiguration) {
        super(configuration)
        this.configuration = configuration
        postInit()
        // Construct the internal connection API.
        connectionInternal = C2sConnInternal1(this, getReactor(), debugger, outgoingElementsQueue)

        // Construct the modules from the module descriptor.
        // We do this before constructing the state graph, as the modules are sometimes used to construct the states.
        for (moduleDescriptor in configuration.moduleDescriptors) {
            let moduleDescriptorClass = moduleDescriptor.getClass()
            let connectionModule = moduleDescriptor.constructXmppConnectionModule(connectionInternal)
            connectionModules.add(moduleDescriptorClass, connectionModule)

            let transport = connectionModule.getTransport()
            if (let Some(v) <- transport) {
                transports.add(moduleDescriptorClass, v)
            }
        }

        let initialStateDescriptorVertex = configuration.initialStateDescriptorVertex
        currentStateVertex = StateDescriptorGraph.convertToStateGraph(initialStateDescriptorVertex, connectionInternal)
    }

    public func getConnectionModuleFor<CM>(descriptorClass: ClassId): CM where CM <: C2sConnectionModule {
        match (connectionModules.get(descriptorClass)) {
            case Some(v: CM) => v
            case _ => throw IllegalArgumentException("no find CM") // should not react here
        }
    }

    protected override func loginInternal(username: ?String, password: ?String, resource: ?Resourcepart): Unit {
        let walkStateGraphContext = buildNewWalkTo("AuthenticatedAndResourceBoundStateDescriptor")
            .withLoginContext(username, password, resource)
            .build()
        walkStateGraph(walkStateGraphContext)
    }

    protected func buildNewWalkTo(finalStateClass: ClassId): WalkStateGraphContextBuilder {
        return WalkStateGraphContext.builder(currentStateVertex.getElement().getStateDescriptor().getClass(),
            finalStateClass)
    }

    /**
     * Unwind the state. This will revert the effects of the state by calling {@link State#resetState()} prior issuing a
     * connection state event of {@link ConnectionStateEvent#StateRevertBackwardsWalk}.
     *
     * @param revertedState the state which is going to get reverted.
     */
    private func unwindState(revertedState: State): Unit {
        invokeConnectionStateMachineListener(ConnectionStateEventStateRevertBackwardsWalk(revertedState))
        revertedState.resetState()
    }

    protected func walkStateGraph(walkStateGraphContext: WalkStateGraphContext): Unit {
        let previousStateVertex = currentStateVertex
        try {
            walkStateGraphInternal(walkStateGraphContext)
        } catch (e: Exception) {
            currentStateVertex = previousStateVertex
            let revertedState = currentStateVertex.getElement()
            unwindState(revertedState)
            throw e
        }
    }

    private func walkStateGraphInternal(walkStateGraphContext: WalkStateGraphContext): Unit {
        let initialStateVertex = currentStateVertex
        let initialState = initialStateVertex.getElement()
        let initialStateDescriptor = initialState.getStateDescriptor()
        walkStateGraphContext.recordWalkTo(initialState)
        if (walkStateGraphContext.isWalksFinalState(initialStateDescriptor)) {
            if (!initialStateDescriptor.isFinalState()) {
                throw AssertionError()
            }
            invokeConnectionStateMachineListener(ConnectionStateEventFinalStateReached(initialState))
            return
        }
        let outgoingStateEdges = initialStateVertex.getOutgoingEdges()
        let mandatoryIntermediateStateVertex = walkStateGraphContext.maybeReturnMandatoryImmediateState(
            outgoingStateEdges)
        if (let Some(vertex) <- mandatoryIntermediateStateVertex) {
            let reason = attemptEnterState(vertex, walkStateGraphContext)
            if (let Some(_: StateTransitionResultSuccess) <- reason) {
                walkStateGraph(walkStateGraphContext)
                return
            }
            throw XmppMandatoryStateFailedException(vertex.getElement(), reason)
        }

        for (i in 0..outgoingStateEdges.size) {
            let successorStateVertex = outgoingStateEdges[i]
            let successorState = successorStateVertex.getElement()
            if (walkStateGraphContext.wouldCauseCycle(successorStateVertex)) {
                invokeConnectionStateMachineListener(
                    ConnectionStateEventTransitionIgnoredDueCycle(initialStateVertex, successorStateVertex))
            } else {
                let result = attemptEnterState(successorStateVertex, walkStateGraphContext)
                if (let Some(_: StateTransitionResultSuccess) <- result) {
                    break
                }
                if (let Some(r) <- result) {
                    walkStateGraphContext.recordFailedState(successorState, r)
                }
            }
            // if do not have next
            if (i >= outgoingStateEdges.size - 1) {
                throw XmppStateGraphDeadEndException.comefrom(walkStateGraphContext, initialStateVertex)
            }
        }
        walkStateGraph(walkStateGraphContext)
    }

    /**
     * Attempt to enter a state. Note that this method may return <code>null</code> if this state can be safely ignored.
     *
     * @param successorStateVertex the successor state vertex.
     * @param walkStateGraphContext the "walk state graph" context.
     * @return A state transition result or <code>null</code> if this state can be ignored.
     * @throws XmppException if Xmpp detected an exceptional situation.
     * @throws XMPPException if an XMPP protocol error was received.
     * @throws IOException if an I/O error occurred.
     */
    private func attemptEnterState(
        successorStateVertex: GraphVertex<State>,
        walkStateGraphContext: WalkStateGraphContext
    ): ?StateTransitionResult {
        let initialStateVertex = currentStateVertex
        let initialState = initialStateVertex.getElement()
        let successorState = successorStateVertex.getElement()
        let successorStateDescriptor = successorState.getStateDescriptor()

        if (!successorStateDescriptor.isMultiVisitState() && walkStateGraphContext.stateAlreadyVisited(successorState)) {
            return None
        }

        if (successorStateDescriptor.isNotImplemented()) {
            let transtionImpossibleBecauseNotImplemented = TransitionImpossibleBecauseNotImplemented(
                successorStateDescriptor)
            invokeConnectionStateMachineListener(
                ConnectionStateEventTransitionNotPossible(initialState, successorState,
                    transtionImpossibleBecauseNotImplemented))
            return transtionImpossibleBecauseNotImplemented
        }

        let transitionAttemptResult: AttemptResult
        try {
            let transitionImpossible = successorState.isTransitionToPossible(walkStateGraphContext)
            if (let Some(transitionImpossible) <- transitionImpossible) {
                invokeConnectionStateMachineListener(
                    ConnectionStateEventTransitionNotPossible(initialState, successorState, transitionImpossible))
                return transitionImpossible
            }
            invokeConnectionStateMachineListener(ConnectionStateEventAboutToTransitionInto(initialState, successorState)
            )
            transitionAttemptResult = successorState.transitionInto(walkStateGraphContext)
        } catch (e: Exception) {
            unwindState(successorState)
            throw e
        }
        if (let Some(transitionFailureResult) <- (transitionAttemptResult as StateTransitionResultFailure)) {
            invokeConnectionStateMachineListener(
                ConnectionStateEventTransitionFailed(initialState, successorState, transitionFailureResult))
            return transitionAttemptResult
        }

        let transitionSuccessResult = (transitionAttemptResult as StateTransitionResultSuccess).getOrThrow()
        currentStateVertex = successorStateVertex
        invokeConnectionStateMachineListener(
            ConnectionStateEventSuccessfullyTransitionedInto(successorState, transitionSuccessResult))

        return transitionSuccessResult
    }

    protected override func sendStanzaInternal(stanza: Stanza): Unit {
        sendTopLevelStreamElement(stanza)
    }

    public override func sendNonza(nonza: Nonza): Unit {
        sendTopLevelStreamElement(nonza)
    }

    private func sendTopLevelStreamElement(element: TopLevelStreamElement): Unit {
        let transport = activeTransport
        if (transport.isNone()) {
            throw NotConnectedException()
        }
        outgoingElementsQueue.put(element)
        transport?.notifyAboutNewOutgoingElements()
    }

    protected override func shutdown(): Unit {
        shutdown(false)
    }

    public override func instantShutdown(): Unit {
        synchronized(lock) {
            shutdown(true)
        }
    }

    public override func getConfiguration(): C2sConnectionConfiguration {
        return configuration
    }

    private func shutdown(instant: Bool): Unit {
        let mandatoryIntermediateState: ClassId
        if (instant) {
            mandatoryIntermediateState = "InstantShutdownStateDescriptor"
        } else {
            mandatoryIntermediateState = "ShutdownStateDescriptor"
        }
        let context = buildNewWalkTo("DisconnectedStateDescriptor")
            .withMandatoryIntermediateState(mandatoryIntermediateState)
            .build()
        try {
            walkStateGraph(context)
        } catch (e: Exception) {
            DEBUGER.log(LogLevel.ERROR, "Ignored exception during shutdown: ${e}", e)
            throw IllegalStateException("A walk to disconnected state should never throw ${e}")
        }
    }

    protected func getSSLSession(): ?TlsSession {
        return activeTransport?.getSslSession() ?? None
    }

    protected override func afterFeaturesReceived(): Unit {
        featuresReceived = true
        notifyWaitingThreads()
    }

    protected func parseAndProcessElement(element: String): Unit {
        try {
            let parser = PacketParserUtils.getParserFor(element)
            parser.next()
            var event = parser.getEventType()

            while (true) {
                match (event) {
                    case START_ELEMENT =>
                        let name = parser.getName()
                        // Note that we don't handle "stream" here as it's done in the splitter.
                        match (name) {
                            case v where v == Message.ELEMENT || v == IQ.IQ_ELEMENT || v == Presence.ELEMENT => try {
                                parseAndProcessStanza(parser)
                            } finally {
                                // Here would be the following stream management code.
                                // clientHandledStanzasCount = SMUtils.incrementHeight(clientHandledStanzasCount)
                            }
                            case "error" =>
                                let streamError = PacketParserUtils.parseStreamError(parser, None)
                                let streamErrorException = StreamErrorException(streamError)
                                currentXmppException = streamErrorException
                                notifyWaitingThreads()
                                throw streamErrorException
                            case "features" =>
                                parseFeatures(parser)
                                afterFeaturesReceived()
                            case _ => parseAndProcessNonza(parser)
                        }
                    case END_DOCUMENT => break // outerloop
                    case _ => () // fall out
                }
                event = parser.next()
            }
        } catch (e: Exception) {
            notifyConnectionError(e)
        }
    }

    protected func prepareToWaitForFeaturesReceived(): Unit {
        synchronized(lock) {
            featuresReceived = false
        }
    }

    protected func waitForFeaturesReceived(waitFor: String): Unit {
        waitForConditionOrThrowConnectionException({=> featuresReceived}, waitFor)
    }

    protected func newStreamOpenWaitForFeaturesSequence(waitFor: String): Unit {
        prepareToWaitForFeaturesReceived()
        sendStreamOpen()
        waitForFeaturesReceived(waitFor)
    }

    var compressionEnabled: Bool = false

    public override func isUsingCompression(): Bool {
        return compressionEnabled
    }

    public func addConnectionStateMachineListener(connectionStateMachineListener: ConnectionStateMachineListener): Unit {
        connectionStateMachineListeners.append(connectionStateMachineListener)
    }

    public func removeConnectionStateMachineListener(connectionStateMachineListener: ConnectionStateMachineListener): Bool {
        return connectionStateMachineListeners.remove(connectionStateMachineListener)
    }

    protected func invokeConnectionStateMachineListener(connectionStateEvent: ConnectionStateEvent): Unit {
        if (connectionStateMachineListeners.isEmpty()) {
            return
        }
        ASYNC_BUT_ORDERED.performAsyncButOrdered(
            this,
            {
                => for (connectionStateMachineListener in connectionStateMachineListeners) {
                    connectionStateMachineListener.onConnectionStateEvent(connectionStateEvent, this)
                }
            }
        )
    }

    public override func isSecureConnection(): Bool {
        return activeTransport?.isTransportSecured() ?? false
    }

    protected override func connectInternal(): Unit {
        let walkStateGraphContext = buildNewWalkTo("ConnectedButUnauthenticatedStateDescriptor").build()
        walkStateGraph(walkStateGraphContext)
    }

    protected func getFilterStats(): Map<String, Object> {
        let filters: Collection<XmppInputOutputFilter>
        let size: Int
        synchronized(lock) {
            if (inputOutputFilters.size > 0 && previousInputOutputFilters.isSome()) {
                let v = previousInputOutputFilters.getOrThrow()
                filters = v
                size = v.size
            } else {
                filters = inputOutputFilters
                size = inputOutputFilters.size
            }
        }
        let filterStats: Map<String, Object> = HashMap<String, Object>(size)
        for (xmppInputOutputFilter in filters) {
            let stats = xmppInputOutputFilter.getStats()
            let filterName = xmppInputOutputFilter.getFilterName()
            filterStats.add(filterName, stats)
        }
        return filterStats
    }

    public func getStats(): Stats {
        let transportsStats: Map<ClassId, C2sTransportStats> = HashMap(transports.size)
        for ((key, value) in transports) {
            let transportStats = value.getStats()
            transportsStats.add(key, transportStats)
        }
        let filterStats = getFilterStats()
        return Stats(transportsStats, filterStats)
    }

    let lock = Mutex()

    public override func getClass(): ClassId {
        "C2sConnection"
    }
}

class C2sConnInternal1 <: C2sConnectionInternal {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, reactor: XmppReactor, xmppDebugger: ?XmppDebugger,
        outgoingElementsQueue: ArrayBlockingQueueWithShutdown<TopLevelStreamElement>) {
        super(c2sconn, reactor, xmppDebugger, outgoingElementsQueue)
        this.c2sconn = c2sconn
    }

    public override func parseAndProcessElement(wrappedCompleteElement: String): Unit {
        c2sconn.parseAndProcessElement(wrappedCompleteElement)
    }

    public override func notifyConnectionError(e: Exception): Unit {
        c2sconn.notifyConnectionError(e)
    }

    public override func onStreamOpen(parser: XmlPullParser): Unit {
        c2sconn.onStreamOpen(parser)
    }

    public override func onStreamClosed(): Unit {
        c2sconn.closingStreamReceived = true
        notifyWaitingThreads()
    }

    public override func fireFirstLevelElementSendListeners(element: TopLevelStreamElement): Unit {
        c2sconn.fireElementSendingListeners(element)
    }

    public override func invokeConnectionStateMachineListener(connectionStateEvent: ConnectionStateEvent): Unit {
        c2sconn.invokeConnectionStateMachineListener(connectionStateEvent)
    }

    public override func getOutgoingStreamXmlEnvironment(): ?XmlEnvironment {
        return c2sconn.outgoingStreamXmlEnvironment
    }

    public override func addXmppInputOutputFilter(xmppInputOutputFilter: XmppInputOutputFilter): Unit {
        c2sconn.inputOutputFilters.prepend(xmppInputOutputFilter)
    }

    public override func getXmppInputOutputFilterBeginIterator(): Iterator<XmppInputOutputFilter> {
        return c2sconn.inputOutputFilters.iterator()
    }

    public override func getXmppInputOutputFilterEndIterator(): ListIterator<XmppInputOutputFilter> {
        return ListIterator(c2sconn.inputOutputFilters.iterator(), c2sconn.inputOutputFilters.size)
    }

    public override func newStreamOpenWaitForFeaturesSequence(waitFor: String): Unit {
        c2sconn.newStreamOpenWaitForFeaturesSequence(waitFor)
    }

    public override func getXmppTlsContext(): XmppTlsContext {
        return c2sconn.getXmppTlsContext()
    }

    public override func sendAndWaitForResponse(nonza: Nonza, successNonzaClass: ClassId, failedNonzaClass: ClassId): ?Nonza {
        let sn = c2sconn.sendAndWaitForResponse(nonza, successNonzaClass, failedNonzaClass)
        return sn.getOrThrow()
    }

    public override func asyncGo(runnable: Runnable): Unit {
        AbstractXMPPConnection.asyncGo(runnable)
    }

    public override func waitForConditionOrThrowConnectionException(condition: Supplier<Bool>, waitFor: String): Unit {
        c2sconn.waitForConditionOrThrowConnectionException(condition, waitFor)
    }

    public override func notifyWaitingThreads(): Unit {
        c2sconn.notifyWaitingThreads()
    }

    public override func setCompressionEnabled(compressionEnabled: Bool): Unit {
        c2sconn.compressionEnabled = compressionEnabled
    }

    public override func setTransport(xmppTransport: ?C2sTransport): Unit {
        c2sconn.activeTransport = xmppTransport
        c2sconn.connected = true
    }
}

public class DisconnectedStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "DisconnectedState",
                {
                    args => DisconnectedState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            ),
            StateDescriptorProperty.finalState
        )
        addSuccessor(LookupRemoteConnectionEndpointsStateDescriptor())
    }

    public override func getClass(): ClassId {
        "DisconnectedStateDescriptor"
    }
}

class DisconnectedState <: State {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        synchronized(c2sconn.lock) {
            if (c2sconn.inputOutputFilters.isEmpty()) {
                c2sconn.previousInputOutputFilters = None
            } else {
                c2sconn.previousInputOutputFilters = ArrayList<XmppInputOutputFilter>(c2sconn.inputOutputFilters)
                c2sconn.inputOutputFilters.clear()
            }
        }

        // Reset all states we have visited when transitioning from disconnected to authenticated.
        // This assumes that every state after authenticated does not need to be reset.
        let list = c2sconn.walkFromDisconnectToAuthenticated.getOrThrow()
        for (i in list.size - 1..=0 : -1) {
            let stateToReset = list[i]
            stateToReset.resetState()
        }
        c2sconn.walkFromDisconnectToAuthenticated = None

        return StateTransitionResultSuccess.EMPTY_INSTANCE
    }

    // public override func getClass(): ClassId {
    //     "DisconnectedState"
    // }
}

public class LookupRemoteConnectionEndpointsStateDescriptor <: StateDescriptor {
    public init() {
        super(
            ClassInfo(
                "LookupRemoteConnectionEndpointsState",
                {
                    args => LookupRemoteConnectionEndpointsState((args[0] as C2sConnection)(),
                        (args[1] as StateDescriptor)(), (args[2] as C2sConnectionInternal)())
                }
            )
        )
    }

    public override func getClass(): ClassId {
        "LookupRemoteConnectionEndpointsStateDescriptor"
    }
}

class LookupRemoteConnectionEndpointsState <: State {
    let c2sconn: C2sConnection
    var outgoingElementsQueueWasShutdown: Bool = false

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        let lookupFutures: Map<C2sTransport, Collection<XmppFuture<LookupConnectionEndpointsResult, Exception>>> = HashMap(
            c2sconn.transports.size)

        let allFutures = ArrayList<XmppFuture<LookupConnectionEndpointsResult, Exception>>()
        for (transport in c2sconn.transports.values()) {
            transport.resetDiscoveredConnectionEndpoints()
            let transportFutures = transport.lookupConnectionEndpoints()
            lookupFutures.add(transport, transportFutures)
            allFutures.add(all: transportFutures)
        }
        let numberOfFutures: Int = allFutures.size
        let list: Collection<XmppFuture<LookupConnectionEndpointsResult, Exception>> = allFutures
        await(list, c2sconn.getReplyTimeout()) // TODO

        let lookupFailures = ArrayList<LookupConnectionEndpointsFailed>(numberOfFutures)
        var atLeastOneConnectionEndpointDiscovered = false
        for ((transport, value) in lookupFutures) {
            for (future in value) {
                let result = future.getIfAvailable() ?? continue

                if (let Some(lookupFailure) <- (result as LookupConnectionEndpointsFailed)) {
                    lookupFailures.add(lookupFailure)
                    continue
                }
                let successResult = (result as LookupConnectionEndpointsSuccess).getOrThrow()
                transport.loadConnectionEndpoints(successResult)
                atLeastOneConnectionEndpointDiscovered = true
            }
        }
        if (!atLeastOneConnectionEndpointDiscovered) {
            throw NoEndpointsDiscoveredException.comefrom(lookupFailures)
        }
        outgoingElementsQueueWasShutdown = c2sconn.outgoingElementsQueue.start()
        return StateTransitionResultSuccess.EMPTY_INSTANCE
    }
    public static func await<V>(
        futures: Collection<XmppFuture<V, Exception>>,
        timeout: Duration
    ): Bool {
        let latch = SyncCounter(futures.size)
        for (future in futures) {
            future.onCompletion {_ => latch.dec()}
        }
        latch.waitUntilZero(timeout: timeout)
        return latch.count == 0
    }

    public override func resetState(): Unit {
        for (transport in c2sconn.transports.values()) {
            transport.resetDiscoveredConnectionEndpoints()
        }
        if (outgoingElementsQueueWasShutdown) {
            c2sconn.outgoingElementsQueue.shutdown()
        }
    }

    // public override func getClass(): ClassId {
    //     "LookupRemoteConnectionEndpointsState"
    // }
}

public class ConnectedButUnauthenticatedStateDescriptor <: StateDescriptor {
    public init() {
        super(
            ClassInfo(
                "ConnectedButUnauthenticatedState",
                {
                    args => ConnectedButUnauthenticatedState((args[0] as C2sConnection)(),
                        (args[1] as StateDescriptor)(), (args[2] as C2sConnectionInternal)())
                }
            ),
            [StateDescriptorProperty.finalState]
        )
        addSuccessor(SaslAuthenticationStateDescriptor())
        addSuccessor(InstantShutdownStateDescriptor())
        addSuccessor(ShutdownStateDescriptor())
    }

    public override func getClass(): ClassId {
        "ConnectedButUnauthenticatedStateDescriptor"
    }
}

class ConnectedButUnauthenticatedState <: State {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        assert(c2sconn.walkFromDisconnectToAuthenticated.isNone())

        if (walkStateGraphContext.isWalksFinalState(getStateDescriptor())) {
            c2sconn.walkFromDisconnectToAuthenticated = walkStateGraphContext.getWalk()
        }
        c2sconn.connected = true
        return StateTransitionResultSuccess.EMPTY_INSTANCE
    }

    public override func resetState(): Unit {
        c2sconn.connected = false
    }

    // public override func getClass(): ClassId {
    //     "ConnectedButUnauthenticatedState"
    // }
}

public class SaslAuthenticationStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "SaslAuthenticationState",
                {
                    args => SaslAuthenticationState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            ),
            "RFC 6120 § 6"
        )
        addSuccessor(AuthenticatedButUnboundStateDescriptor())
    }

    public override func getClass(): ClassId {
        "SaslAuthenticationStateDescriptor"
    }
}

class SaslAuthenticationState <: State {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        c2sconn.prepareToWaitForFeaturesReceived()
        let loginContext = walkStateGraphContext.getLoginContext().getOrThrow()
        let usedSaslMechanism = c2sconn.authenticate(loginContext.username, loginContext.password,
            c2sconn.config.getAuthzid(), c2sconn.getSSLSession())
        c2sconn.waitForFeaturesReceived("server stream features after SASL authentication")
        return SaslAuthenticationSuccessResult(usedSaslMechanism)
    }

    // public override func getClass(): ClassId {
    //     "SaslAuthenticationState"
    // }
}

public class SaslAuthenticationSuccessResult <: StateTransitionResultSuccess {
    private let saslMechanismName: String

    init(usedSaslMechanism: SASLMechanism) {
        super("SASL authentication successfull using ${usedSaslMechanism.getName()}")
        this.saslMechanismName = usedSaslMechanism.getName()
    }

    public func getSaslMechanismName(): String {
        return saslMechanismName
    }

    // public override func getClass(): ClassId {
    //     "SaslAuthenticationSuccessResult"
    // }
}

public class AuthenticatedButUnboundStateDescriptor <: StateDescriptor {
    public init() {
        super([StateDescriptorProperty.multiVisitState])
        addSuccessor(ResourceBindingStateDescriptor())
    }

    public override func getClass(): ClassId {
        "AuthenticatedButUnboundStateDescriptor"
    }
}

public class ResourceBindingStateDescriptor <: StateDescriptor {
    public init() {
        super(
            ClassInfo(
                "ResourceBindingState",
                {
                    args => ResourceBindingState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            ),
            "RFC 6120 § 7"
        )
        addSuccessor(AuthenticatedAndResourceBoundStateDescriptor())
    }

    public override func getClass(): ClassId {
        "ResourceBindingStateDescriptor"
    }
}

class ResourceBindingState <: State {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        c2sconn.lastFeaturesReceived = true
        c2sconn.notifyWaitingThreads()
        let loginContext = walkStateGraphContext.getLoginContext().getOrThrow()
        let resource = c2sconn.bindResourceAndEstablishSession(loginContext.resource)
        c2sconn.streamResumed = false
        return ResourceBoundResult(resource, loginContext.resource)
    }

    // public override func getClass(): ClassId {
    //     "ResourceBindingState"
    // }
}

public class ResourceBoundResult <: StateTransitionResultSuccess {
    private let resource: ?Resourcepart

    init(boundResource: ?Resourcepart, requestedResource: ?Resourcepart) {
        super("Resource '${anyToString(boundResource)}' bound (requested: '${anyToString(requestedResource)}')")
        this.resource = boundResource
    }

    public func getResource(): ?Resourcepart {
        return resource
    }

    // public override func getClass(): ClassId {
    //     "ResourceBoundResult"
    // }
}

public class AuthenticatedAndResourceBoundStateDescriptor <: StateDescriptor {
    public init() {
        super(
            ClassInfo(
                "AuthenticatedAndResourceBoundState",
                {
                    args => AuthenticatedAndResourceBoundState((args[0] as C2sConnection)(),
                        (args[1] as StateDescriptor)(), (args[2] as C2sConnectionInternal)())
                }
            ),
            [StateDescriptorProperty.finalState]
        )
        addSuccessor(InstantShutdownStateDescriptor())
        addSuccessor(ShutdownStateDescriptor())
    }

    public override func getClass(): ClassId {
        "AuthenticatedAndResourceBoundStateDescriptor"
    }
}

class AuthenticatedAndResourceBoundState <: State {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        if (let Some(s) <- c2sconn.walkFromDisconnectToAuthenticated) {
            assert(walkStateGraphContext.getWalk()[0].getStateDescriptor().getClass() != "DisconnectedStateDescriptor")
            walkStateGraphContext.appendWalkTo(s)
        } else {
            let list = ArrayList<State>(walkStateGraphContext.getWalkLength() + 1)
            c2sconn.walkFromDisconnectToAuthenticated = list
            walkStateGraphContext.appendWalkTo(list)
        }
        c2sconn.walkFromDisconnectToAuthenticated?.add(this)
        c2sconn.afterSuccessfulLogin(c2sconn.streamResumed)
        return StateTransitionResultSuccess.EMPTY_INSTANCE
    }

    public override func resetState(): Unit {
        c2sconn.authenticated = false
    }

    // public override func getClass(): ClassId {
    //     "AuthenticatedAndResourceBoundState"
    // }
}

class ShutdownStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "ShutdownState",
                {
                    args => ShutdownState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            )
        )
        addSuccessor(CloseConnectionStateDescriptor())
    }

    public override func getClass(): ClassId {
        "ShutdownStateDescriptor"
    }
}

class ShutdownState <: State {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        ensureNotOnOurWayToAuthenticatedAndResourceBound(walkStateGraphContext)
        return None
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        c2sconn.closingStreamReceived = false
        let streamCloseIssued = c2sconn.outgoingElementsQueue.offerAndShutdown(StreamClose.INSTANCE)
        if (streamCloseIssued) {
            c2sconn.activeTransport?.notifyAboutNewOutgoingElements()
            let successfullyReceivedStreamClose = c2sconn.waitForClosingStreamTagFromServer()
            if (successfullyReceivedStreamClose) {
                for (filter in connectionInternal.getXmppInputOutputFilterBeginIterator()) {
                    filter.closeInputOutput()
                }
                c2sconn.activeTransport?.afterFiltersClosed()
                for (filter in connectionInternal.getXmppInputOutputFilterBeginIterator()) {
                    try {
                        filter.waitUntilInputOutputClosed()
                    } catch (e: Exception) {
                        C2sConnection.LOGGER.log(LogLevel.WARN, "waitUntilInputOutputClosed() threw", e)
                    }
                }
                c2sconn.authenticated = false
            }
        }
        return StateTransitionResultSuccess.EMPTY_INSTANCE
    }

    // public override func getClass(): ClassId {
    //     "ShutdownState"
    // }
}

class InstantShutdownStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "InstantShutdownState",
                {
                    args => InstantShutdownState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            )
        )
        addSuccessor(CloseConnectionStateDescriptor())
    }

    public override func getClass(): ClassId {
        "InstantShutdownStateDescriptor"
    }
}

class InstantShutdownState <: NoOpState {
    init(connection: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(connection, stateDescriptor, connectionInternal)
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        ensureNotOnOurWayToAuthenticatedAndResourceBound(walkStateGraphContext)
        return None
    }

    // public override func getClass(): ClassId {
    //     "InstantShutdownState"
    // }
}

class CloseConnectionStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "CloseConnectionState",
                {
                    args => CloseConnectionState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            )
        )
        addSuccessor(DisconnectedStateDescriptor())
    }

    public override func getClass(): ClassId {
        "CloseConnectionStateDescriptor"
    }
}

class CloseConnectionState <: State {
    let c2sconn: C2sConnection

    init(c2sconn: C2sConnection, stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.c2sconn = c2sconn
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        c2sconn.activeTransport?.disconnect()
        c2sconn.activeTransport = None
        c2sconn.connected = false
        c2sconn.authenticated = false
        return StateTransitionResultSuccess.EMPTY_INSTANCE
    }

    // public override func getClass(): ClassId {
    //     "CloseConnectionState"
    // }
}

public class Stats <: AbstractStats {
    public let transportsStats: Map<ClassId, C2sTransportStats>

    public let filtersStats: Map<String, Object>

    init(transportsStats: Map<ClassId, C2sTransportStats>, filtersStats: Map<String, Object>) {
        super()
        this.transportsStats = Collections.unmodifiableMap(transportsStats)
        this.filtersStats = Collections.unmodifiableMap(filtersStats)
    }

    public override func appendStatsTo(appendable: StringBuilder): Unit {
        StringUtils.appendHeading(appendable, "Connection stats", r'#').append(r'\n')
        for ((transportClass, stats) in transportsStats) {
            StringUtils.appendHeading(appendable, transportClass)
            appendable.append(anyToString(stats))
            appendable.append(r'\n')
        }
        for ((filterName, filterStats) in filtersStats) {
            StringUtils.appendHeading(appendable, filterName)
            appendable.append(anyToString(filterStats))
            appendable.append(r'\n')
        }
    }
}
