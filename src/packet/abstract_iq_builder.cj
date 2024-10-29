/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**  
 * 抽象 IQ 构建器类，用于创建 IQ 数据包的基本实现。
 * <p>
 * 该类是其他具体 IQ 构建器（如请求和响应）类的基类，并提供了构造 IQ 数据包的通用功能。
 * </p>
 */
public abstract class AbstractIqBuilder <: StanzaBuilder & IqView {
    /**
     * IQ 的类型，默认为 "get"。
     */
    protected var typ: IQType = IQType.get

    /**  
     * 构造函数，接受一个现有的 IQ 对象和一个 stanza ID。
     *
     * @param other 现有的 IQ 对象
     * @param stanzaId stanza ID
     */
    init(other: IQ, stanzaId: String) {
        super(other, stanzaId)
    }

    /**  
     * 复制构造函数，从另一个 AbstractIqBuilder 对象创建新实例。
     *
     * @param other 其他抽象 IQ 构建器
     */
    init(other: AbstractIqBuilder) {
        super(other)
        typ = other.typ
    }

    /**  
     * 构造函数，接受一个 StanzaIdSource 以构建 IQ。
     *
     * @param stanzaIdSource stanza ID 源
     */
    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    /**  
     * 构造函数，接受一个 stanza ID。
     *
     * @param stanzaId stanza ID
     */
    init(stanzaId: ?String) {
        super(stanzaId)
    }

    /**  
     * 创建对给定请求的响应 IQ 数据。
     *
     * @param request 原始请求
     * @return 响应 IQ 数据
     */
    public static func createResponse(request: IqView): IqData {
        return createResponse(request, IQResponseType.result)
    }

    /**  
     * 创建对给定请求的错误响应 IQ 数据。
     *
     * @param request 原始请求
     * @return 错误响应 IQ 数据
     */
    public static func createErrorResponse(request: IqView): IqData {
        return createResponse(request, IQResponseType.error)
    }

    /**  
     * 根据请求和响应类型创建 IQ 响应。
     *
     * @param request 原始请求
     * @param responseType 响应的类型（结果或错误）
     * @return 响应 IQ 数据
     * @throws IllegalArgumentException 如果请求不是有效的 IQ 请求
     */
    protected static func createResponse(request: IqView, responseType: IQResponseType): IqData {
        if (!request.isRequestIQ()) {
            throw IllegalArgumentException("IQ request must be of type 'set' or 'get'. Original IQ: ${request}")
        }
        let commonResponseIqData: IqData = StanzaBuilder.buildResponse(request, {s => StanzaBuilder.buildIqData(s)})
        commonResponseIqData.ofType(responseType.getType())
        return commonResponseIqData
    }

    /**  
     * 添加特定于此阶层的属性到字符串生成器。
     *
     * @param builder 字符串生成器
     */
    protected override func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit {
        builder.addValue("type", getType())
    }

    /**  
     * 获取 IQ 的类型。
     *
     * @return IQ 类型
     */
    public override func getType(): IQType {
        return typ
    }
}
