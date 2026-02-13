/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.packet
/**
 * 表示一个空的结果 IQ（信息查询）响应，通常用于表示无内容的成功响应。
 * <p>
 * 该类继承自 {@link IQ}，用于协助构建标准化的 XMPP IQ 空结果响应。
 * </p>
 */
public class EmptyResultIQ <: IQ {
    /**
     * 使用给定的 IqData 构建一个 EmptyResultIQ 实例。
     *
     * @param iqBuilder 包含 IQ 数据的构建器。
     */
    init(iqBuilder: IqData) {
        super(iqBuilder, EMPTY_ELEMENT, EMPTY_NAMESPACE)
    }

    /**
     * 默认构造函数，创建一个空的结果 IQ 响应。
     * <p>
     * TODO: 当分句 builder 和解析逻辑准备好后，应弃用此构造函数。
     * </p>
     */
    public init() {
        super(EMPTY_ELEMENT, EMPTY_NAMESPACE)
        typ = IQType.result
    }

    /**
     * 使用给定的请求创建一个 EmptyResultIQ 实例。
     *
     * @param request 请求的 IQ，可以是任意类型的 IQ。
     */
    public init(request: IQ) {
        this(AbstractIqBuilder.createResponse(request))
    }

    /**
     * 获取该 IQ 的子元素 XML 字符串生成器。
     * <p>
     * 空结果 IQ 不包含任何子元素，因此返回 null。
     * </p>
     *
     * @param xml XML 字符串生成器
     * @return null，因为空结果 IQ 不包含子元素
     */
    protected override func getIQChildElementBuilder(_: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        return None
    }
}
