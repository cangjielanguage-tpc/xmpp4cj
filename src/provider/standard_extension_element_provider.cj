/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.provider

/**
 * The parser for {@link StandardExtensionElement}s.
 */
public class StandardExtensionElementProvider <: ExtensionElementProvider<StandardExtensionElement> {
    private init() {
        super("StandardExtensionElement")
    }

    /**
     * 单例实例，用于访问 {@link StandardExtensionElementProvider}
     */
    public static var INSTANCE: StandardExtensionElementProvider = StandardExtensionElementProvider()

    /**
     * 解析 XML 中的标准扩展元素并返回 {@link StandardExtensionElement} 的实例。
     *
     * @param parser 用于解析 XML 的 {@link XmlPullParser}
     * @param initialDepth 初始深度，用于跟踪 XML 解析的层级
     * @param xmlEnvironment 当前 XML 环境的上下文
     * @return 返回解析后的 {@link StandardExtensionElement} 实例
     * @throws XmlPullParserException 如果解析过程中发生 XML 解析异常
     * @throws IOException 如果在解析期间发生 I/O 错误
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): StandardExtensionElement {
        let name = parser.getName()
        let namespace = parser.getNamespace()
        let builder = StandardExtensionElement.builder(name, namespace)
        let namespaceCount = parser.getNamespaceCount()
        let attributeCount = parser.getAttributeCount()
        let attributes: Map<String, String> = HashMap(namespaceCount + attributeCount) // TODO
        for (i in 0..namespaceCount) {
            let nsprefix = parser.getNamespacePrefix(i)
            if (nsprefix.size == 0) {
                continue
            }
            assert(StringUtils.isNotEmpty(nsprefix))
            let nsuri = parser.getNamespaceUri(i)
            attributes.add("xmlns:${nsprefix}", nsuri)
        }
        for (i in 0..attributeCount) {
            let attributePrefix = parser.getAttributePrefix(i)
            let attributeName = parser.getAttributeName(i)
            let attributeValue = parser.getAttributeValue(i)
            let attributeKey: String
            if (StringUtils.isNullOrEmpty(attributePrefix)) {
                attributeKey = attributeName
            } else {
                attributeKey = "${attributePrefix}:${attributeName}"
            }
            attributes.add(attributeKey, attributeValue)
        }
        builder.addAttributes(attributes)

        while (true) {
            let event = parser.next()
            match (event) {
                case XmlPullParserEvent.START_ELEMENT => builder.addElement(
                    parse(parser, parser.getDepth(), xmlEnvironment))
                case XmlPullParserEvent.TEXT_CHARACTERS => builder.setText(parser.getText())
                case XmlPullParserEvent.END_ELEMENT =>
                    if (initialDepth == parser.getDepth()) {
                        break
                    }
                case _ => ()
            }
        }
        ParserUtils.assertAtEndTag(parser)
        return builder.build()
    }
}
