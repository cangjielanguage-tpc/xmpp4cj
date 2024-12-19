/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 将会发送到服务器以建立会话的 IQ 节。<p>
 * 如果服务器支持会话，它必须在流认证完成后向客户端通告的流特性中包含一个<i>session</i>元素。当客户端被告知服务器要求建立会话时，如果它希望使用即时消息和存在功能，则必须建立会话。<p>
 */
public class Session <: SimpleIQ {
    /**
     * 会话的XML元素名称。
     */
    public static let ELEMENT = "session"

    /**
     * 会话的命名空间。
     */
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-session"

    /**
     * 使用指定的元素名称和命名空间构造新的Session实例。
     * IQ节的类型设置为{@link IQ.type#set}。
     */
    public init() {
        super(ELEMENT, NAMESPACE)
        setType(IQType.set)
    }
}

/**
 * 表示可在XMPP中使用的会话功能元素。
 * 此类可以指示会话功能是否是可选的。
 */
public class SessionFeature <: ExtensionElement {
    /**
     * 会话元素的限定名称。
     */
    public static let QNAME = QName(Session.NAMESPACE, Session.ELEMENT)

    /**
     * 表示可选性的元素。
     */
    public static let OPTIONAL_ELEMENT = "optional"

    private let optional: Bool // 指示该功能是否可选的标志。

    /**
     * Feature类的构造函数。
     *
     * @param optional 指示此功能是否可选。
     */
    public init(optional: Bool) {
        this.optional = optional
    }

    /**
     * 检查会话功能是否可选。
     *
     * @return 如果该功能是可选的，则返回true，否则返回false。
     */
    public func isOptional(): Bool {
        return optional
    }

    public override func getElementName(): String {
        return Session.ELEMENT
    }

    public override func getNamespace(): String {
        return Session.NAMESPACE
    }

    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this)
        if (optional) {
            xml.rightAngleBracket()
            xml.emptyElement(OPTIONAL_ELEMENT)
            xml.closeElement(this)
        } else {
            xml.closeEmptyElement()
        }
        return xml
    }
}
