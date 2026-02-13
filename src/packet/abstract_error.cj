/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.packet

/**
 * AbstractError 类是表示包含描述性文本和扩展元素的错误的抽象基类。
 * 该类提供了获取描述性文本和扩展的功能。
 */
public open class AbstractError {
    /**
     * 描述性文本的命名空间。
     */
    protected let textNamespace: ?String

    /**
     * 存储描述性文本的映射，键为语言代码，值为相应的文本。
     */
    protected let descriptiveTexts: Map<String, String>

    /**
     * 存储扩展元素的列表。
     */
    protected let extensions: Collection<ExtensionElement>

    /**
     * 通过描述性文本映射构造AbstractError
     *
     * @param descriptiveTexts 描述性文本映射
     */
    protected init(descriptiveTexts: ?Map<String, String>) {
        this(descriptiveTexts, None)
    }

    /**
     * 通过描述性文本映射和扩展元素列表构造AbstractError
     *
     * @param descriptiveTexts 描述性文本映射
     * @param extensions 扩展元素列表
     */
    protected init(descriptiveTexts: ?Map<String, String>, extensions: ?Collection<ExtensionElement>) {
        this(descriptiveTexts, None, extensions)
    }

    /**
     * 通过描述性文本映射和命名空间和扩展元素列表构造AbstractError
     *
     * @param descriptiveTexts 描述性文本映射
     * @param textNamespace 命名空间
     * @param extensions 扩展元素列表
     */
    protected init(
        descriptiveTexts: ?Map<String, String>,
        textNamespace: ?String,
        extensions: ?Collection<ExtensionElement>
    ) {
        this.descriptiveTexts = descriptiveTexts ?? Collections.EMPTY_STRING_MAP
        this.textNamespace = textNamespace
        this.extensions = extensions ?? EMPTY_EXTENSION_ELEMENT_COLLECTION
    }

    /**
     * 获取此错误的描述性文本。
     * <p>
     * 如果可能，以系统默认语言返回此错误的描述性文本。可能返回 None。
     * </p>
     *
     * @return 描述性文本或 None。
     */
    public func getDescriptiveText(): ?String {
        if (descriptiveTexts.size == 0) {
            return None
        }
        // attempt to obtain the text in the user's locale, the English text, or the "" default
        let l: TimeZone = TimeZone.Local
        let tags: Array<String> = [
            l.toString(),
            "en",
            ""
        ]
        for (tag in tags) {
            let descriptiveText: ?String = getDescriptiveText(tag)
            if (let Some(v) <- descriptiveText) {
                return v
            }
        }
        return (descriptiveTexts |> take(1) |> map {kv => kv[1]}).next()
    }

    /**
     * 获取此错误的描述性文本。
     * <p>
     * 以给定语言返回此错误的描述性文本。如果不可用，则可能返回 None。
     * </p>
     *
     * @param xmllang 语言。
     * @return 描述性文本或 None。
     */
    public func getDescriptiveText(xmllang: String): ?String {
        return descriptiveTexts.get(xmllang)
    }

    /**
     * 返回第一个与指定元素名称和命名空间匹配的节扩展，或者如果不存在则返回 <code>None</code>。
     *
     * @param elementName 节扩展的 XML 元素名称。
     * @param namespace 节扩展的 XML 元素命名空间。
     * @return 扩展，或者如果不存在则返回 <code>None</code>。
     */
    public func getExtension<PE>(elementName: String, namespace: String): ?ExtensionElement where PE <: ExtensionElement {
        return PacketUtil.extensionElementFrom(extensions, elementName, namespace)
    }

    /**
     * 将描述性文本和扩展内容添加到给定的 XmlStringBuilder 中。
     *
     * @param xml XmlStringBuilder 实例
     */
    protected func addDescriptiveTextsAndExtensions(xml: XmlStringBuilder) {
        for ((xmllang, text) in descriptiveTexts) {
            xml
                .halfOpenElement("text")
                .xmlnsAttribute(textNamespace)
                .optXmlLangAttribute(xmllang)
                .rightAngleBracket()
                .escape(text)
                .closeElement("text")
        }
        xml.append(extensions)
    }
}
