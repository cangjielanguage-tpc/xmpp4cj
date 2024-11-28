/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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
}
