/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.compress

/**  
 * Compress 类表示 XMPP 协议中的压缩非自定义数据（Nonza）元素。
 * <p>
 * 此类用于处理与数据压缩相关的操作，并实现 Nonza 接口。
 * </p>
 */
public class Compress <: Nonza {
    /**  
     * 此元素的名称。
     */
    public static let ELEMENT: String = "compress"

    /**  
     * 此元素所属的命名空间。
     */
    public static let NAMESPACE: String = "http://jabber.org/protocol/compress"

    static init() {
        ELEMENT_MAPPING.put("Compress", ELEMENT)
        NAMESPACE_MAPPING.put("Compress", NAMESPACE)
    }

    /**  
     * 描述所使用的压缩方法。
     */
    public let method: String

    /**  
     * 创建 Compress 实例，指定压缩方法。
     *
     * @param method 使用的压缩方法。
     */
    public init(method: String) {
        this.method = method
    }

    /**
     * 返回根元素名称。
     *
     * @return 元素名称。
     */
    public override func getElementName(): String {
        return ELEMENT
    }

    /**
     * 返回根元素的 XML 命名空间。
     *
     * @return 命名空间。
     */
    public override func getNamespace(): String {
        return NAMESPACE
    }

    /**
     * 返回此元素的 XML 表示形式。
     *
     * @param enclosingNamespace 节点。
     * @return 节扩展作为 XML。
     */
    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml: XmlStringBuilder = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()
        xml.element("method", method)
        xml.closeElement(this)
        return xml
    }
}

/**  
 * Feature 类表示支持的压缩方法的扩展元素。
 * <p>
 * 此类实现了 ExtensionElement 接口，用于表示服务器支持的压缩算法。
 * </p>
 */
public class CompressFeature <: ExtensionElement {
    /**  
     * 此扩展元素的名称。
     */
    public static let ELEMENT: String = "compression"

    /**  
     * 此扩展元素所属的命名空间的 QNAME。
     */
    public static let QNAME: QName = QName(Compress.NAMESPACE, ELEMENT)

    static init() {
        ELEMENT_MAPPING.put("CompressFeature", ELEMENT)
        QNAME_MAPPING.put("CompressFeature", QNAME)
    }

    /**  
     * 支持的压缩方法列表。
     */
    public let methods: Collection<String>

    /**  
     * 创建 Feature 实例，指定支持的压缩方法列表。
     *
     * @param methods 服务器支持的压缩方法。
     */
    public init(methods: Collection<String>) {
        this.methods = methods
    }

    /**  
     * 获取压缩方法的不可修改列表。
     *
     * @return 支持的压缩方法列表。
     */
    public func getMethods(): Collection<String> {
        return methods // Collections.unmodifiableList(methods)
    }

    /**
     * 返回根元素的 XML 命名空间。
     *
     * @return 命名空间。
     */
    public override func getNamespace(): String {
        return Compress.NAMESPACE
    }

    /**
     * 返回根元素名称。
     *
     * @return 元素名称。
     */
    public override func getElementName(): String {
        return ELEMENT
    }

    /**
     * 返回此元素的 XML 表示形式。
     *
     * @param _ 节点。
     * @return 节扩展作为 XML。
     */
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
