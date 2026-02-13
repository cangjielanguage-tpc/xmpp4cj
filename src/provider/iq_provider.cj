/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.provider

/**
 * public abstract class IqProvider<I> <: AbstractProvider<I> where I <: IQ
 *
 * IqProvider 是一个抽象类，用于解析 IQ（信息查询）相关的 XML 数据。
 *
 * @param <I> 解析的 IQ 类型，必须是 IQ 的子类
 */
public abstract class IqProvider<I> <: AbstractProvider<I> where I <: IQ {
    public init(elementClass: ClassId) {
        super(elementClass)
    }
    /**
     * 解析给定的 XML Pull 解析器中的 IQ 数据。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param iqCommon IQ 数据的公共部分
     * @return 解析得到的 IQ 实例
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     * @throws XmppParsingException Xmpp 解析过程中抛出的异常
     */
    public func parse(parser: XmlPullParser, iqCommon: IqData): I {
        return parse(parser, iqCommon, None)
    }

    /**
     * 解析给定的 XML Pull 解析器中的 IQ 数据，支持外部 XML 环境设置。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param iqData IQ 数据对象，包含解析所需的额外信息
     * @param outerXmlEnvironment 外部 XML 环境设置，可能为 null
     * @return 解析得到的 IQ 实例
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     * @throws XmppParsingException Xmpp 解析过程中抛出的异常
     */
    public func parse(parser: XmlPullParser, iqData: IqData, outerXmlEnvironment: ?XmlEnvironment): I {
        let initialDepth = parser.getDepth()
        let xmlEnvironment: XmlEnvironment = XmlEnvironment.froms(parser, outerXmlEnvironment)

        return parse(parser, initialDepth, iqData, xmlEnvironment)
    }

    /**
     * 抽象方法，解析 IQ 数据。
     * 实际解析逻辑由子类实现。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度
     * @param iqData IQ 数据对象，包含解析所需的额外信息
     * @param xmlEnvironment 当前的 XML 环境设置
     * @return 解析得到的 IQ 实例
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     * @throws XmppParsingException Xmpp 解析过程中抛出的异常
     */
    public func parse(parser: XmlPullParser, initialDepth: Int, iqData: IqData, xmlEnvironment: ?XmlEnvironment): I
}

type IqProviderParse4 = (XmlPullParser, Int, IqData, ?XmlEnvironment) -> IQ

class IqProviderWrapper <: IqProvider<IQ> {
    public IqProviderWrapper(elementClass: ClassId, let parse4: IqProviderParse4) {
        super(elementClass)
    }
    public func parse(parser: XmlPullParser, initialDepth: Int, iqData: IqData, xmlEnvironment: ?XmlEnvironment): IQ {
        parse4(parser, initialDepth, iqData, xmlEnvironment)
    }
}
