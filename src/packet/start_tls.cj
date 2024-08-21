/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class StartTls <: Nonza {
    public static let INSTANCE = StartTls()

    public static let ELEMENT = "starttls"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-tls"
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private let required: Bool

    public init() {
        this(false)
    }

    public init(required: Bool) {
        this.required = required
    }

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
