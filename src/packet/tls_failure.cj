/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 表示 TLS 失败的 Nonza 实现。
 * <p>
 * 该类是单例模式，提供了一个实例来表示 TLS 失败的状态。
 * </p>
 */
public class TlsFailure <: Nonza {
    /**
     * 单例实例
     */
    public static let INSTANCE = TlsFailure()

    /**
     * XML 元素名称
     */
    public static let ELEMENT = "failure"

    /**
     * XML 命名空间
     */
    public static let NAMESPACE = TlsProceed.NAMESPACE

    /**
     * QName 对象，用于表示元素的命名空间和名称
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    /**
     *  私有构造函数，防止外部实例化
     */
    private init() {}

    /**
     * 获取元素名称
     *
     * @return 元素名称
     */
    public override func getElementName(): String {
        return ELEMENT
    }

    /**
     * 获取命名空间
     *
     * @return 命名空间
     */
    public override func getNamespace(): String {
        return NAMESPACE
    }

    /**
     * 将该对象转换为 XML 字符串表示
     *
     * @param enclosingNamespace 包含的命名空间
     * @return XML 字符串
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        return "<${ELEMENT} xmlns='${NAMESPACE}'/>"
    }
}
