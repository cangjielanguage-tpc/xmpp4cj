/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.xml

/**
 * 表示一个限定名称（QName）的类，实现了 toString、Hashable 和 Equatable 接口。
 */
public class QName <: ToString & Hashable & Equatable<QName> {
    var namespace: String
    let local: String
    let prefix: String

    /**
     * 初始化方法，只传入本地部分名称，默认命名空间和前缀为空字符串。
     * @param localPart 本地部分名称。
     */
    public init(localPart: String) {
        this("", localPart, "")
    }

    /**
     * 初始化方法，传入命名空间和本地部分名称，默认前缀为空字符串。
     * @param namespaceURI 命名空间。
     * @param localPart 本地部分名称。
     */
    public init(namespaceURI: String, localPart: String) {
        this(namespaceURI, localPart, "")
    }

    /**
     * 完整的初始化方法，传入命名空间、本地部分名称和前缀。
     * @param namespaceURI 命名空间。
     * @param localPart 本地部分名称。
     * @param prefix 前缀。
     */
    public init(namespaceURI: String, localPart: String, prefix: String) {
        this.namespace = namespaceURI
        this.local = localPart
        this.prefix = prefix
    }

    /**
     * 获取命名空间的方法。
     * @return 命名空间字符串。
     */
    public func getNamespaceURI(): String {
        namespace
    }

    /**
     * 获取前缀的方法。
     * @return 前缀字符串。
     */
    public func getPrefix(): String {
        prefix
    }

    /**
     * 获取本地部分名称的方法。
     * @return 本地名称字符串。
     */
    public func getLocalPart(): String {
        local
    }

    /**
     * 获取完整名称的方法。
     * @return 如果前缀为空字符串，返回本地名称；否则返回前缀加冒号加本地名称的字符串。
     */
    public func getFullName(): String {
        if (prefix == "") {
            return local
        } else {
            return "${prefix}:${local}"
        }
    }

    /**
     * 重写 toString 方法。
     * @return 如果命名空间为空字符串，返回本地名称；否则返回大括号括起来的命名空间加本地名称的字符串。
     */
    public override func toString(): String {
        if (namespace == "") {
            return local
        } else {
            return "{${namespace}}${local}"
        }
    }

    /**
     * 重写等于运算符方法。
     * @param qname 要比较的 QName 对象。
     * @return 判断引用是否相等或者命名空间、本地名称和前缀都相等。
     */
    public operator func ==(qname: QName): Bool {
        refEq(this, qname) || (namespace == qname.namespace && local == qname.local && prefix == qname.prefix)
    }

    /**
     * 计算哈希值的方法，并使用了 @OverflowWrapping 属性修饰。
     * @return 计算后的哈希值。
     */
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
