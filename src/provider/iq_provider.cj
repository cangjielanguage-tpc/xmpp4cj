/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

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
