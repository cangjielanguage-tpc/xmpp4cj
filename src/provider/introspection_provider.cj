/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public class IntrospectionProvider {
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
     * Decodes a String into an object of the specified type. If the object
     * type is not supported, null will be returned.
     *
     * @param type the type of the property.
     * @param value the encode String value to decode.
     * @return the String value decoded into the specified type.
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

public abstract class IntrospectionProvider_IQIntrospectionProvider<I> <: IqProvider<I> where I <: IQ {
    private let _elementClass: ClassTypeInfo

    protected init(elementClass: ClassTypeInfo) {
        super()
        this._elementClass = elementClass
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, iqData: IqData, xmlEnvironment: ?XmlEnvironment): I {
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

public abstract class IntrospectionProvider_PacketExtensionIntrospectionProvider<PE> <: ExtensionElementProvider<PE> where PE <: ExtensionElement {
    private let _elementClass: ClassTypeInfo

    protected init(elementClass: ClassTypeInfo) {
        super()
        this._elementClass = elementClass
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): PE {
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
