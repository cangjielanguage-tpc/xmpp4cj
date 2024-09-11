/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public open class AbstractProvider<E> where E <: Element {
    protected var elementClass: ClassId = "" // need init in subclass

    public func getElementClass(): ClassId {
        return elementClass
    }
}

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

/**
 * 一个用于解析自定义扩展元素的抽象类。每个 ExtensionElementProvider 都必须在 ProviderManager 类中注册才能被使用。
 * 这个抽象类的每个实现<b>必须</b>有一个公共的无参构造函数。
 */
public abstract class ExtensionElementProvider<EE> <: Provider<EE> where EE <: Element {}

public abstract class NonzaProvider<N> <: Provider<N> where N <: Element {}

public abstract class IqProvider<I> <: AbstractProvider<I> where I <: IQ {
    // throws XmlPullParserException, IOException, ParsingException 
    public func parse(parser: XmlPullParser, iqCommon: IqData): I {
        return parse(parser, iqCommon, None)
    }

    // throws XmlPullParserException, IOException, ParsingException 
    public func parse(parser: XmlPullParser, iqData: IqData, outerXmlEnvironment: ?XmlEnvironment): I {
        let initialDepth = parser.getDepth()
        let xmlEnvironment: XmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)

        return parse(parser, initialDepth, iqData, xmlEnvironment)
    }

    // throws XmlPullParserException, IOException, ParsingException
    public func parse(parser: XmlPullParser, initialDepth: Int, iqData: IqData, xmlEnvironment: ?XmlEnvironment): I
}

/**
 * 用于将提供者加载到 {@link ProviderManager} 中。
 */
public interface ProviderLoader {
    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的 IQ 提供者的 IQ 提供者信息。
     * @return 要加载的 IQ 提供者信息。
     */
    func getIQProviderInfo(): Iterable<IQProviderInfo>

    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的扩展提供者的扩展提供者信息。
     * @return 要加载的扩展提供者信息。
     */
    func getExtensionProviderInfo(): Iterable<ExtensionProviderInfo>

    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的流特征提供者的流特征提供者信息。
     *
     * @return 要加载的扩展提供者信息。
     */
    func getStreamFeatureProviderInfo(): Iterable<StreamFeatureProviderInfo>
}
