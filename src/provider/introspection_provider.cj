/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**  
 * IntrospectionProvider 类用于提供 XML 的反射式解析功能。
 * 它包含了用于解析 IQ 和 Packet 扩展的两个内部抽象类。
 */
public class IntrospectionProvider {
    /**  
     * 使用反射解析 XML 元素并返回相应的对象。
     *
     * @param objectClass 对应的类类型
     * @param parser XmlPullParser 实例
     * @param initialDepth 解析时的初始深度
     * @return 解析得到的对象
     * @throws NoSuchMethodException 找不到构造方法的异常
     * @throws SecurityException 安全异常
     * @throws InstantiationException 实例化异常
     * @throws IllegalAccessException 访问异常
     * @throws XmlPullParserException XML 解析异常
     * @throws IOException I/O 过程中的异常
     * @throws IllegalArgumentException 非法参数异常
     * @throws InvocationTargetException 调用目标异常
     * @throws ClassNotFoundException 类未找到异常
     */
    public static func parseWithIntrospection(objectClass: ClassTypeInfo, parser: XmlPullParser, initialDepth: Int): Any {
        ParserUtils.assertAtStartTag(parser)
        let object = objectClass.getConstructor().apply()

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let name = parser.getName()
                    let stringValue = parser.nextText()
                    let propertyType = objectClass.getInstanceFunction(
                        "get" + Rune(name[0]).toUpperCase().toString() + name[1..], []).returnType
                    let value = decode(propertyType, stringValue)
                    objectClass.getInstanceFunction("set" + Rune(name[0]).toUpperCase().toString() + name[1..],
                        [propertyType]).apply(object, [value])
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        ParserUtils.assertAtEndTag(parser)
        return object
    }

    /**  
     * 将字符串解码为指定类型的对象。如果不支持该类型，将返回 None。
     *
     * @param type 属性的类型
     * @param value 需要解码的字符串值
     * @return 解码后的对象
     * @throws ClassNotFoundException 类未找到异常
     */
    private static func decode(typ: TypeInfo, value: String): Any {
        let name: String = typ.name
        match (name) {
            case "String" => return value
            case "Bool" => return Bool.parse(value)
            case "Int64" => return Int64.parse(value)
            case "Float64" => return Float64.parse(value)
            case "UInt8" => return UInt8.parse(value)
            case "Rune" => return Rune.parse(value)
            case "TypeInfo" => return TypeInfo.get(value)
            case _ => ()
        }
        return None<Any>
    }
}

/**  
 * IQIntrospectionProvider 是一个抽象类，用于解析 IQ 元素。
 *
 * @param <I> 具体的 IQ 类型
 */
public abstract class IntrospectionProviderIQIntrospectionProvider<I> <: IqProvider<I> where I <: IQ {
    private let _elementClass: ClassTypeInfo

    /**  
     * 构造函数，初始化 IQIntrospectionProvider。
     *
     * @param elementClass IQ 类型的类对象
     */
    protected init(elementClass: ClassTypeInfo) {
        super()
        this._elementClass = elementClass
    }

    /**  
     * 解析 XML pull 解析器中的 IQ 元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度
     * @param _ IqData
     * @param _ XML 环境设置
     * @return 解析得到的 IQ 元素
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, _: IqData, _: ?XmlEnvironment): I {
        try {
            return castOrThrow<Any, I>(IntrospectionProvider.parseWithIntrospection(_elementClass, parser, initialDepth)
            )
        } catch (e: Exception) {
            throw IOException()
        }
    }
}

// extend<> IntrospectionProvider_IQIntrospectionProvider<> <: Equatable<IntrospectionProvider_IQIntrospectionProvider<I>> {
//     public operator func == (that: IntrospectionProvider_IQIntrospectionProvider<I>): Bool {
//         return refEq(this, that)
//     }
// }

/**  
 * PacketExtensionIntrospectionProvider 是一个抽象类，用于解析 Packet 扩展元素。
 *
 * @param <PE> 具体的扩展元素类型
 */
public abstract class IntrospectionProviderPacketExtensionIntrospectionProvider<PE> <: ExtensionElementProvider<PE> where PE <: ExtensionElement {
    private let _elementClass: ClassTypeInfo
    /**  
     * 构造函数，初始化 PacketExtensionIntrospectionProvider。
     *
     * @param elementClass 扩展元素类型的类对象
     */
    protected init(elementClass: ClassTypeInfo) {
        super()
        this._elementClass = elementClass
    }

    /**  
     * 解析 XML pull 解析器中的扩展元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度
     * @param _ XML 环境设置
     * @return 解析得到的扩展元素
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, _: ?XmlEnvironment): PE {
        try {
            return castOrThrow<Any, PE>(IntrospectionProvider.parseWithIntrospection(_elementClass, parser, initialDepth
            ))
        } catch (e: Exception) {
            throw IOException()
        }
    }
}

// extend<> IntrospectionProvider_PacketExtensionIntrospectionProvider<> <: Equatable<IntrospectionProvider_PacketExtensionIntrospectionProvider<PE>> {
//     public operator func == (that: IntrospectionProvider_PacketExtensionIntrospectionProvider<PE>): Bool {
//         return refEq(this, that)
//     }
// }
