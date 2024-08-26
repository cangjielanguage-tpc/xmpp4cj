/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public open class AbstractProvider<E> where E <: Element {
    private let elementClass: ClassId

    protected init(elementClass: ClassId) {
        this.elementClass = elementClass
    }

    public func getElementClass(): ClassId {
        return elementClass
    }
}

/**
 * Xmpp provider are the parsers used to deserialize raw XMPP into the according {@link Element}s.
 * <p>
 * At any time when {@link #parse(XmlPullParser, int, XmlEnvironment)} is invoked any type of exception can be thrown.
 * If the parsed element does not follow the specification,
 * for example by putting a string where only integers are allowed,
 * then a {@link Xmpp4cjException} should be thrown.
 * </p>
 *
 * @param <E> the type of the resulting element.
 */
public abstract class Provider<E> <: AbstractProvider<E> where E <: Element {
    protected init(cid: ClassId) {
        super(cid)
    }

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
 * An abstract class for parsing custom extensions elements. Each ExtensionElementProvider must
 * be registered with the ProviderManager class for it to be used. Every implementation
 * of this abstract class <b>must</b> have a public, no-argument constructor.
 */
public abstract class ExtensionElementProvider<EE> <: Provider<EE> where EE <: Element {
    public init(elementClass: ClassId) {
        super(elementClass)
    }
}

public abstract class NonzaProvider<N> <: Provider<N> where N <: Element {
    public init(cid: ClassId) {
        super(cid)
    }
}

public abstract class IqProvider<I> <: AbstractProvider<I> where I <: IQ {
    public init(cid: ClassId) {
        super(cid)
    }

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
 * Used to load providers into the {@link ProviderManager}.
 */
public interface ProviderLoader {
    /**
     * Provides the IQ provider info for the creation of IQ providers to be added to the <code>ProviderManager</code>.
     * @return The IQ provider info to load.
     */
    func getIQProviderInfo(): Iterator<IQProviderInfo>

    /**
     * Provides the extension providers for the creation of extension providers to be added to the <code>ProviderManager</code>.
     * @return The extension provider info to load.
     */
    func getExtensionProviderInfo(): Iterator<ExtensionProviderInfo>

    /**
     * Provides the stream feature providers information for the creation of stream feature
     * providers to be added to the <code>ProviderManager</code>.
     *
     * @return The extension provider info to load.
     */
    func getStreamFeatureProviderInfo(): Iterator<StreamFeatureProviderInfo>
}
