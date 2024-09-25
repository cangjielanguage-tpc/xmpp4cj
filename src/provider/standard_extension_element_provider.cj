/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 * The parser for {@link StandardExtensionElement}s.
 */
public class StandardExtensionElementProvider <: ExtensionElementProvider<StandardExtensionElement> {
    public init() {
        super()
    }

    public static var INSTANCE: StandardExtensionElementProvider = StandardExtensionElementProvider()

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
            if (!StringUtils.isNotEmpty(nsprefix)) {
                throw Exception("AssertionError")
            }
            let nsuri = parser.getNamespaceUri(i)
            attributes.put("xmlns:" + (nsprefix), nsuri)
        }
        for (i in 0..attributeCount) {
            let attributePrefix = parser.getAttributePrefix(i)
            let attributeName = parser.getAttributeName(i)
            let attributeValue = parser.getAttributeValue(i)
            let attributeKey: String
            if (StringUtils.isNullOrEmpty(attributePrefix)) {
                attributeKey = attributeName
            } else {
                attributeKey = (attributePrefix) + r':'.toString() + (attributeName)
            }
            attributes.put(attributeKey, attributeValue)
        }
        builder.addAttributes(attributes)

        while (true) {
            let event = parser.next()
            match (event) {
                case XmlPullParserEvent.START_ELEMENT => builder.addElement(
                    parse(parser, parser.getDepth(), xmlEnvironment))
                case XmlPullParserEvent.TEXT_CHARACTERS => builder.setText(parser.getText())
                case XmlPullParserEvent.END_ELEMENT => if (initialDepth == parser.getDepth()) {
                    break
                }
                case _ => ()
            }
        }
        ParserUtils.assertAtEndTag(parser)
        return builder.build()
    }
}
