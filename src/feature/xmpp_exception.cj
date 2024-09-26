/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/**
 * A generic exception that is thrown when an error occurs performing an
 * XMPP operation. XMPP servers can respond to error conditions with an error code
 * and textual description of the problem, which are encapsulated in the XMPPError
 * class. When appropriate, an XMPPError instance is attached instances of this exception.<p>
 *
 * When a stream error occurred, the server will send a stream error to the client before
 * closing the connection. Stream errors are unrecoverable errors. When a stream error
 * is sent to the client an XMPPException will be thrown containing the StreamError sent
 * by the server.
 *
 * @see StanzaError
 */
public abstract class XMPPException <: Exception {
    public let cause: ?Exception
    /**
     * Creates a new XMPPException.
     */
    protected init() {
        this("", None)
    }
    /**
     * Creates a new XMPPException with a description of the exception.
     *
     * @param message description of the exception.
     */
    protected init(message: String) {
        this(message, None)
    }
    /**
     * Creates a new XMPPException with a description of the exception and the
     * Throwable that was the root cause of the exception.
     *
     * @param message a description of the exception.
     * @param wrappedThrowable the root cause of the exception.
     */
    protected init(message: String, wrappedThrowable: ?Exception) {
        super(message)
        this.cause = wrappedThrowable
    }

    public open func getMessage(): String {
        message
    }
}

/**
 * An exception caused by an XMPP error stanza response on the protocol level. You can examine the underlying
 * {@link StanzaError} by calling {@link #getStanzaError()}.
 */
public class XMPPErrorException <: XMPPException {
    private let error: StanzaError
    private let stanza: ?Stanza
    /**
     * The request which resulted in the XMPP protocol error response. May be {@code null}.
     */
    private let request: ?Stanza
    /**
     * Creates a new XMPPErrorException with the XMPPError that was the root case of the exception.
     *
     * @param stanza stanza that contained the exception.
     * @param error the root cause of the exception.
     */
    public init(stanza: Stanza, error: StanzaError) {
        this(stanza, error, None)
    }
    /**
     * Creates a new XMPPErrorException with the XMPPError that was the root case of the exception.
     *
     * @param request the request which triggered the error.
     * @param stanza stanza that contained the exception.
     * @param error the root cause of the exception.
     */
    public init(stanza: ?Stanza, error: StanzaError, request: ?Stanza) {
        super()
        this.error = error
        this.stanza = stanza
        this.request = request
    }

    /**
     * Returns the stanza error extension element associated with this exception.
     *
     * @return the stanza error extension element associated with this exception.
     */
    public func getStanzaError(): StanzaError {
        return error
    }

    /**
     * Gets the stanza associated with this exception.
     *
     * @return the stanza from which this exception was created or {@code null} if the exception is not from a
     * stanza.
     */
    public func getStanza(): ?Stanza {
        return stanza
    }

    /**
     * Get the request which triggered the error response causing this exception.
     *
     * @return the request or {@code null}.
     */
    public func getRequest(): ?Stanza {
        return request
    }

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

    public static func ifHasErrorThenThrow(packet: Stanza): Unit {
        ifHasErrorThenThrow(packet, None)
    }

    public static func ifHasErrorThenThrow(packet: Stanza, request: ?Stanza): Unit {
        let xmppError = packet.getError()
        if (let Some(xmppError) <- xmppError) {
            throw XMPPErrorException(packet, xmppError, request)
        }
    }
}

public class FailedNonzaException <: XMPPException {
    private let condition: ?StanzaErrorCondition

    private let nonza: Nonza

    public init(failedNonza: Nonza) {
        this(failedNonza, None)
    }

    public init(nonza: Nonza, condition: ?StanzaErrorCondition) {
        super()
        this.condition = condition
        this.nonza = nonza
    }

    public func getCondition(): ?StanzaErrorCondition {
        return condition
    }

    public func getNonza(): Nonza {
        return nonza
    }
}

public class StreamErrorException <: XMPPException {
    private let streamError: StreamError

    public init(streamError: StreamError) {
        super(
            streamError.getCondition().toString() +
            " You can read more about the meaning of this stream error at http://xmpp.org/rfcs/rfc6120.html#streams-error-conditions\n" +
            streamError.toString())
        this.streamError = streamError
    }

    /**
     * Returns the StreamError associated with this exception. The underlying TCP connection is
     * closed by the server after sending the stream error to the client.
     *
     * @return the StreamError associated with this exception.
     */
    public func getStreamError(): StreamError {
        return streamError
    }
}
