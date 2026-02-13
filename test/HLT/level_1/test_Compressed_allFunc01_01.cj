// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjCompressed{
    var compresseed01=Compressed.INSTANCE
    @TestCase
    func test_Compressed_allFunc01_01_1(): Unit {
        @Assert(Compressed.ELEMENT,"compressed")
        @Assert(Compressed.NAMESPACE,"http://jabber.org/protocol/compress")
        @Assert(Compressed.QNAME.toString(),"{http://jabber.org/protocol/compress}compressed")
    }
    @TestCase
    func test_Compressed_allFunc01_01_2(): Unit {
        @Assert(compresseed01.getElementName(),"compressed")
    }
    @TestCase
    func test_Compressed_allFunc01_01_3(): Unit {
        @Assert(compresseed01.getNamespace(),"http://jabber.org/protocol/compress")
    }
    @TestCase
    func test_Compressed_allFunc01_01_4(): Unit {
        var enclosingNamespace01=None<XmlEnvironment>
        var xmlStringBuilder01=compresseed01.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_Compressed_allFunc01_01_5(): Unit {
        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compresseed01.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_Compressed_allFunc01_01_6(): Unit {
        var xmlEnvironment=XmlEnvironment("my namespace","zh_cn")
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compresseed01.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
    @TestCase
    func test_Compressed_allFunc01_01_7(): Unit {
        var xmlEnvironment_tmp=XmlEnvironment("my_namespace_tmp")
        var xmlEnvironment=XmlEnvironment("my namespace","zh_cn",xmlEnvironment_tmp)
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compresseed01.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toString(),"<compressed xmlns='http://jabber.org/protocol/compress'/>")
    }
}
