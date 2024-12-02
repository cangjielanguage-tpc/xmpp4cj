/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * 用于XMPP客户端到服务器连接的连接配置。
 * 配置良好的XMPP服务通常只需要您提供两个参数：用户的XMPP地址（也称为JID）和密码。理想情况下，所有其他配置参数都可以由Xmpp自动确定。
 * 因此，调用{@link Builder#setXmppAddressAndPassword（CharSequence，String）}就足够了。
 * <p>
 * 从技术上讲，通常至少需要两个参数：用于身份验证的某种凭据。
 * 以及XMPP服务域。凭证通常由用于SASL身份验证的用户名和密码组成。
 * 但也有其他身份验证机制，如客户端证书，不需要特定的用户名和密码。
 * </p>
 * <p>
 * 关于XMPP客户端到服务器的参数存在一些误解：首先，用于身份验证的用户名在身份验证后将等于绑定XMPP地址的本地部分。
 * 虽然这通常是正确的，但不是必需的。
 * 从技术上讲，用于身份验证的用户名和由此产生的XMPP地址完全相互独立。
 * 第二个常见的误解来自“XMPP主机”和“XMPP服务域”这两个术语：XMPP服务主机是托管一个或多个XMPP域的系统。
 * “XMPP服务域”通常是绑定JID的域部分。此域用于验证远程端点，通常使用TLS。
 * 第三个误解是，XMPP服务域需要成为绑定JID的域部分。
 * 同样，虽然这很常见，但并不是严格要求的。
 * </p>
 */
public abstract class ConnectionConfiguration {
    static init() {
        // Xmpp.ensureInitialized() // TODO
    }

    private static let LOGGER = getGlobalLogger(("name", "ConnectionConfiguration"))

    /**
     * XMPP服务的XMPP域。
     * 通常服务器使用与服务器名称相同的服务名称。
     * 然而，有些服务器，比如谷歌，主机是talk/google.com，服务名是gmail.com。
     */
    protected let xmppServiceDomain: DomainBareJid

    /**
     * XMPP 服务域对应的 DNS 名称
     */
    protected let xmppServiceDomainDnsName: ?DnsName

    /**
     * 主机地址
     */
    protected let hostAddress: ?IPAddress

    /**
     * 主机名或者主机地址。
     */
    protected let host: ?DnsName

    /**
     * 端口号
     */
    protected let port: UInt16

    /**
     * 用于获取user信息 基本上这是为了不直接提供用户敏感信息的设计
     * 如果有专门sasl扩展实现 CallbackHandler可作为设计支持
     */
    private let callbackHandler: ?CallbackHandler

    private let debuggerFactory: ?XmppDebuggerFactory

    // 保存用于在连接中生成套接字的套接字工厂
    private let socketFactory: ?SocketFactory

    private let username: ?String

    private let password: ?String

    private let resource: ?Resourcepart

    private var language: ?String

    /**
     * 可选的SASL授权标识 (see RFC 6120 § 6.3.8).
     */
    private let authzid: ?EntityBareJid

    /**
     * 初始存在日期 RFC 6121 § 4.2
     * @see <a href="xmpp/org/rfcs/rfc6121.html#presence-initial">RFC 6121 § 4.2 Initial Presence</a>
     */
    private let sendPresence: Bool

    private let securityMode: ConnectionConfigurationSecurityMode

    let xmppTlsContext: XmppTlsContext

    private let dnssecMode: DnssecMode

    // tls配置统一到TlsClientConfig
    private let tlsClientConfig: ?TlsClientConfig

    // 保存代理信息（如代理主机、代理端口、用户名、密码等）
    protected let proxy: ?ProxyInfo

    // 允许空用户名
    protected let allowNullOrEmptyUsername: Bool

    private let enabledSaslMechanisms: ?Set<String>

    private let compressionEnabled: Bool

    private let stanzaIdSourceFactory: StanzaIdSourceFactory

    /**
     * 初始化方法。
     *
     * @param builder ConnectionConfigurationBuilder。
     */
    protected init(builder: ConnectionConfigurationBuilder) {
        try {
            this.xmppTlsContext = getXmppTlsContext(builder.dnssecMode, builder.tlsClientConfig)
        } catch (e: Exception) {
            throw IllegalArgumentException()
        }

        this.authzid = builder.authzid
        this.username = builder.username
        this.password = builder.password
        this.callbackHandler = builder.callbackHandler

        // 资源可以为空，这意味着服务器必须提供一个
        this.resource = builder.resource
        this.language = builder.language

        this.xmppServiceDomain = builder.xmppServiceDomain.getOrThrow {
            => IllegalArgumentException("Must define the XMPP domain")
        }
        this.xmppServiceDomainDnsName = try {
            xmppServiceDomain.getDomain().toString() // 取jid.Domain部分
        } catch (e: Exception) {
            LOGGER.log(
                LogLevel.INFO,
                "Could not transform XMPP service domain '${xmppServiceDomain}' to a DNS name. TLS X.509 certificate validiation may not be possible.",
                e
            )
            None
        }
        this.hostAddress = builder.hostAddress
        this.host = builder.host
        this.port = builder.port

        this.proxy = builder.proxy
        this.socketFactory = builder.socketFactory

        this.dnssecMode = builder.dnssecMode
        this.securityMode = builder.securityMode
        this.tlsClientConfig = builder.tlsClientConfig
        this.sendPresence = builder.sendPresence
        this.debuggerFactory = builder.debuggerFactory
        this.allowNullOrEmptyUsername = builder.allowEmptyOrNullUsername
        this.enabledSaslMechanisms = builder.enabledSaslMechanisms

        this.compressionEnabled = builder.compressionEnabled
        this.stanzaIdSourceFactory = builder.stanzaIdSourceFactory

        // 如果设置了enabledSaslmechanism，则它们不能为空
        assert(enabledSaslMechanisms.isNone() || enabledSaslMechanisms?.isEmpty() == false)
    }

    private static func getXmppTlsContext(
        dnssecMode: DnssecMode,
        tlsCfg: ?TlsClientConfig
    ): XmppTlsContext {
        let cfg = tlsCfg ?? DEFAULT_TLS_CFG
        var daneVerifier: ?XmppDaneVerifier = None
        if (dnssecMode == DnssecMode.needsDnssecAndDane) {
            let daneProvider = DNSUtil.getDaneProvider().getOrThrow {
                => UnsupportedException("DANE enabled but no XmppDaneProvider configured")
            }
            daneVerifier = daneProvider().getOrThrow {
                => IllegalStateException("DANE requested but DANE provider did not return a DANE verifier")
            }
            // 用户请求DANE验证。
            daneVerifier?.initself(cfg)
        }
        return XmppTlsContext(cfg, daneVerifier)
    }

    /**
     * 返回主机名。
     *
     * @return 主机名。
     */
    public func getHostString(): String {
        if (let Some(v) <- hostAddress) {
            return v.toString()
        }
        if (let Some(v) <- host) {
            return v.toString()
        }
        return xmppServiceDomain.toString()
    }

    /**
     * 返回主机名或者主机地址。
     *
     * @return 主机名或者主机地址。
     */
    public func getHost(): ?DnsName {
        return host
    }

    /**
     * 返回主机地址。
     *
     * @return 主机地址。
     */
    public func getHostAddress(): ?IPAddress {
        return hostAddress
    }

    /**
     * 返回端口号。
     *
     * @return 端口号。
     */
    public func getPort(): UInt16 {
        return port
    }

    /**
     * 返回此配置使用的XMPP域。
     *
     * @return XMPP域。
     */
    public func getXMPPServiceDomain(): DomainBareJid {
        return xmppServiceDomain
    }

    /**
     * 如果可能的话，以DNS名称的形式返回XMPP服务域。需要注意的是，由于并非每个XMPP地址的域部分都是有效的DNS名称，所以此方法可能会返回 `None`。
     *
     * @return 以DNS名称形式表示的XMPP服务域，或者 `None`。
     */
    public func getXmppServiceDomainAsDnsNameIfPossible(): ?DnsName {
        return xmppServiceDomainDnsName
    }

    /**
     * 返回建立连接时所使用的TLS安全模式。默认情况下，该模式为 `{@link SecurityMode#required}`。
     *
     * @return 安全模式。
     */
    public func getSecurityMode(): ConnectionConfigurationSecurityMode {
        return securityMode
    }

    /**  
     * 返回 DNSSEC 模式
     * @return 返回 DNSSEC 模式
     */
    public func getDnssecMode(): DnssecMode {
        return dnssecMode
    }

    /**
     * 返回TlsClientConfig。
     *
     * @return TlsClientConfig
     */
    public func getTlsClientConfig(): ?TlsClientConfig {
        return tlsClientConfig
    }

    /**
     * 返回XMPP调试器工厂。
     *
     * @return XMPP调试器工厂或者 `None`。
     */
    public func getDebuggerFactory(): ?XmppDebuggerFactory {
        return debuggerFactory
    }

    /**
     * 返回用于创建新的XMPP连接套接字的套接字工厂。在通过SOCKS5代理进行连接时，此功能很有用。
     *
     * @return 用于创建新套接字的套接字工厂。
     */
    public func getSocketFactory(): ?SocketFactory {
        return socketFactory
    }

    /**
     * 返回一个回调处理器，用于在SASL身份验证过程中获取诸如密码或主体信息等信息。只有在使用SASL身份验证登录时未指定密码的情况下，才会使用此回调处理器。
     *
     * @return 一个用于在SASL身份验证期间获取诸如密码或主体信息等信息的回调处理器。
     */
    public func getCallbackHandler(): ?CallbackHandler {
        return callbackHandler
    }

    /**
     * 获取已配置的代理信息（如果有的话）。
     *
     * @return 已配置的代理信息或者 `None`。
     */
    public func getProxyInfo(): ?ProxyInfo {
        return proxy
    }

    /**
     * 返回尝试重新连接到服务器时要使用的用户名。
     *
     * @return 尝试重新连接到服务器时要使用的用户名。
     */
    public func getUsername(): ?String {
        return username
    }

    /**
     * 返回尝试重新连接到服务器时要使用的密码。
     *
     * @return 尝试重新连接到服务器时要使用的密码。
     */
    public func getPassword(): ?String {
        return password
    }

    /**
     * 返回尝试重新连接到服务器时要使用的资源。
     *
     * @return 尝试重新连接到服务器时要使用的资源，可能为None。
     */
    public func getResource(): ?Resourcepart {
        return resource
    }

    /**
     * 返回连接到服务器时要使用的流语言。
     *
     * @return 连接到服务器时要使用的流语言，可能为None。
     */
    public func getLanguage(): ?String {
        return language
    }

    /**
     * 返回连接到服务器时要使用的流语言的 `xml:lang` 字符串。
     *
     * <p>如果开发者将语言设置为 `None`，那么此方法也会返回 `None`，这将导致从流中移除 `xml:lang` 标签。</p>
     *
     * @return 连接到服务器时要使用的流语言。
     */
    public func getXmlLang(): ?String {
        language?.replace("_", "-")
    }

    /**
     * 返回作为SASL授权标识要请求的可选XMPP地址。
     *
     * @return 授权标识符。
     * @see <a href="http/tools/ietf/org/html/rfc6120#section-6.3.8">RFC 6120 § 6.3.8. 授权标识</a>
     */
    public func getAuthzid(): ?EntityBareJid {
        return authzid
    }

    /**
     * 如果在重新连接登录时应该发送可用状态，则返回 `true`。
     *
     * @return 如果在重新连接登录时应该发送可用状态，则返回 `true`。
     */
    public func isSendPresence(): Bool {
        return sendPresence
    }

    /**
     * 如果连接将使用流压缩，则返回 `true`。流压缩将在TLS建立之后（如果启用了TLS）且仅当服务器提供流压缩时才会被请求。通过流压缩，网络流量最多可减少90%。默认情况下，压缩是禁用的。
     *
     * @return 如果连接将使用流压缩，则返回 `true`。
     */
    public func isCompressionEnabled(): Bool {
        return compressionEnabled
    }

    /**
     * 检查给定的SASL机制在此次连接配置中是否已启用。
     *
     * @param saslMechanism TODO javadoc me please
     * @return 如果给定的SASL机制已启用，则返回 `true`，否则返回 `false`。
     */
    public func isEnabledSaslMechanism(saslMechanism: String): Bool {
        if (let Some(v) <- enabledSaslMechanisms) {
            return v.contains(saslMechanism)
        } else {
            return !SASLAuthentication.getBlacklistedSASLMechanisms().contains(saslMechanism)
        }
    }

    /**
     * 返回显式启用的SASL机制。如果没有显式启用任何SASL机制，即所有由服务支持并公布的SALS机制都将被考虑在内，那么可能会返回 `None`。
     *
     * @return 已启用的SASL机制或者 `None`。
     */
    public func getEnabledSaslMechanisms(): ?Set<String> {
        if (let Some(v) <- enabledSaslMechanisms) {
            return v // TODO Collections.unmodifiableSet(enabledSaslMechanisms)
        } else {
            return None
        }
    }

    /**
     * 构造并返回一个 StanzaIdSource 类型的对象。
     *
     * @return StanzaIdSource。
     */
    public func constructStanzaIdSource(): StanzaIdSource {
        return stanzaIdSourceFactory.constructStanzaIdSource()
    }
}

public abstract class ConnectionConfigurationBuilder {
    var securityMode: ConnectionConfigurationSecurityMode = ConnectionConfigurationSecurityMode.required
    var dnssecMode: DnssecMode = DnssecMode.disabled
    var tlsClientConfig: ?TlsClientConfig = None
    var authzid: ?EntityBareJid = None
    var username: ?String = None
    var password: ?String = None
    var resource: ?Resourcepart = None
    var language: String = "zh_CN"
    var sendPresence = true
    var proxy: ?ProxyInfo = None
    var callbackHandler: ?CallbackHandler = None
    var debuggerFactory: ?XmppDebuggerFactory = None
    var socketFactory: ?SocketFactory = None
    var xmppServiceDomain: ?DomainBareJid = None
    var hostAddress: ?IPAddress = None
    var host: ?DnsName = None
    var port: UInt16 = 5222
    var allowEmptyOrNullUsername = false
    var saslMechanismsSealed: Bool = false
    var enabledSaslMechanisms: ?Set<String> = None
    var customX509TrustManager: ?TlsClientConfig = None
    var compressionEnabled = false
    var stanzaIdSourceFactory: StanzaIdSourceFactory = StandardStanzaIdSourceFactory()

    /**
     * 初始化ConnectionConfigurationBuilder。
     */
    public ConnectionConfigurationBuilder() {
        if (XmppConfiguration.DEBUG) {
            this.debuggerFactory = XmppConfiguration.getDefaultXmppDebuggerFactory()
            assert(this.debuggerFactory.isSome())
        }
    }

    /**
     * 配置用户名、密码和XMPP服务域的便捷方法。
     *
     * @param jid 用户的XMPP地址。
     * @param password 用户的密码。
     * @return ConnectionConfigurationBuilder
     * @throws XmppStringprepException 以防XMPP地址无效。
     * @see #setXmppAddressAndPassword(EntityBareJid, String)
     */
    public open func setXmppAddressAndPassword(jid: String, password: String): This {
        return setXmppAddressAndPassword(JidCreate.entityBareFrom(jid), password)
    }

    /**
     * 配置用户名、密码和XMPP服务域的便捷方法。提供的JID的localpart用作用户名，domanipart用作XMPP服务域。
     * <p>
     * 请注意，这可以配置也不能配置客户端XMPP地址。XMPP服务不需要分配绑定的JID，其中localpart与用户名匹配，domainpart与验证的domainpart匹配。尽管大多数服务将遵循这种模式。
     * </p>
     *
     * @param jid EntityBareJid
     * @param password 密码
     * @return ConnectionConfigurationBuilder
     */
    public open func setXmppAddressAndPassword(jid: EntityBareJid, password: String): This {
        setUsernameAndPassword(jid.getLocalpart().toString(), password)
        return setXmppDomain(jid.asDomainBareJid())
    }

    /**
     * 设置XMPP实体的用户名和密码。
     * <p>
     * 用户名通常是客户端JID的本地部分。但是，一些SASL机制或服务可能需要不同的格式（例如完整的JID）作为使用的授权标识。
     * </p>
     *
     * @param username 用户名或授权标识
     * @param password 用于身份验证的密码或令牌
     * @return ConnectionConfigurationBuilder
     */
    public open func setUsernameAndPassword(username: String, password: String): This {
        this.username = username
        this.password = password
        return this
    }

    /**
     * 设置XMPP域。XMPP域是XMPP地址（JID）中“@”符号之后的内容。
     *
     * @param xmppDomain XMPP域。
     * @return ConnectionConfigurationBuilder
     */
    public open func setXmppDomain(xmppDomain: DomainBareJid): This {
        this.xmppServiceDomain = xmppDomain
        return this
    }

    /**
     * 设置XMPP域。XMPP域是XMPP地址（JID）中“@”符号之后的内容。
     *
     * @param xmppServiceDomain XMPP域。
     * @return ConnectionConfigurationBuilder
     * @throws XmppStringprepException 如果给定的字符串不是域裸JID。
     */
    public open func setXmppDomain(xmppServiceDomain: String): This {
        this.xmppServiceDomain = JidCreate.domainBareFrom(xmppServiceDomain)
        return this
    }

    /**
     * 设置我们从服务器请求的资源。
     * <p>
     * 如果<code>资源</code>为<code>空</code>-默认值，则服务器将自动为客户端创建资源。
     * 请注意，XMPP客户端仅向服务器建议此资源。
     * XMPP服务器可以忽略客户端建议的资源，而是分配一个完全不同的资源（见RFC 6120§7.7.1）。
     * </p>
     *
     * @param resource 要使用的资源。
     * @return ConnectionConfigurationBuilder
     * @see <a href="https/tools/ietf/org/html/rfc6120#section-7.7.1">RFC 6120 § 7.7.1</a>
     */
    public open func setResource(resource: Resourcepart): This {
        this.resource = resource
        return this
    }

    /**
     * 设置语言。
     *
     * @param language 语言
     * @return ConnectionConfigurationBuilder
     * @see <a href="https/tools/ietf/org/html/rfc6120#section-4.7.4">RFC 6120 § 4.7.4</a>
     * @see <a href="https/www/w3/org/TR/xml/#sec-lang-tag">XML 1.0 § 2.12 Language Identification</a>
     */
    public open func setLanguage(language: String): This {
        this.language = language
        return this
    }

    /**
     * 设置我们从服务器请求的资源。
     *
     * @param resource 使用非空的String来使用资源。
     * @return ConnectionConfigurationBuilder
     * @throws XmppStringprepException 如果String不是有效的资源部分。
     * @see #setResource(Resourcepart)
     */
    public open func setResource(resource: String): This {
        return setResource(Resourcepart.froms(resource))
    }

    /**
     * 设置提供XMPP服务的主机的Internet地址。如果设置了，那么这将覆盖通过{@link#setHost（CharSequence）}设置的任何内容。
     *
     * @param address 提供XMPP服务的主机的互联网地址。
     * @return ConnectionConfigurationBuilder
     */
    public open func setHostAddress(address: IPAddress): This {
        this.hostAddress = address
        return this
    }

    /**
     * 设置提供XMPP服务的主机的名称。此方法接受DNS名称和IP地址。
     *
     * @param host 提供XMPP服务的主机的DNS名称。
     * @return ConnectionConfigurationBuilder
     */
    public open func setHost(host: String): This {
        if (let Some(ip) <- IPAddress.tryParse(host)) {
            setHostAddress(ip)
        } else {
            this.host = host
        }
        return this
    }

    /**
     * 设置端口号。
     *
     * @param port 端口号。
     * @return ConnectionConfigurationBuilder
     */
    public open func setPort(port: UInt16): This {
        this.port = Objects.requireNonNull(port)
        return this
    }

    /**
     * CallbackHandler只在使用SASL验证并且无password时使用
     *
     * @param callbackHandler CallbackHandler。
     * @return ConnectionConfigurationBuilder
     */
    public open func setCallbackHandler(callbackHandler: CallbackHandler): This {
        this.callbackHandler = callbackHandler
        return this
    }

    /**  
     * 设置 DNSSEC 模式
     *
     * @param dnssecMode 要设置的 DNSSEC 模式
     * @return 返回当前实例
     * @throws NullPointerException 如果传入的 dnssecMode 为 None
     */
    public open func setDnssecMode(dnssecMode: DnssecMode): This {
        this.dnssecMode = Objects.requireNonNull(dnssecMode, "DNSSEC mode must not be None")
        return this
    }

    /**
     * 设置建立连接时使用的TLS安全模式。默认情况下，模式为{@link SecurityMode#required}。
     *
     * @param securityMode 安全模式。
     * @return ConnectionConfigurationBuilder
     */
    public open func setSecurityMode(securityMode: ConnectionConfigurationSecurityMode): This {
        this.securityMode = securityMode
        return this
    }

    /**
     * 设置TlsClientConfig。
     *
     * @param tlsClientConfig TlsClientConfig
     * @return ConnectionConfigurationBuilder
     */
    public open func setTlsClientConfig(tlsClientConfig: ?TlsClientConfig): This {
        this.tlsClientConfig = tlsClientConfig
        return this
    }

    /**
     * 设置是否将初始可用状态发送到服务器。
     * 默认情况下，将向服务器发送一个可用状态，指示此状态不在线，无法接收消息。
     * 如果你想在不被“注意”的情况下登录，那么传递一个<code>false</code>值。
     *
     * @param sendPresence 如果登录时将发送初始可用状态，则为true。
     * @return ConnectionConfigurationBuilder
     */
    public open func setSendPresence(sendPresence: Bool): This {
        this.sendPresence = sendPresence
        return this
    }

    /**  
     * 启用默认调试器。
     *
     * 该方法从 Smack 配置中获取默认调试器工厂，并将其分配给 debuggerFactory
     * 字段。方法确保 debuggerFactory 不为 null，从而保证在返回当前实例之前
     * 设置了有效的调试器。
     *
     * @return 返回当前实例以支持链式调用。
     * @throws IllegalStateException 如果默认调试器工厂为 None。
     */
    public open func enableDefaultDebugger(): This {
        this.debuggerFactory = XmppConfiguration.getDefaultXmppDebuggerFactory()
        assert(this.debuggerFactory.isSome())
        return this
    }

    /**
     * 设置用于构造Xmpp调试器的Xmpp调试工厂。
     *
     * @param debuggerFactory Xmpp调试器工厂。
     * @return ConnectionConfigurationBuilder
     */
    public open func setDebuggerFactory(debuggerFactory: XmppDebuggerFactory): This {
        this.debuggerFactory = debuggerFactory
        return this
    }

    /**
     * 设置用于创建新xmppConnection套接字的套接字工厂。
     * 这在通过SOCKS5代理连接时非常有用。
     *
     * @param socketFactory 用于创建新套接字。
     * @return ConnectionConfigurationBuilder
     */
    public open func setSocketFactory(socketFactory: SocketFactory): This {
        this.socketFactory = socketFactory
        return this
    }

    /**
     * 设置有关用于连接的代理的信息。
     *
     * @param proxyInfo 代理信息。
     * @return ConnectionConfigurationBuilder
     */
    public open func setProxyInfo(proxyInfo: ProxyInfo): This {
        this.proxy = proxyInfo
        return this
    }

    /**
     * 允许<code>None</code>或空字符串作为用户名。
     *
     * 一些SASL机制（例如SASL外部）也可能发出用户名信号（作为“授权身份”），在这种情况下，当用户名未设置时，Xmpp不应抛出IllegalArgumentException。
     *
     * @return ConnectionConfigurationBuilder
     */
    public open func allowEmptyOrNullUsernames(): This {
        allowEmptyOrNullUsername = true
        return this
    }

    /**
     * 使用SASL anonymous执行匿名身份验证。您的XMPP服务必须支持此身份验证机制。
     * 此方法还调用{@link#addEnabledSaslMechanism（String）}，参数为“ANONYMOUS”。
     *
     * @return ConnectionConfigurationBuilder
     */
    public open func performSaslAnonymousAuthentication(): This {
        if (!SASLAuthentication.isSaslMechanismRegistered(SASLAnonymous.NAME)) {
            throw IllegalArgumentException("SASL ${SASLAnonymous.NAME} is not registered")
        }
        throwIfEnabledSaslMechanismsSet()
        allowEmptyOrNullUsernames()
        addEnabledSaslMechanism(SASLAnonymous.NAME)
        saslMechanismsSealed = true
        return this
    }

    /**
     * 使用SASL EXTERNAL执行身份验证。您的XMPP服务必须支持此身份验证机制。
     * 此方法还调用{@link#addEnabledSaslMechanism（String）}，参数为“EXTERNAL”。
     * 它还调用{@link#allowEmptyOrNullUsernames（）}和{@link#setSecurityMode（ConnectionConfiguration.SecurityMode）}
     *
     * @param sslContext 要使用的自定义SSLContext。
     * @return ConnectionConfigurationBuilder
     */
    public open func performSaslExternalAuthentication(sslContext: TlsClientConfig): This {
        if (!SASLAuthentication.isSaslMechanismRegistered(SASLMechanism.EXTERNAL)) {
            throw IllegalArgumentException("SASL ${SASLMechanism.EXTERNAL} is not registered")
        }
        setTlsClientConfig(sslContext) // setCustomSSLContext(sslContext)
        throwIfEnabledSaslMechanismsSet()
        allowEmptyOrNullUsernames()
        setSecurityMode(ConnectionConfigurationSecurityMode.required)
        addEnabledSaslMechanism(SASLMechanism.EXTERNAL)
        saslMechanismsSealed = true
        return this
    }

    private func throwIfEnabledSaslMechanismsSet(): Unit {
        if (enabledSaslMechanisms.isSome()) {
            throw Exception("Enabled SASL mechanisms found")
        }
    }

    /**
     * 将给定的机制添加到已启用的机制中。有关启用的SASL机制的讨论，请参阅{@link#addEnabledSaslMechanism（Collection）}。
     *
     * @param saslMechanism 要启用的机制的名称。
     * @return ConnectionConfigurationBuilder
     */
    public open func addEnabledSaslMechanism(saslMechanism: String): This {
        return addEnabledSaslMechanism(
            [StringUtils.requireNotNullNorEmpty(saslMechanism, "saslMechanism must not be null nor empty")])
    }

    /**
     * 启用给定的SASL机制。
     * 如果您从未将机制添加到已启用的机制集中，则Xmpp已知的所有机制都将被启用。
     * 只有当您想将使用的机制限制为已启用的机制时，才显式启用特定的SASL机制。
     *
     * @param saslMechanisms 一组要启用的机制名称。
     * @return ConnectionConfigurationBuilder
     */
    public open func addEnabledSaslMechanism(saslMechanisms: Collection<String>): This {
        if (saslMechanismsSealed) {
            throw IllegalStateException("The enabled SASL mechanisms are sealed, you can not add new ones")
        }
        CollectionUtil.requireNotEmpty(saslMechanisms, "saslMechanisms")
        let blacklistedMechanisms = SASLAuthentication.getBlacklistedSASLMechanisms()
        for (mechanism in saslMechanisms) {
            if (!SASLAuthentication.isSaslMechanismRegistered(mechanism)) {
                throw IllegalArgumentException("SASL ${mechanism} is not available. Consider registering it with Xmpp")
            }
            if (blacklistedMechanisms.contains(mechanism)) {
                throw IllegalArgumentException("SALS ${mechanism} is blacklisted.")
            }
        }
        if (enabledSaslMechanisms.isNone()) {
            enabledSaslMechanisms = HashSet<String>(saslMechanisms.size)
        }
        enabledSaslMechanisms?.putAll(saslMechanisms)
        return this
    }

    /**
     * 设置用作授权标识的XMPP地址。
     * <p>
     * 在XMPP中，授权身份是赤裸裸的。
     * 一般来说，调用者应该允许服务器自动选择授权标识符，而不是调用它。
     * 请注意，设置authzid不会设置XMPP服务域，通常应该匹配。
     * 调用此命令也将是SASL CRAM，因为此机制不支持authzid。
     * </p>
     *
     * @param authzid 请求BareJid作为授权标识符。
     * @return ConnectionConfigurationBuilder
     * @see <a href="http/tools/ietf/org/html/rfc6120#section-6.3.8">RFC 6120 § 6.3.8. Authorization Identity</a>
     */
    public open func setAuthzid(authzid: EntityBareJid): This {
        this.authzid = authzid
        return this
    }

    /**
     * 设置连接是否将使用压缩（默认为false）。
     *
     * 仅当服务器提供压缩时，才会激活压缩。通过压缩，网络流量可以减少高达90%。默认情况下，压缩是禁用的。
     *
     * @param compressionEnabled 如果连接将在HTTP级别使用压缩。
     * @return ConnectionConfigurationBuilder
     */
    public open func setCompressionEnabled(compressionEnabled: Bool): This {
        this.compressionEnabled = compressionEnabled
        return this
    }

    /**
     * 设置要使用的节ID源的工厂。
     *
     * @param stanzaIdSourceFactory 节ID源使用的工厂。
     * @return ConnectionConfigurationBuilder
     */
    public open func setStanzaIdSourceFactory(stanzaIdSourceFactory: StanzaIdSourceFactory): This {
        this.stanzaIdSourceFactory = Objects.requireNonNull(stanzaIdSourceFactory)
        return this
    }

    /**
     * 返回ConnectionConfiguration。
     *
     * @return 返回ConnectionConfiguration。
     */
    public func build(): ConnectionConfiguration
}

public enum ConnectionConfigurationSecurityMode <: ToString & Equatable<ConnectionConfigurationSecurityMode> {
    /**
     * 需要通过TLS加密进行安全保护才能连接。如果服务器不提供TLS或TLS协商失败，则与服务器的连接将失败。
     */
    | required
    /**
     * 只要可用，就会使用TLS加密的安全性。这是默认设置。
     * <p>
     * <b>除非不能使用{@link#required}，否则不要使用此设置</b>。攻击者可以轻松地执行中间人攻击并阻止TLS的使用，从而为您留下未加密（且未经验证）的连接。
     * </p>
     */
    | ifpossible
    /**
     * 通过TLS加密的安全性被禁用，只会使用未加密的连接。如果服务器只提供TLS加密，则连接将失败。
     */
    | disabled

    public override func toString(): String {
        return match (this) {
            case required => "required"
            case ifpossible => "ifpossible"
            case disabled => "disabled"
        }
    }

    public operator func ==(that: ConnectionConfigurationSecurityMode): Bool {
        return match ((this, that)) {
            case (required, required) => true
            case (ifpossible, ifpossible) => true
            case (disabled, disabled) => true
            case _ => false
        }
    }
}
