/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public class BodyElementProvider <: ExtensionElementProvider<MessageBody> {
    public init() {
        super()
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): MessageBody {
        let xmlLang = ParserUtils.getXmlLang(parser)
        let body = PacketParserUtils.parseElementText(parser)
        return MessageBody(xmlLang, body)
    }
}
