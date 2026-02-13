/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.packet

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

/**
 * 定义所有QName映射 因为不能用反射
 * 扩展的Element应在此注册
 */
public let QNAME_MAPPING = HashMap<String, QName>(
    [
        ("BindFeature", BindFeature.QNAME),
        ("Mechanisms", Mechanisms.QNAME),
        ("MessageBody", MessageBody.QNAME),
        ("MessageSubject", MessageSubject.QNAME),
        ("MessageThread", MessageThread.QNAME),
        ("SessionFeature", SessionFeature.QNAME),
        ("StartTls", StartTls.QNAME),
        ("TlsFailure", TlsFailure.QNAME),
        ("TlsProceed", TlsProceed.QNAME)
    ]
)
/**
 * 定义所有ELEMENT映射 因为不能用反射
 * 扩展的Element应在此注册
 */
public let ELEMENT_MAPPING = HashMap<String, String>(
    [
        ("Bind", Bind.ELEMENT),
        ("ErrorIQ", ErrorIQ.ELEMENT),
        ("Mechanisms", Mechanisms.ELEMENT),
        ("Message", Message.ELEMENT),
        ("MessageBody", MessageBody.ELEMENT),
        ("MessageSubject", MessageSubject.ELEMENT),
        ("MessageThread", MessageThread.ELEMENT),
        ("Presence", Presence.ELEMENT),
        ("Session", Session.ELEMENT),
        ("StartTls", StartTls.ELEMENT),
        ("StreamError", StreamError.ELEMENT),
        ("StreamOpen", StreamOpen.ELEMENT),
        ("TlsFailure", TlsFailure.ELEMENT),
        ("TlsProceed", TlsProceed.ELEMENT)
    ]
)
/**
 * 定义所有NAMESPACE映射 因为不能用反射
 * 扩展的Element应在此注册
 */
public let NAMESPACE_MAPPING = HashMap<String, String>(
    [
        ("Bind", Bind.NAMESPACE),
        ("Mechanisms", Mechanisms.NAMESPACE),
        ("MessageBody", MessageBody.NAMESPACE),
        ("MessageSubject", MessageSubject.NAMESPACE),
        ("MessageThread", MessageThread.NAMESPACE),
        ("Session", Session.NAMESPACE),
        ("StartTls", StartTls.NAMESPACE),
        ("StreamError", StreamError.NAMESPACE),
        ("TlsFailure", TlsFailure.NAMESPACE),
        ("TlsProceed", TlsProceed.NAMESPACE)
    ]
)
