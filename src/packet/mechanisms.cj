/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * {@code Mechanisms} 类表示用于 XMPP SASL（简单认证和安全层）认证的机制列表。
 * <p>
 * 该类实现了 {@link ExtensionElement} 接口，并提供了生成对应 XML 表示的方法。
 * 它包含通过 SASL 认证使用的机制名称，并支持从单一机制或机制集合初始化实例。
 * </p>
 */
public class Mechanisms <: ExtensionElement {
    /**
     * mechanisms常量。
     */
    public static let ELEMENT = "mechanisms"

    /**
     * 命名空间。
     */
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-sasl"

    /**
     * QNAME对象。
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    /**
     * 存储机制名称的列表。
     */
    public let mechanisms = LinkedList<String>()

    /**
     * 使用指定的机制名称初始化 {@code Mechanisms} 实例。
     *
     * @param mechanism 要添加的单个 SASL 机制名称。
     */
    public init(mechanism: String) {
        mechanisms.append(mechanism)
    }

    /**
     * 使用指定的机制集合初始化 {@code Mechanisms} 实例。
     *
     * @param mechanisms 要添加的 SASL 机制名称集合。
     */
    public init(mechanisms: Iterable<String>) {
        for (v in mechanisms) {
            this.mechanisms.append(v)
        }
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    /**
     * 获取不可修改的机制名称列表。
     *
     * @return 包含所有机制名称的不可变列表。
     */
    public func getMechanisms(): Collection<String> {
        return mechanisms
    }

    /**
     * 将此 {@code Mechanisms} 实例转换为对应的 XML 表示形式。
     *
     * @param xmlEnvironment 包含的 XML 环境，用于生成正确的 XML 结构。
     * @return XML 字符串构建器，表示该机制的 XML 表示。
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this)
        xml.rightAngleBracket()
        for (mechanism in mechanisms) {
            xml.element("mechanism", mechanism)
        }
        xml.closeElement(this)
        return xml
    }
}
