/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

public class StartTls <: Nonza {
    /**
     * 单例实例
     */
    public static let INSTANCE = StartTls()

    /**
     * XML 元素名称
     */
    public static let ELEMENT = "starttls"

    /**
     * XML 命名空间
     */
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-tls"

    /**
     * QName 对象，用于表示元素的命名空间和名称
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private let required: Bool

    /**
     * 默认构造方法
     */
    public init() {
        this(false)
    }

    /**
     * 入参为bool的构造方法
     *
     * @param required 布尔值。
     */
    public init(required: Bool) {
        this.required = required
    }

    /**
     * 判断 TLS 是否为必需
     *
     * @return 如果 TLS 是必需的，返回 true；否则返回 false
     */
    public func requiredMethod(): Bool {
        return required
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        if (required) {
            xml.rightAngleBracket()
            xml.emptyElement("required")
            xml.closeElement(this)
        } else {
            xml.closeEmptyElement()
        }
        return xml
    }
}
