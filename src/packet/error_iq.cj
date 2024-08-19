/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * An XMPP error IQ.
 * <p>
 * According to RFC 6120 § 8.3.1 "4. An error stanza MUST contain an &lt;error/&gt; child element.",
 * so this class can only be constructed if a stanza error is provided.
 */
public class ErrorIQ <: IQ {
    public static let ELEMENT = StanzaError.ERROR

    private let request: ?IQ

    init(builder: ErrorIQBuilder, childElementQName: ?QName) {
        super(builder, childElementQName)
        Objects.requireNonNull(builder.getError(), "Must provide an stanza error when building error IQs")
        this.request = builder.request
    }

    public static func createErrorResponse(request: IQ, error: StanzaError): ErrorIQ {
        let builder = ErrorIQBuilder(error, request)
        builder.setError(error)
        return builder.build()
    }

    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        return request?.getIQChildElementBuilder(xml) ?? None
    }

    public static func builder(error: StanzaError): ErrorIQBuilder {
        return ErrorIQBuilder(error, IqData.EMPTY.ofType(IQType.error))
    }

    public static func builder(error: StanzaError, iqData: IqData): ErrorIQBuilder {
        return ErrorIQBuilder(error, iqData)
    }
}

// extend ErrorIQ <: Equatable<ErrorIQ> {
//     public operator func == (that: ErrorIQ): Bool {
//         return refEq(this, that)
//     }

//     public operator func != (that: ErrorIQ): Bool {
//         return !(this == that)
//     }
// }

public class ErrorIQBuilder <: IqBuilder {
    var request: ?IQ = None

    init(error: StanzaError, iqData: IqData) {
        super(iqData)
        if (iqData.getType() == IQType.error) {
            throw IllegalArgumentException("Error IQs must be of type 'error'")
        }
        setError(error)
    }

    init(error: StanzaError, request: IQ) {
        this(error, AbstractIqBuilder.createErrorResponse(request))
        this.request = request
    }

    public func getThis(): ErrorIQBuilder {
        return this
    }

    public func build(): ErrorIQ {
        var childElementQname: ?QName = None
        if (let Some(v) <- request) {
            childElementQname = v.getChildElementQName()
        }
        return ErrorIQ(this, childElementQname)
    }
}
