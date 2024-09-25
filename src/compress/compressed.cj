/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.compress

public class Compressed <: Nonza {
    public static let ELEMENT = "compressed"
    public static let NAMESPACE = Compress.NAMESPACE
    public static let QNAME = QName(NAMESPACE, ELEMENT)
    public static let INSTANCE = Compressed()

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<${ELEMENT} xmlns='${NAMESPACE}'/>"
    }
}
