/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.provider

/**
 * BodyElementProvider 类用于解析消息体元素的扩展。
 * 它扩展了 ExtensionElementProvider，专门处理 Message.Body 类型的扩展元素。
 */
public class BodyElementProvider <: ExtensionElementProvider<MessageBody> {
    /**
     * 构造函数，初始化 BodyElementProvider 实例。
     */
    public init() {
        super("MessageBody")
    }

    /**
     * 解析 XML pull 解析器中的消息体元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度，用于跟踪 XML 文档的层次结构
     * @param xmlEnvironment XML 环境设置
     * @return 解析得到的 Message.Body 对象
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中发生的异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): MessageBody {
        let xmlLang = ParserUtils.getXmlLang(parser)
        let body = PacketParserUtils.parseElementText(parser)
        return MessageBody(xmlLang, body)
    }
}
