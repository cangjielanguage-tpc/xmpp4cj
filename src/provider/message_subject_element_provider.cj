/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public class MessageSubjectElementProvider <: ExtensionElementProvider<MessageSubject> {
    public init() {
        super()
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): MessageSubject {
        let xmlLangSubject = ParserUtils.getXmlLang(parser)
        let subject = parser.nextText()
        return MessageSubject(xmlLangSubject, subject)
    }
}
