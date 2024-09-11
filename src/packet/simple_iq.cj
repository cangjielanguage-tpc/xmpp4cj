/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * 一个简单的 IQ。
 * <p>
 * 简单 IQ 的子元素除了“xmlns”之外不包含其他属性。它们可能包含额外的数据包扩展。
 * </p>
 */
public abstract class SimpleIQ <: IQ {
    protected init(childElementName: String, childElementNamespace: String) {
        super(childElementName, childElementNamespace)
    }

    protected init(iqBuilder: IqData, childElementName: String, childElementNamespace: String) {
        super(iqBuilder, childElementName, childElementNamespace)
    }

    protected open override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.setEmptyElement()
        return xml
    }
}
