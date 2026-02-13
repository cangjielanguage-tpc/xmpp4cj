// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjCompressFeature{
    var methon01=["methon01","methon02","methon03"]
    var methon02:Array<String>=[]
    var compressFeature01=CompressFeature(methon01)
    var compressFeature02=CompressFeature(methon02)
    @TestCase
    func test_CompressFeature_allFunc01_01_1(): Unit {
        @Assert(CompressFeature.ELEMENT,"compression")
        @Assert(CompressFeature.QNAME.toString(), "{http://jabber.org/protocol/compress}compression")
    }
    @TestCase
    func test_CompressFeature_allFunc01_01_2(): Unit {
        var enclosingNamespace01=None<XmlEnvironment>
        var xmlStringBuilder01=compressFeature01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compressFeature02.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compression xmlns='http://jabber.org/protocol/compress'><method>methon01</method><method>methon02</method><method>methon03</method></compression>")
        @Assert(xmlStringBuilder02.toString(),"<compression xmlns='http://jabber.org/protocol/compress'></compression>")
    }
    @TestCase
    func test_CompressFeature_allFunc01_01_3(): Unit {
        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compressFeature01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compressFeature02.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compression xmlns='http://jabber.org/protocol/compress'><method>methon01</method><method>methon02</method><method>methon03</method></compression>")
        @Assert(xmlStringBuilder02.toString(),"<compression xmlns='http://jabber.org/protocol/compress'></compression>")
    }
    @TestCase
    func test_CompressFeature_allFunc01_01_4(): Unit {
        var xmlEnvironment=XmlEnvironment("my namespace","zh_cn")
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compressFeature01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compressFeature02.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compression xmlns='http://jabber.org/protocol/compress'><method>methon01</method><method>methon02</method><method>methon03</method></compression>")
        @Assert(xmlStringBuilder02.toString(),"<compression xmlns='http://jabber.org/protocol/compress'></compression>")
    }
    @TestCase
    func test_CompressFeature_allFunc01_01_5(): Unit {
        var xmlEnvironment_tmp=XmlEnvironment("my_namespace_tmp")
        var xmlEnvironment=XmlEnvironment("my namespace","zh_cn",xmlEnvironment_tmp)
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compressFeature01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compressFeature02.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compression xmlns='http://jabber.org/protocol/compress'><method>methon01</method><method>methon02</method><method>methon03</method></compression>")
        @Assert(xmlStringBuilder02.toString(),"<compression xmlns='http://jabber.org/protocol/compress'></compression>")
    }
    @TestCase
    func test_CompressFeature_allFunc01_01_6(): Unit {
        @Assert((compressFeature01.getMethods() as Array<String>).getOrThrow(),methon01)
        @Assert((compressFeature02.getMethods() as Array<String>).getOrThrow(),methon02)
    }
    @TestCase
    func test_CompressFeature_allFunc01_01_7(): Unit {
        @Assert(compressFeature01.getNamespace(),"http://jabber.org/protocol/compress")
        @Assert(compressFeature02.getNamespace(),"http://jabber.org/protocol/compress")
    }
    @TestCase
    func test_CompressFeature_allFunc01_01_8(): Unit {
        @Assert(compressFeature01.getElementName(),"compression")
        @Assert(compressFeature02.getElementName(),"compression")
    }
}
