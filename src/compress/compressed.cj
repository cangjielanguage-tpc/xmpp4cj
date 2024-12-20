/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.compress

/**
 * Compressed 类表示 XMPP 协议中的压缩非自定义数据（Nonza）元素。
 * <p>
 * 该类实现了 Nonza 接口，表示一个通用的压缩指令，可以被客户端和服务器使用。
 * </p>
 */
public class Compressed <: Nonza {
    /**
     * 此元素的名称。
     */
    public static let ELEMENT = "compressed"

    /**
     * 此元素所属的命名空间，引用了 Compress 类的命名空间。
     */
    public static let NAMESPACE = Compress.NAMESPACE

    /**
     * 此元素的 QNAME，包含命名空间和元素名称。
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    /**
     * Compressed 类的单例实例。
     */
    public static let INSTANCE = Compressed()

    static init() {
        QNAME_MAPPING.put("Compressed", QNAME)
        ELEMENT_MAPPING.put("Compressed", ELEMENT)
        NAMESPACE_MAPPING.put("Compressed", NAMESPACE)
    }

    /**
     * 获取此元素的名称。
     *
     * @return 返回元素名称 "compressed"。
     */
    public override func getElementName(): String {
        return ELEMENT
    }

    /**
     * 获取此元素所属的命名空间。
     *
     * @return 返回命名空间字符串。
     */
    public override func getNamespace(): String {
        return NAMESPACE
    }

    /**
     * 将此元素转换为 XML 字符串表示。
     *
     * @param xmlEnvironment 包含此元素的 XML 环境。
     * @return 返回表示此压缩元素的 XML 字符串。
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        return "<${ELEMENT} xmlns='${NAMESPACE}'/>"
    }
}
