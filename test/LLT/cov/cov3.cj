// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
/// EXEC: ./main

// 内部化导致部分用例不可运行，跑覆盖率时可放开。

import cangjie_tpc::xmpp4cj.packet.*
import std.unittest.testmacro.*
import std.collection.*

@Test
public func XmlEvent_1(): Unit {
    @Assert(XmlEvent.Decl.toString(),"Decl")
    @Assert(XmlEvent.Comment.toString(),"Comment")
    @Assert(XmlEvent.ProcInst.toString(),"ProcInst")
    @Assert(XmlEvent.DTD.toString(),"DTD")
    @Assert(XmlEvent.ElementStart.toString(),"ElementStart")
    @Assert(XmlEvent.ElementEnd.toString(),"ElementEnd")
    @Assert(XmlEvent.Attribute.toString(),"Attribute")
    @Assert(XmlEvent.Namespace.toString(),"Namespace")
    @Assert(XmlEvent.Text.toString(),"Text")
    @Assert(XmlEvent.CData.toString(),"CData")
    @Assert(XmlEvent.EntityRef.toString(),"EntityRef")
}

@Test
public func XmlReader_1(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteBuffer()
    input.write("<element/>".toArray())
    let obj = XmlReader(input)
    @AssertThrows[UnsupportedException](obj.getCurrentPosition())
    @AssertThrows[UnsupportedException](obj.getCurrentNamespace())
    @AssertThrows[UnsupportedException](obj.readComment())
    @AssertThrows[UnsupportedException](obj.readProcInst())
    @AssertThrows[UnsupportedException](obj.readDTD())
    @AssertThrows[UnsupportedException](obj.readAttribute(""))
    @AssertThrows[Exception](obj.readCData())
    @AssertThrows[Exception](obj.readDecl())
    obj.skip()
    obj.readElementEnd()
}

@Test
public func XmlReader_2(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteBuffer()
    input.write("<element/>".toArray())
    let obj = XmlReader(input)
    obj.peek()
    obj.skip()
    obj.readElementEnd("element")
}

@Test
public func XmppXmlParser_1(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteBuffer()
    input.write("<element/>".toArray())
    XmppXmlParser.getXmlPullParserFactory()
    XmppXmlParser.setXmlPullParserFactory(staxXmlPullParserFactory)
    XmppXmlParser.newXmlParser(input)
}
