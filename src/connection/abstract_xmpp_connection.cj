/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

/**
 * This abstract class is commonly used as super class for XMPP connection mechanisms like TCP and BOSH. Hence it
 * provides the methods for connection state management, like {@link #connect()}, {@link #login()} and
 * {@link #disconnect()} (which are deliberately not provided by the {@link XMPPConnection} interface).
 * <p>
 * <b>Note:</b> The default entry point to Xmpp's documentation is {@link XMPPConnection}. If you are getting started
 * with Xmpp, then head over to {@link XMPPConnection} and the come back here.
 * </p>
 * <h2>Parsing Exceptions</h2>
 * <p>
 * In case a Xmpp parser (Provider) throws those exceptions are handled over to the {@link ParsingExceptionCallback}. A
 * common cause for a provider throwing is illegal input, for example a non-numeric String where only Integers are
 * allowed. Xmpp's <em>default behavior</em> follows the <b>"fail-hard per default"</b> principle leading to a
 * termination of the connection on parsing exceptions. This default was chosen to make users eventually aware that they
 * should configure their own callback and handle those exceptions to prevent the disconnect. Handle a parsing exception
 * could be as simple as using a non-throwing no-op callback, which would cause the faulty stream element to be taken
 * out of the stream, i.e., Xmpp behaves like that element was never received.
 * </p>
 * <p>
 * If the parsing exception is because Xmpp received illegal input, then please consider informing the authors of the
 * originating entity about that. If it was thrown because of an bug in a Xmpp parser, then please consider filling a
 * bug with Xmpp.
 * </p>
 * <h3>Managing the parsing exception callback</h3>
 * <p>
 * The "fail-hard per default" behavior is achieved by using the
 * {@link xmpp4cj.parsing.ExceptionThrowingCallbackWithHint} as default parsing exception callback. You
 * can change the behavior using {@link #setParsingExceptionCallback(ParsingExceptionCallback)} to set a new callback.
 * Use {@link xmpp4cj.XmppConfiguration#setDefaultParsingExceptionCallback(ParsingExceptionCallback)} to
 * set the default callback.
 * </p>
 */
public abstract class AbstractXMPPConnection <: XMPPConnection & ClassIdentify {
    private static let LOGGER = getGlobalLogger(("name", "AbstractXMPPConnection"))

    protected static let XMPP_REACTOR: XmppReactor = unsafe { zeroValue<XmppReactor>() } // TODO XmppReactor.getInstance()

    /**
     * 计数器，用于唯一标识创建的连接。
     */
    private static let connectionCounter = AtomicInt64(0)

    static init() {
        // Xmpp4cj.ensureInitialized() // TODO
    }

    private let lock = Monitor()

    /**
     * ConnectionListeners的集合，用于监听连接关闭和重新连接事件。
     */
    protected let connectionListeners: ConcurrentSet<ConnectionListener> = ConcurrentSet<ConnectionListener>()

    /**
     * StanzaCollectors的集合，用于收集指定筛选器的数据包，并对结果队列执行阻塞和轮询操作。
     * <p>
     * 我们在这里使用ConcurrentLinkedQueue，因为它的迭代器是弱一致的，我们希望每个循环的{@link#invokeStanzaCollectorsAndNotifyRecvListeners（Stanza）}都是无锁的。
     * 作为缺点，移除StanzaCollector的结果为O（n）。
     * 另一种选择是同步哈希集，但这意味着每次使用<code>收集器</code>时都会有一个同步块。
     * </p>
     */
    private let collectors: ConcurrentLinkedQueue<StanzaCollector> = ConcurrentLinkedQueue()

    private let recvListeners: Map<StanzaListener, AbstractXMPPConnectionListenerWrapper> = LinkedHashMap()

    private let recvListenersLock = Monitor()

    /**
     * 收到新节时将同步通知的PacketListeners列表。
     */
    let syncRecvListeners: Map<StanzaListener, AbstractXMPPConnectionListenerWrapper> = LinkedHashMap()

    private let syncRecvListenersLock = Monitor()

    /**
     * 收到新节时将异步通知的PacketListeners列表。
     */
    private let asyncRecvListeners: Map<StanzaListener, AbstractXMPPConnectionListenerWrapper> = LinkedHashMap()

    private let asyncRecvListenersLock = Monitor()

    /**
     * 发送新节时将收到通知的PacketListeners列表。
     */
    private let sendListeners: Map<StanzaListener, AbstractXMPPConnectionListenerWrapper> = HashMap()

    private let sendListenersLock = Monitor()

    /**
     * 当新节即将发送到服务器时将收到通知的PacketListeners列表。
     * 这些拦截器可能会在节实际发送到服务器之前对其进行修改。
     */
    private let interceptors: Map<StanzaListener, AbstractXMPPConnectionInterceptorWrapper> = HashMap()

    private let interceptorsLock = Monitor()

    private let messageInterceptors: Map<HashableConsumer<MessageBuilder>, GenericInterceptorWrapper<MessageBuilder,
        Message>> = HashMap()

    private let messageInterceptorsLock = Monitor()

    private let presenceInterceptors: Map<HashableConsumer<PresenceBuilder>, GenericInterceptorWrapper<PresenceBuilder,
        Presence>> = HashMap()

    private let presenceInterceptorsLock = Monitor()

    private var incomingStreamXmlEnvironment: ?XmlEnvironment = None

    protected var outgoingStreamXmlEnvironment: ?XmlEnvironment = None

    let nonzaCallbacksMap = MultiMap<QName, NonzaCallback>()

    protected let connectionLock = Monitor()

    protected let streamFeatures: Map<QName, FullyQualifiedElement> = HashMap()

    /**
     * 服务器的资源绑定响应返回的经过身份验证的用户的完整JID。
     * <p>
     * 重要的是，我们不要从login（）参数和配置服务名称推断用户，例如，当使用SASL External时，用户名不是用于登录的，而是从“外部”证书中获取的。
     * </p>
     */
    protected var user: ?EntityFullJid = None

    protected var connected = false

    /**
     * 流ID，见RFC 6120§4.7.3
     */
    protected var streamId: ?String = None

    /**
     * 等待答复的超时时间（毫秒）。
     */
    private var replyTimeout = XmppConfiguration.getDefaultReplyTimeout()

    /**
     * XmppDebugger允许记录和调试XML流量。
     */
    protected var debugger: ?XmppDebugger = None

    /**
     * 用于调试器的读取器。
     */
    protected var reader: ?ObservableReader = None

    /**
     * 用于调试器的Writer。
     */
    protected var writer: ?ObservableWriter = None

    protected var currentXmpp4cjException: ?Xmpp4cjException = None

    protected var currentXmppException: ?XMPPException = None

    protected var tlsHandled: Bool = false

    /**
     * 如果服务器的最后一个特征节已被解析，则设置为<code>true</code>。
     * XMPP连接抖动可以调用多个功能节，例如，当TLS被激活时，服务器会发送第二个功能节。解析完最后一个特征节后，此设置为true。
     */
    protected var lastFeaturesReceived: Bool = false

    /**
     * 如果此连接已从远程端点（即服务器）接收到关闭流元素，则同步点成功。
     */
    protected var saslFeatureReceived: Bool = false

    /**
     * 如果此连接已从远程端点（即服务器）接收到关闭流元素，则同步点成功。
     */
    protected var closingStreamReceived: Bool = false

    /**
     * 负责与服务器进行身份验证的SASLA身份验证管理器。
     */
    protected var saslAuthentication: ?SASLAuthentication = None

    /**
     * 唯一标识所创建连接的数字。这与连接ID不同，连接ID是服务器在建立连接后发送的值。
     */
    protected let connectionCounterValue = connectionCounter.fetchAdd(1)

    /**
     * 保存创建连接时使用的初始配置。
     */
    protected let config: ConnectionConfiguration

    /**
     * 定义如何处理传出节的from属性。
     */
    private var fromMode: XMPPConnectionFromMode = XMPPConnectionFromMode.OMITTED

    protected var compressionHandler: ?XMPPInputOutputStream = None

    private var parsingExceptionCallback = XmppConfiguration.getDefaultParsingExceptionCallback()

    /**
     * 具有自定义线程工厂的缓存线程池执行器服务，用于在线程上设置有意义的名称并将其设置为“守护进程”。
     */
    private static let CACHED_EXECUTOR_SERVICE = {
        runnable: () -> Unit => spawn {
            Thread.currentThread.name = "Xmpp Cached Executor"
            let t = Thread.currentThread
            try {
                runnable()
            } catch (e: Exception) {
                LOGGER.warn("${t.id} ${t.name} encountered uncaught exception", ("exception", e))
            }
        }
    }

    protected static let ASYNC_BUT_ORDERED = AsyncButOrdered<AbstractXMPPConnection>()

    /**
     * 用于建立连接的主机
     */
    protected var host: String = ""

    /**
     * 用于建立连接的端口
     */
    protected var port: ?UInt16 = None

    /**
     * 指示用户当前是否已通过服务器身份验证的标志。
     */
    protected var authenticated = false

    protected var authenticatedConnectionInitiallyEstablishedTimestamp: Duration = Duration.Zero

    /**
     * 当与服务器的连接关闭时（突然或不突然），指示用户是否已通过服务器身份验证的标志。
     */
    protected var wasAuthenticated = false

    private let setIqRequestHandler: ConcurrentHashMap<QName, IQRequestHandler> = ConcurrentHashMap()

    private let getIqRequestHandler: ConcurrentHashMap<QName, IQRequestHandler> = ConcurrentHashMap()

    private let stanzaFactory: StanzaFactory

    /**
     * Create a new XMPPConnection to an XMPP server.
     *
     * @param configuration The configuration which is used to establish the connection.
     */
    protected init(configuration: ConnectionConfiguration) {
        config = configuration

        let stanzaIdSource = configuration.constructStanzaIdSource()
        stanzaFactory = StanzaFactory(stanzaIdSource)
    }
    /* 
     * open class 无法在构造函数中使用 this
     * 部分属性依赖this构建 init后必须调用
     * 影响: 属性加载顺序有变动
     */
    protected open func postInit(): Unit {
        let auth = SASLAuthentication(this, config)
        saslAuthentication = auth
        // Install the SASL Nonza callbacks.
        buildNonzaCallback().listenFor(
            "SaslNonzaChallenge",
            {
                c => try {
                    let challenge = (c as SaslNonzaChallenge).getOrThrow()
                    auth.challengeReceived(challenge)
                } catch (e: Xmpp4cjException) {
                    auth.authenticationFailed(e)
                }
            }
        ).listenFor(
            "SaslNonzaSuccess",
            {
                s => try {
                    let success = (s as SaslNonzaSuccess).getOrThrow()
                    auth.authenticated(success)
                } catch (e: XmppSaslException | NotConnectedException) {
                    auth.authenticationFailed(e)
                }
            }
        ).listenFor(
            "SaslNonzaSASLFailure",
            {f => auth.authenticationFailed((f as SaslNonzaSASLFailure).getOrThrow())}
        ).install()

        let debuggerFactory = config.getDebuggerFactory()
        debugger = debuggerFactory?.create(this)

        // Notify listeners that a new connection has been established
        for (listener in XMPPConnectionRegistry.getConnectionCreationListeners()) {
            listener.connectionCreated(this)
        }
    }

    /**
     * 获取此连接使用的连接配置。
     *
     * @return 连接配置。
     */
    public open func getConfiguration(): ConnectionConfiguration {
        return config
    }

    public override func getXMPPServiceDomain(): DomainBareJid {
        return xmppServiceDomain ?? config.getXMPPServiceDomain()
    }

    public override func getHost(): String {
        return host
    }

    public override func getPort(): Int {
        if (let Some(v) <- this.port) {
            Int64(v)
        } else {
            -1
        }
    }

    // public override func isSecureConnection(): Bool

    protected func sendStanzaInternal(packet: Stanza): Unit

    public override func trySendStanza(stanza: Stanza): Bool {
        // Default implementation which falls back to sendStanza() as mentioned in the methods doc.
        // May be overwritten by subclasses.
        try {
            sendStanza(stanza)
        } catch (e: Exception) {
            LOGGER.trace("Thread blocked in fallback implementation of trySendStanza(Stanza) was interrupted",
                ("exception", e))
            return false
        }
        return true
    }

    public override func trySendStanza(stanza: Stanza, timeout: Duration): Bool {
        // Default implementation which falls back to sendStanza() as mentioned in the methods doc.
        // May be overwritten by subclasses.
        sendStanza(stanza)
        return true
    }

    // public override func sendNonza(element: Nonza): Unit

    // public override func isUsingCompression(): Bool

    protected func initState(): Unit {
        currentXmpp4cjException = None
        currentXmppException = None
        saslFeatureReceived = false
        lastFeaturesReceived = false
        tlsHandled = false
    }

    /**
     * 建立与XMPP服务器的连接。它基本上创建并维护与服务器的连接。
     * <p>
     * 将保留以前连接的侦听器。
     * </p>
     *
     * @throws XMPPException 如果XMPP协议级别发生错误。
     * @throws Xmpp4cjException 如果在XMPP协议级别之外的其他地方发生错误。
     * @throws IOException 如果发生I/O错误
     * @throws InterruptedException 如果调用线程被中断。
     * @return 引用此对象，将<code>connect（）</code>与<code>login（）</code>链接起来。
     */
    public func connect(): AbstractXMPPConnection {
        synchronized(this.lock) {
            // Check if not already connected
            throwAlreadyConnectedExceptionIfAppropriate()
            // Notify connection listeners that we are trying to connect
            callConnectionConnectingListener()
            // Reset the connection state
            initState()
            closingStreamReceived = false
            streamId = None

            try {
                // Perform the actual connection to the XMPP service
                connectInternal()
                // If TLS is required but the server doesn't offer it, disconnect
                // from the server and throw an error. First check if we've already negotiated TLS
                // and are secure, however (features get parsed a second time after TLS is established).
                if (!isSecureConnection() && getConfiguration().getSecurityMode() == ConnectionConfigurationSecurityMode.
                    required) {
                    throw SecurityRequiredByClientException()
                }
            } catch (e: Xmpp4cjException | IOException | XMPPException) {
                LOGGER.log(LogLevel.DEBUG, "3.1 AbstractXMPPConnection.connect", e)
                instantShutdown()
                throw e
            }
            // If connectInternal() did not throw, then this connection must now be marked as connected.
            assert(connected)
            callConnectionConnectedListener()
            return this
        }
    }

    /**
     * Abstract method that concrete subclasses of XMPPConnection need to implement to perform their
     * way of XMPP connection establishment. Implementations are required to perform an automatic
     * login if the previous connection state was logged (authenticated).
     *
     * @throws Xmpp4cjException if Xmpp detected an exceptional situation.
     * @throws IOException if an I/O error occurred.
     * @throws XMPPException if an XMPP protocol error was received.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    protected func connectInternal(): Unit

    private var usedUsername: ?String = None
    private var usedPassword: ?String = None

    /**
     * The resourcepart used for this connection. May not be the resulting resourcepart if it's null or overridden by the XMPP service.
     */
    private var usedResource: ?Resourcepart = None

    /**
     * Logs in to the server using the strongest SASL mechanism supported by
     * the server. If more than the connection's default stanza timeout elapses in each step of the
     * authentication process without a response from the server, a
     * {@link Xmpp4cjException.NoResponseException} will be thrown.
     * <p>
     * Before logging in (i.e. authenticate) to the server the connection must be connected
     * by calling {@link #connect}.
     * </p>
     * <p>
     * It is possible to log in without sending an initial available presence by using
     * {@link ConnectionConfiguration.Builder#setSendPresence(boolean)}.
     * Finally, if you want to not pass a password and instead use a more advanced mechanism
     * while using SASL then you may be interested in using
     * {@link ConnectionConfiguration.Builder#setCallbackHandler(CallbackHandler)}.
     * For more advanced login settings see {@link ConnectionConfiguration}.
     * </p>
     *
     * @throws XMPPException if an error occurs on the XMPP protocol level.
     * @throws Xmpp4cjException if an error occurs somewhere else besides XMPP protocol level.
     * @throws IOException if an I/O error occurs during login.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    public func login(): Unit {
        // The previously used username, password and resource take over precedence over the
        // ones from the connection configuration
        synchronized(this.lock) {
            let username = usedUsername ?? config.getUsername()
            let password = usedPassword ?? config.getPassword()
            let resource = if (let Some(v) <- usedResource) {
                v
            } else {
                config.getResource()
            }
            login(username, password, resource)
        }
    }

    /**
     * Same as {@link #login(CharSequence, String, Resourcepart)}, but takes the resource from the connection
     * configuration.
     *
     * @param username username
     * @param password password
     * @throws XMPPException if an XMPP protocol error was received.
     * @throws Xmpp4cjException if Xmpp detected an exceptional situation.
     * @throws IOException if an I/O error occurred.
     * @throws InterruptedException if the calling thread was interrupted.
     * @see #login
     */
    public func login(username: String, password: String): Unit {
        synchronized(this.lock) {
            login(username, password, config.getResource())
        }
    }

    /**
     * Login with the given username (authorization identity). You may omit the password if a callback handler is used.
     * If resource is null, then the server will generate one.
     *
     * @param username username
     * @param password password
     * @param resource resource
     * @throws XMPPException if an XMPP protocol error was received.
     * @throws Xmpp4cjException if Xmpp detected an exceptional situation.
     * @throws IOException if an I/O error occurred.
     * @throws InterruptedException if the calling thread was interrupted.
     * @see #login
     */
    public func login(username: String, password: String, resource: ?Resourcepart): Unit {
        synchronized(this.lock) {
            if (!config.allowNullOrEmptyUsername) {
                StringUtils.requireNotNullNorEmpty(username, "Username must not be null nor empty")
            }
            throwNotConnectedExceptionIfAppropriate("Did you call connect() before login()?")
            throwAlreadyLoggedInExceptionIfAppropriate()
            usedUsername = username
            usedPassword = password
            usedResource = resource
            loginInternal(usedUsername, usedPassword, usedResource)
        }
    }

    protected func loginInternal(username: ?String, password: ?String, resource: ?Resourcepart): Unit

    public override func isConnected(): Bool {
        return connected
    }

    public override func isAuthenticated(): Bool {
        return authenticated
    }

    public override func getUser(): ?EntityFullJid {
        return user
    }

    public override func getStreamId(): ?String {
        if (!isConnected()) {
            return None
        }
        return streamId
    }

    protected func throwCurrentConnectionException(): Unit {
        if (let Some(v) <- currentXmpp4cjException) {
            throw v
        } else if (let Some(v) <- currentXmppException) {
            throw v
        }
        throw Exception("No current connection exception set, although throwCurrentException() was called")
    }

    protected func hasCurrentConnectionException(): Bool {
        return currentXmpp4cjException.isSome() || currentXmppException.isSome()
    }

    public func setCurrentConnectionExceptionAndNotify(exception: Exception): Unit {
        if (let Some(v) <- exception as Xmpp4cjException) {
            currentXmpp4cjException = v
        } else if (let Some(v) <- exception as XMPPException) {
            currentXmppException = v
        } else {
            currentXmpp4cjException = XmppWrappedException(exception)
        }
        notifyWaitingThreads()
    }

    /**
     * We use an extra object for {@link #notifyWaitingThreads()} and {@link #waitFor(Supplier)}, because all state
     * changing methods of the connection are synchronized using the connection instance as monitor. If we now would
     * also use the connection instance for the internal process to wait for a condition, the {@link Object#wait()}
     * would leave the monitor when it waits, which would allow for another potential call to a state changing function
     * to proceed.
     */
    private let internalMonitor = Monitor()

    public func notifyWaitingThreads(): Unit {
        synchronized(internalMonitor) {
            internalMonitor.notifyAll()
        }
    }

    protected func waitFor(condition: Supplier<Bool>): Bool {
        let deadline = DateTime.now() + getReplyTimeout()
        synchronized(internalMonitor) {
            while (!condition()) {
                let now = DateTime.now()
                if (now >= deadline) {
                    return false
                }
                internalMonitor.wait(timeout: deadline - now)
            }
        }
        return true
    }

    protected func waitForConditionOrThrowConnectionException(condition: Supplier<Bool>, waitFor: String): Unit {
        let success = this.waitFor {=> condition() || hasCurrentConnectionException()}
        if (hasCurrentConnectionException()) {
            throwCurrentConnectionException()
        }
        // If there was no connection exception and we still did not successfully wait for the condition to hold, then
        // we ran into a no-response timeout.
        if (!success) {
            throw NoResponseException.newWith(this, waitFor)
        }
        // Otherwise we successfully awaited the condition.
    }

    public func bindResourceAndEstablishSession(resource: ?Resourcepart): ?Resourcepart {
        // Wait until either:
        // - the servers last features stanza has been parsed
        // - the timeout occurs
        LOGGER.trace("Waiting for last features to be received before continuing with resource binding")
        waitForConditionOrThrowConnectionException({=> lastFeaturesReceived},
            "last stream features received from server")

        if (!hasFeature(Bind.ELEMENT, Bind.NAMESPACE)) {
            // Server never offered resource binding, which is REQUIRED in XMPP client and
            // server implementations as per RFC6120 7.2
            throw ResourceBindingNotOfferedException()
        }

        // Resource binding, see RFC6120 7.
        // Note that we can not use IQReplyFilter here, since the users full JID is not yet
        // available. It will become available right after the resource has been successfully bound.
        let bindResource = Bind.newSet(resource)
        var packetCollector = createStanzaCollectorAndSend(StanzaIdFilter(bindResource), bindResource)
        let response: Bind = (packetCollector.nextResultOrThrow() as Bind).getOrThrow()
        // Set the connections user to the result of resource binding. It is important that we don't infer the user
        // from the login() arguments and the configurations service name, as, for example, when SASL External is used,
        // the username is not given to login but taken from the 'external' certificate.
        user = response.getJid()
        xmppServiceDomain = user?.asDomainBareJid()
        let sessionFeature = getFeature("SessionFeature") as SessionFeature
        if (sessionFeature.isSome() && !sessionFeature().isOptional()) {
            let session = Session()
            packetCollector = createStanzaCollectorAndSend(StanzaIdFilter(session), session)
            packetCollector.nextResultOrThrow()
        }
        return user?.getResourcepart()
    }

    public open func afterSuccessfulLogin(resumed: Bool): Unit {
        if (!resumed) {
            authenticatedConnectionInitiallyEstablishedTimestamp = DateTime.now().toUnixTimeStamp()
        }
        // Indicate that we're now authenticated.
        this.authenticated = true

        // If debugging is enabled, change the the debug window title to include the
        // name we are now logged-in as.
        // If DEBUG was set to true AFTER the connection was created the debugger
        // will be null
        debugger?.userHasLogged(user.getOrThrow())
        callConnectionAuthenticatedListener(resumed)

        // Set presence to online. It is important that this is done after
        // callConnectionAuthenticatedListener(), as this call will also
        // eventually load the roster. And we should load the roster before we
        // send the initial presence.
        if (config.isSendPresence() && !resumed) {
            let availablePresence = getStanzaFactory().buildPresenceStanza().ofType(PresenceType.available).build()
            sendStanza(availablePresence)
        }
    }

    public override func isAnonymous(): Bool {
        return isAuthenticated() && getUsedSaslMechansism() == SASLAnonymous.NAME
    }

    /**
     * Get the name of the SASL mechanism that was used to authenticate this connection. This returns the name of
     * mechanism which was used the last time this connection was authenticated, and will return <code>null</code> if
     * this connection was not authenticated before.
     *
     * @return the name of the used SASL mechanism.
     */
    public func getUsedSaslMechansism(): ?String {
        return saslAuthentication().getNameOfLastUsedSaslMechansism()
    }

    private var xmppServiceDomain: ?DomainBareJid = None

    protected func getConnectionLock(): Monitor {
        return connectionLock
    }

    protected open func throwNotConnectedExceptionIfAppropriate(): Unit {
        throwNotConnectedExceptionIfAppropriate(None)
    }

    protected func throwNotConnectedExceptionIfAppropriate(optionalHint: ?String): Unit {
        if (!isConnected()) {
            throw NotConnectedException(optionalHint)
        }
    }

    protected open func throwAlreadyConnectedExceptionIfAppropriate(): Unit {
        if (isConnected()) {
            throw AlreadyConnectedException()
        }
    }

    protected open func throwAlreadyLoggedInExceptionIfAppropriate(): Unit {
        if (isAuthenticated()) {
            throw AlreadyLoggedInException()
        }
    }

    public override func getStanzaFactory(): StanzaFactory {
        return stanzaFactory
    }

    public override func sendStanza(stanza: Stanza): Unit {
        Objects.requireNonNull(stanza, "Stanza must not be null")
        assert(stanza is Message || stanza is Presence || stanza is IQ)

        throwNotConnectedExceptionIfAppropriate()
        match (fromMode) {
            case XMPPConnectionFromMode.OMITTED => stanza.setFrom(None)
            case XMPPConnectionFromMode.USER => stanza.setFrom(getUser().map {v => v})
            case XMPPConnectionFromMode.UNCHANGED => ()
        }
        // Invoke interceptors for the new stanza that is about to be sent. Interceptors may modify
        // the content of the stanza.
        let stanzaAfterInterceptors = firePacketInterceptors(stanza)
        sendStanzaInternal(stanzaAfterInterceptors)
    }

    /**
     * Authenticate a connection.
     *
     * @param username the username that is authenticating with the server.
     * @param password the password to send to the server.
     * @param authzid the authorization identifier (typically null).
     * @param sslSession the optional SSL/TLS session (if one was established)
     * @return the used SASLMechanism.
     * @throws XMPPErrorException if there was an XMPP error returned.
     * @throws SASLErrorException if a SASL protocol error was returned.
     * @throws IOException if an I/O error occurred.
     * @throws InterruptedException if the calling thread was interrupted.
     * @throws XmppSaslException if a SASL specific error occurred.
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @throws NoResponseException if there was no response from the remote entity.
     * @throws XmppWrappedException in case of an exception.
     * @see SASLAuthentication#authenticate(String, String, EntityBareJid, TlsSession )
     */
    public func authenticate(username: String, password: String, authzid: ?EntityBareJid, sslSession: ?TlsSession): SASLMechanism {
        let saslMechanism = saslAuthentication().authenticate(username, password, authzid, sslSession)
        afterSaslAuthenticationSuccess()
        return saslMechanism
    }

    /**
     * Hook for subclasses right after successful SASL authentication. RFC 6120 § 6.4.6. specifies a that the initiating
     * entity, needs to initiate a new stream in this case. But some transports, like BOSH, requires a special handling.
     * <p>
     * Note that we can not reset XMPPTCPConnection's parser here, because this method is invoked by the thread calling
     * {@link #login()}, but the parser reset has to be done within the reader thread.
     * </p>
     *
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @throws InterruptedException if the calling thread was interrupted.
     * @throws XmppWrappedException in case of an exception.
     */
    protected func afterSaslAuthenticationSuccess(): Unit {
        sendStreamOpen()
    }

    protected func isSaslAuthenticated(): Bool {
        return saslAuthentication().authenticationSuccessful()
    }

    /**
     * Closes the connection by setting presence to unavailable then closing the connection to
     * the XMPP server. The XMPPConnection can still be used for connecting to the server
     * again.
     *
     */
    public func disconnect(): Unit {
        var unavailablePresence: ?Presence = None
        if (isAuthenticated()) {
            unavailablePresence = getStanzaFactory().buildPresenceStanza().ofType(PresenceType.unavailable).build()
        }
        try {
            disconnect(unavailablePresence)
        } catch (e: NotConnectedException) {
            LOGGER.trace("Connection is already disconnected", ("exception", e))
        }
    }

    /**
     * Closes the connection. A custom unavailable presence is sent to the server, followed
     * by closing the stream. The XMPPConnection can still be used for connecting to the server
     * again. A custom unavailable presence is useful for communicating offline presence
     * information such as "On vacation". Typically, just the status text of the presence
     * stanza is set with online information, but most XMPP servers will deliver the full
     * presence stanza with whatever data is set.
     *
     * @param unavailablePresence the optional presence stanza to send during shutdown.
     * @throws NotConnectedException if the XMPP connection is not connected.
     */
    public func disconnect(unavailablePresence: ?Presence): Unit {
        synchronized(this.lock) {
            if (let Some(unavailablePresence) <- unavailablePresence) {
                try {
                    sendStanza(unavailablePresence)
                } catch (e: Exception) {
                    LOGGER.trace(
                        "Was interrupted while sending unavailable presence. Continuing to disconnect the connection",
                        ("exception", e)
                    )
                }
            }
            shutdown()
            callConnectionClosedListener()
        }
    }

    private let notifyConnectionErrorMonitor = Monitor()

    /**
     * Sends out a notification that there was an error with the connection
     * and closes the connection.
     *
     * @param exception the exception that causes the connection close event.
     */
    public func notifyConnectionError(exception: Exception): Unit {
        synchronized(notifyConnectionErrorMonitor) {
            if (!isConnected()) {
                LOGGER.info("Connection was already disconnected when attempting to handle ${exception}",
                    ("exception", exception))
                return
            }

            // Note that we first have to set the current connection exception and notify waiting threads, as one of them
            // could hold the instance lock, which we also need later when calling instantShutdown().
            setCurrentConnectionExceptionAndNotify(exception)

            // Closes the connection temporary. A if the connection supports stream management, then a reconnection is
            // possible. Note that a connection listener of e.g. XMPPTCPConnection will drop the SM state in
            // case the Exception is a StreamErrorException.
            instantShutdown()

            for (collector in collectors) {
                collector.notifyConnectionError(exception)
            }
            Async.go(
                {
                    =>
                    // Notify connection listeners of the error.
                    callConnectionClosedOnErrorListener(exception)
                },
                "${this} callConnectionClosedOnErrorListener()"
            )
        }
    }

    /**
     * Performs an unclean disconnect and shutdown of the connection. Does not send a closing stream stanza.
     */
    public func instantShutdown(): Unit

    /**
     * Shuts the current connection down.
     */
    protected func shutdown(): Unit

    public func waitForClosingStreamTagFromServer(): Bool {
        try {
            waitForConditionOrThrowConnectionException({=> closingStreamReceived}, "closing stream tag from the server")
        } catch (e: Xmpp4cjException | XMPPException) {
            LOGGER.info("Exception while waiting for closing stream element from the server ${this}", ("exception", e))
            return false
        }
        return true
    }

    public override func addConnectionListener(connectionListener: ConnectionListener): Unit {
        let v = connectionListener //?? return
        connectionListeners.put(v)
    }

    public override func removeConnectionListener(connectionListener: ConnectionListener): Unit {
        connectionListeners.remove(connectionListener)
    }

    public override func sendIqRequestAndWaitForResponse(request: IQ): IQ {
        let collector = createStanzaCollectorAndSend(request)
        let resultResponse = collector.nextResultOrThrow()
        let concreteResultResponse = resultResponse
        return (concreteResultResponse as IQ).getOrThrow()
    }

    public override func createStanzaCollectorAndSend(packet: IQ): StanzaCollector {
        let packetFilter: StanzaFilter = IQReplyFilter(packet, this.getUser(), this.getXMPPServiceDomain())
        // Create the packet collector before sending the packet
        let packetCollector = createStanzaCollectorAndSend(packetFilter, packet)
        return packetCollector
    }

    public override func createStanzaCollectorAndSend(packetFilter: StanzaFilter, packet: Stanza): StanzaCollector {
        let configuration = StanzaCollector.newConfiguration().setStanzaFilter(packetFilter).setRequest(packet)
        // Create the packet collector before sending the packet
        let packetCollector = createStanzaCollector(configuration)
        try {
            // Now we can send the packet as the collector has been created
            sendStanza(packet)
        } catch (e: Exception) {
            packetCollector.cancel()
            throw e
        }
        return packetCollector
    }

    public override func createStanzaCollector(packetFilter: StanzaFilter): StanzaCollector {
        let configuration = StanzaCollector.newConfiguration().setStanzaFilter(packetFilter)
        return createStanzaCollector(configuration)
    }

    public override func createStanzaCollector(configuration: StanzaCollectorConfiguration): StanzaCollector {
        let collector = StanzaCollector(this, configuration)
        // Add the collector to the list of active collectors.
        collectors.append(collector)
        return collector
    }

    public override func removeStanzaCollector(collector: StanzaCollector): Unit {
        collectors.remove(collector)
    }

    public override func addStanzaListener(stanzaListener: StanzaListener, stanzaFilter: StanzaFilter): Unit {
        let wrapper = AbstractXMPPConnectionListenerWrapper(stanzaListener, stanzaFilter)
        synchronized(recvListenersLock) {
            recvListeners.put(stanzaListener, wrapper)
        }
    }

    public override func removeStanzaListener(stanzaListener: StanzaListener): Bool {
        synchronized(recvListenersLock) {
            return recvListeners.remove(stanzaListener).isSome()
        }
    }

    public override func addSyncStanzaListener(packetListener: StanzaListener, packetFilter: StanzaFilter): Unit {
        let wrapper = AbstractXMPPConnectionListenerWrapper(packetListener, packetFilter)
        synchronized(syncRecvListenersLock) {
            syncRecvListeners.put(packetListener, wrapper)
        }
    }

    public override func removeSyncStanzaListener(packetListener: StanzaListener): Bool {
        synchronized(syncRecvListenersLock) {
            return syncRecvListeners.remove(packetListener).isSome()
        }
    }

    public override func addAsyncStanzaListener(packetListener: StanzaListener, packetFilter: StanzaFilter): Unit {
        let wrapper = AbstractXMPPConnectionListenerWrapper(packetListener, packetFilter)
        synchronized(asyncRecvListenersLock) {
            asyncRecvListeners.put(packetListener, wrapper)
        }
    }

    public override func removeAsyncStanzaListener(packetListener: StanzaListener): Bool {
        synchronized(asyncRecvListenersLock) {
            return asyncRecvListeners.remove(packetListener).isSome()
        }
    }

    public override func addStanzaSendingListener(packetListener: StanzaListener, packetFilter: StanzaFilter): Unit {
        let wrapper = AbstractXMPPConnectionListenerWrapper(packetListener, packetFilter)
        synchronized(sendListenersLock) {
            sendListeners.put(packetListener, wrapper)
        }
    }

    public override func removeStanzaSendingListener(packetListener: StanzaListener): Unit {
        synchronized(sendListenersLock) {
            sendListeners.remove(packetListener)
        }
    }

    /**
     * Process all stanza listeners for sending stanzas.
     * <p>
     * Compared to {@link #firePacketInterceptors(Stanza)}, the listeners will be invoked in a new thread.
     * </p>
     *
     * @param sendTopLevelStreamElement the top level stream element which just got send.
     */
    public func fireElementSendingListeners(sendTopLevelStreamElement: TopLevelStreamElement): Unit {
        debugger?.onOutgoingStreamElement(sendTopLevelStreamElement)

        if (!(sendTopLevelStreamElement is TopLevelStreamElement)) {
            return
        }
        let packet = (sendTopLevelStreamElement as Stanza).getOrThrow()

        let listenersToNotify = LinkedList<StanzaListener>()
        synchronized(sendListenersLock) {
            for (listenerWrapper in sendListeners.values()) {
                if (listenerWrapper.filterMatches(packet)) {
                    listenersToNotify.append(listenerWrapper.getListener())
                }
            }
        }
        if (listenersToNotify.isEmpty()) {
            return
        }
        // Notify in a new thread, because we can
        asyncGo {
            => for (listener in listenersToNotify) {
                try {
                    listener.processStanza(packet)
                } catch (e: Exception) {
                    LOGGER.warn("Sending listener threw exception", ("exception", e))
                    continue
                }
            }
        }
    }

    // @Deprecated
    // public func addStanzaInterceptor(@ packetInterceptor: StanzaListener, @ packetFilter: StanzaFilter): Unit {
    //     if (packetInterceptor.isEmpty()) {
    //         throw NoneValueException("Packet interceptor is null.")
    //     }
    //     let interceptorWrapper = AbstractXMPPConnectionInterceptorWrapper(packetInterceptor, packetFilter)
    //     synchronized (interceptorsLock) {
    //         interceptors.put(packetInterceptor, interceptorWrapper)
    //     }
    // }
    // @Deprecated
    // public override func removeStanzaInterceptor(@ packetInterceptor: StanzaListener): Unit {
    //     synchronized (interceptorsLock) {
    //         interceptors.remove(packetInterceptor)
    //     }
    // }

    private static func addInterceptor<MPB, MP>(
        interceptors: Map<HashableConsumer<MPB>, GenericInterceptorWrapper<MPB, MP>>,
        interceptorsLock: Monitor,
        interceptor: HashableConsumer<MPB>,
        filter: Predicate<MP>
    ): Unit where MPB <: MessageOrPresenceBuilder, MP <: MessageOrPresence {
        Objects.requireNonNull(interceptor, "Interceptor must not be null")
        let interceptorWrapper = GenericInterceptorWrapper<MPB, MP>(interceptor._accept, filter)
        synchronized(interceptorsLock) {
            interceptors.put(interceptor, interceptorWrapper)
        }
    }

    private static func removeInterceptor<MPB, MP>(
        interceptors: Map<HashableConsumer<MPB>, GenericInterceptorWrapper<MPB, MP>>,
        interceptorsLock: Monitor,
        interceptor: HashableConsumer<MPB>
    ): Unit where MPB <: MessageOrPresenceBuilder, MP <: MessageOrPresence {
        synchronized(interceptorsLock) {
            interceptors.remove(interceptor)
        }
    }

    public override func addMessageInterceptor(
        messageInterceptor: HashableConsumer<MessageBuilder>,
        messageFilter: Predicate<Message>
    ): Unit {
        addInterceptor(messageInterceptors, messageInterceptorsLock, messageInterceptor, messageFilter)
    }

    public override func removeMessageInterceptor(messageInterceptor: HashableConsumer<MessageBuilder>): Unit {
        removeInterceptor(messageInterceptors, messageInterceptorsLock, messageInterceptor)
    }

    public override func addPresenceInterceptor(
        presenceInterceptor: HashableConsumer<PresenceBuilder>,
        presenceFilter: Predicate<Presence>
    ): Unit {
        addInterceptor(presenceInterceptors, presenceInterceptorsLock, presenceInterceptor, presenceFilter)
    }

    public override func removePresenceInterceptor(presenceInterceptor: HashableConsumer<PresenceBuilder>): Unit {
        removeInterceptor(presenceInterceptors, presenceInterceptorsLock, presenceInterceptor)
    }

    private static func fireMessageOrPresenceInterceptors<MPB, MP>(
        messageOrPresence: MP,
        interceptors: Map<HashableConsumer<MPB>, GenericInterceptorWrapper<MPB, MP>>,
        interceptorsLock: Monitor
    ): MP where MPB <: MessageOrPresenceBuilder, MP <: MessageOrPresence {
        var tempmessageOrPresence = messageOrPresence
        let interceptorsToInvoke = LinkedList<Consumer<MPB>>()
        synchronized(interceptorsLock) {
            for (interceptorWrapper in interceptors.values()) {
                if (interceptorWrapper.filterMatches(tempmessageOrPresence)) {
                    let interceptor = interceptorWrapper.getInterceptor()
                    interceptorsToInvoke.append(interceptor)
                }
            }
        }

        // Avoid transforming the stanza to a builder if there is no interceptor.
        if (interceptorsToInvoke.isEmpty()) {
            return tempmessageOrPresence
        }
        let builder = (tempmessageOrPresence.asBuilder() as MPB).getOrThrow()
        for (interceptor in interceptorsToInvoke) {
            interceptor(builder)
        }

        // Now that the interceptors have (probably) modified the stanza in its builder form, we need to re-assemble it.
        tempmessageOrPresence = (builder.build() as MP).getOrThrow()
        return tempmessageOrPresence
    }

    /**
     * Process interceptors. Interceptors may modify the stanza that is about to be sent.
     * Since the thread that requested to send the stanza will invoke all interceptors,
     * it is important that interceptors perform their work as soon as possible so that
     * the thread does not remain blocked for a long period.
     *
     * @param packet the stanza that is going to be sent to the server.
     * @return the, potentially modified stanza, after the interceptors are run.
     */
    private func firePacketInterceptors(packet: Stanza): Stanza {
        let interceptorsToInvoke = LinkedList<StanzaListener>()
        synchronized(interceptorsLock) {
            for (interceptorWrapper in interceptors.values()) {
                if (interceptorWrapper.filterMatches(packet)) {
                    interceptorsToInvoke.append(interceptorWrapper.getInterceptor())
                }
            }
        }
        for (interceptor in interceptorsToInvoke) {
            try {
                interceptor.processStanza(packet)
            } catch (e: Exception) {
                LOGGER.error("Packet interceptor threw exception", ("exception", e))
            }
        }
        let stanzaAfterInterceptors: Stanza
        if (let Some(message) <- (packet as Message)) {
            stanzaAfterInterceptors = fireMessageOrPresenceInterceptors(message, messageInterceptors,
                messageInterceptorsLock)
        } else if (let Some(presence) <- (packet as Presence)) {
            stanzaAfterInterceptors = fireMessageOrPresenceInterceptors(presence, presenceInterceptors,
                presenceInterceptorsLock)
        } else {
            // We do not (yet) support interceptors for IQ stanzas.
            assert(packet is IQ)
            stanzaAfterInterceptors = packet
        }
        return stanzaAfterInterceptors
    }

    /**
     * Initialize the {@link #debugger}. You can specify a customized {@link XmppDebugger}
     * by setup the system property <code>xmpp.debuggerClass</code> to the implementation.
     *
     * @throws IllegalStateException if the reader or writer isn't yet initialized.
     * @throws IllegalArgumentException if the XmppDebugger can't be loaded.
     */
    protected func initDebugger(): Unit {
        if (reader.isNone() || writer.isNone()) {
            throw NoneValueException("Reader or writer isn't initialized.")
        }
        // If debugging is enabled, we open a window and write out all network traffic.
        if (let Some(debugger) <- debugger) {
            // Obtain new reader and writer from the existing debugger
            reader = debugger.newConnectionReader(reader())
            writer = debugger.newConnectionWriter(writer())
        }
    }

    public override func getReplyTimeout(): Duration {
        return replyTimeout
    }

    public override func setReplyTimeout(timeout: Duration): Unit {
        if (Duration.millisecond * Int64.Max - DateTime.now().toUnixTimeStamp() < timeout) {
            throw IllegalArgumentException("Extremely long reply timeout")
        } else {
            replyTimeout = timeout
        }
    }

    private var unknownIqRequestReplyMode = XmppConfiguration.getUnknownIqRequestReplyMode()

    /**
     * Set how Xmpp behaves when an unknown IQ request has been received.
     *
     * @param unknownIqRequestReplyMode reply mode.
     */
    public func setUnknownIqRequestReplyMode(unknownIqRequestReplyMode: XmppConfigurationUnknownIqRequestReplyMode): Unit {
        this.unknownIqRequestReplyMode = Objects.requireNonNull(unknownIqRequestReplyMode, "Mode must not be null")
    }

    protected func buildNonzaCallback(): NonzaCallbackBuilder {
        return NonzaCallbackBuilder(this)
    }

    protected func sendAndWaitForResponse<SN, FN>(nonza: Nonza, successNonzaClass: ClassId, failedNonzaClass: ClassId): ?SN where SN <: Nonza,
        FN <: Nonza {
        let builder = buildNonzaCallback()
        let successNonza = NonzaCallback.sendAndWaitForResponse<SN, FN>(builder, nonza, successNonzaClass,
            failedNonzaClass)
        return successNonza
    }

    private func maybeNotifyDebuggerAboutIncoming(incomingTopLevelStreamElement: TopLevelStreamElement): Unit {
        let debugger = this.debugger
        if (debugger.isSome()) {
            debugger?.onIncomingStreamElement(incomingTopLevelStreamElement)
        }
    }

    public func parseAndProcessNonza(parser: XmlPullParser): Unit {
        ParserUtils.assertAtStartTag(parser)

        let initialDepth = parser.getDepth()
        let element = parser.getName()
        let namespace = parser.getNamespace()
        let key = QName(namespace, element)

        let nonzaProvider = if (let Some(v) <- ProviderManager.getNonzaProvider(key)) {
            v
        } else {
            LOGGER.error("Unknown nonza: ${key}")
            ParserUtils.forwardToEndTagOfDepth(parser, initialDepth)
            return
        }

        var nonzaCallbacks: ?ArrayList<NonzaCallback>
        synchronized(nonzaCallbacksMap.lock.writeMutex) {
            nonzaCallbacks = ArrayList(nonzaCallbacksMap.getAll(key))
        }
        if (nonzaCallbacks.isNone()) {
            LOGGER.info("No nonza callback for ${key}")
            ParserUtils.forwardToEndTagOfDepth(parser, initialDepth)
            return
        }
        let nonza = nonzaProvider.parse(parser, incomingStreamXmlEnvironment)
        maybeNotifyDebuggerAboutIncoming(nonza)
        for (nonzaCallback in nonzaCallbacks.getOrThrow()) {
            nonzaCallback.onNonzaReceived(nonza)
        }
    }

    protected func parseAndProcessStanza(parser: XmlPullParser): Unit {
        ParserUtils.assertAtStartTag(parser)
        let parserDepth = parser.getDepth()
        var stanza: ?Stanza = None
        try {
            stanza = PacketParserUtils.parseStanza(parser, incomingStreamXmlEnvironment())
        } catch (e: XmlPullParserException | XmppParsingException | IOException | IllegalArgumentException) {
            let content = PacketParserUtils.parseContentDepth(parser, parserDepth)
            let message = UnparseableStanza(content, e)
            let callback = getParsingExceptionCallback()
            callback.handleUnparsableStanza(message)
        }
        ParserUtils.assertAtEndTag(parser)
        if (let Some(stanza) <- stanza) {
            processStanza(stanza)
        }
    }

    /**
     * Processes a stanza after it's been fully parsed by looping through the installed
     * stanza collectors and listeners and letting them examine the stanza to see if
     * they are a match with the filter.
     *
     * @param stanza the stanza to process.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    protected func processStanza(stanza: Stanza): Unit {
        // assert (stanza.isSome())
        maybeNotifyDebuggerAboutIncoming(stanza)
        lastStanzaReceived = DateTime.now().toUnixTimeStamp()
        // Deliver the incoming packet to listeners.
        invokeStanzaCollectorsAndNotifyRecvListeners(stanza)
    }

    /**
     * Invoke {@link StanzaCollector#processStanza(Stanza)} for every
     * StanzaCollector with the given packet. Also notify the receive listeners with a matching stanza filter about the packet.
     * <p>
     * This method will be invoked by the connections incoming processing thread which may be shared across multiple connections and
     * thus it is important that no user code, e.g. in form of a callback, is invoked by this method. For the same reason,
     * this method must not block for an extended period of time.
     * </p>
     *
     * @param packet the stanza to notify the StanzaCollectors and receive listeners about.
     */
    protected func invokeStanzaCollectorsAndNotifyRecvListeners(packet: Stanza): Unit {
        if (let Some(iq) <- packet as IQ) {
            if (iq.isRequestIQ()) {
                let iqRequest = iq
                let key = iqRequest.getChildElementQName()
                let Type = iq.getType()
                let iqRequestHandler: ?IQRequestHandler = match (Type) {
                    case IQType.set => setIqRequestHandler.get(key)
                    case IQType.get => getIqRequestHandler.get(key)
                    case _ => throw Exception("Should only encounter IQ type 'get' or 'set'")
                }
                if (iqRequestHandler.isNone()) {
                    let replyCondition: StanzaErrorCondition = match (unknownIqRequestReplyMode) {
                        case doNotReply => return
                        case replyFeatureNotImplemented => StanzaErrorCondition.feature_not_implemented
                        case replyServiceUnavailable => StanzaErrorCondition.service_unavailable
                    }

                    // If the IQ stanza is of type "get" or "set" with no registered IQ request handler, then answer an
                    // IQ of type 'error' with condition 'service-unavailable'.
                    let errorIQ = IQ.createErrorResponse(iq, StanzaError.getBuilder(replyCondition).build())
                    // Use async sendStanza() here, since if sendStanza() would block, then some connections, e.g.
                    // XmppNioTcpConnection, would deadlock, as this operation is performed in the same thread that is
                    asyncGo {
                        => try {
                            sendStanza(errorIQ)
                        } catch (e: NotConnectedException) {
                            LOGGER.warn("Exception while sending error IQ to unkown IQ request", ("exception", e))
                        }
                    }
                } else {
                    let finalIqRequestHandler = iqRequestHandler.getOrThrow()
                    let executorService: Executor = match (finalIqRequestHandler.getMode()) {
                        case IQRequestHandlerMode.sync => ASYNC_BUT_ORDERED.asExecutorFor(this)
                        case IQRequestHandlerMode.async => {runnable => this.asyncGoLimited(runnable)}
                    }
                    executorService(
                        {
                            =>
                            // It is not ideal if the IQ request handler does not return an IQ response,
                            // because RFC 6120 § 8.1.2 does specify that a response is mandatory.
                            // But some APIs, mostly the file transfer one, does not always return a result, so we need to handle this case.
                            // Also sometimes a request handler may decide that it's better to not send a response,
                            // e.g. to avoid presence leaks.
                            let response: IQ = finalIqRequestHandler.handleIQRequest(iq) ?? return ()

                            assert(response.isResponseIQ())

                            response.setTo(iqRequest.getFrom())
                            response.setStanzaId(iqRequest.getStanzaId())
                            try {
                                sendStanza(response)
                            } catch (e: NotConnectedException) {
                                LOGGER.warn("Exception while sending response to IQ request", ("exception", e))
                            }
                        }
                    )
                }
                // The following returns makes it impossible for packet listeners and collectors to
                // filter for IQ request stanzas, i.e. IQs of type 'set' or 'get'. This is the
                // desired behavior.
                return
            }
        }

        // First handle the async recv listeners. Note that this code is very similar to what follows a few lines below,
        // the only difference is that asyncRecvListeners is used here and that the packet listeners are started in
        // their own thread.
        let listenersToNotify: LinkedList<StanzaListener> = LinkedList<StanzaListener>()
        extractMatchingListeners(packet, asyncRecvListeners, asyncRecvListenersLock, listenersToNotify)
        for (listener in listenersToNotify) {
            asyncGoLimited(
                {
                => try {
                    listener.processStanza(packet)
                } catch (e: Exception) {
                    LOGGER.error("Exception in async packet listener", ("exception", e))
                }
            })
        }

        // Loop through all collectors and notify the appropriate ones.
        for (collector in collectors) {
            collector.processStanza(packet)
        }

        listenersToNotify.clear()
        extractMatchingListeners(packet, recvListeners, recvListenersLock, listenersToNotify)
        let listenerSemaphore = Semaphore(1 - listenersToNotify.size)
        for (stanzaListener in listenersToNotify) {
            asyncGoLimited(
                {
                => try {
                    stanzaListener.processStanza(packet)
                } catch (e: NotConnectedException) {
                    LOGGER.warn("Got not connected exception, aborting", ("exception", e))
                } catch (e: Exception) {
                    LOGGER.error("Exception in packet listener", ("exception", e))
                } finally {
                    listenerSemaphore.release()
                }
            })
        }
        listenerSemaphore.acquire()

        // Notify the receive listeners interested in the packet
        listenersToNotify.clear()
        extractMatchingListeners(packet, syncRecvListeners, syncRecvListenersLock, listenersToNotify)
        // Decouple incoming stanza processing from listener invocation. Unlike async listeners, this uses a single
        // threaded executor service and therefore keeps the order.
        ASYNC_BUT_ORDERED.performAsyncButOrdered(
            this,
            {
                =>
                // As listeners are able to remove themselves and because the timepoint where it is decided to invoke a
                // listener is a different timepoint where the listener is actually invoked (here), we have to check
                // again if the listener is still active.
                synchronized(syncRecvListenersLock) {
                    listenersToNotify.removeIf {
                        v =>
                        // The listener was removed from syncRecvListener, also remove him from listenersToNotify.
                        !syncRecvListeners.contains(v)
                    }
                }
                for (listener in listenersToNotify) {
                    try {
                        listener.processStanza(packet)
                    } catch (e: NotConnectedException) {
                        LOGGER.warn("Got not connected exception, aborting", ("exception", e))
                        break
                    } catch (e: Exception) {
                        LOGGER.error("Exception in packet listener", ("exception", e))
                    }
                }
            }
        )
    }

    private static func extractMatchingListeners(stanza: Stanza,
        listeners: Map<StanzaListener, AbstractXMPPConnectionListenerWrapper>, listenersLock: Monitor,
        listenersToNotify: LinkedList<StanzaListener>): Unit {
        synchronized(listenersLock) {
            for (listenerWrapper in listeners.values()) {
                if (listenerWrapper.filterMatches(stanza)) {
                    listenersToNotify.append(listenerWrapper.getListener())
                }
            }
        }
    }

    /**
     * Sets whether the connection has already logged in the server. This method assures that the
     * {@link #wasAuthenticated} flag is never reset once it has ever been set.
     *
     */
    protected func setWasAuthenticated(): Unit {
        // Never reset the flag if the connection has ever been authenticated
        if (!wasAuthenticated) {
            wasAuthenticated = authenticated
        }
    }

    protected func callConnectionConnectingListener(): Unit {
        for (listener in connectionListeners) {
            listener.connecting(this)
        }
    }

    protected func callConnectionConnectedListener(): Unit {
        for (listener in connectionListeners) {
            listener.connected(this)
        }
    }

    protected func callConnectionAuthenticatedListener(resumed: Bool): Unit {
        for (listener in connectionListeners) {
            try {
                listener.authenticated(this, resumed)
            } catch (e: Exception) {
                // Catch and print any exception so we can recover
                // from a faulty listener and finish the shutdown process
                LOGGER.error("Exception in authenticated listener", ("exception", e))
            }
        }
    }

    func callConnectionClosedListener(): Unit {
        for (listener in connectionListeners) {
            try {
                listener.connectionClosed()
            } catch (e: Exception) {
                LOGGER.error("Error in listener while closing connection", ("exception", e))
            }
        }
    }

    private func callConnectionClosedOnErrorListener(e: Exception): Unit {
        var logWarning = true
        if (let Some(see) <- e as StreamErrorException) {
            if (see.getStreamError().getCondition() == StreamErrorCondition.not_authorized && wasAuthenticated) {
                logWarning = false
                LOGGER.trace(
                    "Connection closed with not-authorized stream error after it was already authenticated. The account was likely deleted/unregistered on the server"
                )
            }
        }
        if (logWarning) {
            LOGGER.warn("Connection ${this} closed with error", ("exception", e))
        }
        for (listener in connectionListeners) {
            try {
                listener.connectionClosedOnError(e)
            } catch (e2: Exception) {
                // Catch and print any exception so we can recover
                // from a faulty listener
                LOGGER.error("Error in listener while closing connection", ("exception", e2))
            }
        }
    }

    public override func getConnectionCounter(): Int {
        return connectionCounterValue
    }

    public override func setFromMode(fromMode: XMPPConnectionFromMode): Unit {
        this.fromMode = fromMode
    }

    public override func getFromMode(): XMPPConnectionFromMode {
        return this.fromMode
    }

    protected func parseFeatures(parser: XmlPullParser): Unit {
        streamFeatures.clear()
        let initialDepth = parser.getDepth()
        while (true) {
            let eventType = parser.next()
            if (eventType == XmlPullParserEvent.START_ELEMENT && parser.getDepth() == initialDepth + 1) {
                var streamFeature: ?FullyQualifiedElement = None
                let name = parser.getName()
                let namespace = parser.getNamespace()
                match (name) {
                    case v where v == StartTls.ELEMENT => streamFeature = PacketParserUtils.parseStartTlsFeature(parser)
                    case v where v == Mechanisms.ELEMENT => streamFeature = Mechanisms(
                        PacketParserUtils.parseMechanisms(parser))
                    case v where v == Bind.ELEMENT => streamFeature = BindFeature.INSTANCE
                    case v where v == Session.ELEMENT => streamFeature = PacketParserUtils.parseSessionFeature(parser)
                    case v where v == CompressFeature.ELEMENT => streamFeature = parseCompressionFeature(parser)
                    case _ =>
                        let provider = ProviderManager.getStreamFeatureProvider(name, namespace)
                        if (let Some(provider) <- provider) {
                            streamFeature = provider.parse(parser, incomingStreamXmlEnvironment)
                        }
                }
                if (streamFeature.isSome()) {
                    addStreamFeature(streamFeature.getOrThrow())
                }
            } else if (eventType == XmlPullParserEvent.END_ELEMENT && parser.getDepth() == initialDepth) {
                break
            }
        }
    }

    public func parseFeaturesAndNotify(parser: XmlPullParser): Unit {
        parseFeatures(parser)

        if (hasFeature(Mechanisms.ELEMENT, Mechanisms.NAMESPACE)) {
            // Only proceed with SASL auth if TLS is disabled or if the server doesn't announce it
            if (!hasFeature(StartTls.ELEMENT, StartTls.NAMESPACE) || config.getSecurityMode() ==
                ConnectionConfigurationSecurityMode.disabled) {
                saslFeatureReceived = true
                tlsHandled = true
                notifyWaitingThreads()
            }
        }

        // If the server reported the bind feature then we are that that we did SASL and maybe
        // STARTTLS. We can then report that the last 'stream:features' have been parsed
        if (hasFeature(Bind.ELEMENT, Bind.NAMESPACE)) {
            if (!hasFeature(CompressFeature.ELEMENT, Compress.NAMESPACE) || !config.isCompressionEnabled()) {
                // This where the last stream features from the server,
                // either it did not contain compression or we disabled it.
                lastFeaturesReceived = true
                notifyWaitingThreads()
            }
        }
        afterFeaturesReceived()
    }

    protected open func afterFeaturesReceived(): Unit {
        // Default implementation does nothing
    }

    public override func getFeature(qname: QName): ?FullyQualifiedElement {
        return streamFeatures.get(qname)
    }

    public override func hasFeature(qname: QName): Bool {
        return streamFeatures.contains(qname)
    }

    protected func addStreamFeature(feature: FullyQualifiedElement): Unit {
        let key = feature.getQName()
        streamFeatures.put(key, feature)
    }

    public override func sendIqRequestAsync(request: IQ): XmppFuture<IQ, Exception> {
        return sendIqRequestAsync(request, getReplyTimeout())
    }

    public override func sendIqRequestAsync(request: IQ, timeout: Duration): XmppFuture<IQ, Exception> {
        let replyFilter: StanzaFilter = IQReplyFilter(request, this.getUser(), this.getXMPPServiceDomain())
        return sendAsyncGeneric(request, replyFilter, timeout)
    }

    public override func sendAsync(stanza: Stanza, replyFilter: StanzaFilter): XmppFuture<Stanza, Exception> {
        return sendAsync(stanza, replyFilter, getReplyTimeout())
    }

    public override func sendAsync(
        stanza: Stanza,
        replyFilter: StanzaFilter,
        timeout: Duration
    ): XmppFuture<Stanza, Exception> {
        sendAsyncGeneric(stanza, replyFilter, timeout)
    }

    public func sendAsyncGeneric<S>(
        stanza: Stanza,
        replyFilter: StanzaFilter,
        timeout: Duration
    ): XmppFuture<S, Exception> where S <: Stanza {
        Objects.requireNonNull(stanza, "stanza must not be null")
        // While Xmpp allows to add PacketListeners with a PacketFilter value of 'null', we
        // disallow it here in the async API as it makes no sense
        Objects.requireNonNull(replyFilter, "replyFilter must not be null")

        let future = InternalXmppFuture<S, Exception>()
        let stanzaListener: StanzaListener = SimpleStanzaListener {
            stanza, stanzaListener =>
            let removed = removeAsyncStanzaListener(stanzaListener)
            if (!removed) {
                // We lost a race against the "no response" handling runnable. Avoid calling the callback, as the
                // exception callback will be invoked (if any).
                return
            }
            try {
                XMPPErrorException.ifHasErrorThenThrow(stanza)
                let s = (stanza as S).getOrThrow()
                future.setResult(s)
            } catch (exception: XMPPErrorException) {
                future.setException(exception)
            }
        }
        schedule(
            {
                =>
                let removed = removeAsyncStanzaListener(stanzaListener)
                if (!removed) {
                    // We lost a race against the stanza listener, he already removed itself because he received a
                    // reply. There is nothing more to do here.
                    return
                }

                // If the packetListener got removed, then it was never run and
                // we never received a response, inform the exception callback
                let exception: Exception = if (!isConnected()) {
                    // If the connection is no longer connected, throw a not connected exception.
                    NotConnectedException(this, replyFilter)
                } else {
                    NoResponseException.newWith(this, replyFilter)
                }
                future.setException(exception)
            },
            timeout
        )

        addAsyncStanzaListener(stanzaListener, replyFilter)
        let sendOperation: Runnable = {
            => try {
                sendStanza(stanza)
            } catch (exception: NotConnectedException) {
                future.setException(exception)
            }
        }
        if (XmppConfiguration.TRUELY_ASYNC_SENDS) {
            Async.go(sendOperation)
        } else {
            sendOperation()
        }
        return future
    }

    public override func addOneTimeSyncCallback(callback: StanzaListener, packetFilter: StanzaFilter): Unit {
        let packetListener: StanzaListener = SimpleStanzaListener {
            packet, stanzaListener => try {
                callback.processStanza(packet)
            } finally {
                removeSyncStanzaListener(stanzaListener)
            }
        }
        addSyncStanzaListener(packetListener, packetFilter)
        schedule({=> removeSyncStanzaListener(packetListener)}, getReplyTimeout())
    }

    public override func registerIQRequestHandler(iqRequestHandler: IQRequestHandler): ?IQRequestHandler {
        let key = iqRequestHandler.getQName()
        match (iqRequestHandler.getType()) {
            case IQType.set => setIqRequestHandler.put(key, iqRequestHandler)
            case IQType.get => getIqRequestHandler.put(key, iqRequestHandler)
            case _ => throw IllegalArgumentException("Only IQ type of 'get' and 'set' allowed")
        }
    }

    public override func unregisterIQRequestHandler(iqRequestHandler: IQRequestHandler): ?IQRequestHandler {
        return unregisterIQRequestHandler(iqRequestHandler.getElement(), iqRequestHandler.getNamespace(),
            iqRequestHandler.getType())
    }

    public override func unregisterIQRequestHandler(element: String, namespace: String, Type: IQType): ?IQRequestHandler {
        let key = QName(namespace, element)
        match (Type) {
            case IQType.set => setIqRequestHandler.remove(key)
            case IQType.get => getIqRequestHandler.remove(key)
            case _ => throw IllegalArgumentException("Only IQ type of 'get' and 'set' allowed")
        }
    }

    private var lastStanzaReceived: Duration = Duration.Zero

    public override func getLastStanzaReceived(): Duration {
        return lastStanzaReceived
    }

    /**
     * Get the timestamp when the connection was the first time authenticated, i.e., when the first successful login was
     * performed. Note that this value is not reset on disconnect, so it represents the timestamp from the last
     * authenticated connection. The value is also not reset on stream resumption.
     *
     * @return the timestamp or {@code null}.
     */
    public func getAuthenticatedConnectionInitiallyEstablishedTimestamp(): Duration {
        return authenticatedConnectionInitiallyEstablishedTimestamp
    }

    /**
     * Install a parsing exception callback, which will be invoked once an exception is encountered while parsing a
     * stanza.
     *
     * @param callback the callback to install
     */
    public func setParsingExceptionCallback(callback: ParsingExceptionCallback): Unit {
        parsingExceptionCallback = callback
    }

    /**
     * Get the current active parsing exception callback.
     *
     * @return the active exception callback or null if there is none
     */
    public func getParsingExceptionCallback(): ParsingExceptionCallback {
        return parsingExceptionCallback
    }

    public func toString(): String {
        let localEndpoint: ?EntityFullJid = getUser()
        let localEndpointString: String = localEndpoint?.toString() ?? "not-authenticated"
        return "${getClass()}[${localEndpointString}] (${getConnectionCounter()})"
    }

    /**
     * A queue of deferred runnables that where not executed immediately because {@link #currentAsyncRunnables} reached
     * {@link #maxAsyncRunnables}. Note that we use a {@code LinkedList} in order to avoid space blowups in case the
     * list ever becomes very big and shrinks again.
     */
    private let deferredAsyncRunnables: LinkedList<() -> Unit> = LinkedList()
    private let deferredAsyncRunnablesLock = Monitor()

    private var deferredAsyncRunnablesCount: Int = 0

    private var deferredAsyncRunnablesCountPrevious: Int = 0

    private var maxAsyncRunnables = XmppConfiguration.getDefaultConcurrencyLevelLimit()

    private var currentAsyncRunnables: Int = 0

    protected func asyncGoLimited(runnable: Runnable): Unit {
        let wrappedRunnable: Runnable = {
            =>
            runnable()

            synchronized(deferredAsyncRunnablesLock) {
                let defferredRunnable: ?Runnable = deferredAsyncRunnables.popFirst()
                if (let Some(v) <- defferredRunnable) {
                    deferredAsyncRunnablesCount--
                    asyncGo(v)
                } else {
                    currentAsyncRunnables--
                }
            }
        }

        synchronized(deferredAsyncRunnablesLock) {
            if (currentAsyncRunnables < maxAsyncRunnables) {
                currentAsyncRunnables++
                asyncGo(wrappedRunnable)
            } else {
                deferredAsyncRunnablesCount++
                deferredAsyncRunnables.append(wrappedRunnable)
            }

            let HIGH_WATERMARK = 100
            let INFORM_WATERMARK = 20
            let deferredAsyncRunnablesCount = this.deferredAsyncRunnablesCount

            if (deferredAsyncRunnablesCount >= HIGH_WATERMARK && deferredAsyncRunnablesCountPrevious < HIGH_WATERMARK) {
                LOGGER.warn("High watermark of ${HIGH_WATERMARK} simultaneous executing runnables reached")
            } else if (deferredAsyncRunnablesCount >= INFORM_WATERMARK && deferredAsyncRunnablesCountPrevious <
                INFORM_WATERMARK) {
                LOGGER.info("${INFORM_WATERMARK} simultaneous executing runnables reached")
            }
            deferredAsyncRunnablesCountPrevious = deferredAsyncRunnablesCount
        }
    }

    public func setMaxAsyncOperations(maxAsyncOperations: Int): Unit {
        if (maxAsyncOperations < 1) {
            throw IllegalArgumentException("Max async operations must be greater than 0")
        }
        synchronized(deferredAsyncRunnablesLock) {
            maxAsyncRunnables = maxAsyncOperations
        }
    }

    public static func asyncGo(runnable: Runnable): Unit {
        CACHED_EXECUTOR_SERVICE(runnable)
    }

    protected func getReactor(): XmppReactor {
        return XMPP_REACTOR
    }

    protected static func schedule(runnable: Runnable, delay: Duration): ScheduledAction {
        return XMPP_REACTOR.schedule(runnable, delay, ScheduledActionKind.NonBlocking)
    }

    public func onStreamOpen(parser: XmlPullParser): Unit {
        // We found an opening stream.
        if (parser.getNamespace(None) == "jabber:client") {
            streamId = parser.getAttributeValue("", "id")
            incomingStreamXmlEnvironment = XmlEnvironment.froms(parser)
            // RFC 6120 § 4.7.1. makes no explicit statement whether or not 'from' in the stream
            // open from the server in c2s connections is required or not.
            let reportedServerDomainString = parser.getAttributeValue("", "from") ?? return ()
            try {
                let reportedServerDomain = JidCreate.domainBareFrom(reportedServerDomainString)
                let configuredXmppServiceDomain = config.getXMPPServiceDomain()
                if (configuredXmppServiceDomain != reportedServerDomain) {
                    LOGGER.warn(
                        "Domain reported by server '${reportedServerDomain}' does not match configured domain '${configuredXmppServiceDomain}'"
                    )
                }
            } catch (e: XmppStringprepException) {
                LOGGER.warn(
                    "XMPP service domain '${reportedServerDomainString}' as reported by server could not be transformed to a valid JID",
                    ("exception", e)
                )
            }
        }
    }

    protected func sendStreamOpen(): Unit {
        // If possible, provide the receiving entity of the stream open tag, i.e. the server, as much information as
        // possible. The 'to' attribute is *always* available. The 'from' attribute if set by the user and no external
        // mechanism is used to determine the local entity (user). And the 'id' attribute is available after the first
        // response from the server (see e.g. RFC 6120 § 9.1.1 Step 2.)
        let to = getXMPPServiceDomain().toString()
        var comefrom: ?String = None
        let localpart = config.getUsername()
        if (localpart.size > 0) {
            comefrom = XmppStringUtils.completeJidFrom(localpart, to)
        }
        let id = getStreamId()

        let streamOpen = StreamOpen(to, comefrom, id, config.getXmlLang(), StreamOpenStreamContentNamespace.client)
        sendNonza(streamOpen)

        let xmlEnvironmentBuilder = XmlEnvironment.builder()
        xmlEnvironmentBuilder.withs(streamOpen)
        outgoingStreamXmlEnvironment = xmlEnvironmentBuilder.build()
    }

    protected func getXmppTlsContext(): XmppTlsContext {
        return config.xmppTlsContext
    }

    public static func getClassId(): ClassId {
        "AbstractXmppConnection"
    }
    public open operator override func ==(that: XMPPConnection): Bool {
        match (that) {
            case v: AbstractXMPPConnection => refEq(this, v)
            case _ => false
        }
    }
    private var cachedHash: ?Int = None
    public open override func hashCode(): Int {
        if (let Some(cachedHash) <- cachedHash) {
            cachedHash
        } else {
            let v = RandomUtil.nextSecureRandomInt()
            cachedHash = v
            v
        }
    }
}

public enum SyncPointState <: Equatable<SyncPointState> {
    | initial
    | request_sent
    | successful

    public operator override func ==(other: SyncPointState): Bool {
        match ((this, other)) {
            case (initial, initial) => true
            case (request_sent, request_sent) => true
            case (successful, successful) => true
            case _ => false
        }
    }
}

/**
 * A wrapper class to associate a stanza filter with a listener.
 */
public class AbstractXMPPConnectionListenerWrapper {
    private let packetListener: StanzaListener
    private let packetFilter: ?StanzaFilter

    /**
     * Create a class which associates a stanza filter with a listener.
     *
     * @param packetListener the stanza listener.
     * @param packetFilter the associated filter or null if it listen for all packets.
     */
    public init(packetListener: StanzaListener, packetFilter: ?StanzaFilter) {
        this.packetListener = packetListener
        this.packetFilter = packetFilter
    }

    public func filterMatches(packet: Stanza): Bool {
        return packetFilter?.accept(packet) ?? true
    }

    public func getListener(): StanzaListener {
        return packetListener
    }
}

/**
 * A wrapper class to associate a stanza filter with an interceptor.
 */
class AbstractXMPPConnectionInterceptorWrapper {
    /**
     * Create a class which associates a stanza filter with an interceptor.
     *
     * @param packetInterceptor the interceptor.
     * @param packetFilter the associated filter or null if it intercepts all packets.
     */
    public AbstractXMPPConnectionInterceptorWrapper(
        let packetInterceptor: StanzaListener,
        let packetFilter: ?StanzaFilter
    ) {}

    public func filterMatches(packet: Stanza): Bool {
        return packetFilter?.accept(packet) ?? true
    }

    public func getInterceptor(): StanzaListener {
        return packetInterceptor
    }
}

class GenericInterceptorWrapper<MPB, MP> where MPB <: MessageOrPresenceBuilder, MP <: MessageOrPresence {
    private let stanzaInterceptor: Consumer<MPB>
    private let stanzaFilter: ?Predicate<MP>

    init(stanzaInterceptor: Consumer<MPB>, stanzaFilter: ?Predicate<MP>) {
        this.stanzaInterceptor = stanzaInterceptor
        this.stanzaFilter = stanzaFilter
    }

    public func filterMatches(stanza: MP): Bool {
        return stanzaFilter?.test(stanza) ?? true
    }

    public func getInterceptor(): Consumer<MPB> {
        return stanzaInterceptor
    }
}

public class HashableConsumer<T> <: Hashable & Equatable<HashableConsumer<T>> {
    let lock = Monitor()

    public HashableConsumer(let _accept: (T) -> Unit) {}

    public func accept(t: T) {
        _accept(t)
    }

    public override func hashCode(): Int {
        0
    }

    public operator override func ==(that: HashableConsumer<T>): Bool {
        refEq(this, that)
    }

    func getConcumer(): Consumer<T> {
        _accept
    }
}
