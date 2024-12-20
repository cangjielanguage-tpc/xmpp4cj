/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.provider

/**
 * public abstract class Provider<E> <: AbstractProvider<E> where E <: Element
 *
 * XMPP 提供者是用于将原始 XMPP 反序列化为相应的 {@link Element} 的解析器。
 * <p>
 * 在任何时候调用 {@link #parse(XmlPullParser, int, XmlEnvironment)} 时都可能抛出任何类型的异常。
 * 如果解析的元素不符合规范，例如在只允许整数的地方放入一个字符串，
 * 那么应该抛出一个 {@link Xmpp4cjException}。
 * </p>
 *
 * @param <E> 结果元素的类型。
 */
public abstract class Provider<E> <: AbstractProvider<E> where E <: Element {
    public init(elementClass: ClassId) {
        super(elementClass)
    }

    /**
     * 使用给定的 XML Pull 解析器解析元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @return 解析得到的元素实例
     * @throws IOException 读写过程中的异常
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws XmppParsingException Xmpp 解析过程中抛出的异常
     */
    public func parse(parser: XmlPullParser): E {
        return parse(parser, None)
    }

    /**
     * 使用给定的 XML Pull 解析器和外部 XML 环境设置解析元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param outerXmlEnvironment 外部 XML 环境设置，可能为 null
     * @return 解析得到的元素实例
     * @throws IOException 读写过程中的异常
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws XmppParsingException Xmpp 解析过程中抛出的异常
     */
    public func parse(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): E {
        // XPP3 调用约定断言：解析器应位于开始标签 
        ParserUtils.assertAtStartTag(parser)

        let initialDepth = parser.getDepth()
        let xmlEnvironment: XmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)

        let e: E = parse(parser, initialDepth, xmlEnvironment)

        //  XPP3 调用约定断言：解析器应位于已处理/解析元素的结束标签 
        ParserUtils.forwardToEndTagOfDepth(parser, initialDepth)
        return e
    }

    /**
     * 抽象方法，用于解析元素。
     * 实际解析逻辑由子类实现。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度
     * @param xmlEnvironment 当前的 XML 环境设置
     * @return 解析得到的元素实例
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     * @throws XmppParsingException Xmpp 解析过程中抛出的异常
     */
    public func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): E
}
