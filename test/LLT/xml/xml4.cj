/// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f  --test
// EXEC: ./main 
//--filter=*.*

import stdx.log.*
import stdx.logger.*
import std.io.*
import cangjie_tpc::xmpp4cj.xml.*
import std.unittest.testmacro.*
import std.unittest.*

class XmlInput <: InputStream {
    var pos = 0
    XmlInput(let arr: Array<String>) {}
    public func read(buffer: Array<UInt8>): Int64 {
        let bytes = arr[pos].toArray()
        buffer[..bytes.size] = bytes
        pos++
        return bytes.size
    }
}

func parse(buf: InputStream): String {
    let res = StringBuilder()
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let parser = staxXmlPullParserFactory.newXmlPullParser(buf)
    while (true) {
        match (parser.getEventType()) {
            case START_ELEMENT =>
                res.append("<${parser.getQName()}>")
                for (i in 0..parser.getAttributeCount()) {
                    if (parser.getAttributeValue(i).size > 10) {
                        res.append("\n  ${parser.getAttributeQName(i)}:${parser.getAttributeValue(i).size} ")
                    } else {
                        res.append("\n  ${parser.getAttributeQName(i)}:${parser.getAttributeValue(i)} ")
                    }
                }
                res.append("\n")
            case END_ELEMENT => res.append("</${parser.getQName()}>\n")
            case TEXT_CHARACTERS => res.append("  <${parser.getText()}>\n")
            case e =>
                res.append("${e}\n")
                if (e == END_DOCUMENT) {
                    break
                }
        }
        parser.next()
    }
    res.toString()
}

@Test
func xmlSplitTest(): Unit {
    // 模拟xml输入流截断解析
    let xml = #"<message to="1@xmpp.testserver/1" type="error" from="2@xmpp.testserver"><body>1@xmpp.testserver to 2@xmpp.testserver</body><error code="503" type="cancel"><service-unavailable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></message>"#

    let xmlres = #"START_DOCUMENT
<message>
  to:19 
  type:error 
  from:17 
<body>
  <1@xmpp.testserver to 2@xmpp.testserver>
</body>
<error>
  code:503 
  type:cancel 
<{urn:ietf:params:xml:ns:xmpp-stanzas}service-unavailable>
</{urn:ietf:params:xml:ns:xmpp-stanzas}service-unavailable>
</error>
</message>
END_DOCUMENT
"#

    var res = ""
    for (i in 1..xml.size - 1) {
        // for (i in 212..213) {
        try {
            let arr = [xml[..i], xml[i..]]
            let buf = XmlInput(arr)
            res = parse(buf)
            @Assert(res, xmlres)
        // println(res)
        } catch (e: Exception) {
            println("err: ${i} ${e}\n${res}")
            throw e
        }
    }
}

main(): Unit {
    xmlSplitTest()
}
