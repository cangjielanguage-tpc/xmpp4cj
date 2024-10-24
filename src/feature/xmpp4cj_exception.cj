/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/**
 * Xmpp对任何Xmpp规范都没有定义的错误使用Xmpp4cjExceptions。
 */
public abstract class Xmpp4cjException <: Exception {
    /**
     * 异常。
     */
    public let cause: ?Exception

    /**
     * 使用作为异常根本原因的Throwable创建新的Xmpp4cjException。
     *
     * @param wrappedThrowable 异常的根本原因。
     */
    protected init(wrappedThrowable: Exception) {
        this("", wrappedThrowable)
    }

    /**  
     * 使用指定的消息创建新的 Xmpp4cjException，不带原始异常。
     *
     * @param message 异常消息。
     */
    protected init(message: String) {
        this(message, None)
    }

    /**  
     * 使用指定的消息和作为异常根本原因的 Throwable 创建新的 Xmpp4cjException。
     *
     * @param message 异常消息。
     * @param wrappedThrowable 异常的根本原因 {@link Throwable}。
     */
    protected init(message: String, wrappedThrowable: ?Exception) {
        super(message)
        this.cause = wrappedThrowable
    }

    /**  
     * 使用默认消息创建新的 Xmpp4cjException，不带原始异常。
     */
    protected init() {
        this("", None)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "Xmpp4cjException"
    }
}

public class NotLoggedInException <: Xmpp4cjException {
    /**  
     * 使用默认消息创建新的 NotLoggedInException。
     */
    public init() {
        super("Client is not logged in")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "NotLoggedInException"
    }
}

public class AlreadyLoggedInException <: Xmpp4cjException {
    /**  
     * 使用默认消息创建新的 AlreadyLoggedInException。
     */
    public init() {
        super("Client is already logged in")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "AlreadyLoggedInException"
    }
}

public class AlreadyConnectedException <: Xmpp4cjException {
    /**  
     * 使用默认消息创建新的 AlreadyConnectedException。
     */
    public init() {
        super("Client is already connected")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "AlreadyConnectedException"
    }
}

public class IllegalStateChangeException <: Xmpp4cjException {
    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "IllegalStateChangeException"
    }
}

public abstract class SecurityRequiredException <: Xmpp4cjException {
    /**  
     * 使用指定的消息创建新的 SecurityRequiredException。
     *
     * @param message 异常消息。
     */
    public init(message: String) {
        super(message)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "SecurityRequiredException"
    }
}

public class SecurityRequiredByClientException <: SecurityRequiredException {
    /**  
     * 使用默认消息创建新的 SecurityRequiredByClientException。
     */
    public init() {
        super("SSL/TLS required by client but not supported by server")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "SecurityRequiredByClientException"
    }
}

public class SecurityRequiredByServerException <: SecurityRequiredException {
    /**  
     * 使用默认消息创建新的 SecurityRequiredByServerException。
     */
    public init() {
        super("SSL/TLS required by server but disabled in client")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "SecurityRequiredByServerException"
    }
}

public class SecurityNotPossibleException <: Xmpp4cjException {
    /**  
     * 使用指定的消息创建新的 SecurityNotPossibleException。
     *
     * @param message 异常消息。
     */
    public init(message: String) {
        super(message)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "SecurityNotPossibleException"
    }
}

public abstract class ConnectionException <: Xmpp4cjException {
    /**
     * 使用作为异常根本原因的Throwable创建新的Xmpp4cjException。
     *
     * @param wrappedThrowable 异常的根本原因。
     */
    protected init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }

    /**  
     * 使用指定的消息创建新的 SecurityNotPossibleException。
     *
     * @param message 异常消息。
     */
    protected init(message: String) {
        super(message)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "ConnectionException"
    }
}

public class GenericConnectionException <: ConnectionException {
    /**
     * 使用作为异常根本原因的Throwable创建新的Xmpp4cjException。
     *
     * @param wrappedThrowable 异常的根本原因。
     */
    public init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "GenericConnectionException"
    }
}

/**
 * 如果Xmpp无法连接到给定Xmpp服务的所有主机，则会引发此异常。
 * 可以使用{@link EndpointConnectionException#getConnectionExceptions（）}检索连接异常，该异常将导致连接失败，并可使用{@link-RemoteConnectionException#getException（）}进行检索。
 */
public class EndpointConnectionException <: ConnectionException {
    private let lookupFailures: Collection<RemoteConnectionEndpointLookupFailure>

    private let connectionExceptions: Collection<RemoteConnectionException<RemoteConnectionEndpoint>>
    /**  
     * 创建一个新的 EndpointConnectionException 实例。
     *
     * @param message                异常消息。
     * @param lookupFailures         与远程连接终端查找失败相关的错误列表。
     * @param connectionExceptions    连接异常的列表。
     * @throws IllegalArgumentException 如果两个列表都为空。
     */
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

    /**  
     * 从给定的查找失败和连接异常列表创建 EndpointConnectionException。
     *
     * @param lookupFailures         发生的查找失败列表。
     * @param connectionExceptions    发生的连接异常列表。
     * @return 创建的 EndpointConnectionException 实例。
     */
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

    /**  
     * 获取与远程连接终端查找失败相关的错误列表。
     *
     * @return 远程连接终端查找失败的列表。
     */
    public func getLookupFailures(): Collection<RemoteConnectionEndpointLookupFailure> {
        return lookupFailures
    }

    /**  
     * 获取连接异常的列表，表示在连接时遇到的错误。
     *
     * @return 连接异常的列表。
     */
    public func getConnectionExceptions(): Collection<RemoteConnectionException<RemoteConnectionEndpoint>> {
        return connectionExceptions
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "EndpointConnectionException"
    }
}

public class FeatureNotSupportedException <: Xmpp4cjException {
    private let feature: String

    private let jid: ?Jid

    /**  
     * 使用指定的消息创建新的 XmppMessageException。
     *
     * @param message 异常消息。
     */
    public init(feature: String) {
        this(feature, None)
    }

    /**  
     * 使用指定的消息和Jid创建新的 XmppMessageException。
     *
     * @param message 异常消息。
     * @param jid Jid对象。
     */
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
     * 获取异常信息。
     *
     * @return 异常信息。
     */
    public func getFeature(): String {
        return feature
    }

    /**
     * 获取不支持该功能的JID。当为此功能查询了多个JID时，JID可以为空。
     *
     * @return 不支持该功能的JID，或为空
     */
    public func getJid(): ?Jid {
        return jid
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "FeatureNotSupportedException"
    }
}

public class ResourceBindingNotOfferedException <: Xmpp4cjException {
    /**  
     * 使用默认消息创建新的 ResourceBindingNotOfferedException。
     */
    public init() {
        super("Resource binding was not offered by server")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "ResourceBindingNotOfferedException"
    }
}

public class XmppWrappedException <: Xmpp4cjException {
    /**
     * 使用作为异常根本原因的Throwable创建新的Xmpp4cjException。
     *
     * @param wrappedThrowable 异常的根本原因。
     */
    public init(exception: Exception) {
        super(exception)
    }

    /**  
     * 使用指定的消息和作为异常根本原因的 Throwable 创建新的 Xmpp4cjException。
     *
     * @param message 异常消息。
     * @param wrappedThrowable 异常的根本原因 {@link Throwable}。
     */
    public init(message: String, exception: Exception) {
        super(message, exception)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XmppWrappedException"
    }
}

/**
 * A Xmpp exception wrapping a text message. Note that usage of this class is consider bad practice. This class
 * will eventually be marked deprecated and removed.
 */
public class XmppMessageException <: Xmpp4cjException {
    /**  
     * 使用指定的消息创建新的 XmppMessageException。
     *
     * @param message 异常消息。
     */
    public init(message: String) {
        super(message)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XmppMessageException"
    }
}

/**
 * 此类表示使用SASL时发生的错误。
 */
public open class XmppSaslException <: Xmpp4cjException {
    /**
     * 使用作为异常根本原因的Throwable创建新的Xmpp4cjException。
     *
     * @param wrappedThrowable 异常的根本原因。
     */
    public init(exception: Exception) {
        super(exception)
    }

    /**  
     * 使用指定的消息创建新的 XmppSaslException。
     *
     * @param message 异常消息。
     */
    public init(message: String) {
        super(message)
    }

    /**  
     * 使用指定的消息和作为异常根本原因的 Throwable 创建新的 Xmpp4cjException。
     *
     * @param message 异常消息。
     * @param wrappedThrowable 异常的根本原因 {@link Throwable}。
     */
    public init(message: String, exception: Exception) {
        super(message, exception)
    }

    /**
     * 获取原始异常
     *
     * @return 原始异常
     */
    public func getCause(): ?Exception {
        return cause
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XmppSaslException"
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

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XmppCertificateException"
    }
}
