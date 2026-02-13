/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.provider

public class MessageSubjectElementProvider <: ExtensionElementProvider<MessageSubject> {
    /**
     * 构造函数，初始化 MessageSubjectElementProvider 实例。
     */
    public init() {
        super("MessageSubject")
    }

    /**
     * 用于解析元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度
     * @param xmlEnvironment 当前的 XML 环境设置
     * @return 解析得到的元素实例
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     * @throws XmppParsingException Xmpp 解析过程中抛出的异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): MessageSubject {
        let xmlLangSubject = ParserUtils.getXmlLang(parser)
        let subject = parser.nextText()
        return MessageSubject(xmlLangSubject, subject)
    }
}
