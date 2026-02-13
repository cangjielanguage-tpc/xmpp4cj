/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.provider

/**
 * IntrospectionProvider 类用于提供 XML 的解析功能。
 * 它包含了用于解析 IQ 和 ExtensionElement 的两个抽象类。
 */
public class IntrospectionProvider {
    /**
     * 解析 XML 元素并返回相应的对象。
     *
     * @param parser XmlPullParser 实例
     * @param initialDepth 解析时的初始深度
     * @param eInit 泛型的构造函数
     * @param ePropertySetter 泛型实例的setter方法 (E实例, 属性名, 属性值) -> Unit
     *
     * @return 解析得到的对象
     *
     * @throws XmlPullParserException XML 解析异常
     * @throws IOException I/O 过程中的异常
     */
    public static func parseWithIntrospection<E>(
        parser: XmlPullParser,
        initialDepth: Int,
        eInit: () -> E,
        ePropertySetter: (E, String, String) -> Unit
    ): E where E <: Element {
        ParserUtils.assertAtStartTag(parser)
        let object = eInit()

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let name = parser.getName()
                    let stringValue = parser.nextText()
                    ePropertySetter(object, name, stringValue)
                case XmlPullParserEvent.END_ELEMENT =>
                    if (parser.getDepth() == initialDepth) {
                        break
                    }
                case _ => ()
            }
        }
        ParserUtils.assertAtEndTag(parser)
        return object
    }
}

/**
 * public abstract class IQIntrospectionProvider<I> <: IqProvider<I> where I <: IQ
 *
 * IQIntrospectionProvider 是一个抽象类，用于解析 IQ 元素。
 *
 * @param <I> 具体的 IQ 类型
 */
public abstract class IQIntrospectionProvider<I> <: IqProvider<I> where I <: IQ {
    /**
     * 构造函数，初始化 IQIntrospectionProvider。
     *
     * @param elementClass 泛型I的ClassId
     * @param iqInit 泛型I的构造方法
     * @param iqPropertySetter 泛型I的setter方法 (IQ实例, 属性名, 属性值) -> Unit
     */
    protected IQIntrospectionProvider(
        elementClass: ClassId,
        private let iqInit: () -> I,
        private let iqPropertySetter: (I, String, String) -> Unit
    ) {
        super(elementClass)
    }

    /**
     * 解析 XML pull 解析器中的 IQ 元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度
     * @param iqData IqData
     * @param xmlEnvironment XML 环境设置
     * @return 解析得到的 IQ 元素
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, iqData: IqData, xmlEnvironment: ?XmlEnvironment): I {
        try {
            return IntrospectionProvider.parseWithIntrospection(parser, initialDepth, iqInit, iqPropertySetter)
        } catch (e: Exception) {
            throw XmppParsingException(e)
        }
    }
}

/**
 * public abstract class PacketExtensionIntrospectionProvider<PE> <: ExtensionElementProvider<PE> where PE <: ExtensionElement
 *
 * PacketExtensionIntrospectionProvider 是一个抽象类，用于解析 Packet 扩展元素。
 *
 * @param <PE> 具体的扩展元素类型
 */
public abstract class PacketExtensionIntrospectionProvider<PE> <: ExtensionElementProvider<PE> where PE <: ExtensionElement {
    /**
     * 构造函数，初始化 PacketExtensionIntrospectionProvider。
     *
     * @param elementClass 扩展元素类型的ClassId
     * @param peInit 泛型PE的构造方法
     * @param pePropertySetter 泛型PE的setter方法 (IQ实例, 属性名, 属性值) -> Unit
     */
    protected PacketExtensionIntrospectionProvider(
        elementClass: ClassId,
        private let peInit: () -> PE,
        private let pePropertySetter: (PE, String, String) -> Unit
    ) {
        super(elementClass)
    }

    /**
     * 解析 XML pull 解析器中的扩展元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度
     * @param xmlEnvironment XML 环境设置
     * @return 解析得到的扩展元素
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): PE {
        try {
            return IntrospectionProvider.parseWithIntrospection(parser, initialDepth, peInit, pePropertySetter)
        } catch (e: Exception) {
            throw XmppParsingException(e)
        }
    }
}
