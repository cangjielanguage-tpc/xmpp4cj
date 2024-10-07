/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public interface QNameField {
    /**
     * 获取默认的QNAME
     */
    prop QNAME_FIELD: QName
}

public interface ElementField {
    /**
     * 获取默认的元素名称
     */
    prop ELEMENT_FIELD: String
}

public interface NamespaceField {
    /**
     * 获取默认的命名空间
     */
    prop NAMESPACE_FIELD: String
}

public interface XmlField <: QNameField & ElementField & NamespaceField & ClassIdentify {}

extend MessageSubject <: XmlField {
    /**
     * 获取默认的QNAME
     */
    public prop QNAME_FIELD: QName {
        get() {
            MessageSubject.QNAME
        }
    }

    /**
     * 获取默认的元素名称
     */
    public prop ELEMENT_FIELD: String {
        get() {
            MessageSubject.ELEMENT
        }
    }

    /**
     * 获取默认的命名空间
     */
    public prop NAMESPACE_FIELD: String {
        get() {
            MessageSubject.NAMESPACE
        }
    }

    /**  
     * 获取ClassId。
     *
     * @return ClassId。
     */
    public func getClass(): ClassId {
        getClassId()
    }

    /**  
     * 获取ClassId。
     *
     * @return ClassId。
     */
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

    /**  
     * 获取ClassId。
     *
     * @return ClassId。
     */
    public func getClass(): ClassId {
        getClassId()
    }

    /**  
     * 获取ClassId。
     *
     * @return ClassId。
     */
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

    /**  
     * 获取ClassId。
     *
     * @return ClassId。
     */
    public func getClass(): ClassId {
        getClassId()
    }

    /**  
     * 获取ClassId。
     *
     * @return ClassId。
     */
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
