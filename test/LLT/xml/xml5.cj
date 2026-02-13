// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.xml.*

@Test
public func t1(): Unit {
    var xml: String = """
<a>
    <b xmlns='outer-namespace'>
        <c/>
    </b>
</a>"""
    parseXml(xml)
}

@Test
public func t2(): Unit {
    var xml: String = """
<a><b xmlns='outer-namespace'><c/></b></a>"""
    parseXml(xml)
}

@Test
public func t3(): Unit {
    var xml: String = "<outer-element xmlns='outer-namespace'><inner-element/></outer-element>"
    parseXml(xml)
}

func parseXml(xml: String): Unit {
    println(xml)
    let buffer = ByteBuffer()
    buffer.write(xml.toArray())

    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let parser: StaxXmlPullParser = (staxXmlPullParserFactory
        .newXmlPullParser(buffer) as StaxXmlPullParser)
        .getOrThrow()
    while (true) {
        match (parser.getEventType()) {
            case START_DOCUMENT => println(parser.getEventType())
            case START_ELEMENT =>
                let nss = ArrayList<String>()
                for (i in 0..parser.getNamespaceCount()) {
                    nss.add("${parser.getNamespacePrefix(i)}:${parser.getNamespaceUri(i)}, ")
                }
                /*                 
                let tagNssStr = ArrayList<String>()
                for (k in parser.tagNss.keySet()) {
                    let vs = parser.tagNss.getAll(k)
                    tagNssStr.append("${vs |> map{v=>"${v.depth}_${k}_${v.namespace}"} |> collectArray}")
                }
                let arr = parser.tagNss.kvIter() |> filter {kv: (String, ValueType) => kv[1].depth == parser.getDepth()} |>
                    map {kv: (String, ValueType) => "${kv[0]}_${kv[1].depth}_${kv[1].namespace}"} |> collectArray
                println(
                    """
                ${parser.getEventType()}
                tag:${parser.getQName()}
                depth:${parser.getDepth()}
                ns:${parser.getNamespace()}
                nscount : ${parser.getNamespaceCount()} : ${nss}
                tagNss: ${tagNssStr}
                tagNss_kvIter: ${parser.tagNss.kvIter() |> map{kv:(String,ValueType)=>"${kv[0]}_${kv[1].depth}_${kv[1].namespace}"} |> collectArray}
                currentDepNss: ${parser.currentDepNss.getOrThrow() |> map{kv=>"${kv[0]}_${kv[1]}"} |> collectArray}
                arr: ${arr}
                attrcount:${parser.getAttributeCount()}"""
                ) */
                println(
                    """
${parser.getEventType()}
    tag:${parser.getQName()}
    depth:${parser.getDepth()}
    ns:${parser.getNamespace()}
    nscount : ${parser.getNamespaceCount()} : ${nss}
    attrcount:${parser.getAttributeCount()}"""
                )
            case END_ELEMENT => println("${parser.getEventType()} ${parser.getQName()}")
            case TEXT_CHARACTERS => println("${parser.getEventType()} ${parser.getText()}")
            case END_DOCUMENT =>
                println(parser.getEventType())
                break
            case OTHER => println(parser.getEventType())
            case _ => println(parser.getEventType())
        }
        parser.next()
    }
}
