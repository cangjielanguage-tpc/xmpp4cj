/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * public abstract class SimpleIQ <: IQ
 *
 * 一个简单的 IQ。
 * <p>
 * 简单 IQ 的子元素除了“xmlns”之外不包含其他属性。它们可能包含额外的数据包扩展。
 * </p>
 */
public abstract class SimpleIQ <: IQ {
    /**
     * SimpleIQ类的构造函数。
     *
     * @param childElementName 名称。
     * @param childElementNamespace 命名空间。
     */
    protected init(childElementName: String, childElementNamespace: String) {
        super(childElementName, childElementNamespace)
    }

    /**
     * SimpleIQ类的构造函数。
     *
     * @param iqBuilder IqData类。
     * @param childElementName 名称。
     * @param childElementNamespace 命名空间。
     */
    protected init(iqBuilder: IqData, childElementName: String, childElementNamespace: String) {
        super(iqBuilder, childElementName, childElementNamespace)
    }

    /**
     * 创建IQChildElementXmlStringBuilder
     *
     * @param xml 一个预先创建的构建器，已经设置了子元素和“xmlns”属性。
     * @return IQChildElementXmlStringBuilder。
     */
    protected open override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.setEmptyElement()
        return xml
    }
}
