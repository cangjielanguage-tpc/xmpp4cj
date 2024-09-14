import std.reflect.*
import std.io.*
import xmpp4cj.packet.*
// func factoryinit(factoryClass: TypeInfo): XmlPullParserFactory {
//     return factoryClass.getDeclaredConstructor().newInstance()
// }

let StAXFactory: XmlPullParserFactory = StaxXmlPullParserFactory()
// let XPP3Factory: XmlPullParserFactory = factoryinit(TypeInfo.of<Xpp3XmlPullParserFactory>())

public enum XmlPullParserKind {
    StAX

    prop factory: XmlPullParserFactory {
        get() {
            match (this) {
                case StAX => StAXFactory
            }
        }
    }
}

let Xml_Pull_Parser_Factorys: Array<XmlPullParserFactory> = [StaxXmlPullParserFactory()]

public class SmackTestUtil {
    public static func parse<P, E>(xml: CharSequence, parserKind: XmlPullParserKind): E where E <: Element,
        P <: AbstractProvider<E> {
        let provider: P = providerClassToProvider<P, E>()
        return parse(xml, provider, parserKind)
    }

    public static func parse<P, E>(inputStream: InputStream, parserKind: XmlPullParserKind): E where E <: Element,
        P <: AbstractProvider<E> {
        let provider: P = providerClassToProvider<P, E>()
        return parse(inputStream, provider, parserKind)
    }

    public static func parse<E>(
        xml: CharSequence,
        provider: AbstractProvider<E>,
        parserKind: XmlPullParserKind
    ): E where E <: Element {
        let xmlString: String = xml.toString()
        let reader = ByteArrayStream()
        reader.write(xmlString.toArray())
        return parse(reader, provider, parserKind)
    }

    public static func parse<E>(
        reader: InputStream,
        abstractProvider: AbstractProvider<E>,
        parserKind: XmlPullParserKind
    ): E where E <: Element {
        let parser: XmlPullParser = getParserFor(reader, parserKind)

        let element: E = match (abstractProvider) {
            case provider: Provider<E> => provider.parse(parser)
            case iqProvider: IqProvider<IQ> => // TODO IqProvider<E>
                let iqData: IqData = PacketParserUtils.parseIqData(parser)
                parser.next()
                ParserUtils.forwardToStartElement(parser)
                let e: IQ = iqProvider.parse(parser, iqData)
                return (e as E).getOrThrow()
            case _ => throw Exception("not implement")
        }

        return element
    }

    public static func getParserFor(xml: String, parserKind: XmlPullParserKind): XmlPullParser {
        let reader = ByteArrayStream()
        reader.write(xml.toArray())
        return getParserFor(reader, parserKind)
    }

    public static func getParserFor(reader: InputStream, parserKind: XmlPullParserKind): XmlPullParser {
        let parser: XmlPullParser = parserKind.factory.newXmlPullParser(reader)
        forwardParserToStartElement(parser)
        return parser
    }

    public static func getParserFor(xml: String, startTagQName: QName, parserKind: XmlPullParserKind): XmlPullParser {
        let parser: XmlPullParser = getParserFor(xml, parserKind)
        forwardParserToStartElement(parser, {p => p.getQName() == startTagQName})
        return parser
    }

    public static func getParserFor(xml: String, startTagLocalpart: String, parserKind: XmlPullParserKind): XmlPullParser {
        let parser: XmlPullParser = getParserFor(xml, parserKind)
        forwardParserToStartElement(parser, {p => p.getName() == startTagLocalpart})
        return parser
    }

    private static func providerClassToProvider<P, E>(): P where P <: AbstractProvider<E>, E <: Element {
        let providerClass = TypeInfo.of<P>()
        try {
            match (providerClass.getStaticProperty("INSTANCE").getValue()) {
                case v: P => return v
                case _ => ()
            }
        } catch (_: InfoNotFoundException) {}

        let cti: ClassTypeInfo = (providerClass as ClassTypeInfo).getOrThrow()
        try {
            match (cti.getStaticVariable("INSTANCE").getValue()) {
                case v: P => return v
                case _ => ()
            }
        } catch (_: InfoNotFoundException) {}

        match (cti.getConstructor().apply()) {
            case v: P => return v
            case _ => ()
        }
        throw Exception("providerClass newInstance failed")
    }

    private static func forwardParserToStartElement(parser: XmlPullParser): Unit {
        forwardParserToStartElement(parser, {p => true})
    }

    private static func forwardParserToStartElement(parser: XmlPullParser, doneForwarding: (XmlPullParser) -> Bool): Unit {
        while (true) {
            let event: XmlPullParserEvent = parser.getEventType()
            match (event) {
                case START_ELEMENT => if (doneForwarding(parser)) {
                    break
                }
                case END_DOCUMENT => throw IllegalArgumentException("Not matching START_ELEMENT found")
                case _ => () // Catch all for incomplete match (MissingCasesInEnumSwitch) statement.
            }
            parser.next()
        }
    }

    private static func createDummyParser(): XmlPullParser {
        let dummyElement: String = "<empty-element/>"
        return PacketParserUtils.getParserFor(dummyElement)
    }
}
