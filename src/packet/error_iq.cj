/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * 一个 XMPP 错误 IQ。
 * <p>
 * 根据 RFC 6120 § 8.3.1 “4. 一个错误节必须包含一个 &lt;error/&gt; 子元素。”，所以只有在提供了节错误的情况下才能构造这个类。
 */
public class ErrorIQ <: IQ {
    /**
     * 定义 error 元素的常量
     */
    public static let ELEMENT = StanzaError.ERROR

    private let request: ?IQ // 原请求的 IQ 

    /**  
     * 使用 Builder 创建 ErrorIQ 实例。
     *
     * @param builder 用于构建 ErrorIQ 的 Builder。
     * @param childElementQName 子元素的 QName。
     * @throws NullPointerException 如果未提供错误元素。
     */
    init(builder: ErrorIQBuilder, childElementQName: ?QName) {
        super(builder, childElementQName)
        Objects.requireNonNull(builder.getError(), "Must provide an stanza error when building error IQs")
        this.request = builder.request
    }

    /**  
     * 创建一个错误响应，返回一个 ErrorIQ 实例。
     *
     * @param request 原请求的 IQ。
     * @param error 发生的错误。
     * @return 构建好的 ErrorIQ 实例。
     */
    public static func createErrorResponse(request: IQ, error: StanzaError): ErrorIQ {
        let builder = ErrorIQBuilder(error, request)
        builder.setError(error)
        return builder.build()
    }

    /**  
     * 获取该 IQ 的子元素 XML 字符串生成器。
     *
     * @param xml XML 字符串生成器。
     * @return 包含请求的 XML 字符串生成器，如果请求为 null，则返回 null。
     */
    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        return request?.getIQChildElementBuilder(xml) ?? None
    }

    /**  
     * 创建一个 Builder 实例以构建 ErrorIQ。
     *
     * @param error 要设置的错误。
     * @return ErrorIQ 的 Builder。
     */
    public static func builder(error: ?StanzaError): ErrorIQBuilder {
        return ErrorIQBuilder(error, IqData.EMPTY.ofType(IQType.error))
    }

    /**  
     * 创建一个 Builder 实例以构建 ErrorIQ，并提供 IQ 数据。
     *
     * @param error 要设置的错误。
     * @param iqData IQ 数据。
     * @return ErrorIQ 的 Builder。
     */
    public static func builder(error: ?StanzaError, iqData: IqData): ErrorIQBuilder {
        return ErrorIQBuilder(error, iqData)
    }
}

/**  
 * 用于构建 ErrorIQ 的 Builder 类。
 */
public class ErrorIQBuilder <: IqBuilder {
    var request: ?IQ = None // 原请求的 IQ  

    /**  
     * 使用错误和 IQ 数据构建 Builder 实例。
     *
     * @param error 要设置的错误。
     * @param iqData IQ 数据。
     * @throws IllegalArgumentException 如果 iqData 不是类型为 'error'。
     * @throws NullPointerException 如果未提供错误。
     */
    init(error: ?StanzaError, iqData: IqData) {
        super(iqData)
        if (iqData.getType() != IQType.error) {
            throw IllegalArgumentException("Error IQs must be of type 'error'")
        }
        setError(error)
    }

    /**  
     * 使用错误和原请求构建 Builder 实例。
     *
     * @param error 要设置的错误。
     * @param request 原请求的 IQ。
     */
    init(error: StanzaError, request: IQ) {
        this(error, AbstractIqBuilder.createErrorResponse(request))
        this.request = request
    }

    /**  
     * 构建并返回一个 ErrorIQ 实例。
     *
     * @return 构造的 ErrorIQ 实例。
     */
    public func build(): ErrorIQ {
        var childElementQname: ?QName = None
        if (let Some(v) <- request) {
            childElementQname = v.getChildElementQName()
        }
        return ErrorIQ(this, childElementQname)
    }

    /**  
     * 返回当前ErrorIQBuilder实例。
     *
     * @return 当前ErrorIQBuilder实例。
     */
    public override func getThis(): ErrorIQBuilder {
        return this
    }

    /**
     * 设置节的接收方地址。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #to(Jid)
     */
    public override func to(to: String): ErrorIQBuilder {
        super.to(to)
        getThis()
    }

    /**
     * 设置节要发送给谁。
     * XMPP 协议通常使“to”属性是可选的，所以它并不总是需要被设置。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     */
    public override func to(to: ?Jid): ErrorIQBuilder {
        super.to(to)
        getThis()
    }

    /**
     * 设置节从谁那里发送。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #froms(Jid)
     */
    public override func froms(froms: String): ErrorIQBuilder {
        super.froms(froms)
        getThis()
    }

    /**
     * 设置节从谁那里发送。
     * XMPP 协议通常使“from”属性是可选的，所以它并不总是需要被设置。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     */
    public override func froms(froms: ?Jid): ErrorIQBuilder {
        super.froms(froms)
        getThis()
    }

    /**
     * 设置这个节的错误。
     *
     * @param stanzaError 要与这个节关联的错误。
     * @return 对这个构建器的引用。
     */
    public override func setError(stanzaError: ?StanzaError): ErrorIQBuilder {
        super.setError(stanzaError)
        getThis()
    }

    /**
     * 设置这个节的 xml:lang。
     *
     * @param language 这个节的 xml:lang。
     * @return 对这个构建器的引用。
     */
    public override func setLanguage(language: ?String): ErrorIQBuilder {
        super.setLanguage(language)
        getThis()
    }

    /**  
     * 添加子元素到构建器中。
     *
     * @param extensionElement 要添加的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addExtension(extensionElement: ExtensionElement): ErrorIQBuilder {
        super.addExtension(extensionElement)
        getThis()
    }

    /**  
     * 添加可选的多个子元素。
     *
     * @param extensionElements 要添加的子元素集（可以为空，但不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addOptExtensions(extensionElements: ?Collection<ExtensionElement>): ErrorIQBuilder {
        super.addOptExtensions(extensionElements)
        getThis()
    }

    /**  
     * 添加多个子元素。
     *
     * @param extensionElements 要添加的子元素集（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addExtensions(extensionElements: Collection<ExtensionElement>): ErrorIQBuilder {
        super.addExtensions(extensionElements)
        getThis()
    }

    /**  
     * 替换现有的子元素。
     *
     * @param extensionElement 要替换的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func overrideExtension(extensionElement: ExtensionElement): ErrorIQBuilder {
        super.overrideExtension(extensionElement)
        getThis()
    }

    /**  
     * 移除指定的子元素。
     *
     * @param elementName 要移除的元素名称
     * @param namespace 该元素的命名空间
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func removeExtension(elementName: String, namespace: String): ErrorIQBuilder {
        super.removeExtension(elementName, namespace)
        getThis()
    }

    /**  
     * 移除指定的子元素。
     *
     * @param extension 要移除的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func removeExtension(extension: ExtensionElement): ErrorIQBuilder {
        super.removeExtension(extension)
        getThis()
    }
}
