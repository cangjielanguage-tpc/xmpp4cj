/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * public abstract class AbstractTextElement <: ExtensionElement
 *
 * 抽象文本元素类，实现了扩展元素的基本特性。
 * <p>
 * 该类为实现带文本内容的扩展元素提供了基础，包含文本和语言的处理。
 * </p>
 */
public abstract class AbstractTextElement <: ExtensionElement {
    /**
     * XML 元素名称
     */
    public static let ELEMENT: String = "text"

    private let text: String // 文本内容 

    private let lang: ?String // 语言标识 

    /**
     * 构造函数，创建一个抽象文本元素。
     *
     * @param text 文本内容，不能为空。
     * @param lang 语言标识，可以为空。
     * @throws IllegalArgumentException 如果文本为空或 null。
     */
    protected AbstractTextElement(text: String, lang: ?String) {
        this.text = StringUtils.requireNotNullNorEmpty(text, "Text must not be None nor empty")
        this.lang = lang
    }

    /**
     * 获取元素的名称。
     *
     * @return XML 元素名称，始终为 "text"。
     */
    public override func getElementName(): String {
        return ELEMENT
    }

    /**
     * 将该元素转换为 XML 格式的字符串。
     *
     * @param enclosingNamespace XML 环境（可能的命名空间）。
     * @return 该元素的 XML 表示。
     */
    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()
        xml.escape(text)
        xml.closeElement(this)
        return xml
    }

    /**
     * 获取文本内容。
     *
     * @return 文本内容，不能为空。
     */
    public func getText(): String {
        return text
    }

    /**
     * 获取语言标识。
     *
     * @return 语言标识，可以为空。
     */
    public override func getLanguage(): ?String {
        return lang
    }
}

/**
 * 表示一个用于 XMPP 短语错误的文本元素。
 * <p>
 * 该类扩展了 {@link AbstractTextElement}，用于在 XMPP 协议中描述错误条件及其相关文本。
 * </p>
 */
public class StanzaErrorTextElement <: AbstractTextElement {
    /**
     * 命名空间，定义错误条件和文本的特定命名空间.
     */
    public static let NAMESPACE: String = StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE

    /**
     * 构造一个 StanzaErrorTextElement 实例。
     *
     * @param text 文本内容，不能为空。
     * @param lang 语言标识，可以为空。
     * @throws IllegalArgumentException 如果文本为空或 null。
     */
    public StanzaErrorTextElement(text: String, lang: ?String) {
        super(text, lang)
    }

    /**
     * 获取该元素的命名空间。
     *
     * @return 该元素的命名空间，作为错误条件和文本命名空间。
     */
    public override func getNamespace(): String {
        return NAMESPACE
    }
}
