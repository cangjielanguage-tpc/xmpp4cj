/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public class BindIQProvider <: IqProvider<Bind> {
    public override func parse(parser: XmlPullParser, initialDepth: Int, iqData: IqData, xmlEnvironment: ?XmlEnvironment): Bind {
        var name: String
        var bind: ?Bind = None

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    name = parser.getName()
                    match (name) {
                        case "resource" =>
                            let resourceString = parser.nextText()
                            bind = Bind.newSet(Resourcepart.froms(resourceString))
                        case "jid" =>
                            let fullJid = JidCreate.entityFullFrom(parser.nextText())
                            bind = Bind.newResult(fullJid)
                        case _ => ()
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        return bind.getOrThrow()
    }
}
