/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.filter

/**
 * 用于过滤具有特定类型 Stanza 扩展的 Stanzas。
 */
public class StanzaExtensionFilter <: StanzaFilter {
    /** 
     * 要匹配的 XML 元素名称
     */
    private let elementName: ?String

    /** 
     * 要匹配的 XML 命名空间
     */
    private let namespace: String

    /**
     * 创建一个新的 Stanza 扩展过滤器。只有当 Stanza 的扩展与指定的元素名称和命名空间匹配时，
     * 才会通过过滤器。
     *
     * @param elementName Stanza 扩展的 XML 元素名称。
     * @param namespace Stanza 扩展的 XML 命名空间。
     */
    public init(elementName: ?String, namespace: String) {
        StringUtils.requireNotNullNorEmpty(namespace, "namespace must not be null nor empty")
        this.elementName = elementName
        this.namespace = namespace
    }

    /**
     * 创建一个新的 Stanza 扩展过滤器。只有当 Stanza 的扩展与指定的命名空间匹配时，
     * 才会通过过滤器。
     *
     * @param namespace Stanza 扩展的 XML 命名空间。
     */
    public init(namespace: String) {
        this(None, namespace)
    }

    /**
     * 根据给定的 Stanza 扩展创建一个新的 Stanza 扩展过滤器。
     *
     * @param packetExtension Stanza 扩展对象。
     */
    public init(packetExtension: ExtensionElement) {
        this(packetExtension.getElementName(), packetExtension.getNamespace())
    }

    /**
     * 检查指定的 Stanza 是否通过该过滤器。
     *
     * @param packet 要检查的 Stanza。
     * @return 如果 Stanza 拥有与过滤器匹配的扩展，则返回 true；否则返回 false。
     */
    public override func accept(packet: Stanza): Bool {
        return packet.hasExtension(elementName, namespace)
    }

    /**
     * 返回过滤器的字符串表示形式，包含元素名称和命名空间信息。
     *
     * @return 过滤器的字符串表示。
     */
    public override func toString(): String {
        return if (let Some(v) <- elementName) {
            "StanzaExtensionFilter: element=${v} namespace=${namespace}"
        } else {
            "StanzaExtensionFilter: element=None namespace=${namespace}"
        }
    }
}
