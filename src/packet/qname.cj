/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class QName <: ToString & Hashable & Equatable<QName> {
    let namespaceURI: String
    let localPart: String
    let prefix: String
    public init(namespaceURI: String, localPart: String) {
        this(namespaceURI, localPart, "")
    }
    public init(namespaceURI: String, localPart: String, prefix: String) {
        this.namespaceURI = namespaceURI
        this.localPart = localPart
        this.prefix = prefix
    }
    public func getLocalPart(): String {
        localPart
    }
    public func getNamespaceURI(): String {
        namespaceURI
    }
    public override func toString(): String {
        if (namespaceURI == "") {
            return localPart
        } else {
            return "{" + namespaceURI + "}" + localPart
        }
    }
    public operator func ==(qname: QName): Bool {
        refEq(this, qname) || (namespaceURI == qname.namespaceURI && localPart == qname.localPart && prefix == qname.
            prefix)
    }
    public operator func !=(qname: QName): Bool {
        !(this == qname)
    }

    @OverflowWrapping
    public func hashCode(): Int64 {
        var result: Int64 = 17
        result = 31 * result + namespaceURI.hashCode()
        result = 31 * result + localPart.hashCode()
        result = 31 * result + prefix.hashCode()
        return result
    }
}

let EMPTY_QNAME = QName("", "")
let EMPTY_ELEMENT = ""
let EMPTY_NAMESPACE = ""

public interface QNameField {
    prop QNAME_FIELD: QName
}

public interface ElementField {
    prop ELEMENT_FIELD: String
}

public interface NamespaceField {
    prop NAMESPACE_FIELD: String
}

public interface XmlField <: QNameField & ElementField & NamespaceField & ClassIdentify {}

extend MessageSubject <: XmlField {
    public prop QNAME_FIELD: QName {
        get() {
            MessageSubject.QNAME
        }
    }
    public prop ELEMENT_FIELD: String {
        get() {
            MessageSubject.ELEMENT
        }
    }
    public prop NAMESPACE_FIELD: String {
        get() {
            MessageSubject.NAMESPACE
        }
    }
    public func getClass(): ClassId {
        getClassId()
    }
    public static func getClassId(): ClassId {
        "MessageSubject"
    }
}

extend MessageThread <: XmlField {
    public prop QNAME_FIELD: QName {
        get() {
            MessageThread.QNAME
        }
    }
    public prop ELEMENT_FIELD: String {
        get() {
            MessageThread.ELEMENT
        }
    }
    public prop NAMESPACE_FIELD: String {
        get() {
            MessageThread.NAMESPACE
        }
    }
    public func getClass(): ClassId {
        getClassId()
    }
    public static func getClassId(): ClassId {
        "MessageThread"
    }
}

extend MessageBody <: XmlField {
    public prop QNAME_FIELD: QName {
        get() {
            MessageBody.QNAME
        }
    }
    public prop ELEMENT_FIELD: String {
        get() {
            MessageBody.ELEMENT
        }
    }
    public prop NAMESPACE_FIELD: String {
        get() {
            MessageBody.NAMESPACE
        }
    }
    public func getClass(): ClassId {
        getClassId()
    }
    public static func getClassId(): ClassId {
        "MessageBody"
    }
}

func getQnameFromClassid(cid: ClassId): ?QName {
    match (cid) {
        case "MessageSubject" => MessageSubject.QNAME
        case "MessageThread" => MessageThread.QNAME
        case "MessageBody" => MessageBody.QNAME
        case _ => None
    }
}

func getElementFromClassid(cid: ClassId): ?String {
    match (cid) {
        case "MessageSubject" => MessageSubject.ELEMENT
        case "MessageThread" => MessageThread.ELEMENT
        case "MessageBody" => MessageBody.ELEMENT
        case _ => None
    }
}

func getNamespaceFromClassid(cid: ClassId): ?String {
    match (cid) {
        case "MessageSubject" => MessageSubject.NAMESPACE
        case "MessageThread" => MessageThread.NAMESPACE
        case "MessageBody" => MessageBody.NAMESPACE
        case _ => None
    }
}
