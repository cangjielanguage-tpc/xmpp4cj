/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * Base class for SASL mechanisms.
 * Subclasses will likely want to implement their own versions of these methods:
 * <ul>
 *  <li>{@link #authenticate(String, String, DomainBareJid, String, EntityBareJid, SSLSession)} -- Initiate authentication stanza using the
 *  deprecated method.</li>
 *  <li>{@link #authenticate(String, DomainBareJid, CallbackHandler, EntityBareJid, SSLSession)} -- Initiate authentication stanza
 *  using the CallbackHandler method.</li>
 *  <li>{@link #challengeReceived(String, boolean)} -- Handle a challenge from the server.</li>
 * </ul>
 */
public abstract class SASLMechanism <: Comparable<SASLMechanism> & ToString {
    public static let CRAMMD5 = "CRAM-MD5"
    public static let DIGESTMD5 = "DIGEST-MD5"
    public static let EXTERNAL = "EXTERNAL"
    public static let GSSAPI = "GSSAPI"
    public static let PLAIN = "PLAIN"

    /**
     * Boolean indicating if SASL negotiation has finished and was successful.
     */
    private var authenticationSuccessful: Bool = false

    /**
     * Either of type {@link XmppSaslException},{@link SASLErrorException}, {@link NotConnectedException} or
     * {@link InterruptedException}.
     */
    private var exception: ?Exception = None

    protected var connection: ?XMPPConnection = None

    protected var connectionConfiguration: ?ConnectionConfiguration = None

    /**
     * Then authentication identity (authcid). RFC 6120 § 6.3.7 informs us that some SASL mechanisms use this as a
     * "simple user name". But the exact form is a matter of the mechanism and that it does not necessarily map to an
     * localpart. But it usually is the localpart of the client JID, although sometimes other formats are used (e.g. the
     * full JID).
     * <p>
     * Not to be confused with the authzid (see RFC 6120 § 6.3.8).
     * </p>
     */
    public var authenticationId: ?String = None

    /**
     * The authorization identifier (authzid).
     * This is always a bare Jid, but can be null.
     */
    protected var authorizationId: ?EntityBareJid = None

    /**
     * The name of the XMPP service
     */
    protected var serviceName: ?DomainBareJid = None

    /**
     * The users password
     */
    public var password: ?String = None
    protected var host: ?String = None

    /**
     * The used SSL/TLS session (if any).
     */
    protected var sslSession: ?TlsSession = None

    /**
     * Builds and sends the <code>auth</code> stanza to the server. Note that this method of
     * authentication is not recommended, since it is very inflexible. Use
     * {@link #authenticate(String, DomainBareJid, CallbackHandler, EntityBareJid, SSLSession)} whenever possible.
     *
     * Explanation of auth stanza:
     *
     * The client authentication stanza needs to include the digest-uri of the form: xmpp/serviceName
     * From RFC-2831:
     * digest-uri = "digest-uri" "=" digest-uri-value
     * digest-uri-value = serv-type "/" host [ "/" serv-name ]
     *
     * digest-uri:
     * Indicates the principal name of the service with which the client
     * wishes to connect, formed from the serv-type, host, and serv-name.
     * For example, the FTP service
     * on "ftp.example.com" would have a "digest-uri" value of "ftp/ftp.example.com"; the SMTP
     * server from the example above would have a "digest-uri" value of
     * "smtp/mail3.example.com/example.com".
     *
     * host:
     * The DNS host name or IP address for the service requested. The DNS host name
     * must be the fully-qualified canonical name of the host. The DNS host name is the
     * preferred form; see notes on server processing of the digest-uri.
     *
     * serv-name:
     * Indicates the name of the service if it is replicated. The service is
     * considered to be replicated if the client's service-location process involves resolution
     * using standard DNS lookup operations, and if these operations involve DNS records (such
     * as SRV, or MX) which resolve one DNS name into a set of other DNS names. In this case,
     * the initial name used by the client is the "serv-name", and the final name is the "host"
     * component. For example, the incoming mail service for "example.com" may be replicated
     * through the use of MX records stored in the DNS, one of which points at an SMTP server
     * called "mail3.example.com"; it's "serv-name" would be "example.com", it's "host" would be
     * "mail3.example.com". If the service is not replicated, or the serv-name is identical to
     * the host, then the serv-name component MUST be omitted
     *
     * digest-uri verification is needed for ejabberd 2.0.3 and higher
     *
     * @param username the username of the user being authenticated.
     * @param host the hostname where the user account resides.
     * @param serviceName the xmpp service location - used by the SASL client in digest-uri creation
     * serviceName format is: host [ "/" serv-name ] as per RFC-2831
     * @param password the password for this account.
     * @param authzid the optional authorization identity.
     * @param sslSession the optional SSL/TLS session (if one was established)
     * @throws XmppSaslException if a SASL related error occurs.
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    public func authenticate(
        username: ?String,
        host: String,
        serviceName: DomainBareJid,
        password: ?String,
        authzid: ?EntityBareJid,
        sslSession: ?TlsSession
    ): Unit {
        this.authenticationId = username
        this.host = host
        this.serviceName = serviceName
        this.password = password
        this.authorizationId = authzid
        this.sslSession = sslSession
        assert(authorizationId.isNone() || authzidSupported())
        authenticateInternal()
        authenticate()
    }

    protected open func authenticateInternal(): Unit {}

    /**
     * Builds and sends the <code>auth</code> stanza to the server. The callback handler will handle
     * any additional information, such as the authentication ID or realm, if it is needed.
     *
     * @param host     the hostname where the user account resides.
     * @param serviceName the xmpp service location
     * @param cbh      the CallbackHandler to obtain user information.
     * @param authzid the optional authorization identity.
     * @param sslSession the optional SSL/TLS session (if one was established)
     * @throws XmppSaslException if a SASL related error occurs.
     * @throws NotConnectedException if the XMPP connection is not connected.
     * @throws InterruptedException if the calling thread was interrupted.
     */
    public open func authenticate(
        host: String,
        serviceName: DomainBareJid,
        cbh: ?CallbackHandler,
        authzid: ?EntityBareJid,
        sslSession: ?TlsSession
    ): Unit {
        this.host = host
        this.serviceName = serviceName
        this.authorizationId = authzid
        this.sslSession = sslSession
        assert(authorizationId.isNone() || authzidSupported())
        authenticateInternal(cbh)
        authenticate()
    }

    protected func authenticateInternal(cbh: ?CallbackHandler): Unit

    private func authenticate(): Unit {
        let authenticationBytes = getAuthenticationText()
        let authenticationText: String = if (((authenticationBytes?.size) ?? -1) > 0) {
            toBase64String(authenticationBytes.getOrThrow())
        } else {
            "="
        }
        connection?.sendNonza(SaslNonzaAuthMechanism(getName(), authenticationText))
    }

    /**
     * Should return the initial response of the SASL mechanism. The returned byte array will be
     * send base64 encoded to the server. SASL mechanism are free to return <code>null</code> or an
     * empty array here.
     *
     * @return the initial response or null
     * @throws XmppSaslException if a SASL specific error occurred.
     */
    protected func getAuthenticationText(): ?Array<UInt8>

    /**
     * The server is challenging the SASL mechanism for the stanza he just sent. Send a
     * response to the server's challenge.
     *
     * @param challengeString a base64 encoded string representing the challenge.
     * @param finalChallenge true if this is the last challenge send by the server within the success stanza
     * @throws XmppSaslException if a SASL related error occurs.
     * @throws InterruptedException if the connection is interrupted
     * @throws NotConnectedException if the XMPP connection is not connected.
     */
    public func challengeReceived(challengeString: ?String, finalChallenge: Bool): Unit {
        var str = challengeString ?? ""
        if (str == "=") {
            str = ""
        }
        let challenge = fromBase64String(str)
        let response = evaluateChallenge(challenge.getOrThrow())
        if (finalChallenge) {
            return
        }
        let responseStanza: SaslNonzaResponse = if (let Some(v) <- response) {
            SaslNonzaResponse(toBase64String(v))
        } else {
            SaslNonzaResponse()
        }
        connection?.sendNonza(responseStanza)
    }

    /**
     * Evaluate the SASL challenge.
     *
     * @param challenge challenge to evaluate.
     *
     * @return null.
     * @throws XmppSaslException If a SASL related error occurs.
     */
    protected open func evaluateChallenge(challenge: Array<UInt8>): ?Array<UInt8> {
        return None
    }

    public override func compare(other: SASLMechanism): Ordering {
        let ourPriority = getPriority()
        return ourPriority.compare(other.getPriority())
    }

    /**
     * Returns the common name of the SASL mechanism. E.g.: PLAIN, DIGEST-MD5 or GSSAPI.
     *
     * @return the common name of the SASL mechanism.
     */
    public func getName(): String

    /**
     * Get the priority of this SASL mechanism. Lower values mean higher priority.
     *
     * @return the priority of this SASL mechanism.
     */
    public func getPriority(): Int

    /**
     * Check if the SASL mechanism was successful and if it was, then mark it so.
     *
     * @throws XmppSaslException in case of an SASL error.
     */
    public func afterFinalSaslChallenge(): Unit {
        checkIfSuccessfulOrThrow()
        authenticationSuccessful = true
    }

    protected func checkIfSuccessfulOrThrow(): Unit

    public func instanceForAuthentication(connection: XMPPConnection, connectionConfiguration: ConnectionConfiguration): SASLMechanism {
        let saslMechansim = newInstance()
        saslMechansim.connection = connection
        saslMechansim.connectionConfiguration = connectionConfiguration
        return saslMechansim
    }

    public open func authzidSupported(): Bool {
        return false
    }

    public open func requiresPassword(): Bool {
        return true
    }

    public open func isAuthenticationSuccessful(): Bool {
        return authenticationSuccessful
    }

    public open func isFinished(): Bool {
        return isAuthenticationSuccessful() || exception.isSome()
    }

    public open func throwExceptionIfRequired(): Unit {
        if (let Some(e) <- exception) {
            match (e) {
                case v: XmppSaslException => throw v
                case v: SASLErrorException => throw v
                case v: NotConnectedException => throw v
                // case v: InterruptedException => throw v // TODO
                case _ => throw IllegalStateException("Unexpected exception type ${exception}")
            }
        }
        if (!authenticationSuccessful) {
            throw NoResponseException.newWith(connection(), "successful SASL authentication")
        }
    }

    public func setException(exception: Exception): Unit {
        this.exception = exception
    }

    protected func newInstance(): SASLMechanism

    protected static func toBytes(string: String): Array<UInt8> {
        return StringUtils.toUtf8Bytes(string)
    }

    /**
     * SASLprep the given String. The resulting String is in UTF-8.
     *
     * @param string the String to sasl prep.
     * @return the given String SASL preped
     * @see <a href="http/tools/ietf/org/html/rfc4013">RFC 4013 - SASLprep: Stringprep Profile for User Names and Passwords</a>
     */
    protected static func saslPrep(string: String): String {
        // return Normalizer.normalize(string, Normalizer_Form.NFKC) // not support yet
        string
    }
    public override func toString(): String {
        return "SASL Mech: ${getName()}, Prio: ${getPriority()}"
    }
}
