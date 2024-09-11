/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * 将会发送到服务器以建立会话的 IQ 节。<p>
 *
 * 如果服务器支持会话，它必须在流认证完成后向客户端通告的流特性中包含一个<i>session</i>元素。当客户端被告知服务器要求建立会话时，如果它希望使用即时消息和存在功能，则必须建立会话。<p>
 *
 * For more information refer to the following
 * <a href=xmpp/org/specs/rfc3921.html#session>link</a>.
 */
public class Session <: SimpleIQ {
    public static let ELEMENT = "session"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-session"

    public init() {
        super(ELEMENT, NAMESPACE)
        setType(IQType.set)
    }
}

public class SessionFeature <: ExtensionElement {
    public static let QNAME = QName(Session.NAMESPACE, Session.ELEMENT)

    public static let OPTIONAL_ELEMENT = "optional"

    private let optional: Bool

    public init(optional: Bool) {
        this.optional = optional
    }

    public func isOptional(): Bool {
        return optional
    }

    public override func getElementName(): String {
        return Session.ELEMENT
    }

    public override func getNamespace(): String {
        return Session.NAMESPACE
    }

    public override func toXML(_: ?XmlEnvironment): XmlStringBuilder {
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
