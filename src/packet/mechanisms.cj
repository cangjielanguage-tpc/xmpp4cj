/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class Mechanisms <: ExtensionElement {
    public static let ELEMENT = "mechanisms"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-sasl"
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    public let mechanisms = LinkedList<String>()

    public init(mechanism: String) {
        mechanisms.append(mechanism)
    }

    public init(mechanisms: Iterator<String>) {
        for (v in mechanisms) {
            this.mechanisms.append(v)
        }
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public func getMechanisms(): Collection<String> {
        return mechanisms
    }

    public override func toXML(_: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this)
        xml.rightAngleBracket()
        for (mechanism in mechanisms) {
            xml.element("mechanism", mechanism)
        }
        xml.closeElement(this)
        return xml
    }
}
