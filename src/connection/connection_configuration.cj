/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * The connection configuration used for XMPP client-to-server connections. A well configured XMPP service will
 * typically only require you to provide two parameters: The XMPP address, also known as the JID, of the user and the
 * password. All other configuration parameters could ideally be determined automatically by Xmpp. Hence it is often
 * enough to call {@link Builder#setXmppAddressAndPassword(CharSequence, String)}.
 * <p>
 * Technically there are typically at least two parameters required: Some kind of credentials for authentication. And
 * the XMPP service domain. The credentials often consists of a username and password use for the SASL authentication.
 * But there are also other authentication mechanisms, like client side certificates, which do not require a particular
 * username and password.
 * </p>
 * <p>
 * There are some misconceptions about XMPP client-to-server parameters: The first is that the username used for
 * authentication will be equal to the localpart of the bound XMPP address after authentication. While this is usually
 * true, it is not required. Technically the username used for authentication and the resulting XMPP address are
 * completely independent from each other. The second common misconception steers from the terms "XMPP host" and "XMPP
 * service domain": An XMPP service host is a system which hosts one or multiple XMPP domains. The "XMPP service domain"
 * will be usually the domainpart of the bound JID. This domain is used to verify the remote endpoint, typically using
 * TLS. This third misconception is that the XMPP service domain is required to become the domainpart of the bound JID.
 * Again, while this is very common to be true, it is not strictly required.
 * </p>
 */
public abstract class ConnectionConfiguration {
    static init() {
        // Xmpp.ensureInitialized() // TODO
    }
    private static let LOGGER = getGlobalLogger(("name", "ConnectionConfiguration"))

    /**
     * The XMPP domain of the XMPP Service.
     * Usually servers use the same service name as the name of the server.
     * However, there are some servers like google where host would be talk/google/com and the serviceName would be gmail/com.
     */
    protected let xmppServiceDomain: DomainBareJid

    protected let xmppServiceDomainDnsName: ?DnsName

    protected let hostAddress: ?IPAddress
    protected let host: ?DnsName
    protected let port: UInt16

    private let debuggerFactory: ?XmppDebuggerFactory

    // Holds the socket factory that is used to generate the socket in the connection
    private let socketFactory: ?SocketFactory

    private let username: String

    private let password: String

    private let resource: ?Resourcepart

    private var language: ?String

    /**
     * The optional SASL authorization identity (see RFC 6120 § 6.3.8).
     */
    private let authzid: ?EntityBareJid

    /**
     * Initial presence as of RFC 6121 § 4.2
     * @see <a href="xmpp/org/rfcs/rfc6121.html#presence-initial">RFC 6121 § 4.2 Initial Presence</a>
     */
    private let sendPresence: Bool

    private let securityMode: ConnectionConfigurationSecurityMode

    let xmppTlsContext: XmppTlsContext

    private let dnssecMode: DnssecMode

    // tls配置统一到TlsClientConfig
    private let tlsClientConfig: ?TlsClientConfig

    // Holds the proxy information (such as proxyhost, proxyport, username, password etc)
    protected let proxy: ?ProxyInfo

    protected let allowNullOrEmptyUsername: Bool

    private let enabledSaslMechanisms: ?Set<String>

    private let compressionEnabled: Bool

    private let stanzaIdSourceFactory: StanzaIdSourceFactory

    protected init(builder: ConnectionConfigurationBuilder) {
        try {
            this.xmppTlsContext = getXmppTlsContext(builder.dnssecMode, builder.tlsClientConfig)
        } catch (e: Exception) {
            throw IllegalArgumentException()
        }

        this.authzid = builder.authzid
        this.username = builder.username
        this.password = builder.password

        // Resource can be null, this means that the server must provide one
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

        // If the enabledSaslmechanisms are set, then they must not be empty
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
            // User requested DANE verification.
            daneVerifier?.initself(cfg)
        }
        return XmppTlsContext(cfg, daneVerifier)
    }

    public func getHostString(): String {
        if (let Some(v) <- hostAddress) {
            return v.toString()
        }
        if (let Some(v) <- host) {
            return v.toString()
        }
        return xmppServiceDomain.toString()
    }

    public func getHost(): ?DnsName {
        return host
    }

    public func getHostAddress(): ?IPAddress {
        return hostAddress
    }

    public func getPort(): UInt16 {
        return port
    }

    /**
     * Returns the XMPP domain used by this configuration.
     *
     * @return the XMPP domain.
     */
    public func getXMPPServiceDomain(): DomainBareJid {
        return xmppServiceDomain
    }

    /**
     * Returns the XMPP service domain as DNS name if possible. Note that since not every XMPP address domainpart is a
     * valid DNS name, this method may return <code>null</code>.
     *
     * @return the XMPP service domain as DNS name or <code>null</code>.
     */
    public func getXmppServiceDomainAsDnsNameIfPossible(): ?DnsName {
        return xmppServiceDomainDnsName
    }

    /**
     * Returns the TLS security mode used when making the connection. By default,
     * the mode is {@link SecurityMode#required}.
     *
     * @return the security mode.
     */
    public func getSecurityMode(): ConnectionConfigurationSecurityMode {
        return securityMode
    }

    public func getDnssecMode(): DnssecMode {
        return dnssecMode
    }

    /**
     * Return the TlsClientConfig.
     *
     * @return the TlsClientConfig
     */
    public func getTlsClientConfig(): ?TlsClientConfig {
        return tlsClientConfig
    }

    /**
     * Returns the Xmpp debugger factory.
     *
     * @return the Xmpp debugger factory or <code>null</code>
     */
    public func getDebuggerFactory(): ?XmppDebuggerFactory {
        return debuggerFactory
    }

    /**
     * Returns the socket factory used to create new xmppConnection sockets.
     * This is useful when connecting through SOCKS5 proxies.
     *
     * @return socketFactory used to create new sockets.
     */
    public func getSocketFactory(): ?SocketFactory {
        return socketFactory
    }

    /**
     * Returns a CallbackHandler to obtain information, such as the password or
     * principal information during the SASL authentication. A CallbackHandler
     * will be used <b>ONLY</b> if no password was specified during the login while
     * using SASL authentication.
     *
     * @return a CallbackHandler to obtain information, such as the password or
     * principal information during the SASL authentication.
     */
    public func getCallbackHandler(): ?CallbackHandler {
        return None // TODO
    }

    /**
     * Get the configured proxy information (if any).
     *
     * @return the configured proxy information or <code>null</code>.
     */
    public func getProxyInfo(): ?ProxyInfo {
        return proxy
    }

    /**
     * Returns the username to use when trying to reconnect to the server.
     *
     * @return the username to use when trying to reconnect to the server.
     */
    public func getUsername(): String {
        return username
    }

    /**
     * Returns the password to use when trying to reconnect to the server.
     *
     * @return the password to use when trying to reconnect to the server.
     */
    public func getPassword(): String {
        return password
    }

    /**
     * Returns the resource to use when trying to reconnect to the server.
     *
     * @return the resource to use when trying to reconnect to the server.
     */
    public func getResource(): ?Resourcepart {
        return resource
    }

    /**
     * Returns the stream language to use when connecting to the server.
     *
     * @return the stream language to use when connecting to the server.
     */
    public func getLanguage(): ?String {
        return language
    }

    /**
     * Returns the xml:lang string of the stream language to use when connecting to the server.
     *
     * <p>If the developer sets the language to null, this will also return null, leading to
     * the removal of the xml:lang tag from the stream. If a Locale("") is configured, this will
     * return "", which can be used as an override.</p>
     *
     * @return the stream language to use when connecting to the server.
     */
    public func getXmlLang(): ?String {
        language?.replace("_", "-")
    }

    /**
     * Returns the optional XMPP address to be requested as the SASL authorization identity.
     *
     * @return the authorization identifier.
     * @see <a href="http/tools/ietf/org/html/rfc6120#section-6.3.8">RFC 6120 § 6.3.8. Authorization Identity</a>
     */
    public func getAuthzid(): ?EntityBareJid {
        return authzid
    }

    /**
     * Returns true if an available presence should be sent when logging in while reconnecting.
     *
     * @return true if an available presence should be sent when logging in while reconnecting
     */
    public func isSendPresence(): Bool {
        return sendPresence
    }

    /**
     * Returns true if the connection is going to use stream compression. Stream compression
     * will be requested after TLS was established (if TLS was enabled) and only if the server
     * offered stream compression. With stream compression network traffic can be reduced
     * up to 90%. By default compression is disabled.
     *
     * @return true if the connection is going to use stream compression.
     */
    public func isCompressionEnabled(): Bool {
        return compressionEnabled
    }

    /**
     * Check if the given SASL mechansism is enabled in this connection configuration.
     *
     * @param saslMechanism TODO javadoc me please
     * @return true if the given SASL mechanism is enabled, false otherwise.
     */
    public func isEnabledSaslMechanism(saslMechanism: String): Bool {
        if (let Some(v) <- enabledSaslMechanisms) {
            return v.contains(saslMechanism)
        } else {
            return !SASLAuthentication.getBlacklistedSASLMechanisms().contains(saslMechanism)
        }
    }

    /**
     * Return the explicitly enabled SASL mechanisms. May return <code>null</code> if no SASL mechanisms where
     * explicitly enabled, i.e. all SALS mechanisms supported and announced by the service will be considered.
     *
     * @return the enabled SASL mechanisms or <code>null</code>.
     */
    public func getEnabledSaslMechanisms(): ?Set<String> {
        if (let Some(v) <- enabledSaslMechanisms) {
            return v // TODO Collections.unmodifiableSet(enabledSaslMechanisms)
        } else {
            return None
        }
    }

    public func constructStanzaIdSource(): StanzaIdSource {
        return stanzaIdSourceFactory.constructStanzaIdSource()
    }
}

public abstract class ConnectionConfigurationBuilder {
    var securityMode: ConnectionConfigurationSecurityMode = ConnectionConfigurationSecurityMode.required

    var dnssecMode: DnssecMode = DnssecMode.disabled

    var tlsClientConfig: ?TlsClientConfig = None

    var authzid: ?EntityBareJid = None

    var username: String = ""

    var password: String = ""

    var resource: ?Resourcepart = None

    var language: String = "zh_CN"

    var sendPresence = true

    var proxy: ?ProxyInfo = None

    var debuggerFactory: ?XmppDebuggerFactory = None

    var socketFactory: ?SocketFactory = None

    var xmppServiceDomain: ?DomainBareJid = None

    var hostAddress: ?IPAddress = None

    var host: ?DnsName = None

    var port: UInt16 = 5222

    var allowEmptyOrNullUsername = false

    private var saslMechanismsSealed: Bool = false

    var enabledSaslMechanisms: ?Set<String> = None

    var customX509TrustManager: ?TlsClientConfig = None

    var compressionEnabled = false

    var stanzaIdSourceFactory: StanzaIdSourceFactory = StandardStanzaIdSourceFactory()

    public ConnectionConfigurationBuilder() {
        if (XmppConfiguration.DEBUG) {
            this.debuggerFactory = XmppConfiguration.getDefaultXmppDebuggerFactory()
            assert(this.debuggerFactory.isSome())
        }
    }

    /**
     * Convenience method to configure the username, password and XMPP service domain.
     *
     * @param jid the XMPP address of the user.
     * @param password the password of the user.
     * @return a reference to this builder.
     * @throws XmppStringprepException in case the XMPP address is not valid.
     * @see #setXmppAddressAndPassword(EntityBareJid, String)
     */
    public func setXmppAddressAndPassword(jid: String, password: String): ConnectionConfigurationBuilder {
        return setXmppAddressAndPassword(JidCreate.entityBareFrom(jid), password)
    }

    /**
     * Convenience method to configure the username, password and XMPP service domain. The localpart of the provided
     * JID is used as username and the domanipart is used as XMPP service domain.
     * <p>
     * Please note that this does and can not configure the client XMPP address. XMPP services are not required to
     * assign bound JIDs where the localpart matches the username and the domainpart matches the verified domainpart.
     * Although most services will follow that pattern.
     * </p>
     *
     * @param jid TODO javadoc me please
     * @param password TODO javadoc me please
     * @return a reference to this builder.
     */
    public func setXmppAddressAndPassword(jid: EntityBareJid, password: String): ConnectionConfigurationBuilder {
        setUsernameAndPassword(jid.getLocalpart().toString(), password)
        return setXmppDomain(jid.asDomainBareJid())
    }

    /**
     * Set the XMPP entities username and password.
     * <p>
     * The username is usually the localpart of the clients JID. But some SASL mechanisms or services may require a different
     * format (e.g. the full JID) as used authorization identity.
     * </p>
     *
     * @param username the username or authorization identity
     * @param password the password or token used to authenticate
     * @return a reference to this builder.
     */
    public func setUsernameAndPassword(username: String, password: String): ConnectionConfigurationBuilder {
        this.username = username
        this.password = password
        return getThis()
    }

    /**
     * Set the XMPP domain. The XMPP domain is what follows after the '@' sign in XMPP addresses (JIDs).
     *
     * @param xmppDomain the XMPP domain.
     * @return a reference to this builder.
     */
    public func setXmppDomain(xmppDomain: DomainBareJid): ConnectionConfigurationBuilder {
        this.xmppServiceDomain = xmppDomain
        return getThis()
    }

    /**
     * Set the XMPP domain. The XMPP domain is what follows after the '@' sign in XMPP addresses (JIDs).
     *
     * @param xmppServiceDomain the XMPP domain.
     * @return a reference to this builder.
     * @throws XmppStringprepException if the given string is not a domain bare JID.
     */
    public func setXmppDomain(xmppServiceDomain: String): ConnectionConfigurationBuilder {
        this.xmppServiceDomain = JidCreate.domainBareFrom(xmppServiceDomain)
        return getThis()
    }

    /**
     * Set the resource we are requesting from the server.
     * <p>
     * If <code>resource</code> is <code>null</code>, the default, then the server will automatically create a
     * resource for the client. Note that XMPP clients only suggest this resource to the server. XMPP servers are
     * allowed to ignore the client suggested resource and instead assign a completely different
     * resource (see RFC 6120 § 7.7.1).
     * </p>
     *
     * @param resource the resource to use.
     * @return a reference to this builder.
     * @see <a href="https/tools/ietf/org/html/rfc6120#section-7.7.1">RFC 6120 § 7.7.1</a>
     */
    public func setResource(resource: Resourcepart): ConnectionConfigurationBuilder {
        this.resource = resource
        return getThis()
    }

    /**
     * Set the stream language.
     *
     * @param language the language to use.
     * @return a reference to this builder.
     * @see <a href="https/tools/ietf/org/html/rfc6120#section-4.7.4">RFC 6120 § 4.7.4</a>
     * @see <a href="https/www/w3/org/TR/xml/#sec-lang-tag">XML 1.0 § 2.12 Language Identification</a>
     */
    public func setLanguage(language: String): ConnectionConfigurationBuilder {
        this.language = language
        return getThis()
    }

    /**
     * Set the resource we are requesting from the server.
     *
     * @param resource the non-null CharSequence to use a resource.
     * @return a reference ot this builder.
     * @throws XmppStringprepException if the CharSequence is not a valid resourcepart.
     * @see #setResource(Resourcepart)
     */
    public func setResource(resource: String): ConnectionConfigurationBuilder {
        return setResource(Resourcepart.froms(resource))
    }

    /**
     * Set the Internet address of the host providing the XMPP service. If set, then this will overwrite anything
     * set via {@link #setHost(CharSequence)}.
     *
     * @param address the Internet address of the host providing the XMPP service.
     * @return a reference to this builder.
     */
    public func setHostAddress(address: IPAddress): ConnectionConfigurationBuilder {
        this.hostAddress = address
        return getThis()
    }

    /**
     * Set the name of the host providing the XMPP service. This method takes DNS names and
     * IP addresses.
     *
     * @param host the DNS name of the host providing the XMPP service.
     * @return a reference to this builder.
     */
    public func setHost(host: String): ConnectionConfigurationBuilder {
        if (let Some(ip) <- IPAddress.tryParse(host)) {
            setHostAddress(ip)
        } else {
            this.host = host
        }
        return getThis()
    }

    public func setPort(port: Int64): ConnectionConfigurationBuilder {
        if (port < 0 || port > 65535) {
            throw IllegalArgumentException(
                "Port must be a 16-bit unsigned integer (i.e. between 0-65535. Port was: ${port.toString()}")
        }
        let portUint16 = UInt16(port)
        return setPort(portUint16)
    }

    public func setPort(port: UInt16): ConnectionConfigurationBuilder {
        this.port = Objects.requireNonNull(port)
        return getThis()
    }

    public func setDnssecMode(dnssecMode: DnssecMode): ConnectionConfigurationBuilder {
        this.dnssecMode = Objects.requireNonNull(dnssecMode, "DNSSEC mode must not be null")
        return getThis()
    }

    /**
     * Sets the TLS security mode used when making the connection. By default,
     * the mode is {@link SecurityMode#required}.
     *
     * @param securityMode the security mode.
     * @return a reference to this builder.
     */
    public func setSecurityMode(securityMode: ConnectionConfigurationSecurityMode): ConnectionConfigurationBuilder {
        this.securityMode = securityMode
        return getThis()
    }

    /**
     * Set the TlsClientConfig.
     *
     * @param TlsClientConfig
     * @return a reference to this builder.
     */
    public func setTlsClientConfig(tlsClientConfig: ?TlsClientConfig): ConnectionConfigurationBuilder {
        this.tlsClientConfig = tlsClientConfig
        return getThis()
    }

    /**
     * Sets if an initial available presence will be sent to the server. By default
     * an available presence will be sent to the server indicating that this presence
     * is not online and available to receive messages. If you want to log in without
     * being 'noticed' then pass a <code>false</code> value.
     *
     * @param sendPresence true if an initial available presence will be sent while logging in.
     * @return a reference to this builder.
     */
    public func setSendPresence(sendPresence: Bool): ConnectionConfigurationBuilder {
        this.sendPresence = sendPresence
        return getThis()
    }

    public func enableDefaultDebugger(): ConnectionConfigurationBuilder {
        this.debuggerFactory = XmppConfiguration.getDefaultXmppDebuggerFactory()
        assert(this.debuggerFactory.isSome())
        return getThis()
    }

    /**
     * Set the Xmpp debugger factory used to construct Xmpp debuggers.
     *
     * @param debuggerFactory the Xmpp debugger factory.
     * @return a reference to this builder.
     */
    public func setDebuggerFactory(debuggerFactory: XmppDebuggerFactory): ConnectionConfigurationBuilder {
        this.debuggerFactory = debuggerFactory
        return getThis()
    }

    /**
     * Sets the socket factory used to create new xmppConnection sockets.
     * This is useful when connecting through SOCKS5 proxies.
     *
     * @param socketFactory used to create new sockets.
     * @return a reference to this builder.
     */
    public func setSocketFactory(socketFactory: SocketFactory): ConnectionConfigurationBuilder {
        this.socketFactory = socketFactory
        return getThis()
    }

    /**
     * Set the information about the Proxy used for the connection.
     *
     * @param proxyInfo the Proxy information.
     * @return a reference to this builder.
     */
    public func setProxyInfo(proxyInfo: ProxyInfo): ConnectionConfigurationBuilder {
        this.proxy = proxyInfo
        return getThis()
    }

    /**
     * Allow <code>null</code> or the empty String as username.
     *
     * Some SASL mechanisms (e.g. SASL External) may also signal the username (as "authorization identity"), in
     * which case Xmpp should not throw an IllegalArgumentException when the username is not set.
     *
     * @return a reference to this builder.
     */
    public func allowEmptyOrNullUsernames(): ConnectionConfigurationBuilder {
        allowEmptyOrNullUsername = true
        return getThis()
    }

    /**
     * Perform anonymous authentication using SASL ANONYMOUS. Your XMPP service must support this authentication
     * mechanism. This method also calls {@link #addEnabledSaslMechanism(String)} with "ANONYMOUS" as argument.
     *
     * @return a reference to this builder.
     */
    public func performSaslAnonymousAuthentication(): ConnectionConfigurationBuilder {
        if (!SASLAuthentication.isSaslMechanismRegistered(SASLAnonymous.NAME)) {
            throw IllegalArgumentException("SASL ${SASLAnonymous.NAME} is not registered")
        }
        throwIfEnabledSaslMechanismsSet()
        allowEmptyOrNullUsernames()
        addEnabledSaslMechanism(SASLAnonymous.NAME)
        saslMechanismsSealed = true
        return getThis()
    }

    /**
     * Perform authentication using SASL EXTERNAL. Your XMPP service must support this
     * authentication mechanism. This method also calls {@link #addEnabledSaslMechanism(String)} with "EXTERNAL" as
     * argument. It also calls {@link #allowEmptyOrNullUsernames()} and {@link #setSecurityMode(ConnectionConfiguration.SecurityMode)} to
     * {@link SecurityMode#required}.
     *
     * @param sslContext custom SSLContext to be used.
     * @return a reference to this builder.
     */
    public func performSaslExternalAuthentication(sslContext: TlsClientConfig): ConnectionConfigurationBuilder {
        if (!SASLAuthentication.isSaslMechanismRegistered(SASLMechanism.EXTERNAL)) {
            throw IllegalArgumentException("SASL ${SASLMechanism.EXTERNAL} is not registered")
        }
        setTlsClientConfig(sslContext) // setCustomSSLContext(sslContext)
        throwIfEnabledSaslMechanismsSet()
        allowEmptyOrNullUsernames()
        setSecurityMode(ConnectionConfigurationSecurityMode.required)
        addEnabledSaslMechanism(SASLMechanism.EXTERNAL)
        saslMechanismsSealed = true
        return getThis()
    }

    private func throwIfEnabledSaslMechanismsSet(): Unit {
        if (enabledSaslMechanisms.isSome()) {
            throw Exception("Enabled SASL mechanisms found")
        }
    }

    /**
     * Add the given mechanism to the enabled ones. See {@link #addEnabledSaslMechanism(Collection)} for a discussion about enabled SASL mechanisms.
     *
     * @param saslMechanism the name of the mechanism to enable.
     * @return a reference to this builder.
     */
    public func addEnabledSaslMechanism(saslMechanism: String): ConnectionConfigurationBuilder {
        return addEnabledSaslMechanism(
            [StringUtils.requireNotNullNorEmpty(saslMechanism, "saslMechanism must not be null nor empty")])
    }

    /**
     * Enable the given SASL mechanisms. If you never add a mechanism to the set of enabled ones, <b>all mechanisms
     * known to Xmpp</b> will be enabled. Only explicitly enable particular SASL mechanisms if you want to limit
     * the used mechanisms to the enabled ones.
     *
     * @param saslMechanisms a collection of names of mechanisms to enable.
     * @return a reference to this builder.
     */
    public func addEnabledSaslMechanism(saslMechanisms: Collection<String>): ConnectionConfigurationBuilder {
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
        return getThis()
    }

    /**
     * Set the XMPP address to be used as authorization identity.
     * <p>
     * In XMPP, authorization identities are bare jids. In general, callers should allow the server to select the
     * authorization identifier automatically, and not call this. Note that setting the authzid does not set the XMPP
     * service domain, which should typically match.
     * Calling this will also SASL CRAM, since this mechanism does not support authzid.
     * </p>
     *
     * @param authzid The BareJid to be requested as the authorization identifier.
     * @return a reference to this builder.
     * @see <a href="http/tools/ietf/org/html/rfc6120#section-6.3.8">RFC 6120 § 6.3.8. Authorization Identity</a>
     */
    public func setAuthzid(authzid: EntityBareJid): ConnectionConfigurationBuilder {
        this.authzid = authzid
        return getThis()
    }

    /**
     * Sets if the connection is going to use compression (default false).
     *
     * Compression is only activated if the server offers compression. With compression network
     * traffic can be reduced up to 90%. By default compression is disabled.
     *
     * @param compressionEnabled if the connection is going to use compression on the HTTP level.
     * @return a reference to this object.
     */
    public func setCompressionEnabled(compressionEnabled: Bool): ConnectionConfigurationBuilder {
        this.compressionEnabled = compressionEnabled
        return getThis()
    }

    /**
     * Set the factory for stanza ID sources to use.
     *
     * @param stanzaIdSourceFactory the factory for stanza ID sources to use.
     * @return a reference to this builder.
     */
    public func setStanzaIdSourceFactory(stanzaIdSourceFactory: StanzaIdSourceFactory): ConnectionConfigurationBuilder {
        this.stanzaIdSourceFactory = Objects.requireNonNull(stanzaIdSourceFactory)
        return getThis()
    }

    public func build(): ConnectionConfiguration

    protected func getThis(): ConnectionConfigurationBuilder
}

public enum ConnectionConfigurationSecurityMode <: ToString & Equatable<ConnectionConfigurationSecurityMode> {
    /**
     * Security via TLS encryption is required in order to connect. If the server
     * does not offer TLS or if the TLS negotiation fails, the connection to the server
     * will fail.
     */
    | required
    /**
     * Security via TLS encryption is used whenever it's available. This is the
     * default setting.
     * <p>
     * <b>Do not use this setting</b> unless you can't use {@link #required}. An attacker could easily perform a
     * Man-in-the-middle attack and prevent TLS from being used, leaving you with an unencrypted (and
     * unauthenticated) connection.
     * </p>
     */
    | ifpossible
    /**
     * Security via TLS encryption is disabled and only un-encrypted connections will
     * be used. If only TLS encryption is available from the server, the connection
     * will fail.
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
