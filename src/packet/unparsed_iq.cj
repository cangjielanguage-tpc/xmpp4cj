/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 由于未找到提供程序而无法解析的 IQ 节。
 */
public class UnparsedIQ <: IQ {
    private let content: String

    /**
     * 构造方法
     *
     * @param element 节点名称。
     * @param namespace 命名空间。
     * @param content 节点内容。
     */
    public init(element: String, namespace: String, content: String) {
        super(element, namespace)
        this.content = content
    }

    /**
     * 获取节点内容。
     *
     * @return e 节点内容。
     */
    public func getContent(): String {
        return content
    }

    /**
     * 创建IQChildElementXmlStringBuilder。
     *
     * @param xml 一个预先创建的构建器，已经设置了子元素和“xmlns”属性。
     * @return IQChildElementXmlStringBuilder。
     */
    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        if (StringUtils.isEmpty(content)) {
            xml.setEmptyElement()
        } else {
            xml.rightAngleBracket()
            xml.escape(content)
        }
        return xml
    }
}
