/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * 这个抽象类通常用作诸如TCP和BOSH等XMPP连接机制的超类。
 * 它提供了用于连接状态管理的一系列方法，这些方法在连接的不同阶段发挥作用，具体如下：
 * - {@link #connect()}：用于建立连接的相关操作。
 * - {@link #login()}：处理登录相关的流程。
 * - {@link #disconnect()}：负责断开连接的操作。
 * 需要注意的是，这些方法特意未由{@link XMPPConnection}接口提供。
 *
 * <p><b>注意：</b> Xmpp文档的默认入口点是{@link XMPPConnection}。
 * 如果您刚开始接触Xmpp，建议先查阅{@link XMPPConnection}相关内容，然后再回到此处深入了解本类的相关细节。</p>
 *
 * <h2>解析异常</h2>
 * <p>
 * 在Xmpp的运行过程中，如果一个Xmpp解析器（也可称为提供者）抛出异常，
 * 这些异常会被传递给{@link ParsingExceptionCallback}进行处理。
 * 解析器抛出异常的常见原因是接收到了非法输入，
 * 例如，在程序逻辑中只允许输入整数的情况下，却接收到了非数字字符串。
 * Xmpp的<em>默认行为</em>遵循< b >“默认严格失败”</b>原则，
 * 这意味着一旦出现解析异常，将会导致连接直接终止。
 * 之所以选择这样的默认行为，是为了让用户能够意识到他们需要自行配置回调机制，
 * 并妥善处理这些异常情况，以避免连接意外断开。
 * 处理解析异常的方式可以很简单，比如使用一个不抛出异常的空操作回调。
 * 采用这种回调方式时，当遇到有问题的流元素，会将其从流中移除，
 * 此时Xmpp的表现就如同从未接收到那个有问题的元素一样。
 * </p>
 * <p>
 * 如果解析异常是因为Xmpp接收到了非法输入而引发的，
 * 那么请考虑将此情况告知源实体的作者，以便他们能够对输入数据进行检查和修正。
 * 如果异常是由于Xmpp解析器自身存在漏洞而抛出的，
 * 那么请考虑向Xmpp项目提交一个漏洞报告，帮助开发团队修复问题，提升软件质量。
 * </p>
 *
 * <h3>管理解析异常回调</h3>
 * <p>
 * “默认严格失败”的行为是通过使用
 * {@link xmpp4cj.parsing.ExceptionThrowingCallbackWithHint}作为默认解析异常回调来实现的。
 * 如果您希望改变这种默认行为，可以使用
 * {@link #setParsingExceptionCallback(ParsingExceptionCallback)}方法来设置一个新的回调。
 * 另外，还可以通过
 * {@link xmpp4cj.XmppConfiguration#setDefaultParsingExceptionCallback(ParsingExceptionCallback)}方法
 * 来设置整个项目的默认回调。
 * </p>
 */
public abstract class AbstractXMPPConnection <: XMPPConnection & ClassIdentify {
    private static let LOGGER = getGlobalLogger(("name", "AbstractXMPPConnection"))

    protected static let XMPP_REACTOR: XmppReactor = XmppReactor.getInstance()

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
     * 创建到XMPP服务器的新XMPPConnection。
     *
     * @param configuration 用于建立连接的配置。
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
        // 安装SASL（Simple Authentication and Security Layer，简单认证与安全层）Nonza回调。
        // SASL是一种用于网络协议中进行身份验证和安全通信的框架，这里的Nonza可能是指与SASL相关的特定类型的回调处理机制，具体取决于上下文。
        buildNonzaCallback()
            .listenFor(
                "SaslNonzaChallenge",
                {
                    c => try {
                        let challenge = (c as SaslNonzaChallenge).getOrThrow()
                        auth.challengeReceived(challenge)
                    } catch (e: Xmpp4cjException) {
                        auth.authenticationFailed(e)
                    }
                }
            )
            .listenFor(
                "SaslNonzaSuccess",
                {
                    s => try {
                        let success = (s as SaslNonzaSuccess).getOrThrow()
                        auth.authenticated(success)
                    } catch (e: XmppSaslException | NotConnectedException) {
                        auth.authenticationFailed(e)
                    }
                }
            )
            .listenFor(
                "SaslNonzaSASLFailure",
                {f => auth.authenticationFailed((f as SaslNonzaSASLFailure).getOrThrow())}
            )
            .install()

        let debuggerFactory = config.getDebuggerFactory()
        debugger = debuggerFactory?.create(this)

        // 通知侦听器已建立新连接
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
        //默认实现，如方法文档中所述，可以回退到sendStanza（）。
        //可能被子类覆盖。
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
        //默认实现，如方法文档中所述，可以回退到sendStanza（）。
        //可能被子类覆盖。
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
            // 检查是否尚未连接
            throwAlreadyConnectedExceptionIfAppropriate()
            // 通知连接侦听器我们正在尝试连接
            callConnectionConnectingListener()
            // 重置连接状态
            initState()
            closingStreamReceived = false
            streamId = None

            try {
                // 执行与XMPP服务的实际连接
                connectInternal()
                // 如果需要TLS但服务器不提供，请断开连接
                // 从服务器发送并抛出错误。首先检查我们是否已经协商了TLS
                // 并且是安全的（在建立TLS后第二次解析特征）。
                if (!isSecureConnection() && getConfiguration().getSecurityMode() == ConnectionConfigurationSecurityMode
                    .required) {
                    throw SecurityRequiredByClientException()
                }
            } catch (e: Xmpp4cjException | IOException | XMPPException) {
                LOGGER.log(LogLevel.WARN, "AbstractXMPPConnection.connect", e)
                instantShutdown()
                throw e
            }
            // 如果connectInternal（）没有抛出，那么现在必须将此连接标记为已连接。
            assert(connected)
            callConnectionConnectedListener()
            return this
        }
    }

    /**
     * XMPPConnection的具体子类需要实现的抽象方法来执行它们的XMPP连接建立方式。
     * 如果记录了之前的连接状态（经过身份验证），则需要实现自动登录。
     *
     * @throws Xmpp4cjException 如果Xmpp检测到异常情况。
     * @throws IOException 如果发生I/O错误。
     * @throws XMPPException 如果收到XMPP协议错误。
     * @throws InterruptedException 如果调用线程被中断。
     */
    protected func connectInternal(): Unit

    private var usedUsername: ?String = None
    private var usedPassword: ?String = None

    /**
     * 用于此连接的资源部分。如果它为None或被XMPP服务覆盖，则可能不是结果资源部分。
     */
    private var usedResource: ?Resourcepart = None

    /**
     * 使用服务器支持的最强SASL机制登录到服务器。
     * 如果在身份验证过程的每一步中超过连接的默认节超时，而服务器没有响应，则将抛出{@link Xmpp4cjException.NoResponseException}。
     * <p>
     * 在登录（即身份验证）到服务器之前，必须通过调用{@link#connect}来连接连接。
     * <p>
     * <p>
     * 通过使用{@link ConnectionConfiguration.Builder#setSendPresence（boolean）}，可以在不发送初始可用状态的情况下登录。
     * 最后，如果你想在使用SASL时不传递密码，而是使用更高级的机制，那么你可能会对使用{@link ConnectionConfiguration.Builder#setcallback Handler（callback Handler）}感兴趣。
     * 有关更高级的登录设置，请参阅｛@link ConnectionConfiguration｝。
     * <p>
     *
     * @throws XMPPException 如果XMPP协议级别发生错误。
     * @throws Xmpp4cjException 如果在XMPP协议级别之外的其他地方发生错误。
     * @throws IOException 如果在登录过程中发生I/O错误。
     * @throws InterruptedException 如果调用线程被中断。
     */
    public func login(): Unit {
        // 以前使用的用户名、密码和资源优先于
        // 连接配置中的
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
     * 与{@link#login(String, String, ?Resourcepart)}相同，但从连接配置中获取资源。
     *
     * @param username 用户名
     * @param password 密码
     * @throws XMPPException 如果收到XMPP协议错误。
     * @throws Xmpp4cjException 如果Xmpp检测到异常情况。
     * @throws IOException 如果发生I/O错误。
     * @throws InterruptedException 如果调用线程被中断。
     * @see #login
     */
    public func login(username: String, password: String): Unit {
        synchronized(this.lock) {
            login(username, password, config.getResource())
        }
    }

    /**
     * 使用给定的用户名（授权标识）登录。
     * 如果使用回调处理程序，则可以省略密码。
     * 如果资源为空，则服务器将生成一个。
     *
     * @param username 用户名
     * @param password 密码
     * @param resource 资源
     * @throws XMPPException 如果收到XMPP协议错误。
     * @throws Xmpp4cjException 如果Xmpp检测到异常情况。
     * @throws IOException 如果发生I/O错误。
     * @throws InterruptedException 如果调用线程被中断。
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
        match (exception) {
            case v: Xmpp4cjException => currentXmpp4cjException = v
            case v: XMPPException => currentXmppException = v
            case _ => currentXmpp4cjException = XmppWrappedException(exception)
        }
        notifyWaitingThreads()
    }

    /**
     * 我们为{@link#notifyWaitingThreads（）}和{@link#waitFor（Supplier）}使用了一个额外的对象，因为连接的所有状态更改方法都是使用连接实例作为监视器同步的。
     * 如果我们现在也使用内部进程的连接实例来等待条件，那么{@link Object#wait（）}将在等待时离开监视器，这将允许对状态更改函数的另一个潜在调用继续进行。
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
        // 如果没有连接异常，并且我们仍然没有成功等待条件成立，那么我们遇到了无响应超时。
        if (!success) {
            throw NoResponseException.newWith(this, waitFor)
        }
        // 否则，我们成功地等待了条件。
    }

    public func bindResourceAndEstablishSession(resource: ?Resourcepart): ?Resourcepart {
        // 等待以下任一时间：
        //- 服务器上一个特征节已被解析
        //- 超时发生
        LOGGER.trace("Waiting for last features to be received before continuing with resource binding")
        waitForConditionOrThrowConnectionException({=> lastFeaturesReceived},
            "last stream features received from server")

        if (!hasFeature(Bind.ELEMENT, Bind.NAMESPACE)) {
            // 服务器从未提供资源绑定，根据RFC6120 7.2，XMPP客户端和服务器实现中需要资源绑定。
            throw ResourceBindingNotOfferedException()
        }
        // 资源绑定，请参见RFC6120 7。
        // 请注意，我们不能在这里使用IQReplyFilter，因为用户的完整JID还不可用。
        // 成功绑定资源后，它将立即可用。
        let bindResource = Bind.newSet(resource)
        var packetCollector = createStanzaCollectorAndSend(StanzaIdFilter(bindResource), bindResource)
        let response: Bind = (packetCollector.nextResultOrThrow() as Bind).getOrThrow()
        // 将连接用户设置为资源绑定的结果。
        // 重要的是，我们不要从login（）参数和配置服务名称推断用户，例如，当使用SASL External时，用户名不是用于登录的，而是从“external”证书中获取的。
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
        // 表示我们现在已通过身份验证。
        this.authenticated = true

        // 如果启用了调试，请更改调试窗口标题，以包含我们现在登录的名称。
        // 如果在创建连接后将debug设置为true，则调试器将为None
        debugger?.userHasLogged(user.getOrThrow())
        callConnectionAuthenticatedListener(resumed)

        // 将在线状态设置为在线。需要注意的是，这一步操作必须在调用callConnectionAuthenticatedListener()之后进行，
        // 因为该调用最终也会加载联系人列表（roster）。并且我们应该在发送初始在线状态之前先加载联系人列表。
        if (config.isSendPresence() && !resumed) {
            let availablePresence = getStanzaFactory().buildPresenceStanza().ofType(PresenceType.available).build()
            sendStanza(availablePresence)
        }
    }

    public override func isAnonymous(): Bool {
        return isAuthenticated() && getUsedSaslMechansism() == SASLAnonymous.NAME
    }

    /**
     * 获取用于对此连接进行身份验证的SASL机制的名称。
     * 这将返回上次对此连接进行身份验证时使用的机制的名称，如果此连接之前未经过身份验证，则将返回<code>None</code>。
     *
     * @return 所用SASL机制的名称。
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
        // 为即将发送的新节调用拦截器。拦截器可以修改节的内容。
        let stanzaAfterInterceptors = firePacketInterceptors(stanza)
        sendStanzaInternal(stanzaAfterInterceptors)
    }

    /**
     * 对连接进行身份验证。
     *
     * @param username 正在与服务器进行身份验证的用户名。
     * @param password 发送到服务器的密码。
     * @param authzid 授权标识符（通常为空）。
     * @param sslSession 可选SSL/TLS会话（如果已建立）
     * @return 使用过的SASL机制。
     * @throws XMPPErrorException 如果返回XMPP错误。
     * @throws SASLErrorException 如果返回SASL协议错误。
     * @throws IOException 如果发生I/O错误。
     * @throws InterruptedException 如果调用线程被中断。
     * @throws XmppSaslException 如果发生特定于SASL的错误。
     * @throws NotConnectedException 如果XMPP连接未连接。
     * @throws NoResponseException 如果远程实体没有响应。
     * @throws XmppWrappedException 在发生异常时。
     * @see SASLAuthentication#authenticate(String, String, EntityBareJid, TlsSession )
     */
    public func authenticate(username: String, password: String, authzid: ?EntityBareJid, sslSession: ?TlsSession): SASLMechanism {
        let saslMechanism = saslAuthentication().authenticate(username, password, authzid, sslSession)
        afterSaslAuthenticationSuccess()
        return saslMechanism
    }

    /**
     * SASL身份验证成功后，立即为子类设置钩子。RFC 6120 § 6.4.6。指定在这种情况下发起实体需要发起新流的。但有些运输工具，如BOSH，需要特殊处理。
     * <p>
     * 请注意，我们不能在这里重置XMPPTCPConnection的解析器，因为此方法是由调用{@link#login（）}的线程调用的，但解析器重置必须在读取器线程内完成。
     * <p>
     *
     * @throws NotConnectedException 如果XMPP连接未连接。
     * @throws InterruptedException 如果调用线程被中断。
     * @throws XmppWrappedException 在发生异常时抛出。
     */
    protected func afterSaslAuthenticationSuccess(): Unit {
        sendStreamOpen()
    }

    protected func isSaslAuthenticated(): Bool {
        return saslAuthentication().authenticationSuccessful()
    }

    /**
     * 通过将存在设置为不可用，然后关闭与XMPP服务器的连接来关闭连接。
     * XMPPConnection仍然可以用于再次连接到服务器。
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
     * 关闭连接。向服务器发送自定义不可用状态，然后关闭流。
     * XMPPConnection仍然可以用于再次连接到服务器。
     * 自定义不可用状态对于传达离线状态信息（如“度假”）很有用。
     * 通常，只有状态节的状态文本设置了在线信息，但大多数XMPP服务器将提供完整的状态节以及设置的任何数据。
     *
     * @param unavailablePresence 是关机期间要发送的可选状态节。
     * @throws NotConnectedException 如果XMPP连接未连接。
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
     * 发送连接出错的通知并关闭连接。
     *
     * @param exception 导致连接关闭事件的异常。
     */
    public func notifyConnectionError(exception: Exception): Unit {
        synchronized(notifyConnectionErrorMonitor) {
            if (!isConnected()) {
                LOGGER.info("Connection was already disconnected when attempting to handle ${exception}",
                    ("exception", exception))
                return
            }

            // 注意，我们首先必须设置当前的连接异常并通知正在等待的线程，因为其中一个等待线程可能持有实例锁，
            // 而我们在稍后调用instantShutdown()时也需要该实例锁。
            setCurrentConnectionExceptionAndNotify(exception)

            // 临时关闭连接。如果该连接支持流管理，那么就有可能重新建立连接。需要注意的是，例如XMPPTCPConnection的连接监听器在遇到异常是StreamErrorException的情况下，将会丢弃流管理（SM）状态。
            instantShutdown()

            for (collector in collectors) {
                collector.notifyConnectionError(exception)
            }
            Async.go(
                {
                    =>
                    // 将该错误通知给连接监听器。
                    callConnectionClosedOnErrorListener(exception)
                },
                "${this} callConnectionClosedOnErrorListener()"
            )
        }
    }

    /**
     * 执行连接的不干净断开和关闭。不发送结束流节。
     */
    public func instantShutdown(): Unit

    /**
     * 关闭当前连接。
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
        // 在发送数据包之前创建数据包收集器。
        let packetCollector = createStanzaCollectorAndSend(packetFilter, packet)
        return packetCollector
    }

    public override func createStanzaCollectorAndSend(packetFilter: StanzaFilter, packet: Stanza): StanzaCollector {
        let configuration = StanzaCollector.newConfiguration().setStanzaFilter(packetFilter).setRequest(packet)
        // 在发送数据包之前创建数据包收集器。
        let packetCollector = createStanzaCollector(configuration)
        try {
            // 现在由于数据包收集器已经创建好，我们可以发送数据包了。
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
        // 将收集器添加到活动收集器列表中。
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

    public override func addSyncStanzaListener(packetListener: StanzaListener, packetFilter: ?StanzaFilter): Unit {
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
     * 处理所有节侦听器以发送节.
     * <p>
     * 与{@link#firePacketInterceptors（Stanza）}相比，侦听器将在新线程中被调用
     * </p>
     *
     * @param sendTopLevelStreamElement 刚刚发送的TopLevelStreamElement
     */
    public func fireElementSendingListeners(sendTopLevelStreamElement: TopLevelStreamElement): Unit {
        debugger?.onOutgoingStreamElement(sendTopLevelStreamElement)

        let packet = (sendTopLevelStreamElement as Stanza) ?? return
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
        // 在一个新线程中进行通知，因为我们可以（这么做）。
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

        // 如果没有拦截器，就避免将节（stanza，在XMPP等协议中用于表示消息单元）转换为构建器。
        if (interceptorsToInvoke.isEmpty()) {
            return tempmessageOrPresence
        }
        let builder = (tempmessageOrPresence.asBuilder() as MPB).getOrThrow()
        for (interceptor in interceptorsToInvoke) {
            interceptor(builder)
        }

        // 既然拦截器（很可能）已经以构建器的形式修改了节（stanza，在类似XMPP等协议里表示消息单元的一种结构），我们就需要重新组装它。
        tempmessageOrPresence = (builder.build() as MP).getOrThrow()
        return tempmessageOrPresence
    }

    /**
     * 处理拦截器相关操作。拦截器可能会修改即将要发送的节（stanza，在相关协议中表示消息单元）。
     * 由于请求发送节的线程会调用所有拦截器，所以拦截器尽快完成其工作非常重要，
     * 这样该线程才不会长时间处于阻塞状态。
     *
     * @param packet 将要发送到服务器的节。
     * @return 在运行拦截器之后，可能已被修改过的节。
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
        let stanzaAfterInterceptors: Stanza = match (packet) {
            case message: Message => fireMessageOrPresenceInterceptors(message, messageInterceptors,
                messageInterceptorsLock)
            case presence: Presence => fireMessageOrPresenceInterceptors(presence, presenceInterceptors,
                presenceInterceptorsLock)
            case _ =>
                // 我们（目前）还不支持针对IQ节（stanza，在相关协议里类似消息单元的一种结构，这里特指IQ类型的）的拦截器。
                assert(packet is IQ)
                packet
        }
        return stanzaAfterInterceptors
    }

    /**
     * 初始化{@link #debugger}。你可以通过将系统属性 <code>xmpp.debuggerClass</code> 设置为相应的实现类，来指定一个自定义的{@link XmppDebugger}。

     * @throws IllegalStateException 如果读取器（reader）或写入器（writer）尚未初始化，则抛出此异常。
     * @throws IllegalArgumentException 如果无法加载{@link XmppDebugger}，则抛出此异常。
     */
    protected func initDebugger(): Unit {
        if (reader.isNone() || writer.isNone()) {
            throw NoneValueException("Reader or writer isn't initialized.")
        }
        // 如果调试功能已启用，我们将打开一个窗口并输出所有网络流量信息。
        if (let Some(debugger) <- debugger) {
            // 从现有的调试器中获取新的读取器和写入器。
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
     * 设置当接收到一个未知的IQ请求时，Xmpp的行为方式。
     *
     * @param unknownIqRequestReplyMode 回复模式。
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
        synchronized(nonzaCallbacksMap.lock) {
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
     * 在一个节（stanza，在相关协议中表示消息单元之类的结构）被完全解析之后对其进行处理，处理方式是通过遍历已安装的节收集器和监听器，
     * 并让它们检查该节，以查看它们是否与过滤器匹配。

     * @param stanza 要处理的节。
     * @throws InterruptedException 如果调用线程被中断，则抛出此异常。
     */
    protected open func processStanza(stanza: Stanza): Unit {
        maybeNotifyDebuggerAboutIncoming(stanza)
        lastStanzaReceived = DateTime.now().toUnixTimeStamp()
        // 将传入的数据包传递给监听器。
        invokeStanzaCollectorsAndNotifyRecvListeners(stanza)
    }

    /**
     * 针对每个节收集器（StanzaCollector），使用给定的数据包调用{@link StanzaCollector#processStanza(Stanza)}方法。
     * 同时，使用匹配的节过滤器将该数据包通知给接收监听器。
     * <p>
     * 此方法将由处理传入数据的连接线程调用，该线程可能会在多个连接之间共享，
     * 因此，此方法不能调用任何用户代码（例如以回调的形式），这一点很重要。基于同样的原因，
     * 此方法绝不能长时间阻塞。
     * </p>
     *
     * @param packet 要通知给节收集器和接收监听器的节（stanza，在相关协议里类似消息单元的结构）。
     */
    protected func invokeStanzaCollectorsAndNotifyRecvListeners(packet: Stanza): Unit {
        if (let Some(iq) <- (packet as IQ)) {
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
                    // 如果IQ节（stanza，在相关协议里类似消息单元的结构，这里特指IQ类型）的类型是“get”（获取）或“set”（设置），
                    // 并且没有已注册的IQ请求处理程序，那么就用“service-unavailable”（服务不可用）的条件来回复一个类型为“error”（错误）的IQ。
                    let errorIQ = IQ.createErrorResponse(iq, StanzaError.getBuilder(replyCondition).build())
                    // 在此处使用异步的sendStanza()方法，因为如果sendStanza()方法会阻塞的话，那么某些连接（例如XmppNioTcpConnection）将会发生死锁，
                    // 因为此操作是在（与其他相关操作）相同的线程中执行的。
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
                            // 如果IQ请求处理程序不返回IQ响应，这并不是理想的情况，
                            // 因为RFC 6120第8.1.2节明确规定了响应是必需的。
                            // 但是一些API（主要是文件传输相关的API）并不总是返回结果，所以我们需要处理这种情况。
                            // 而且有时候请求处理程序可能会判定不发送响应更好，
                            // 例如，为了避免状态信息泄露。
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
                // 以下的返回情况使得数据包监听器和收集器无法针对IQ请求节（stanza，在相关协议里类似消息单元的结构，这里特指IQ类型的‘set’或‘get’请求）进行过滤。这正是我们所期望的行为。
                return
            }
        }

        // 首先处理异步接收监听器。请注意，这段代码与下面几行的代码非常相似，
        // 唯一的区别在于这里使用了asyncRecvListeners，并且数据包监听器是在它们自己的线程中启动的。
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

        // 遍历所有收集器，并通知相应的收集器。
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

        // 通知对该数据包感兴趣的接收监听器。
        listenersToNotify.clear()
        extractMatchingListeners(packet, syncRecvListeners, syncRecvListenersLock, listenersToNotify)
        // 将传入节（stanza，在相关协议里类似消息单元的结构）的处理与监听器调用分离开来。与异步监听器不同的是，这里使用了单线程的执行器服务，因此能够保持处理顺序。
        ASYNC_BUT_ORDERED.performAsyncButOrdered(
            this,
            {
                =>
                // 由于监听器能够自行移除自身，并且因为决定调用监听器的时间点与实际调用监听器的时间点（此处）是不同的，所以我们必须再次检查该监听器是否仍然处于活动状态。
                synchronized(syncRecvListenersLock) {
                    listenersToNotify.removeIf {
                        v =>
                        // 该监听器已从同步接收监听器（syncRecvListener）中移除，也要将其从待通知监听器（listenersToNotify）中移除。
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
     * 设置连接是否已登录服务器。
     * 此方法确保一旦设置了{@link#wasAuthenticated}标志，它就永远不会重置。
     */
    protected func setWasAuthenticated(): Unit {
        // 如果连接曾经已经通过认证，就绝不要重置该标志。
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
                // 捕获并打印任何异常，这样我们就能从出现故障的监听器中恢复过来，并完成关闭进程。
                LOGGER.error("Exception in authenticated listener", ("exception", e))
            }
        }
    }

    public func callConnectionClosedListener(): Unit {
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
        if (let Some(see) <- (e as StreamErrorException)) {
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
                // 捕获并打印任何异常，以便我们能从出现故障的监听器中恢复过来。
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
                if (let Some(v) <- streamFeature) {
                    addStreamFeature(v)
                }
            } else if (eventType == XmlPullParserEvent.END_ELEMENT && parser.getDepth() == initialDepth) {
                break
            }
        }
    }

    public func parseFeaturesAndNotify(parser: XmlPullParser): Unit {
        parseFeatures(parser)

        if (hasFeature(Mechanisms.ELEMENT, Mechanisms.NAMESPACE)) {
            // 只有在TLS（传输层安全协议）被禁用或者服务器未声明启用TLS的情况下，才继续进行SASL（简单认证与安全层）认证。
            if (!hasFeature(StartTls.ELEMENT, StartTls.NAMESPACE) || config.getSecurityMode() == ConnectionConfigurationSecurityMode
                .disabled) {
                saslFeatureReceived = true
                tlsHandled = true
                notifyWaitingThreads()
            }
        }

        // 如果服务器报告了绑定功能，那么我们可以确定我们已经完成了SASL（简单认证与安全层）认证，并且可能也完成了STARTTLS（启动TLS协议）操作。然后我们就可以报告说最后的“stream:features”（流特性）已经被解析完成了。
        if (hasFeature(Bind.ELEMENT, Bind.NAMESPACE)) {
            if (!hasFeature(CompressFeature.ELEMENT, Compress.NAMESPACE) || !config.isCompressionEnabled()) {
                // 这里是服务器发送的最后一组流特性（stream features），
                // 要么它（指流特性）不包含压缩功能，要么是我们已经禁用了压缩功能。
                lastFeaturesReceived = true
                notifyWaitingThreads()
            }
        }
        afterFeaturesReceived()
    }

    protected open func afterFeaturesReceived(): Unit {
        // 默认实现不执行任何操作。
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
        // 虽然XMPP（可扩展消息处理现场协议）允许添加PacketFilter（数据包过滤器）值为“null”（空）的PacketListeners（数据包监听器），但我们在异步API中在此处禁止这种做法，因为这毫无意义。
        Objects.requireNonNull(replyFilter, "replyFilter must not be null")

        let future = InternalXmppFuture<S, Exception>()
        let stanzaListener: StanzaListener = SimpleStanzaListener {
            stanza, stanzaListener =>
            let removed = removeAsyncStanzaListener(stanzaListener)
            if (!removed) {
                // 我们在与“无响应”处理可运行对象的竞争中失败了。避免调用回调函数，因为异常回调（如果有的话）将会被调用。
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
                    // 我们在与节（stanza，在相关协议里类似消息单元的结构）监听器的竞争中落败了，它已经因为接收到了一个回复而将自身移除了。在这里已经没有其他事情可做了。
                    return
                }

                // 如果数据包监听器已被移除，那么它从未被运行过，
                // 并且我们也从未收到过回复，此时要通知异常回调（函数）。
                let exception: Exception = if (!isConnected()) {
                    // 如果连接不再处于连接状态，抛出一个未连接异常。
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
     * 获取连接首次通过身份验证的时间戳，即首次成功登录的时间。
     * 请注意，此值在断开连接时不会重置，因此它表示上次经过身份验证的连接的时间戳。
     * 该值在流恢复时也不会重置。
     *
     * @return 时间戳。
     */
    public func getAuthenticatedConnectionInitiallyEstablishedTimestamp(): Duration {
        return authenticatedConnectionInitiallyEstablishedTimestamp
    }

    /**
     * 安装一个解析异常回调，在解析节时遇到异常时将调用该回调。
     *
     * @param callback 回调以进行安装
     */
    public func setParsingExceptionCallback(callback: ParsingExceptionCallback): Unit {
        parsingExceptionCallback = callback
    }

    /**
     * 获取当前活动的解析异常回调。
     *
     * @return 活动异常回调。
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
     * 一个延迟可运行对象（deferred runnables）的队列，这些可运行对象未能立即执行，是因为{@link #currentAsyncRunnables}（当前异步可运行对象数量）达到了{@link #maxAsyncRunnables}（最大异步可运行对象数量）。
     * 请注意，我们使用{@code LinkedList}（链表）是为了避免在列表变得非常大然后又缩小时出现空间膨胀的情况。
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
        // 我们发现了一个开启的流。
        if (parser.getNamespace(None) == "jabber:client") {
            streamId = parser.getAttributeValue("", "id")
            incomingStreamXmlEnvironment = XmlEnvironment.froms(parser)
            // RFC 6120（可扩展消息处理现场协议相关的标准文档）第4.7.1节并未明确说明在客户端到服务器（c2s）连接中，服务器发起的流打开操作里的“from”（发送方信息）是必需的还是非必需的。
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
        // 如果可能的话，要为流打开标签的接收实体（也就是服务器）提供尽可能多的信息。“to”（接收方）属性是“始终”可用的。
        // “from”（发送方）属性，如果由用户设置且没有使用外部机制来确定本地实体（用户）时是可用的。
        // 而“id”（标识）属性在收到服务器的第一次响应之后可用（例如，参见RFC 6120第9.1.1节步骤2）。
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

/**  
 * 表示同步点不同状态的枚举。
 */
public enum SyncPointState <: Equatable<SyncPointState> {
    /**  
     * 同步点的初始状态。
     */
    | initial
    /**  
     * 发送请求。
     */
    | request_sent
    /**  
     * 同步点已成功完成的状态。
     */
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
 * 一个包装类，用于将节过滤器与监听器相关联。
 */
public class AbstractXMPPConnectionListenerWrapper {
    private let packetListener: StanzaListener

    private let packetFilter: ?StanzaFilter

    /**
     * 创建一个类，将节过滤器与监听器相关联。
     *
     * @param packetListener 节侦听器。
     * @param packetFilter 关联的过滤器，如果它监听所有数据包，则为None。
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
 * 一个包装类，用于将节过滤器与拦截器相关联。
 */
class AbstractXMPPConnectionInterceptorWrapper {
    /**
     * 创建一个类，将节过滤器与拦截器相关联。
     *
     * @param packetInterceptor 拦截器。
     * @param packetFilter 关联的过滤器，如果它拦截了所有数据包，则为None。
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
