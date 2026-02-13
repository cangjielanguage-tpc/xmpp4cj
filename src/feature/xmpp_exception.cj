/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.feature

/**
 * public abstract class XMPPException <: ExceptionExt
 *
 * 执行XMPP操作时发生错误时引发的通用异常。
 * XMPP服务器可以用错误代码和问题的文本描述来响应错误情况，这些代码和描述封装在XMPPError类中。
 * 在适当的时候，XMPPError实例是此异常的附加实例
 *
 * 当发生流错误时，服务器将在关闭连接之前向客户端发送流错误。
 * 流错误是不可恢复的错误。
 * 当向客户端发送流错误时，将抛出包含服务器发送的StreamError的XMPPException。
 *
 * @see StanzaError
 */
public abstract class XMPPException <: ExceptionExt {
    /**
     * 创建新的XMPPException。
     */
    protected init() {
        this("", None)
    }

    /**
     * 创建带有异常描述的新XMPPException。
     *
     * @param message 异常的描述。
     */
    protected init(message: String) {
        this(message, None)
    }

    /**
     * 创建一个新的XMPPException，其中包含异常的描述和作为异常根本原因的Throwable。
     *
     * @param message 对异常的描述。
     * @param wrappedThrowable 异常的根本原因。
     */
    protected init(message: String, wrappedThrowable: ?Exception) {
        super(message, wrappedThrowable)
        this.cause = wrappedThrowable
    }

    /**
     * 获取异常消息。
     *
     * @return 异常消息。
     */
    public open func getMessage(): String {
        message
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "XMPPException"
    }
}

/**
 * 由协议级别的XMPP错误节响应引起的异常。您可以通过调用{@link#getStanzaError（）}来检查底层{@linkStanzaError}。
 */
public class XMPPErrorException <: XMPPException {
    private let error: StanzaError

    private let stanza: ?Stanza

    /**
     * 导致XMPP协议错误响应的请求。可能为｛@code null｝。
     */
    private let request: ?Stanza

    /**
     * 使用作为异常根案例的XMPPError创建新的XMPPErrorException。
     *
     * @param stanza 包含异常的节。
     * @param error 异常的根本原因。
     */
    public init(stanza: Stanza, error: StanzaError) {
        this(stanza, error, None)
    }

    /**
     * 使用作为异常根案例的XMPPError创建新的XMPPErrorException。
     *
     * @param stanza 包含异常的节。
     * @param error 异常的根本原因。
     * @param request 触发错误的请求。
     */
    public init(stanza: ?Stanza, error: StanzaError, request: ?Stanza) {
        super()
        this.error = error
        this.stanza = stanza
        this.request = request
    }

    /**
     * 返回与此异常关联的节错误扩展元素。
     *
     * @return 与此异常关联的节错误扩展元素。
     */
    public func getStanzaError(): StanzaError {
        return error
    }

    /**
     * 获取与此异常关联的节。
     *
     * @return 创建此异常的节，或者如果异常不是来自节，则使用{@code None}。
     */
    public func getStanza(): ?Stanza {
        return stanza
    }

    /**
     * 获取触发导致此异常的错误响应的请求。
     *
     * @return 请求或{@code None}。
     */
    public func getRequest(): ?Stanza {
        return request
    }

    /**
     * 获取异常消息。
     *
     * @return 异常消息。
     */
    public override func getMessage(): String {
        let sb = StringBuilder()
        if (let Some(stanza) <- stanza) {
            let comefrom = stanza.getFrom()
            if (let Some(comefrom) <- comefrom) {
                sb.append("XMPP error reply received from ${comefrom}: ")
            }
        }
        sb.append(error)
        if (let Some(request) <- request) {
            sb.append(" as result of the following request: ")
            sb.append(request)
        }
        return sb.toString()
    }

    /**
     * 检查给定的 Stanza 是否包含错误，如果包含错误则抛出 XMPPErrorException。
     *
     * @param packet 要检查的 Stanza 对象。
     * @throws XMPPErrorException 如果 Stanza 包含错误。
     */
    public static func ifHasErrorThenThrow(packet: Stanza): Unit {
        ifHasErrorThenThrow(packet, None)
    }

    /**
     * 检查给定的 Stanza 是否包含错误，如果包含错误则抛出 XMPPErrorException。
     * 此方法允许提供一个请求的 Stanza 作为上下文。
     *
     * @param packet 要检查的 Stanza 对象。
     * @param request 与当前 Stanza 相关的请求 Stanza，可能为 null。
     * @throws XMPPErrorException 如果 Stanza 包含错误。
     */
    public static func ifHasErrorThenThrow(packet: Stanza, request: ?Stanza): Unit {
        let xmppError = packet.getError()
        if (let Some(xmppError) <- xmppError) {
            throw XMPPErrorException(packet, xmppError, request)
        }
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XMPPErrorException"
    }
}

/**
 * FailedNonzaException 是一个自定义异常，表示处理 Nonza 时发生的错误。
 * 该异常扩展自 XMPPException，包含有关失败的 Nonza 和错误条件的信息。
 */
public class FailedNonzaException <: XMPPException {
    /**
     * 失败的 Nonza 所对应的错误条件。
     */
    private let condition: ?StanzaErrorCondition

    /**
     * 导致异常的 Nonza。
     */
    private let nonza: Nonza

    /**
     * 创建一个 FailedNonzaException，指定失败的 Nonza。
     * 错误条件将被设置为 null。
     *
     * @param failedNonza 发生错误的 Nonza。
     */
    public init(failedNonza: Nonza) {
        this(failedNonza, None)
    }

    /**
     * 创建一个 FailedNonzaException，指定失败的 Nonza 和相应的错误条件。
     *
     * @param nonza 发生错误的 Nonza。
     * @param condition 相关的错误条件。
     */
    public init(nonza: Nonza, condition: ?StanzaErrorCondition) {
        super()
        this.condition = condition
        this.nonza = nonza
    }

    /**
     * 获取错误条件。
     *
     * @return 关联的错误条件，如果没有则返回 null。
     */
    public func getCondition(): ?StanzaErrorCondition {
        return condition
    }

    /**
     * 获取导致异常的 Nonza。
     *
     * @return 发生错误的 Nonza。
     */
    public func getNonza(): Nonza {
        return nonza
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "FailedNonzaException"
    }
}

public class StreamErrorException <: XMPPException {
    private let streamError: StreamError

    /**
     * 使用StreamError创建新的StreamErrorException。
     *
     * @param streamError StreamError异常。
     */
    public init(streamError: StreamError) {
        super(
            "${anyToString(streamError.getCondition())} You can read more about the meaning of this stream error at http://xmpp.org/rfcs/rfc6120.html#streams-error-conditions\n${streamError.toString()}"
        )
        this.streamError = streamError
    }

    /**
     * 返回与此异常关联的StreamError。在向客户端发送流错误后，服务器会关闭底层TCP连接。
     *
     * @return 与此异常关联的StreamError。
     */
    public func getStreamError(): StreamError {
        return streamError
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "StreamErrorException"
    }
}
