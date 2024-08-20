/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xml

public class QName <: ToString & Hashable & Equatable<QName> {
    var namespace: String
    let local: String
    let prefix: String
    public init(localPart: String) {
        this("", localPart, "")
    }
    public init(namespaceURI: String, localPart: String) {
        this(namespaceURI, localPart, "")
    }
    public init(namespaceURI: String, localPart: String, prefix: String) {
        this.namespace = namespaceURI
        this.local = localPart
        this.prefix = prefix
    }
    public func getNamespaceURI(): String {
        namespace
    }
    public func getPrefix(): String {
        prefix
    }
    public func getLocalPart(): String {
        local
    }
    public func getFullName(): String {
        if (prefix == "") {
            return local
        } else {
            return "${prefix}:${local}"
        }
    }
    public override func toString(): String {
        if (namespace == "") {
            return local
        } else {
            return "{" + namespace + "}" + local
        }
    }
    public operator func ==(qname: QName): Bool {
        refEq(this, qname) || (namespace == qname.namespace && local == qname.local && prefix == qname.prefix)
    }
    public operator func !=(qname: QName): Bool {
        !(this == qname)
    }

    @OverflowWrapping
    public func hashCode(): Int64 {
        var result: Int64 = 17
        result = 31 * result + namespace.hashCode()
        result = 31 * result + local.hashCode()
        result = 31 * result + prefix.hashCode()
        return result
    }
}

public let EMPTY_QNAME = QName("", "")
public let EMPTY_ELEMENT = ""
public let EMPTY_NAMESPACE = ""
