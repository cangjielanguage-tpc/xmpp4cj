/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class TlsProceed <: Nonza {
    public static let INSTANCE = TlsProceed()

    public static let ELEMENT = "proceed"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-tls"
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private init() {}

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func toXML(_: ?XmlEnvironment): ToString {
        return "<${ELEMENT} xmlns='${NAMESPACE}'/>"
    }
}
