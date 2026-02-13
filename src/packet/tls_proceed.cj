/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.packet

/**
 * Tls Proceed。
 */
public class TlsProceed <: Nonza {
    /**
     * 默认的TlsProceed。
     */
    public static let INSTANCE = TlsProceed()

    /**
     * 默认的元素名称。
     */
    public static let ELEMENT = "proceed"

    /**
     * 默认的命名空间。
     */
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-tls"

    /**
     * 默认的QNAME对象。
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private init() {}

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        return "<${ELEMENT} xmlns='${NAMESPACE}'/>"
    }
}
