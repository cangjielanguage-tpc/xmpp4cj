/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
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
    // throws IOException, XmlPullParserException, ParsingException
    public func parse(parser: XmlPullParser): E {
        return parse(parser, None)
    }

    // throws IOException, XmlPullParserException, ParsingException
    public func parse(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): E {
        // XPP3 calling convention assert: Parser should be at start tag
        ParserUtils.assertAtStartTag(parser)

        let initialDepth = parser.getDepth()
        let xmlEnvironment: XmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)

        let e: E = parse(parser, initialDepth, xmlEnvironment)

        // XPP3 calling convention assert: Parser should be at end tag of the consumed/parsed element
        ParserUtils.forwardToEndTagOfDepth(parser, initialDepth)
        return e
    }

    // throws XmlPullParserException, IOException, ParsingException
    public func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): E
}
