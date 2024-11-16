/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

/**
 * Creates a socket connection to an XMPP server. This is the default connection
 * to an XMPP server and is specified in the XMPP Core (RFC 6120).
 *
 * @see XMPPConnection
 */
public class XMPPTCPConnection <: AbstractXMPPConnection {
    static let QUEUE_SIZE = 500
    static let LOGGER = getGlobalLogger(("name", "XMPPTCPConnection"))

    /**
     * The socket which is used for this connection.
     */
    private var socket: ?StreamingSocket = None

    private var disconnectedButResumeable = false

    private var secureSocket: ?TlsSocket = None

    /**
     * Protected access level because of unit test purposes
     */
    protected prop packetWriter: XMPPTCPConnectionPacketWriter {
        get() {
            _packetWriter ?? {
                =>
                let writer = XMPPTCPConnectionPacketWriter(this)
                _packetWriter = writer
                writer
            }()
        }
    }
    private var _packetWriter: ?XMPPTCPConnectionPacketWriter = None

    /**
     * Protected access level because of unit test purposes
     */
    protected prop packetReader: XMPPTCPConnectionPacketReader {
        get() {
            _packetReader ?? {
                =>
                let reader = XMPPTCPConnectionPacketReader(this)
                _packetReader = reader
                reader
            }()
        }
    }
    private var _packetReader: ?XMPPTCPConnectionPacketReader = None

    private var streamFeaturesAfterAuthenticationReceived: Bool = false

    var compressSyncPoint: Bool = false

    private static var defaultBundleAndDeferCallback: ?BundleAndDeferCallback = None

    var bundleAndDeferCallback: ?BundleAndDeferCallback = defaultBundleAndDeferCallback

    private static var useSmDefault = true

    private static var useSmResumptionDefault = true

    /**
     * The stream ID of the stream that is currently resumable, ie. the stream we hold the state
     * for in {@link #clientHandledStanzasCount}, {@link #serverHandledStanzasCount} and
     * {@link #unFailedNonzaExceptionacknowledgedStanzas}.
     */
    var smSessionId: ?String = None

    /**
     * Represents the state of stream management resumption.
     * <p>
     * Unlike other sync points, this sync point is marked volatile because it is also read by the reader thread.
     * </p>
     */
    var smResumedSyncPoint: ?SyncPointState = None
    var smResumptionFailed: ?StreamManagementFailed = None

    /**
     * Represents the state of stream magement.
     * <p>
     * This boolean is marked volatile as it is read by various threads, including the reader thread via {@link #isSmEnabled()}.
     * </p>
     */
    var smEnabledSyncPoint: Bool = false

    /**
     * The client's preferred maximum resumption time in seconds.
     */
    private var smClientMaxResumptionTime = Duration.second * -1

    /**
     * The server's preferred maximum resumption time in seconds.
     */
    var smServerMaxResumptionTime = Duration.second * -1

    /**
     * Indicates whether Stream Management (XEP-198) should be used if it's supported by the server.
     */
    private var useSm = useSmDefault
    private var useSmResumption = useSmResumptionDefault

    /**
     * The counter that the server sends the client about it's current height. For example, if the server sends
     * {@code <a h='42'/>}, then this will be set to 42 (while also handling the {@link #unacknowledgedStanzas} queue).
     */
    private var serverHandledStanzasCount = 0

    /**
     * The counter for stanzas handled ("received") by the client.
     * <p>
     * Note that we don't need to synchronize this counter. Although JLS 17.7 states that reads and writes to longs are
     * not atomic, it guarantees that there are at most 2 separate writes, one to each 32-bit half. And since
     * {@link SMUtils#incrementHeight(long)} masks the lower 32 bit, we only operate on one half of the long and
     * therefore have no concurrency problem because the read/write operations on one half are guaranteed to be atomic.
     * </p>
     */
    var clientHandledStanzasCount = 0

    var unacknowledgedStanzas: ?ArrayBlockingQueue<Stanza> = None

    /**
     * Set to true if Stream Management was at least once enabled for this connection.
     */
    var smWasEnabledAtLeastOnce = false

    /**
     * This listeners are invoked for every stanza that got acknowledged.
     * <p>
     * We use a {@link ConcurrentLinkedQueue} here in order to allow the listeners to remove
     * themselves after they have been invoked.
     * </p>
     */
    let stanzaAcknowledgedListeners: ConcurrentLinkedQueue<StanzaListener> = ConcurrentLinkedQueue()

    /**
     * These listeners are invoked for every stanza that got dropped.
     * <p>
     * We use a {@link ConcurrentLinkedQueue} here in order to allow the listeners to remove
     * themselves after they have been invoked.
     * </p>
     */
    private let stanzaDroppedListeners: ConcurrentLinkedQueue<StanzaListener> = ConcurrentLinkedQueue()

    /**
     * This listeners are invoked for a acknowledged stanza that has the given stanza ID. They will
     * only be invoked once and automatically removed after that.
     */
    let stanzaIdAcknowledgedListeners: ConcurrentHashMap<String, StanzaListener> = ConcurrentHashMap()

    /**
     * Predicates that determine if an stream management ack should be requested from the server.
     * <p>
     * We use a linked hash set here, so that the order how the predicates are added matches the
     * order in which they are invoked in order to determine if an ack request should be send or not.
     * </p>
     * 根据上下文 忽略顺序
     * 此处实际需要线程安全的Set
     */
    private let requestAckPredicates: ConcurrentSet<StanzaFilter> = ConcurrentSet()

    private let tcpConfig: XMPPTCPConnectionConfiguration

    /**
     * Creates a new XMPP connection over TCP (optionally using proxies).
     * <p>
     * Note that XMPPTCPConnection constructors do not establish a connection to the server
     * and you must call {@link #connect()}.
     * </p>
     *
     * @param tcpConfig the connection configuration.
     */
    public init(tcpConfig: XMPPTCPConnectionConfiguration) {
        super(tcpConfig)
        this.tcpConfig = tcpConfig
        postInit()
        addConnectionListener(
            ConnectionListenerBuilder()
            .connectionClosedOnError {
                e => if (e is StreamErrorException || e is StreamManagementException) {
                    dropSmState()
                }
            }
            .build())
        // Re-init the reader and writer in case of SASL <success/>.
        // This is done to reset the parser since a new stream is initiated.
        buildNonzaCallback().listenFor("SaslNonzaSuccess", {s => resetParser()}).install()
    }

    /**
     * Creates a new XMPP connection over TCP.
     * <p>
     * Note that {@code jid} must be the bare JID, e.g. "user@example.org". More fine-grained control over the
     * connection settings is available using the {@link #XMPPTCPConnection(XMPPTCPConnectionConfiguration)}
     * constructor.
     * </p>
     *
     * @param jid the bare JID used by the client.
     * @param password the password or authentication token.
     * @throws XmppStringprepException if the provided string is invalid.
     */
    public init(jid: String, password: String) {
        this(
            {
            =>
            let builder = XMPPTCPConnectionConfiguration.builder()
            builder.setXmppAddressAndPassword(jid, password)
            return builder.build()
        }())
    }

    /**
     * Creates a new XMPP connection over TCP.
     * <p>
     * This is the simplest constructor for connecting to an XMPP server. Alternatively,
     * you can get fine-grained control over connection settings using the
     * {@link #XMPPTCPConnection(XMPPTCPConnectionConfiguration)} constructor.
     * </p>
     * @param username TODO javadoc me please
     * @param password TODO javadoc me please
     * @param serviceName TODO javadoc me please
     * @throws XmppStringprepException if the provided string is invalid.
     */
    public init(username: String, password: String, serviceName: String) {
        this(
            {
            =>
            let builder = XMPPTCPConnectionConfiguration.builder()
            builder.setUsernameAndPassword(username, password).setXmppDomain(JidCreate.domainBareFrom(serviceName))
            return builder.build()
        }())
    }

    protected override func throwNotConnectedExceptionIfAppropriate(): Unit {
        packetWriter.throwNotConnectedExceptionIfDoneAndResumptionNotPossible()
    }

    protected override func throwAlreadyConnectedExceptionIfAppropriate(): Unit {
        if (isConnected() && !disconnectedButResumeable) {
            throw AlreadyConnectedException()
        }
    }

    protected override func throwAlreadyLoggedInExceptionIfAppropriate(): Unit {
        if (isAuthenticated() && !disconnectedButResumeable) {
            throw AlreadyLoggedInException()
        }
    }

    public override func afterSuccessfulLogin(resumed: Bool): Unit {
        // Reset the flag in case it was set
        disconnectedButResumeable = false
        super.afterSuccessfulLogin(resumed)
    }

    protected override func loginInternal(username: ?String, password: ?String, resource: ?Resourcepart): Unit {
        synchronized(lock) {
            // Authenticate using SASL
            let sslSession: ?TlsSession = (secureSocket?.session).flatten()

            streamFeaturesAfterAuthenticationReceived = false
            authenticate(username(), password(), tcpConfig.getAuthzid(), sslSession)

            waitForConditionOrThrowConnectionException({=> streamFeaturesAfterAuthenticationReceived},
                "compress features from server")

            maybeEnableCompression()

            smResumedSyncPoint = SyncPointState.initial
            smResumptionFailed = None
            if (isSmResumptionPossible()) {
                smResumedSyncPoint = SyncPointState.request_sent
                sendNonza(StreamManagementResume(clientHandledStanzasCount, smSessionId()))
                waitForConditionOrThrowConnectionException(
                    {=> smResumedSyncPoint == SyncPointState.successful || smResumptionFailed.isSome()},
                    "resume previous stream"
                )
                if (smResumedSyncPoint == SyncPointState.successful) {
                    afterSuccessfulLogin(true)
                    return
                }
                assert(smResumptionFailed.isSome())
                LOGGER.trace(
                    "Stream resumption failed, continuing with normal stream establishment process: ${anyToString(smResumptionFailed)}"
                )
            }

            smEnabledSyncPoint = false

            let previouslyUnackedStanzas = LinkedList<Stanza>()
            if (let Some(unacknowledgedStanzas) <- unacknowledgedStanzas) {
                unacknowledgedStanzas.drainTo(previouslyUnackedStanzas)
                dropSmState()
            }

            bindResourceAndEstablishSession(resource)

            if (isSmAvailable() && useSm) {
                serverHandledStanzasCount = 0
                sendNonza(StreamManagementEnable(useSmResumption, smClientMaxResumptionTime))
                waitForConditionOrThrowConnectionException({=> smEnabledSyncPoint}, "enabling stream mangement")
                synchronized(requestAckPredicates.lock) {
                    if (requestAckPredicates.isEmpty()) {
                        requestAckPredicates.put(StreamPredicate.forMessagesOrAfter5Stanzas())
                    }
                }
            }

            if (!stanzaDroppedListeners.isEmpty()) {
                for (stanza in previouslyUnackedStanzas) {
                    for (listener in stanzaDroppedListeners) {
                        try {
                            listener.processStanza(stanza)
                        } catch (e: NotConnectedException | NotLoggedInException) {
                            LOGGER.log(LogLevel.TRACE, "StanzaDroppedListener received exception", e)
                        }
                    }
                }
            } else {
                for (stanza in previouslyUnackedStanzas) {
                    sendStanzaInternal(stanza)
                }
            }
            afterSuccessfulLogin(false)
        }
    }

    public override func isSecureConnection(): Bool {
        return secureSocket.isSome()
    }

    /**
     * Shuts the current connection down. After this method returns, the connection must be ready
     * for re-use by connect.
     */
    protected override func shutdown(): Unit {
        if (isSmEnabled()) {
            try {
                sendSmAcknowledgementInternal()
            } catch (e: Exception) {
                LOGGER.log(LogLevel.TRACE, "Can not send final SM ack as connection is not connected", e)
            }
        }
        shutdown(false)
    }

    public override func instantShutdown(): Unit {
        synchronized(lock) {
            shutdown(true)
        }
    }

    private func shutdown(instant: Bool): Unit {
        if (!packetWriter.done()) {
            LOGGER.trace("${packetWriter.threadName} shutdown()")
            packetWriter.shutdown(instant)
            LOGGER.trace("${packetWriter.threadName} shutdown() returned")
            if (!instant) {
                waitForClosingStreamTagFromServer()
            }
        }

        LOGGER.trace("${packetReader.threadName} shutdown()")
        packetReader.shutdown()
        LOGGER.trace("${packetReader.threadName} shutdown() returned")
        CloseableUtil.maybeClose(socket, LOGGER)
        setWasAuthenticated()

        try {
            let readerAndWriterThreadsTermianted = waitFor({=> !packetWriter.running && !packetReader.running})
            if (!readerAndWriterThreadsTermianted) {
                LOGGER.error(
                    "Reader and/or writer threads did not terminate timely. Writer running: ${packetWriter.running}, Reader running: ${packetReader.running}"
                )
            } else {
                LOGGER.trace("Reader and writer threads terminated")
            }
        } catch (e: Exception) {
            LOGGER.log(LogLevel.TRACE, "Interrupted while waiting for reader and writer threads to terminate", e)
        }

        if (disconnectedButResumeable) {
            return
        }

        if (instant) {
            disconnectedButResumeable = isSmResumptionPossible()
            if (!disconnectedButResumeable) {
                smSessionId = None
            }
        } else {
            disconnectedButResumeable = false
            dropSmState()
        }
        authenticated = false
        connected = false
        secureSocket = None
        reader = None
        writer = None

        initState()
    }

    public override func sendNonza(element: Nonza): Unit {
        packetWriter.sendStreamElement(element)
    }

    protected override func sendStanzaInternal(packet: Stanza): Unit {
        packetWriter.sendStreamElement(packet)
        if (isSmEnabled()) {
            for (requestAckPredicate in requestAckPredicates) {
                if (requestAckPredicate.accept(packet)) {
                    requestSmAcknowledgementInternal()
                    break
                }
            }
        }
    }

    private func connectUsingConfiguration(): Unit {
        let result = RemoteXmppTcpConnectionEndpoints.lookup(tcpConfig)
        let connectionExceptions = ArrayList<RemoteConnectionException<RemoteConnectionEndpoint>>()
        let socketFactory: SocketFactory = tcpConfig.getSocketFactory() ?? SocketFactory.DEFAULT
        let proxyInfo = tcpConfig.getProxyInfo()
        let timeout = tcpConfig.getConnectTimeout()
        for (endpoint in result.discoveredRemoteConnectionEndpoints) {
            let host: String = endpoint.getHost()
            let portUint16 = endpoint.getPort()
            let port = portUint16
            if (proxyInfo.isNone()) {
                let addrs = endpoint.getInetAddresses()
                let inetAddresses = addrs.iterator()
                assert(addrs.size > 0)

                while (let Some(inetAddress) <- inetAddresses.next()) {
                    let socketFuture = SocketFuture(socketFactory, inetAddress)
                    let inetSocketAddress: IPSocketAddress = inetAddress
                    LOGGER.trace("Trying to establish TCP connection to ${inetSocketAddress}")
                    socketFuture.connectAsync(inetSocketAddress, timeout)
                    try {
                        socket = socketFuture.getOrThrow()
                    } catch (e: IOException) {
                        let rce = RemoteConnectionException<RemoteConnectionEndpoint>(
                            endpoint,
                            inetAddress,
                            e
                        )
                        connectionExceptions.append(rce)
                        continue
                    }
                    LOGGER.trace("Established TCP connection to ${inetSocketAddress}")
                    this.host = host
                    this.port = portUint16
                    return
                }
            } else {
                StringUtils.requireNotNullNorEmpty(host,
                    "Host of endpoint ${anyToString(endpoint)} must not be null when using a Proxy")
                let hostAndPort: String = "${host} at port ${port}"
                LOGGER.trace("Trying to establish TCP connection via Proxy to ${hostAndPort}")
                try {
                    socket = socketFactory.createSocket(host, port)
                    socket = proxyInfo?.getProxySocketConnection().connect(socket(), host, port, timeout)
                } catch (e: IOException) {
                    CloseableUtil.maybeClose(socket, LOGGER)
                    let rce = RemoteConnectionException<RemoteConnectionEndpoint>(endpoint, None, e)
                    connectionExceptions.append(rce)
                    continue
                }
                LOGGER.trace("Established TCP connection to ${hostAndPort}")
                this.host = host
                this.port = portUint16
                return
            }
        }
        throw EndpointConnectionException.comefrom(result.lookupFailures, connectionExceptions)
    }

    /**
     * Initializes the connection by creating a stanza reader and writer and opening a
     * XMPP stream to the server.
     *
     * @throws XMPPException if establishing a connection to the server fails.
     * @throws Xmpp4cjException if the server fails to respond back or if there is anther error.
     */
    private func initConnection(): Unit {
        compressionHandler = None
        // Set the reader and writer instance variables
        initReaderAndWriter()
        // Start the writer thread. This will open an XMPP stream to the server
        packetWriter.initself()
        // Start the reader thread. The startup() method will block until we
        // get an opening stream packet back from server
        packetReader.initself()
    }

    func initReaderAndWriter(): Unit {
        var input: InputStream = socket.getOrThrow()
        var output: OutputStream = socket.getOrThrow()
        if (let Some(compressionHandler) <- compressionHandler) {
            input = compressionHandler.getInputStream(input)
            output = compressionHandler.getOutputStream(output)
        }
        writer = ObservableWriter(output)
        let bufferedInput = ObservableReader(input)
        reader = bufferedInput
        initDebugger()
    }

    /**
     * The server has indicated that TLS negotiation can start. We now need to secure the
     * existing plain connection and perform a handshake. This method won't return until the
     * connection has finished the handshake or an error occurred while securing the connection.
     * @throws IOException if an I/O error occurred.
     * @throws SecurityNotPossibleException if TLS is not possible.
     * @throws CertificateException if there is an issue with the certificate.
     */
    func proceedTLSReceived(): Unit {
        let xmppTlsContext = getXmppTlsContext()

        let plain = match (socket) {
            case Some(s: TcpSocket) => s
            case _ => throw IllegalStateException("socket is not TcpSocket")
        }
        // let port = plain.remoteAddress
        // let xmppServiceDomainString: String = tcpConfig.getXMPPServiceDomain().toString()
        let sslSocketFactory = xmppTlsContext.tlsSocketFactory
        // Secure the plain connection
        let sslSocket: TlsSocket = sslSocketFactory(plain, None, None)
        socket = sslSocket

        // Initialize the reader and writer with the new secured version
        initReaderAndWriter()

        // Proceed to do the handshake
        sslSocket.handshake()

        xmppTlsContext.daneVerifier?.finish(sslSocket.session)

        let verifierHostname: String
        let xmppServiceDomainDnsName = getConfiguration().getXmppServiceDomainAsDnsNameIfPossible()
        // Try to convert the XMPP service domain, which potentially includes Unicode characters, into ASCII
        // Compatible Encoding (ACE) to match RFC3280 dNSname IA5String constraint.
        if (let Some(xmppServiceDomainDnsName) <- xmppServiceDomainDnsName) {
            verifierHostname = xmppServiceDomainDnsName.toString() // TODO xmppServiceDomainDnsName.ace
        } else {
            LOGGER.log(
                LogLevel.WARN,
                "XMPP service domain name '${getXMPPServiceDomain()}' can not be represented as DNS name. TLS X.509 certificate validiation may fail."
            )
            verifierHostname = getXMPPServiceDomain().toString()
        }

        // Set that TLS was successful
        secureSocket = sslSocket
    }

    /**
     * Returns the compression handler that can be used for one compression methods offered by the server.
     *
     * @return a instance of XMPPInputOutputStream or null if no suitable instance was found
     */
    private static func maybeGetCompressionHandler(compression: CompressFeature): ?XMPPInputOutputStream {
        for (handler in XmppConfiguration.getCompressionHandlers()) {
            let method = handler.getCompressionMethod()
            if (compression.getMethods() |> contains(method)) {
                return handler
            }
        }
        return None
    }

    public override func isUsingCompression(): Bool {
        return compressionHandler.isSome() && compressSyncPoint
    }

    /**
     * <p>
     * Starts using stream compression that will compress network traffic. Traffic can be
     * reduced up to 90%. Therefore, stream compression is ideal when using a slow speed network
     * connection. However, the server and the client will need to use more CPU time in order to
     * un/compress network data so under high load the server performance might be affected.
     * </p>
     * <p>
     * Stream compression has to have been previously offered by the server. Currently only the
     * zlib method is supported by the client. Stream compression negotiation has to be done
     * before authentication took place.
     * </p>
     *
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @throws Xmpp4cjException if Xmpp detected an exceptional situation.
     * @throws XMPPException if an XMPP protocol error was received.
     */
    private func maybeEnableCompression(): Unit {
        if (!tcpConfig.isCompressionEnabled()) {
            return
        }

        let compression = match (getFeature("CompressFeature")) {
            case Some(v: CompressFeature) => v
            case _ => return
        }

        if (let Some(compressionHandler) <- maybeGetCompressionHandler(compression)) {
            this.compressionHandler = compressionHandler
            compressSyncPoint = false
            sendNonza(Compress(compressionHandler.getCompressionMethod()))
            waitForConditionOrThrowConnectionException({=> compressSyncPoint}, "establishing stream compression")
        } else {
            LOGGER.warn("Could not enable compression because no matching handler/method pair was found")
        }
    }

    /**
     * Establishes a connection to the XMPP server. It basically
     * creates and maintains a socket connection to the server.
     * <p>
     * Listeners will be preserved from a previous connection if the reconnection
     * occurs after an abrupt termination.
     * </p>
     *
     * @throws XMPPException if an error occurs while trying to establish the connection.
     * @throws Xmpp4cjException if Xmpp detected an exceptional situation.
     */
    protected override func connectInternal(): Unit {
        // Establishes the TCP connection to the server and does setup the reader and writer.
        // Throws an exception if there is an error establishing the connection
        connectUsingConfiguration()
        connected = true
        // We connected successfully to the servers TCP port
        initConnection()
        // TLS handled will be true either if TLS was established, or if it was not mandatory.
        waitForConditionOrThrowConnectionException({=> tlsHandled}, "establishing TLS")
        // Wait with SASL auth until the SASL mechanisms have been received
        waitForConditionOrThrowConnectionException({=> saslFeatureReceived},
            "SASL mechanisms stream feature from server")
    }

    /**
     * For unit testing purposes
     *
     * @param writer
     */
    protected func setWriter(writer: ObservableWriter): Unit {
        this.writer = writer
    }

    protected override func afterFeaturesReceived(): Unit {
        match (getFeature("StartTls")) {
            case Some(startTlsFeature: StartTls) =>
                if (startTlsFeature.requiredMethod() && tcpConfig.getSecurityMode() == ConnectionConfigurationSecurityMode
                    .disabled) {
                    let xmppException = SecurityRequiredByServerException()
                    currentXmpp4cjException = xmppException
                    notifyWaitingThreads()
                    throw xmppException
                }
                if (tcpConfig.getSecurityMode() != ConnectionConfigurationSecurityMode.disabled) {
                    sendNonza(StartTls())
                } else {
                    tlsHandled = true
                    notifyWaitingThreads()
                }
            case _ =>
                tlsHandled = true
                notifyWaitingThreads()
        }
        if (isSaslAuthenticated()) {
            streamFeaturesAfterAuthenticationReceived = true
            notifyWaitingThreads()
        }
    }

    private func resetParser(): Unit {
        try {
            packetReader.parser = XmppXmlParser.newXmlParser(reader())
        } catch (e: XmlPullParserException) {
            throw IOException(e.message)
        }
    }

    func openStreamAndResetParser(): Unit {
        sendStreamOpen()
        resetParser()
    }

    /**
     * Set if Stream Management should be used by default for new connections.
     *
     * @param useSmDefault true to use Stream Management for new connections.
     */
    public static func setUseStreamManagementDefault(useSmDefault: Bool): Unit {
        XMPPTCPConnection.useSmDefault = useSmDefault
    }

    /**
     * Set if Stream Management resumption should be used by default for new connections.
     *
     * @param useSmResumptionDefault true to use Stream Management resumption for new connections.
     */
    public static func setUseStreamManagementResumptionDefault(useSmResumptionDefault: Bool): Unit {
        if (useSmResumptionDefault) {
            setUseStreamManagementDefault(useSmResumptionDefault)
        }
        XMPPTCPConnection.useSmResumptionDefault = useSmResumptionDefault
    }

    /**
     * Set if Stream Management should be used if supported by the server.
     *
     * @param useSm true to use Stream Management.
     */
    public func setUseStreamManagement(useSm: Bool): Unit {
        this.useSm = useSm
    }

    /**
     * Set if Stream Management resumption should be used if supported by the server.
     *
     * @param useSmResumption true to use Stream Management resumption.
     */
    public func setUseStreamManagementResumption(useSmResumption: Bool): Unit {
        if (useSmResumption) {
            setUseStreamManagement(useSmResumption)
        }
        this.useSmResumption = useSmResumption
    }

    /**
     * Set the preferred resumption time in seconds.
     * @param resumptionTime the preferred resumption time in seconds
     */
    public func setPreferredResumptionTime(resumptionTime: Duration): Unit {
        smClientMaxResumptionTime = resumptionTime
    }

    /**
     * Add a predicate for Stream Management acknowledgment requests.
     * <p>
     * Those predicates are used to determine when a Stream Management acknowledgement request is send to the server.
     * Some pre-defined predicates are found in the <code>xmpp4cj.sm.predicates</code> package.
     * </p>
     * <p>
     * If not predicate is configured, the {@link Predicate#forMessagesOrAfter5Stanzas()} will be used.
     * </p>
     *
     * @param predicate the predicate to add.
     * @return if the predicate was not already active.
     */
    public func addRequestAckPredicate(predicate: StanzaFilter): Bool {
        return requestAckPredicates.put(predicate)
    }

    /**
     * Remove the given predicate for Stream Management acknowledgment request.
     * @param predicate the predicate to remove.
     * @return true if the predicate was removed.
     */
    public func removeRequestAckPredicate(predicate: StanzaFilter): Bool {
        return requestAckPredicates.remove(predicate)
    }

    /**
     * Remove all predicates for Stream Management acknowledgment requests.
     */
    public func removeAllRequestAckPredicates(): Unit {
        requestAckPredicates.clear()
    }

    /**
     * Send an unconditional Stream Management acknowledgement request to the server.
     *
     * @throws StreamManagementNotEnabledException if Stream Management is not enabled.
     * @throws NotConnectedException if the connection is not connected.
     */
    public func requestSmAcknowledgement(): Unit {
        if (!isSmEnabled()) {
            throw StreamManagementNotEnabledException()
        }
        requestSmAcknowledgementInternal()
    }

    func requestSmAcknowledgementInternal(): Unit {
        packetWriter.sendStreamElement(StreamManagementAckRequest.INSTANCE)
    }

    /**
     * Send a unconditional Stream Management acknowledgment to the server.
     * <p>
     * See <a href="xmpp/org/extensions/xep-0198.html#acking">XEP-198: Stream Management § 4. Acks</a>:
     * "Either party MAY send an &lt;a/&gt; element at any time (e.g., after it has received a certain number of stanzas,
     * or after a certain period of time), even if it has not received an &lt;r/&gt; element from the other party."
     * </p>
     *
     * @throws StreamManagementNotEnabledException if Stream Management is not enabled.
     * @throws NotConnectedException if the connection is not connected.
     */
    public func sendSmAcknowledgement(): Unit {
        if (!isSmEnabled()) {
            throw StreamManagementNotEnabledException()
        }
        sendSmAcknowledgementInternal()
    }

    func sendSmAcknowledgementInternal(): Unit {
        let ackAnswer = StreamManagementAckAnswer(clientHandledStanzasCount)
        // Do net put an ack to the queue if it has already been shutdown.
        // Some servers, like ejabberd, like to request an ack even after
        // we have send a stream close (and hance the queue was shutdown).
        // If we would not check here, then the ack would dangle around in the queue,
        // and be send on the next re-connection attempt even before the stream open.
        packetWriter.queue.putIfNotShutdown(ackAnswer)
    }

    /**
     * Add a Stanza acknowledged listener.
     * <p>
     * Those listeners will be invoked every time a Stanza has been acknowledged by the server. The will not get
     * automatically removed. Consider using {@link #addStanzaIdAcknowledgedListener(String, StanzaListener)} when
     * possible.
     * </p>
     *
     * @param listener the listener to add.
     */
    public func addStanzaAcknowledgedListener(listener: StanzaListener): Unit {
        stanzaAcknowledgedListeners.append(listener)
    }

    /**
     * Remove the given Stanza acknowledged listener.
     *
     * @param listener the listener.
     * @return true if the listener was removed.
     */
    public func removeStanzaAcknowledgedListener(listener: StanzaListener): Bool {
        return stanzaAcknowledgedListeners.remove(listener)
    }

    /**
     * Remove all stanza acknowledged listeners.
     */
    public func removeAllStanzaAcknowledgedListeners(): Unit {
        stanzaAcknowledgedListeners.clear()
    }

    /**
     * Add a Stanza dropped listener.
     * <p>
     * Those listeners will be invoked every time a Stanza has been dropped due to a failed SM resume. They will not get
     * automatically removed. If at least one StanzaDroppedListener is configured, no attempt will be made to retransmit
     * the Stanzas.
     * </p>
     *
     * @param listener the listener to add.
     */
    public func addStanzaDroppedListener(listener: StanzaListener): Unit {
        stanzaDroppedListeners.append(listener)
    }

    /**
     * Remove the given Stanza dropped listener.
     *
     * @param listener the listener.
     * @return true if the listener was removed.
     */
    public func removeStanzaDroppedListener(listener: StanzaListener): Bool {
        return stanzaDroppedListeners.remove(listener)
    }

    /**
     * Add a new Stanza ID acknowledged listener for the given ID.
     * <p>
     * The listener will be invoked if the stanza with the given ID was acknowledged by the server. It will
     * automatically be removed after the listener was run.
     * </p>
     *
     * @param id the stanza ID.
     * @param listener the listener to invoke.
     * @return the previous listener for this stanza ID or null.
     * @throws StreamManagementNotEnabledException if Stream Management is not enabled.
     */
    public func addStanzaIdAcknowledgedListener(id: String, listener: StanzaListener): ?StanzaListener {
        if (!smWasEnabledAtLeastOnce) {
            throw StreamManagementNotEnabledException()
        }
        let sec = getMaxSmResumptionTime()
        let secmin = Duration.second * 3 * 60 * 60
        let removeAfterSeconds = if (sec < secmin) {
            sec
        } else {
            secmin
        }
        schedule({=> stanzaIdAcknowledgedListeners.remove(id)}, removeAfterSeconds)
        return stanzaIdAcknowledgedListeners.put(id, listener)
    }

    /**
     * Remove the Stanza ID acknowledged listener for the given ID.
     *
     * @param id the stanza ID.
     * @return true if the listener was found and removed, false otherwise.
     */
    public func removeStanzaIdAcknowledgedListener(id: String): ?StanzaListener {
        return stanzaIdAcknowledgedListeners.remove(id)
    }

    /**
     * Removes all Stanza ID acknowledged listeners.
     */
    public func removeAllStanzaIdAcknowledgedListeners(): Unit {
        let keys = stanzaIdAcknowledgedListeners |> map {kv => kv[0]} |> collectArray
        for (k in keys) {
            stanzaIdAcknowledgedListeners.remove(k)
        }
    }

    /**
     * Returns true if Stream Management is supported by the server.
     *
     * @return true if Stream Management is supported by the server.
     */
    public func isSmAvailable(): Bool {
        return hasFeature(StreamManagementFeature.ELEMENT, StreamManagement.NAMESPACE)
    }

    /**
     * Returns true if Stream Management was successfully negotiated with the server.
     *
     * @return true if Stream Management was negotiated.
     */
    public func isSmEnabled(): Bool {
        return smEnabledSyncPoint
    }

    /**
     * Returns true if the stream was successfully resumed with help of Stream Management.
     *
     * @return true if the stream was resumed.
     */
    public func streamWasResumed(): Bool {
        return match (smResumedSyncPoint) {
            case Some(SyncPointState.successful) => true
            case _ => false
        }
    }

    /**
     * Returns true if the connection is disconnected by a Stream resumption via Stream Management is possible.
     *
     * @return true if disconnected but resumption possible.
     */
    public func isDisconnectedButSmResumptionPossible(): Bool {
        return disconnectedButResumeable && isSmResumptionPossible()
    }

    /**
     * Returns true if the stream is resumable.
     *
     * @return true if the stream is resumable.
     */
    public func isSmResumptionPossible(): Bool {
        // There is no resumable stream available
        if (smSessionId.isNone()) {
            return false
        }

        // Seems like we are already reconnected, report true
        let shutdownTimestamp = packetWriter.shutdownTimestamp ?? return true

        let current = DateTime.now().toUnixTimeStamp()
        let maxResumptionMillies = getMaxSmResumptionTime() * 1000
        if (current > shutdownTimestamp + maxResumptionMillies) {
            // Stream resumption is *not* possible if the current timestamp is 
            // greater than the greatest timestamp where resumption is possible
            return false
        } else {
            return true
        }
    }

    /**
     * Drop the stream management state. Sets {@link #smSessionId} and
     * {@link #unacknowledgedStanzas} to <code>null</code>.
     */
    func dropSmState(): Unit {
        // clientHandledCount and serverHandledCount will be reset on <enable/> and <enabled/> respective.
        // No need to reset them here.
        smSessionId = None
        unacknowledgedStanzas = None
    }

    /**
     * Get the maximum resumption time in seconds after which a managed stream can be resumed.
     * <p>
     * This method will return {@link Integer#MAX_VALUE} if neither the client nor the server specify a maximum
     * resumption time. Be aware of integer overflows when using this value, e.g. do not add arbitrary values to it
     * without checking for overflows before.
     * </p>
     *
     * @return the maximum resumption time in seconds or {@link Integer#MAX_VALUE} if none set.
     */
    public func getMaxSmResumptionTime(): Duration {
        let clientResumptionTime = if (smClientMaxResumptionTime > Duration.Zero) {
            smClientMaxResumptionTime
        } else {
            Duration.second * Int64.Max
        }
        let serverResumptionTime = if (smServerMaxResumptionTime > Duration.Zero) {
            smServerMaxResumptionTime
        } else {
            Duration.second * Int64.Max
        }
        return min(clientResumptionTime, serverResumptionTime)
    }

    func processHandledCount(handledCount: Int64): Unit {
        let ackedStanzasCount = SMUtils.calculateDelta(handledCount, serverHandledStanzasCount)
        let ackedStanzas = ArrayList<Stanza>(
            if (ackedStanzasCount <= Int64(Int.Max)) {
            ackedStanzasCount
        } else {
            Int64(Int.Max)
        })
        var i = 0
        while (i < ackedStanzasCount) {
            let ackedStanza = (unacknowledgedStanzas?.tryDequeue()).flatten() ?? throw StreamManagementCounterError(
                handledCount, serverHandledStanzasCount, ackedStanzasCount, ackedStanzas)
            ackedStanzas.append(ackedStanza)
            i++
        }
        var atLeastOneStanzaAcknowledgedListener = false
        if (!stanzaAcknowledgedListeners.isEmpty()) {
            atLeastOneStanzaAcknowledgedListener = true
        } else {
            for (ackedStanza in ackedStanzas) {
                let id = ackedStanza.getStanzaId()
                if (id.isSome() && stanzaIdAcknowledgedListeners.contains(id())) {
                    atLeastOneStanzaAcknowledgedListener = true
                    break
                }
            }
        }
        if (atLeastOneStanzaAcknowledgedListener) {
            asyncGo(
                {
                => for (ackedStanza in ackedStanzas) {
                    for (listener in stanzaAcknowledgedListeners) {
                        try {
                            listener.processStanza(ackedStanza)
                        } catch (e: NotConnectedException | NotLoggedInException) {
                            XMPPTCPConnection.LOGGER.log(LogLevel.TRACE, "Received exception", e)
                        }
                    }
                    let id = ackedStanza.getStanzaId()
                    if (StringUtils.isNullOrEmpty(id)) {
                        continue
                    }
                    let listener = stanzaIdAcknowledgedListeners.remove(id()) ?? continue
                    try {
                        listener.processStanza(ackedStanza)
                    } catch (e: NotConnectedException | NotLoggedInException) {
                        XMPPTCPConnection.LOGGER.log(LogLevel.TRACE, "Received exception", e)
                    }
                }
            })
        }
        serverHandledStanzasCount = handledCount
    }

    public static func setDefaultBundleAndDeferCallback(defaultBundleAndDeferCallback: BundleAndDeferCallback): Unit {
        XMPPTCPConnection.defaultBundleAndDeferCallback = defaultBundleAndDeferCallback
    }

    public func setBundleandDeferCallback(bundleAndDeferCallback: BundleAndDeferCallback): Unit {
        this.bundleAndDeferCallback = bundleAndDeferCallback
    }

    private let lock = Monitor()

    public override func getClass(): ClassId {
        "XMPPTCPConnection"
    }
}

public class XMPPTCPConnectionPacketReader {
    prop threadName: String {
        get() {
            "Xmpp Reader (${conn.getConnectionCounter()})"
        }
    }

    var parser: XmlPullParser = unsafe { zeroValue<XmlPullParser>() } // 占位 已确保初始化

    private var done: Bool = false

    var running: Bool = false

    let conn: XMPPTCPConnection
    init(xmppPTCPConnection: XMPPTCPConnection) {
        this.conn = xmppPTCPConnection
    }

    /**
     * Initializes the reader in order to be used. The reader is initialized during the
     * first connection and when reconnecting due to an abruptly disconnection.
     */
    func initself(): Unit {
        done = false
        running = true
        Async.go(
            {
                =>
                XMPPTCPConnection.LOGGER.trace("${threadName} start")
                try {
                    parsePackets()
                } finally {
                    XMPPTCPConnection.LOGGER.trace("${threadName} exit")
                    running = false
                    conn.notifyWaitingThreads()
                }
            },
            threadName
        )
    }

    /**
     * Shuts the stanza reader down. This method simply sets the 'done' flag to true.
     */
    func shutdown(): Unit {
        done = true
    }

    /**
     * Parse top-level packets in order to process them further.
     */
    func parsePackets(): Unit {
        try {
            conn.openStreamAndResetParser()
            var eventType = parser.getEventType()
            while (!done) {
                match (eventType) {
                    case XmlPullParserEvent.START_ELEMENT =>
                        let name = parser.getName()
                        match (name) {
                            case v where v == Message.ELEMENT || v == IQ.IQ_ELEMENT || v == Presence.ELEMENT => try {
                                conn.parseAndProcessStanza(parser)
                            } finally {
                                conn.clientHandledStanzasCount = SMUtils.incrementHeight(conn.clientHandledStanzasCount)
                            }
                            case "stream" => conn.onStreamOpen(parser)
                            case "error" =>
                                let streamError = PacketParserUtils.parseStreamError(parser)
                                throw StreamErrorException(streamError)
                            case "features" => conn.parseFeaturesAndNotify(parser)
                            case "proceed" =>
                                conn.proceedTLSReceived()
                                conn.openStreamAndResetParser()
                            case "failure" =>
                                let namespace = parser.getNamespace(None)
                                match (namespace) {
                                    case v where v == "urn:ietf:params:xml:ns:xmpp-tls" => throw XmppMessageException(
                                        "TLS negotiation has failed")
                                    case v where v == Compress.NAMESPACE =>
                                        conn.currentXmpp4cjException = XmppMessageException(
                                            "Could not establish compression")
                                        conn.notifyWaitingThreads()
                                    case _ => conn.parseAndProcessNonza(parser)
                                }
                            case v where v == Compressed.ELEMENT =>
                                conn.initReaderAndWriter()
                                conn.openStreamAndResetParser()
                                conn.compressSyncPoint = true
                                conn.notifyWaitingThreads()
                            case v where v == StreamManagementEnabled.ELEMENT =>
                                let enabled = ParseStreamManagement.enabled(parser)
                                if (enabled.isResumeSet()) {
                                    conn.smSessionId = enabled.getId()
                                    if (StringUtils.isNullOrEmpty(conn.smSessionId)) {
                                        let xmppException: Xmpp4cjException = XmppMessageException(
                                            "Stream Management 'enabled' element with resume attribute but without session id received"
                                        )
                                        conn.setCurrentConnectionExceptionAndNotify(xmppException)
                                        throw xmppException
                                    }
                                    conn.smServerMaxResumptionTime = enabled.getMaxResumptionTime()
                                } else {
                                    conn.smSessionId = None
                                }
                                conn.clientHandledStanzasCount = 0
                                conn.smWasEnabledAtLeastOnce = true
                                conn.smEnabledSyncPoint = true
                                conn.notifyWaitingThreads()
                            case v where v == StreamManagementFailed.ELEMENT =>
                                let failed = ParseStreamManagement.failed(parser)
                                if (conn.smResumedSyncPoint == SyncPointState.request_sent) {
                                    conn.smResumptionFailed = failed
                                    conn.notifyWaitingThreads()
                                } else {
                                    let xmppException = FailedNonzaException(failed, failed.getStanzaErrorCondition())
                                    conn.setCurrentConnectionExceptionAndNotify(xmppException)
                                }
                            case v where v == StreamManagementResumed.ELEMENT =>
                                let resumed = ParseStreamManagement.resumed(parser)
                                if (conn.smSessionId != resumed.getPrevId()) {
                                    throw StreamIdDoesNotMatchException(conn.smSessionId(), resumed.getPrevId())
                                }
                                conn.smEnabledSyncPoint = true
                                conn.processHandledCount(resumed.getHandledCount())
                                let stanzasToResend = ArrayList<Stanza>(conn.unacknowledgedStanzas().size)
                                conn.unacknowledgedStanzas?.drainTo(stanzasToResend)
                                for (stanza in stanzasToResend) {
                                    conn.sendStanzaInternal(stanza)
                                }
                                if (!stanzasToResend.isEmpty()) {
                                    conn.requestSmAcknowledgementInternal()
                                }
                                conn.smResumedSyncPoint = SyncPointState.successful
                                conn.notifyWaitingThreads()
                            case v where v == StreamManagementAckAnswer.ELEMENT =>
                                let ackAnswer = ParseStreamManagement.ackAnswer(parser)
                                conn.processHandledCount(ackAnswer.getHandledCount())
                            case v where v == StreamManagementAckRequest.ELEMENT =>
                                ParseStreamManagement.ackRequest(parser)
                                if (conn.smEnabledSyncPoint) {
                                    conn.sendSmAcknowledgementInternal()
                                } else {
                                    XMPPTCPConnection.LOGGER.warn("SM Ack Request received while SM is not enabled")
                                }
                            case _ => conn.parseAndProcessNonza(parser)
                        }
                    case XmlPullParserEvent.END_ELEMENT =>
                        let endTagName = parser.getName()
                        if ("stream" == endTagName) {
                            if (!(parser.getNamespace() == ETHERX_JABBER_STREAMS_NAMESPACE)) {
                                XMPPTCPConnection
                                    .LOGGER
                                    .warn("${conn} </stream> but different namespace ${parser.getNamespace()}")
                                break
                            }
                            let queueWasShutdown = conn.packetWriter.queue.isShutdown()
                            conn.closingStreamReceived = true
                            conn.notifyWaitingThreads()
                            if (queueWasShutdown) {
                                return
                            } else {
                                XMPPTCPConnection
                                    .LOGGER
                                    .info(
                                        "${conn} received closing </stream> element. Server wants to terminate the connection, calling disconnect()"
                                    )
                                AbstractXMPPConnection
                                    .ASYNC_BUT_ORDERED
                                    .performAsyncButOrdered(conn, {=> conn.disconnect()})
                            }
                        }
                    case XmlPullParserEvent.END_DOCUMENT => throw XmppMessageException(
                        "Parser got END_DOCUMENT event. This could happen e.g. if the server closed the connection without sending a closing stream element"
                    )
                    case _ => ()
                }
                eventType = parser.next()
            }
        } catch (e: Exception) {
            // Set running to false since this thread will exit here and notifyConnectionError() will wait until
            // the reader and writer thread's 'running' value is false. Hence we need to set it to false before calling
            // notifyConnetctionError() below, even though run() also sets it to false. Therefore, do not remove this.
            running = false
            var ignoreReasonThread: String = ""
            let writerThreadWasShutDown = conn.packetWriter.queue.isShutdown()
            if (writerThreadWasShutDown) {
                ignoreReasonThread = "writer"
            } else if (done) {
                ignoreReasonThread = "reader"
            }
            e.printStackTrace()
            try {
            } catch (e: Exception) {
                e.printStackTrace()
            }
            if (ignoreReasonThread.size > 0) {
                XMPPTCPConnection
                    .LOGGER
                    .log(LogLevel.TRACE, "Ignoring ${e} as ${ignoreReasonThread} was already shut down")
                return
            }
            // Close the connection and notify connection listeners of the error.
            conn.notifyConnectionError(e)
        }
    }
}

public class XMPPTCPConnectionPacketWriter {
    public static let QUEUE_SIZE = XMPPTCPConnection.QUEUE_SIZE
    public static let UNACKKNOWLEDGED_STANZAS_QUEUE_SIZE = 1024
    public static let UNACKKNOWLEDGED_STANZAS_QUEUE_SIZE_HIGH_WATER_MARK = Int64(0.3 * Float64(UNACKKNOWLEDGED_STANZAS_QUEUE_SIZE))

    prop threadName: String {
        get() {
            "Xmpp Writer (${conn.getConnectionCounter()})"
        }
    }

    let queue = ArrayBlockingQueueWithShutdown<Element>(QUEUE_SIZE, true)
    /**
     * If set, the stanza writer is shut down
     */
    protected var shutdownTimestamp: ?Duration = None

    private var instantShutdown: Bool = false

    /**
     * True if some preconditions are given to start the bundle and defer mechanism.
     * <p>
     * This will likely get set to true right after the start of the writer thread, because
     * {@link #nextStreamElement()} will check if {@link queue} is empty, which is probably the case, and then set
     * this field to true.
     * </p>
     */
    private var shouldBundleAndDefer: Bool = false

    var running: Bool = false

    let conn: XMPPTCPConnection

    protected init(xmppPTCPConnection: XMPPTCPConnection) {
        this.conn = xmppPTCPConnection
    }

    /**
     * Initializes the writer in order to be used. It is called at the first connection and also
     * is invoked if the connection is disconnected by an error.
     */
    public func initself(): Unit {
        shutdownTimestamp = None
        if (conn.unacknowledgedStanzas.isSome()) {
            // It's possible that there are new stanzas in the writer queue that
            // came in while we were disconnected but resumable, drain those into
            // the unacknowledged queue so that they get resent now
            drainWriterQueueToUnacknowledgedStanzas()
        }
        queue.start()
        running = true
        Async.go(
            {
                =>
                XMPPTCPConnection.LOGGER.trace("${threadName} start")
                try {
                    writePackets()
                } finally {
                    XMPPTCPConnection.LOGGER.trace("${threadName} exit")
                    running = false
                    conn.notifyWaitingThreads()
                }
            },
            threadName
        )
    }

    func done(): Bool {
        return shutdownTimestamp.isSome()
    }

    protected func throwNotConnectedExceptionIfDoneAndResumptionNotPossible(): Unit {
        let done = done()
        if (done) {
            let smResumptionPossible = conn.isSmResumptionPossible()
            // Don't throw a NotConnectedException is there is an resumable stream available
            if (!smResumptionPossible) {
                throw NotConnectedException(conn, "done=${done} smResumptionPossible=${smResumptionPossible}")
            }
        }
    }

    /**
     * Sends the specified element to the server.
     *
     * @param element the element to send.
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    protected func sendStreamElement(element: Element): Unit {
        throwNotConnectedExceptionIfDoneAndResumptionNotPossible()
        try {
            queue.put(element)
        } catch (e: Exception) {
            // put() may throw an InterruptedException for two reasons:
            // 1. If the queue was shut down
            // 2. If the thread was interrupted
            // so we have to check which is the case
            throwNotConnectedExceptionIfDoneAndResumptionNotPossible()
            // If the method above did not throw, then the sending thread was interrupted
            throw e
        }
    }

    /**
     * Shuts down the stanza writer. Once this method has been called, no further
     * packets will be written to the server.
     */
    func shutdown(instant: Bool): Unit {
        instantShutdown = instant
        queue.shutdown()
        shutdownTimestamp = DateTime.now().toUnixTimeStamp()
    }

    /**
     * Maybe return the next available element from the queue for writing. If the queue is shut down <b>or</b> a
     * spurious interrupt occurs, <code>null</code> is returned. So it is important to check the 'done' condition in
     * that case.
     *
     * @return the next element for writing or null.
     */
    private func nextStreamElement(): ?Element {
        // It is important the we check if the queue is empty before removing an element from it
        if (queue.isEmpty()) {
            shouldBundleAndDefer = true
        }
        var packet: ?Element = None
        try {
            packet = queue.take()
        } catch (e: Exception) {
            if (!queue.isShutdown()) {
                // Users shouldn't try to interrupt the packet writer thread
                XMPPTCPConnection
                    .LOGGER
                    .log(LogLevel.WARN, "Writer thread was interrupted. Don't do that. Use disconnect() instead.", e)
            }
        }
        return packet
    }

    public func writePackets(): Unit {
        try {
            // Write out packets from the queue.
            while (!done()) {
                let element = nextStreamElement() ?? continue

                // Get a local version of the bundle and defer callback,
                // in case it's unset between the null check and the method invocation
                let localBundleAndDeferCallback = conn.bundleAndDeferCallback
                // If the preconditions are given (e.g. bundleAndDefer callback is set, queue is empty),
                // then we could wait a bit for further stanzas attempting to decrease our energy consumption
                if (localBundleAndDeferCallback.isSome() && conn.isAuthenticated() && shouldBundleAndDefer) {
                    // Reset shouldBundleAndDefer to false,
                    // nextStreamElement() will set it to true once the queue is empty again.
                    shouldBundleAndDefer = false
                    let bundlingAndDeferringStopped = AtomicBool(false)
                    let bundlingAndDeferringStoppedLock = Monitor()
                    let bundleAndDeferMillis = localBundleAndDeferCallback().getBundleAndDeferMillis(
                        BundleAndDefer(bundlingAndDeferringStopped))
                    if (bundleAndDeferMillis > Duration.Zero) {
                        var remainingWait = bundleAndDeferMillis
                        let waitStart = DateTime.now()
                        synchronized(bundlingAndDeferringStoppedLock) {
                            while (!bundlingAndDeferringStopped.load() && remainingWait > Duration.Zero) {
                                bundlingAndDeferringStoppedLock.wait(timeout: remainingWait)
                                remainingWait = bundleAndDeferMillis - (DateTime.now() - waitStart)
                            }
                        }
                    }
                }
                var packet: ?Stanza = None
                if (element is Stanza) {
                    packet = element as Stanza
                } else if (element is StreamManagementEnable) {
                    // The client needs to add messages to the unacknowledged stanzas queue right after it sent 'enabled'.
                    // Stanza will be added once unacknowledgedStanzas is not null.
                    conn.unacknowledgedStanzas = ArrayBlockingQueue<Stanza>(UNACKKNOWLEDGED_STANZAS_QUEUE_SIZE)
                }
                maybeAddToUnacknowledgedStanzas(packet)
                let elementXml = element.toXML(conn.outgoingStreamXmlEnvironment)
                if (let Some(elementXml) <- (elementXml as XmlStringBuilder)) {
                    try {
                        elementXml.write(conn.writer(), conn.outgoingStreamXmlEnvironment)
                    } catch (npe: NoneValueException) {
                        XMPPTCPConnection
                            .LOGGER
                            .log(LogLevel.TRACE,
                                "NPE in XmlStringBuilder of ${anyClassId(element)}: ${anyToString(element)}", npe)
                        throw npe
                    }
                } else {
                    conn.writer?.write(elementXml.toString())
                }
                if (queue.isEmpty()) {
                    conn.writer?.flush()
                }
                if (let Some(packet) <- packet) {
                    conn.fireElementSendingListeners(packet)
                }
            }
            if (!instantShutdown) {
                // Flush out the rest of the queue.
                try {
                    while (!queue.isEmpty()) {
                        let packet = queue.remove()
                        if (packet is Stanza) {
                            let stanza = packet as Stanza
                            maybeAddToUnacknowledgedStanzas(stanza)
                        }
                        conn.writer?.write(packet.toXML().toString())
                    }
                } catch (e: Exception) {
                    XMPPTCPConnection
                        .LOGGER
                        .log(LogLevel.WARN, "Exception flushing queue during shutdown, ignore and continue", e)
                }
                // Close the stream.
                try {
                    conn.writer?.write("</stream:stream>")
                    conn.writer?.flush()
                } catch (e: Exception) {
                    XMPPTCPConnection.LOGGER.log(LogLevel.WARN, "Exception writing closing stream element", e)
                }
                // Delete the queue contents (hopefully nothing is left).
                queue.clear()
            } else if (instantShutdown && conn.isSmEnabled()) {
                // This was an instantShutdown and SM is enabled,
                // drain all remaining stanzas into the unacknowledgedStanzas queue
                drainWriterQueueToUnacknowledgedStanzas()
            }
        // Do *not* close the writer here, as it will cause the socket to get closed.
        // But we may want to receive further stanzas until the closing stream tag is received.
        // The socket will be closed in shutdown().
        } catch (e: Exception) {
            // The exception can be ignored if the the connection is 'done'
            // or if the it was caused because the socket got closed
            if (!(done() || queue.isShutdown())) {
                // Set running to false since this thread will exit here and notifyConnectionError() will wait until
                // the reader and writer thread's 'running' value is false.
                running = false
                conn.notifyConnectionError(e)
            } else {
                XMPPTCPConnection.LOGGER.log(LogLevel.TRACE, "Ignoring Exception in writePackets()", e)
            }
        }
    }

    private func drainWriterQueueToUnacknowledgedStanzas(): Unit {
        let elements = ArrayList<Element>(queue.size)
        queue.drainTo(elements)
        for (i in 0..elements.size) {
            let element = elements[i]
            let unacknowledgedStanzas = conn.unacknowledgedStanzas()
            if (unacknowledgedStanzas.capacity - unacknowledgedStanzas.size == 0) {
                let exception = StreamManagementUnacknowledgedQueueFullException.newWith(i, elements,
                    CollectionBlockingQueue(unacknowledgedStanzas))
                XMPPTCPConnection
                    .LOGGER
                    .log(
                        LogLevel.WARN,
                        "Some stanzas may be lost as not all could be drained to the unacknowledged stanzas queue",
                        exception
                    )
                return
            }
            if (let Some(element) <- (element as Stanza)) {
                unacknowledgedStanzas.enqueue(element)
            }
        }
    }

    private func maybeAddToUnacknowledgedStanzas(stanza: ?Stanza): Unit {
        // Check if the stream element should be put to the unacknowledgedStanza queue.
        // Note that we can not do the put() in sendStanzaInternal()
        // and the packet order is not stable at this point
        // (sendStanzaInternal() can be called concurrently).
        if (conn.unacknowledgedStanzas.isSome() && stanza.isSome()) {
            // If the unacknowledgedStanza queue reaching its high water mark,
            // request an new ack from the server in order to drain it
            if (conn.unacknowledgedStanzas?.size == UNACKKNOWLEDGED_STANZAS_QUEUE_SIZE_HIGH_WATER_MARK) {
                conn.writer?.write(StreamManagementAckRequest.INSTANCE.toXML())
            }
            try {
                // It is important the we put the stanza in the unacknowledged stanza
                // queue before we put it on the wire
                conn.unacknowledgedStanzas?.enqueue(stanza.getOrThrow())
            } catch (e: Exception) {
                throw Exception()
            }
        }
    }
}

extend<T> ArrayBlockingQueue<T> {
    func drainTo(list: ArrayList<T>): Unit {
        while (let Some(v) <- this.tryDequeue()) {
            list.append(v)
        }
    }
    func drainTo(list: LinkedList<T>): Unit {
        while (let Some(v) <- this.tryDequeue()) {
            list.append(v)
        }
    }
}
