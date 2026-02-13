/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

/**
 * <p>该类负责使用 SASL 验证用户，绑定资源到连接并与服务器建立会话。</p>
 *
 * <p>一旦 TLS 已成功协商（即连接已加密），便可以向服务器注册或使用 SASL 进行身份验证。
 * 如果服务器支持 SASL，则 Xmpp 将尝试使用 SASL 进行身份验证。</p>
 *
 * <p>服务器可能支持多种用于身份验证的 SASL 机制。默认情况下，Xmpp 提供几种 SASL 机制，但可以注册新的 SASL 机制。
 * 使用 {@link #registerSASLMechanism(SASLMechanism)} 注册新机制。</p>
 *
 * @see SASLMechanism
 */
public class SASLAuthentication {
    private static let LOGGER = getGlobalLogger("SASLAuthentication") // 日志记录器

    private static let REGISTERED_MECHANISMS = ArrayList<SASLMechanism>() // 已注册的 SASL 机制列表

    private static let REGISTERED_MECHANISMS_LOCK = Monitor() // 锁

    private static let BLACKLISTED_MECHANISMS: HashSet<String> = HashSet<String>() // 黑名单 SASL 机制集合

    private static let BLACKLISTED_MECHANISMS_LOCK = Monitor() // 锁

    static init() {
        // 暂时将 SCRAM-SHA-1-PLUS 机制列入黑名单
        blacklistSASLMechanism(ScramSha1PlusMechanism.NAME)
    }

    /**
     * 注册新的 SASL 机制。
     *
     * @param mechanism 一个 SASLMechanism 子类的实例。
     */
    public static func registerSASLMechanism(mechanism: SASLMechanism): Unit {
        synchronized(REGISTERED_MECHANISMS_LOCK) {
            REGISTERED_MECHANISMS.add(mechanism)
            REGISTERED_MECHANISMS.sort()
        }
    }

    /**
     * 返回已注册的 SASLMechanism，按优先级排序。
     *
     * @return 已注册的 SASLMechanism 对象，按优先级排序
     */
    public static func getRegisterdSASLMechanisms(): Map<String, String> {
        let answer: Map<String, String> = LinkedHashMap()
        synchronized(REGISTERED_MECHANISMS_LOCK) {
            for (mechanism in REGISTERED_MECHANISMS) {
                answer.add(anyClassId(mechanism), anyToString(mechanism)) // TODO
            }
        }
        return answer
    }

    /**
     * 检查指定的 SASL 机制是否已注册。
     *
     * @param saslMechanism 要检查的 SASL 机制名称
     * @return 如果已注册，返回 true；否则返回 false
     */
    public static func isSaslMechanismRegistered(saslMechanism: String): Bool {
        synchronized(REGISTERED_MECHANISMS_LOCK) {
            for (mechanism in REGISTERED_MECHANISMS) {
                if (mechanism.getName() == saslMechanism) {
                    return true
                }
            }
        }
        return false
    }

    /**
     * 根据其完整类名注销 SASLMechanism。例如：
     * "SASLCramMD5Mechanism"。
     *
     * @param clazz SASLMechanism 类名
     * @return 如果成功移除给定的 SASLMechanism，返回 true；否则返回 false
     */
    public static func unregisterSASLMechanism(clazz: String): Bool {
        synchronized(REGISTERED_MECHANISMS_LOCK) {
            for (i in 0..REGISTERED_MECHANISMS.size) {
                let mechanism = REGISTERED_MECHANISMS[i]
                if (anyClassId(mechanism) == clazz) {
                    REGISTERED_MECHANISMS.remove(at: i)
                    return true
                }
            }
        }
        return false
    }

    /**
     * 将指定的 SASL 机制列入黑名单。
     *
     * @param mechanism 要加入黑名单的机制名称
     * @return 如果成功加入，则返回 true；否则返回 false
     */
    public static func blacklistSASLMechanism(mechanism: String): Bool {
        synchronized(BLACKLISTED_MECHANISMS_LOCK) {
            return BLACKLISTED_MECHANISMS.add(mechanism)
        }
    }

    /**
     * 将指定的 SASL 机制移除黑名单。
     *
     * @param mechanism 要移除黑名单的机制名称
     * @return 如果成功移除，则返回 true；否则返回 false
     */
    public static func unBlacklistSASLMechanism(mechanism: String): Bool {
        synchronized(BLACKLISTED_MECHANISMS_LOCK) {
            return BLACKLISTED_MECHANISMS.remove(mechanism)
        }
    }

    /**
     * 以不可更改的方式返回已被列入黑名单的 SASL 机制集合。
     *
     * @return 不可更改的 SASL 机制黑名单集合
     */
    public static func getBlacklistedSASLMechanisms(): Set<String> {
        return BLACKLISTED_MECHANISMS // TODO Collections.unmodifiableSet(BLACKLISTED_MECHANISMS)
    }

    private let lock = Monitor() //锁

    private let connection: AbstractXMPPConnection //当前连接的 XMPP 连接

    private let configuration: ConnectionConfiguration //当前连接的配置

    private var currentMechanism: ?SASLMechanism = None //当前使用的 SASL 机制

    /**
     * 构造函数，初始化 SASLAuthentication 类的实例。
     *
     * @param connection 与此身份验证相关的 XMPP 连接
     * @param configuration 连接配置
     */
    init(connection: AbstractXMPPConnection, configuration: ConnectionConfiguration) {
        this.configuration = configuration
        this.connection = connection
    }

    /**
     * 执行指定用户的 SASL 身份验证。如果 SASL 身份验证成功，则执行资源绑定和会话建立。
     * 此方法将返回绑定资源时服务器提供的完整 JID。
     *
     * <p>服务器可能会赋予与本方法请求的不同的用户名或资源的完整 JID。</p>
     *
     * @param username 需要认证的用户名
     * @param password 发送到服务器的密码
     * @param authzid 授权标识符（通常为 null）
     * @param sslSession 可选的 SSL/TLS 会话（如果已建立）
     * @return 已使用的 SASLMechanism
     * @throws XMPPErrorException 如果返回了 XMPP 错误
     * @throws SASLErrorException 如果返回了 SASL 协议错误
     * @throws IOException 如果发生 I/O 错误
     * @throws InterruptedException 如果调用线程被中断
     * @throws XmppSaslException 如果发生 SASL 特定错误
     * @throws NotConnectedException 如果 XMPP 连接未连接
     * @throws NoResponseException 如果远程实体没有响应
     */
    func authenticate(username: ?String, password: ?String, authzid: ?EntityBareJid, sslSession: ?TlsSession): SASLMechanism {
        let mechanism = selectMechanism(authzid, password)
        let callbackHandler = configuration.getCallbackHandler()
        let host = connection.getHost()
        let xmppServiceDomain = connection.getXMPPServiceDomain()

        synchronized(lock) {
            currentMechanism = mechanism
            if (callbackHandler.isSome()) {
                mechanism.authenticate(host, xmppServiceDomain, callbackHandler, authzid, sslSession)
            } else {
                mechanism.authenticate(username, host, xmppServiceDomain, password, authzid, sslSession)
            }
            let deadline = DateTime.now() + connection.getReplyTimeout()
            while (!mechanism.isFinished()) {
                let now = DateTime.now()
                if (now >= deadline) {
                    break
                }
                // Wait until SASL negotiation finishes
                lock.wait(timeout: deadline - now)
            }
        }
        mechanism.throwExceptionIfRequired()
        return mechanism
    }

    /**
     * 处理接收到的挑战消息，包装 {@link #challengeReceived(String, boolean)} 方法，并将
     * <code>finalChallenge</code> 设置为 <code>false</code>。
     *
     * @param challenge 来自服务器的挑战 Nonza
     * @throws XmppException 如果 Xmpp 检测到异常情况
     * @throws InterruptedException 如果调用线程被中断
     */
    func challengeReceived(challenge: SaslNonzaChallenge): Unit {
        challengeReceived(challenge.getData(), false)
    }

    /**
     * 当前正挑战 SASL 身份验证，转发挑战给当前使用的 SASLMechanism。
     * SASLMechanism 将最终向服务器发送响应。挑战-响应序列的长度根据使用的 SASLMechanism 而变化。
     *
     * @param challenge 一个 base64 编码的字符串，表示挑战
     * @param finalChallenge 如果这是服务器在成功 stanzas 发出的最后挑战，则为 true
     * @throws XmppSaslException 如果发生 SASL 特定错误
     * @throws NotConnectedException 如果 XMPP 连接未连接
     * @throws InterruptedException 如果调用线程被中断
     */
    private func challengeReceived(challenge: ?String, finalChallenge: Bool): Unit {
        let mechanism = synchronized(lock) {
            currentMechanism
        }
        mechanism?.challengeReceived(challenge, finalChallenge)
    }

    /**
     * 接收通知，表示 SASL 身份验证成功。下一步将是绑定资源。
     *
     * @param success 身份验证的结果
     * @throws InterruptedException 如果调用线程被中断
     * @throws XmppSaslException 如果发生 SASL 特定错误
     * @throws NotConnectedException 如果 XMPP 连接未连接
     */
    func authenticated(success: SaslNonzaSuccess): Unit {
        if (let Some(v) <- success.getData()) {
            challengeReceived(v, true)
        }
        // Wake up the thread that is waiting in the #authenticate method
        synchronized(lock) {
            currentMechanism?.afterFinalSaslChallenge()
            lock.notify()
        }
    }

    /**
     * 处理 SASL 身份验证失败的通知消息。服务器可能会根据可重试的次数关闭连接。
     *
     * @param saslFailure 服务器报告的 SASL 失败
     * @see <a href="https/tools/ietf/org/html/rfc6120#section-6.5">RFC6120 6.5</a>
     */
    func authenticationFailed(saslFailure: SaslNonzaSASLFailure): Unit {
        let saslErrorException: SASLErrorException
        synchronized(lock) {
            saslErrorException = SASLErrorException(currentMechanism().getName(), saslFailure)
        }
        authenticationFailed(saslErrorException)
    }

    /**
     * 处理 SASL 身份验证失败的通知。此方法将唤醒在 #authenticate 方法中等待的线程。
     *
     * @param exception 发生的异常，表示身份验证失败
     */
    func authenticationFailed(exception: Exception): Unit {
        synchronized(lock) {
            currentMechanism?.setException(exception)
            lock.notify()
        }
    }

    /**
     * 检查当前的 SASL 身份验证是否成功。
     *
     * @return 如果身份验证成功，则返回 true；否则返回 false
     */
    public func authenticationSuccessful(): Bool {
        synchronized(lock) {
            return currentMechanism?.isAuthenticationSuccessful() ?? false
        }
    }

    /**
     * 获取最后使用的 SASL 机制的名称。
     *
     * @return 最后使用的 SASL 机制的名称，如果没有使用过机制，则返回 null
     */
    func getNameOfLastUsedSaslMechansism(): ?String {
        return currentMechanism?.getName()
    }

    /**
     * 根据授权标识符和密码选择合适的 SASL 机制。
     *
     * @param authzid 授权标识符（通常为 null）
     * @param password 用户的密码
     * @return 选择的 SASL 机制
     * @throws XmppException.XmppSaslException 如果选择机制时发生错误
     */
    private func selectMechanism(authzid: ?EntityBareJid, password: ?String): SASLMechanism {
        let passwordAvailable = StringUtils.isNotEmpty(password)

        let it: Iterator<SASLMechanism> = REGISTERED_MECHANISMS.iterator()
        let serverMechanisms = getServerMechanisms()
        if (serverMechanisms.isEmpty()) {
            LOGGER.warn("Server did not report any SASL mechanisms")
        }

        let skipReasons = ArrayList<String>()
        while (let Some(mechanism) <- it.next()) {
            let mechanismName = mechanism.getName()
            if (!serverMechanisms.contains(mechanismName)) {
                continue
            }
            synchronized(BLACKLISTED_MECHANISMS_LOCK) {
                if (BLACKLISTED_MECHANISMS.contains(mechanismName)) {
                    continue
                }
            }
            if (!configuration.isEnabledSaslMechanism(mechanismName)) {
                continue
            }
            if (authzid.isSome() && !mechanism.authzidSupported()) {
                skipReasons.add(
                    "Skipping ${mechanism} because authzid is required by not supported by this SASL mechanism")
                continue
            }
            if (mechanism.requiresPassword() && !passwordAvailable) {
                skipReasons.add(
                    "Skipping ${mechanism} because a password is required for it, but none was provided to the connection configuration"
                )
                continue
            }
            return mechanism.instanceForAuthentication(connection, configuration)
        }
        synchronized(BLACKLISTED_MECHANISMS_LOCK) {
            throw XmppSaslException(
                "No supported and enabled SASL Mechanism provided by server. Server announced mechanisms: ${serverMechanisms}. Registered SASL mechanisms with Xmpp: REGISTERED_MECHANISMS. Enabled SASL mechanisms for this connection: ${anyToString(configuration.getEnabledSaslMechanisms())}. Blacklisted SASL mechanisms: ${BLACKLISTED_MECHANISMS}. Skip reasons: ${skipReasons}"
            )
        }
    }

    /**
     * 获取服务器支持的 SASL 机制列表。
     *
     * @return 服务器支持的 SASL 机制名称列表
     */
    private func getServerMechanisms(): ArrayList<String> {
        let mechanisms = connection.getFeature("Mechanisms")
        match (mechanisms) {
            case Some(v: Mechanisms) => ArrayList(v.getMechanisms())
            case _ => ArrayList()
        }
    }
}
