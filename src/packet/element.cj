/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 表示 XML 元素的接口。这与 {@link ExtensionElement} 类似，但不携带命名空间，通常作为节扩展的子元素包含在内。
 */
public interface Element {
    /**
     * 返回此元素的 XML 表示形式。
     *
     * @param xmlEnvironment 节点。
     * @return 节扩展作为 XML。
     */
    func toXML(xmlEnvironment: ?XmlEnvironment): ToString

    /**
     * 返回此元素的 XML 表示形式。此方法接受一个可选的封闭命名空间参数，如果该值未知，则可以是 None 或空字符串。
     *
     * @param enclosingNamespace 封闭命名空间或 {@code None}。
     * @return 节扩展作为 XML。
     */
    func toXML(enclosingNamespace: String): ToString {
        var xmlEnvironment: XmlEnvironment = XmlEnvironment(enclosingNamespace)
        return toXML(xmlEnvironment)
    }

    /**
     * 返回此元素的 XML 表示形式。
     *
     * @return 节扩展作为 XML。
     */
    func toXML(): ToString {
        return toXML(XmlEnvironment.EMPTY)
    }
}

public interface XmlLangElement {
    /**
     * 返回此 XML 元素的 xml:lang，如果未设置则返回 None。
     *
     * @return 此 XML 元素的 xml:lang，或者 None。
     */
    func getLanguage(): ?String
}

/**
 * 表示 XML 元素的接口。这与 {@link ExtensionElement} 类似，但不携带单个命名空间，而是与多个命名空间一起使用。这种情况的例子包括 MUC 的 &ltdestroy/&gt 元素。
 * <p>
 * 请注意，不鼓励使用此接口。原因是每个 XML 元素都是完全限定的，即由命名空间限定。命名空间可能不会明确给出，而是从外部元素继承。在可能的情况下，请使用 {@link FullyQualifiedElement} 代替。
 * </p>
 */
public interface NamedElement <: Element {
    /**
     * 返回根元素名称。
     *
     * @return 元素名称。
     */
    func getElementName(): String
}

public interface FullyQualifiedElement <: NamedElement & XmlLangElement {
    /**
     * 返回根元素的 XML 命名空间。
     *
     * @return 命名空间。
     */
    func getNamespace(): String

    /**
     * 返回QName对象。
     *
     * @return QName对象。
     */
    func getQName(): QName {
        let namespaceURI = getNamespace()
        let localPart = getElementName()
        return QName(namespaceURI, localPart)
    }

    /**
     * 返回语言标识。
     *
     * @return 语言标识。
     */
    func getLanguage(): ?String {
        return None
    }
}

/**
 * 表示扩展元素的接口。
 * <p>
 * 扩展元素是一个带有根元素名称和命名空间的 XML 子文档。扩展元素用于提供超出基本 XMPP 规范的扩展功能。扩展元素的例子包括消息事件、消息属性和额外的存在数据。IQ 节对扩展元素的支持有限。
 * <p>
 * 这个类主要用于 XMPP 节中的扩展内容，充当所谓的“扩展元素”。更多信息请参见 <a href="tools/ietf/org/html/rfc6120#section-8.4">RFC 6120 § 8.4 扩展内容</a>。
 * </p>
 *
 * @see ExtensionElementProvider
 */
public interface ExtensionElement <: FullyQualifiedElement {}

/**
 * XMPP 顶级流元素。这要么是一个节（{@link Stanza}），要么只是一个普通的流元素（{@link Nonza}）。
 */
public interface TopLevelStreamElement <: FullyQualifiedElement {}

public interface PresenceView <: StanzaView {
    /**
     * 返回此存在节的类型。
     *
     * @return 存在节的类型。
     */
    func getType(): PresenceType

    /**
     * 返回存在更新的状态消息，如果没有状态则返回 <code>None</code>。状态是描述用户存在的自由格式文本（例如，“去吃午饭了”）。
     *
     * @return 状态消息。
     */
    func getStatus(): ?String

    /**
     * 返回存在的优先级。
     *
     * @return 优先级。
     * @see <a href="tools/ietf/org/html/rfc6121#section-4.7.2.3">RFC 6121 § 4.7.2.3. 优先级元素</a>
     */
    func getPriority(): Int64

    /**
     * 返回存在的优先级。
     *
     * @return 优先级。
     * @see <a href="tools/ietf/org/html/rfc6121#section-4.7.2.3">RFC 6121 § 4.7.2.3. 优先级元素</a>
     */
    func getPriorityByte(): Byte

    /**
     * 返回存在更新的模式。
     *
     * @return 模式。
     */
    func getMode(): PresenceMode
}
