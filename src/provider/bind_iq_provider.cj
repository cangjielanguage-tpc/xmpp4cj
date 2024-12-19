/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.provider

/**
 * BindIQProvider 类用于解析 Bind IQ 请求和响应的 XML 数据。
 * 它扩展了 IQProvider，专门处理 Bind 类型的 IQ 消息。
 */
public class BindIQProvider <: IqProvider<Bind> {
    /**
     * 构造函数，初始化 BindIQProvider 实例。
     */
    public init() {
        super("Bind")
    }

    /**
     * 解析 XML pull 解析器中的 Bind 元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度，用于跟踪 XML 文档的层次结构
     * @param iqData IqData
     * @param xmlEnvironment XML 环境设置
     * @return 解析得到的 Bind 对象，可能为 None
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中发生的异常
     */
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
                case XmlPullParserEvent.END_ELEMENT =>
                    if (parser.getDepth() == initialDepth) {
                        break
                    }
                case _ => ()
            }
        }
        return bind.getOrThrow()
    }
}
