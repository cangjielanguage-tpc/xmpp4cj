// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.xml.*

@Test
public func t1(): Unit {
    var xml: String = "<outer-element xmlns='outer-namespace'><inner-element/></outer-element>"
    println(xml)
    let buffer = ByteBuffer()
    buffer.write(xml.toArray())

    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let parser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(buffer)
    while (parser.getEventType() != XmlPullParserEvent.END_DOCUMENT) {
        match (parser.getEventType()) {
            case START_DOCUMENT | END_DOCUMENT | OTHER => println(parser.getEventType())
            case START_ELEMENT => println(
                "${parser.getEventType()} ${parser.getQName()} ${parser.getNamespace()} ${parser.getNamespaceCount()} ${parser.getAttributeCount()}"
            )
            case END_ELEMENT => println("${parser.getEventType()} ${parser.getQName()}")
            case TEXT_CHARACTERS => println("${parser.getEventType()} ${parser.getText()}")
            case _ => println(parser.getEventType())
        }
        parser.next()
    }
}
