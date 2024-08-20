/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

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
