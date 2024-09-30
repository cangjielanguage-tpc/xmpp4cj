/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/**
 * Xmpp uses Xmpp4cjExceptions for errors that are not defined by any XMPP specification.
 */
public abstract class Xmpp4cjException <: Exception {
    public let cause: ?Exception
    /**
     * Creates a new Xmpp4cjException with the Throwable that was the root cause of the exception.
     *
     * @param wrappedThrowable the root cause of the exception.
     */
    protected init(wrappedThrowable: Exception) {
        this("", wrappedThrowable)
    }

    protected init(message: String) {
        this(message, None)
    }

    protected init(message: String, wrappedThrowable: ?Exception) {
        super(message)
        this.cause = wrappedThrowable
    }

    protected init() {
        this("", None)
    }
}

public class NotLoggedInException <: Xmpp4cjException {
    public init() {
        super("Client is not logged in")
    }
}

public class AlreadyLoggedInException <: Xmpp4cjException {
    public init() {
        super("Client is already logged in")
    }
}

public class AlreadyConnectedException <: Xmpp4cjException {
    public init() {
        super("Client is already connected")
    }
}

public class IllegalStateChangeException <: Xmpp4cjException {}

public abstract class SecurityRequiredException <: Xmpp4cjException {
    public init(message: String) {
        super(message)
    }
}

public class SecurityRequiredByClientException <: SecurityRequiredException {
    public init() {
        super("SSL/TLS required by client but not supported by server")
    }
}

public class SecurityRequiredByServerException <: SecurityRequiredException {
    public init() {
        super("SSL/TLS required by server but disabled in client")
    }
}

public class SecurityNotPossibleException <: Xmpp4cjException {
    public init(message: String) {
        super(message)
    }
}

public abstract class ConnectionException <: Xmpp4cjException {
    protected init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }

    protected init(message: String) {
        super(message)
    }
}

public class GenericConnectionException <: ConnectionException {
    public init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }
}

/**
 * This exception is thrown if Xmpp is unable to connect to all hosts of a given XMPP
 * service. The connection exceptions can be retrieved with
 * {@link EndpointConnectionException#getConnectionExceptions()}, which will have the exception causing the
 * connection failure set and retrievable with {@link RemoteConnectionException#getException()}.
 */
public class EndpointConnectionException <: ConnectionException {
    private let lookupFailures: Collection<RemoteConnectionEndpointLookupFailure>

    private let connectionExceptions: Collection<RemoteConnectionException<RemoteConnectionEndpoint>>

    private init(message: String, lookupFailures: Collection<RemoteConnectionEndpointLookupFailure>,
        connectionExceptions: Collection<RemoteConnectionException<RemoteConnectionEndpoint>>) {
        super(message)
        // At least one list must contain an entry.
        if (lookupFailures.isEmpty() && connectionExceptions.isEmpty()) {
            throw Exception("AssertionError")
        }
        this.lookupFailures = lookupFailures
        this.connectionExceptions = connectionExceptions
    }

    public static func comefrom(
        lookupFailures: Collection<RemoteConnectionEndpointLookupFailure>,
        connectionExceptions: Collection<RemoteConnectionException<RemoteConnectionEndpoint>>
    ): EndpointConnectionException {
        let sb = StringBuilder()
        if (lookupFailures.isEmpty()) {
            sb.append("Could not lookup the following endpoints: ")
            StringUtils.appendTo(lookupFailures, sb)
        }
        if (connectionExceptions.isEmpty()) {
            sb.append("The following addresses failed: ")
            StringUtils.appendTo(connectionExceptions, sb, {rce => sb.append(rce.getErrorMessage())})
        }
        return EndpointConnectionException(sb.toString(), lookupFailures, connectionExceptions)
    }

    public func getLookupFailures(): Collection<RemoteConnectionEndpointLookupFailure> {
        return lookupFailures
    }

    public func getConnectionExceptions(): Collection<RemoteConnectionException<RemoteConnectionEndpoint>> {
        return connectionExceptions
    }
}

public class FeatureNotSupportedException <: Xmpp4cjException {
    private let feature: String

    private let jid: ?Jid

    public init(feature: String) {
        this(feature, None)
    }

    public init(feature: String, jid: ?Jid) {
        super("${feature} not supported" + (if (let Some(v) <- jid) {
            " by '${v}'"
        } else {
            ""
        }))
        this.jid = jid
        this.feature = feature
    }

    /**
     * Get the feature which is not supported.
     *
     * @return the feature which is not supported
     */
    public func getFeature(): String {
        return feature
    }

    /**
     * Get JID which does not support the feature. The JID can be null in cases when there are
     * multiple JIDs queried for this feature.
     *
     * @return the JID which does not support the feature, or null
     */
    public func getJid(): ?Jid {
        return jid
    }
}

public class ResourceBindingNotOfferedException <: Xmpp4cjException {
    public init() {
        super("Resource binding was not offered by server")
    }
}

public class XmppWrappedException <: Xmpp4cjException {
    public init(exception: Exception) {
        super(exception)
    }

    public init(message: String, exception: Exception) {
        super(message, exception)
    }
}

/**
 * A Xmpp exception wrapping a text message. Note that usage of this class is consider bad practice. This class
 * will eventually be marked deprecated and removed.
 */
public class XmppMessageException <: Xmpp4cjException {
    public init(message: String) {
        super(message)
    }
}

public open class XmppSaslException <: Xmpp4cjException {
    public init(exception: Exception) {
        super(exception)
    }

    public init(message: String) {
        super(message)
    }

    public init(message: String, exception: Exception) {
        super(message, exception)
    }
}

public class XmppCertificateException <: Xmpp4cjException {
    //     private let certificateException: CertificateException

    //     public init(certificateException: CertificateException) {
    //         super()
    //         this.certificateException = certificateException
    //     }

    //     public func getCertificateException(): CertificateException {
    //         return certificateException
    //     }
}
