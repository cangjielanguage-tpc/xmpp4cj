/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class ParseStreamManagement {
    public static func enabled(parser: XmlPullParser): StreamManagementEnabled {
        ParserUtils.assertAtStartTag(parser)
        let resume = ParserUtils.getBooleanAttribute(parser, "resume", false)
        let id = parser.getAttributeValue("", "id")
        let location = parser.getAttributeValue("", "location")
        let max = ParserUtils.getIntegerAttribute(parser, "max", -1)
        parser.next()
        ParserUtils.assertAtEndTag(parser)
        return StreamManagementEnabled(id, resume, location, Duration.second * max)
    }

    public static func failed(parser: XmlPullParser): StreamManagementFailed {
        ParserUtils.assertAtStartTag(parser)
        var name: String
        var condition: ?StanzaErrorCondition = None
        let textElements = ArrayList<StanzaErrorTextElement>(4)

        while (true) {
            let event = parser.next()
            match (event) {
                case XmlPullParserEvent.START_ELEMENT =>
                    name = parser.getName()
                    let namespace = parser.getNamespace()
                    if (StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE == namespace) {
                        if (name == AbstractTextElement.ELEMENT) {
                            let lang = ParserUtils.getXmlLang(parser)
                            let text = parser.nextText()
                            let stanzaErrorTextElement = StanzaErrorTextElement(text, lang)
                            textElements.append(stanzaErrorTextElement)
                        } else {
                            condition = StanzaErrorCondition.fromString(name)
                        }
                    }
                case XmlPullParserEvent.END_ELEMENT =>
                    name = parser.getName()
                    if (StreamManagementFailed.ELEMENT == name) {
                        break
                    }
                case _ => ()
            }
        }
        ParserUtils.assertAtEndTag(parser)
        return StreamManagementFailed(condition, textElements)
    }

    public static func resumed(parser: XmlPullParser): StreamManagementResumed {
        ParserUtils.assertAtStartTag(parser)
        let h = ParserUtils.getLongAttribute(parser, "h").getOrThrow() // TODO
        let previd = parser.getAttributeValue("", "previd").getOrThrow() // TODO
        parser.next()
        ParserUtils.assertAtEndTag(parser)
        return StreamManagementResumed(h, previd)
    }

    public static func ackAnswer(parser: XmlPullParser): StreamManagementAckAnswer {
        ParserUtils.assertAtStartTag(parser)
        let h = ParserUtils.getLongAttribute(parser, "h").getOrThrow() // TODO
        parser.next()
        ParserUtils.assertAtEndTag(parser)
        return StreamManagementAckAnswer(h)
    }

    public static func ackRequest(parser: XmlPullParser): StreamManagementAckRequest {
        ParserUtils.assertAtStartTag(parser)
        parser.next()
        ParserUtils.assertAtEndTag(parser)
        return StreamManagementAckRequest.INSTANCE
    }
}
