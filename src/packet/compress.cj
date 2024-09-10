/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class Compress <: Nonza {
    public static let ELEMENT: String = "compress"
    public static let NAMESPACE: String = "http://jabber.org/protocol/compress"

    public let method: String

    public init(method: String) {
        this.method = method
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml: XmlStringBuilder = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()
        xml.element("method", method)
        xml.closeElement(this)
        return xml
    }
}

public class CompressFeature <: ExtensionElement {
    public static let ELEMENT: String = "compression"
    public static let QNAME: QName = QName(Compress.NAMESPACE, ELEMENT)

    public let methods: Collection<String>

    public init(methods: Collection<String>) {
        this.methods = methods
    }

    public func getMethods(): Collection<String> {
        return methods // TODO
    }

    public override func getNamespace(): String {
        return Compress.NAMESPACE
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func toXML(_: ?XmlEnvironment): XmlStringBuilder {
        let xml: XmlStringBuilder = XmlStringBuilder(this)
        xml.rightAngleBracket()
        for (method in methods) {
            xml.element("method", method)
        }
        xml.closeElement(this)
        return xml
    }
}
