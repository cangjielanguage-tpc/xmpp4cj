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

public class ErrorIQBuilder <: IqBuilder {
    var request: ?IQ = None

    init(error: StanzaError, iqData: IqData) {
        super(iqData)
        if (iqData.getType() != IQType.error) {
            throw IllegalArgumentException("Error IQs must be of type 'error'")
        }
        setError(error)
    }

    init(error: StanzaError, request: IQ) {
        this(error, AbstractIqBuilder.createErrorResponse(request))
        this.request = request
    }

    public func build(): ErrorIQ {
        var childElementQname: ?QName = None
        if (let Some(v) <- request) {
            childElementQname = v.getChildElementQName()
        }
        return ErrorIQ(this, childElementQname)
    }

    public override func getThis(): ErrorIQBuilder {
        return this
    }
    public override func to(to: String): ErrorIQBuilder {
        super.to(to)
        getThis()
    }
    public override func to(to: ?Jid): ErrorIQBuilder {
        super.to(to)
        getThis()
    }
    public override func froms(froms: String): ErrorIQBuilder {
        super.froms(froms)
        getThis()
    }
    public override func froms(froms: ?Jid): ErrorIQBuilder {
        super.froms(froms)
        getThis()
    }
    public override func setError(stanzaError: StanzaError): ErrorIQBuilder {
        super.setError(stanzaError)
        getThis()
    }
    public override func setLanguage(language: String): ErrorIQBuilder {
        super.setLanguage(language)
        getThis()
    }
    public override func addExtension(extensionElement: ExtensionElement): ErrorIQBuilder {
        super.addExtension(extensionElement)
        getThis()
    }
    public override func addOptExtensions(extensionElements: Collection<ExtensionElement>): ErrorIQBuilder {
        super.addOptExtensions(extensionElements)
        getThis()
    }
    public override func addExtensions(extensionElements: Collection<ExtensionElement>): ErrorIQBuilder {
        super.addExtensions(extensionElements)
        getThis()
    }
    public override func overrideExtension(extensionElement: ExtensionElement): ErrorIQBuilder {
        super.overrideExtension(extensionElement)
        getThis()
    }
    public override func removeExtension(elementName: String, namespace: String): ErrorIQBuilder {
        super.removeExtension(elementName, namespace)
        getThis()
    }
    public override func removeExtension(extension: ExtensionElement): ErrorIQBuilder {
        super.removeExtension(extension)
        getThis()
    }
}
