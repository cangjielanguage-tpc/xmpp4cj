/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

/**
 * 默认连接超时时间。预初始化为30秒。如果更改此值，新的Builder实例将使用新值作为默认值。
 */
public let DEFAULT_CONNECT_TIMEOUT: Duration = Duration.second * 30

/**
 * 通过TCP的XMPP连接的连接配置（常见情况）。
 * <p>
 * 您可以使用{@link#builder（）}获取配置生成器的实例，并使用{@link builder#build（）}构建最终的不可变连接配置。
 * </p>
 * <pre>
 * {@code
 * let conf = XMPPTCPConnectionConfiguration.builder()
 *     .setXmppDomain("example.org")
 *     .setUsernameAndPassword("user", "password")
 *     .setCompressionEnabled(false)
 *     .build()
 * let connection: XMPPTCPConnection = XMPPTCPConnection(conf)
 * }
 * </pre>
 */
public class XMPPTCPConnectionConfiguration <: ConnectionConfiguration {
    /**
     * 套接字将等待多长时间才能建立TCP连接。
     */
    private let connectTimeout: Duration

    /**
     * 通过 XMPPTCPConnectionConfigurationBuilder 构建 XMPPTCPConnectionConfiguration。
     *
     * @param builder XMPPTCPConnectionConfigurationBuilder
     */
    init(builder: XMPPTCPConnectionConfigurationBuilder) {
        // TODO
        super(builder)
        connectTimeout = builder.connectTimeout
    }

    /**
     * 套接字将等待多长时间才能建立TCP连接（以毫秒为单位）。默认为{@link#DEFAULT_CONNECT_TIMEOUT}。
     *
     * @return 超时值
     */
    public func getConnectTimeout(): Duration {
        return connectTimeout
    }

    /**
     * 创建 XMPPTCPConnectionConfigurationBuilder 对象。
     *
     * @return XMPPTCPConnectionConfigurationBuilder对象
     */
    public static func builder(): XMPPTCPConnectionConfigurationBuilder {
        return XMPPTCPConnectionConfigurationBuilder()
    }
}

/**
 * 用于通过TCP进行XMPP连接的配置生成器。使用{@link XMPPTCPConnectionConfiguration#builder（）}获取新实例，并使用{@link#build}构建配置。
 */
public class XMPPTCPConnectionConfigurationBuilder <: ConnectionConfigurationBuilder {
    var connectTimeout: Duration = DEFAULT_CONNECT_TIMEOUT

    init() {
        super()
    }

    public override func setXmppAddressAndPassword(jid: String, password: String): XMPPTCPConnectionConfigurationBuilder {
        super.setXmppAddressAndPassword(jid, password)
        return getThis()
    }

    public override func setXmppAddressAndPassword(jid: EntityBareJid, password: String): XMPPTCPConnectionConfigurationBuilder {
        super.setXmppAddressAndPassword(jid, password)
        return getThis()
    }

    public override func setUsernameAndPassword(username: String, password: String): XMPPTCPConnectionConfigurationBuilder {
        super.setUsernameAndPassword(username, password)
        return getThis()
    }

    public override func setXmppDomain(xmppDomain: DomainBareJid): XMPPTCPConnectionConfigurationBuilder {
        super.setXmppDomain(xmppDomain)
        return getThis()
    }

    public func setXmppDomain(xmppServiceDomain: String): XMPPTCPConnectionConfigurationBuilder {
        super.setXmppDomain(xmppServiceDomain)
        return getThis()
    }

    public override func setResource(resource: Resourcepart): XMPPTCPConnectionConfigurationBuilder {
        super.setResource(resource)
        return getThis()
    }

    public override func setLanguage(language: String): XMPPTCPConnectionConfigurationBuilder {
        super.setLanguage(language)
        return getThis()
    }

    public override func setResource(resource: String): XMPPTCPConnectionConfigurationBuilder {
        super.setResource(resource)
        return getThis()
    }

    public override func setHostAddress(address: IPAddress): XMPPTCPConnectionConfigurationBuilder {
        super.setHostAddress(address)
        return getThis()
    }

    public override func setHost(host: String): XMPPTCPConnectionConfigurationBuilder {
        super.setHost(host)
        return getThis()
    }

    public override func setPort(port: Int64): XMPPTCPConnectionConfigurationBuilder {
        super.setPort(port)
        return getThis()
    }

    public override func setPort(port: UInt16): XMPPTCPConnectionConfigurationBuilder {
        super.setPort(port)
        return getThis()
    }

    public override func setDnssecMode(dnssecMode: DnssecMode): XMPPTCPConnectionConfigurationBuilder {
        super.setDnssecMode(dnssecMode)
        return getThis()
    }

    public override func setSecurityMode(securityMode: ConnectionConfigurationSecurityMode): XMPPTCPConnectionConfigurationBuilder {
        super.setSecurityMode(securityMode)
        return getThis()
    }

    public override func setTlsClientConfig(tlsClientConfig: ?TlsClientConfig): XMPPTCPConnectionConfigurationBuilder {
        super.setTlsClientConfig(tlsClientConfig)
        return getThis()
    }

    public override func setSendPresence(sendPresence: Bool): XMPPTCPConnectionConfigurationBuilder {
        super.setSendPresence(sendPresence)
        return getThis()
    }

    public override func enableDefaultDebugger(): XMPPTCPConnectionConfigurationBuilder {
        super.enableDefaultDebugger()
        return getThis()
    }

    public override func setDebuggerFactory(debuggerFactory: XmppDebuggerFactory): XMPPTCPConnectionConfigurationBuilder {
        super.setDebuggerFactory(debuggerFactory)
        return getThis()
    }

    public override func setSocketFactory(socketFactory: SocketFactory): XMPPTCPConnectionConfigurationBuilder {
        super.setSocketFactory(socketFactory)
        return getThis()
    }

    public override func setProxyInfo(proxyInfo: ProxyInfo): XMPPTCPConnectionConfigurationBuilder {
        super.setProxyInfo(proxyInfo)
        return getThis()
    }

    public override func allowEmptyOrNullUsernames(): XMPPTCPConnectionConfigurationBuilder {
        super.allowEmptyOrNullUsernames()
        return getThis()
    }

    public override func performSaslAnonymousAuthentication(): XMPPTCPConnectionConfigurationBuilder {
        super.performSaslAnonymousAuthentication()
        return getThis()
    }

    public override func performSaslExternalAuthentication(sslContext: TlsClientConfig): XMPPTCPConnectionConfigurationBuilder {
        super.performSaslExternalAuthentication(sslContext)
        return getThis()
    }

    public override func addEnabledSaslMechanism(saslMechanism: String): XMPPTCPConnectionConfigurationBuilder {
        super.addEnabledSaslMechanism(saslMechanism)
        return getThis()
    }

    public override func addEnabledSaslMechanism(saslMechanisms: Collection<String>): XMPPTCPConnectionConfigurationBuilder {
        super.addEnabledSaslMechanism(saslMechanisms)
        return getThis()
    }

    public override func setAuthzid(authzid: EntityBareJid): XMPPTCPConnectionConfigurationBuilder {
        super.setAuthzid(authzid)
        return getThis()
    }

    public override func setCompressionEnabled(compressionEnabled: Bool): XMPPTCPConnectionConfigurationBuilder {
        super.setCompressionEnabled(compressionEnabled)
        return getThis()
    }

    public override func setStanzaIdSourceFactory(stanzaIdSourceFactory: StanzaIdSourceFactory): XMPPTCPConnectionConfigurationBuilder {
        super.setStanzaIdSourceFactory(stanzaIdSourceFactory)
        return getThis()
    }

    public func setConnectTimeout(connectTimeout: Duration): XMPPTCPConnectionConfigurationBuilder {
        this.connectTimeout = connectTimeout
        return this
    }

    protected override func getThis(): XMPPTCPConnectionConfigurationBuilder {
        return this
    }

    public override func build(): XMPPTCPConnectionConfiguration {
        return XMPPTCPConnectionConfiguration(this)
    }
}
