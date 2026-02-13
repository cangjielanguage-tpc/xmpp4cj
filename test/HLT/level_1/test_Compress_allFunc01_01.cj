// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjCompress{
    var compress01=Compress("")
    var compress02=Compress("compress methon")
    var compress03=Compress("compress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methon")
    @TestCase
    func test_Compress_allFunc01_01_1(): Unit {
        @Assert(Compress.ELEMENT,"compress")
        @Assert(Compress.NAMESPACE,"http://jabber.org/protocol/compress")
    }
    @TestCase
    func test_Compress_allFunc01_01_2(): Unit {
        @Assert(compress01.getElementName(),"compress")
        @Assert(compress02.getElementName(),"compress")
        @Assert(compress03.getElementName(),"compress")
    }
    @TestCase
    func test_Compress_allFunc01_01_3(): Unit {
        @Assert(compress01.getNamespace(),"http://jabber.org/protocol/compress")
        @Assert(compress02.getNamespace(),"http://jabber.org/protocol/compress")
        @Assert(compress03.getNamespace(),"http://jabber.org/protocol/compress")
    }
    @TestCase
    func test_Compress_allFunc01_01_4(): Unit {
        var enclosingNamespace01=None<XmlEnvironment>
        var xmlStringBuilder01=compress01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compress02.toXML(enclosingNamespace01)
        var xmlStringBuilder03=compress03.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method/></compress>")
        @Assert(xmlStringBuilder02.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methon</method></compress>")
        @Assert(xmlStringBuilder03.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methon</method></compress>")
    }
    @TestCase
    func test_Compress_allFunc01_01_5(): Unit {
        var xmlEnvironment=XmlEnvironment("my namespace")
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compress01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compress02.toXML(enclosingNamespace01)
        var xmlStringBuilder03=compress03.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method/></compress>")
        @Assert(xmlStringBuilder02.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methon</method></compress>")
        @Assert(xmlStringBuilder03.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methon</method></compress>")

    }
    @TestCase
    func test_Compress_allFunc01_01_6(): Unit {
        var xmlEnvironment=XmlEnvironment("my namespace","zh_cn")
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compress01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compress02.toXML(enclosingNamespace01)
        var xmlStringBuilder03=compress03.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method/></compress>")
        @Assert(xmlStringBuilder02.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methon</method></compress>")
        @Assert(xmlStringBuilder03.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methon</method></compress>")
     }
    @TestCase
    func test_Compress_allFunc01_01_7(): Unit {
        var xmlEnvironment_tmp=XmlEnvironment("my_namespace_tmp")
        var xmlEnvironment=XmlEnvironment("my namespace02","zh_cn",xmlEnvironment_tmp)
        var enclosingNamespace01=Some(xmlEnvironment)
        var xmlStringBuilder01=compress01.toXML(enclosingNamespace01)
        var xmlStringBuilder02=compress02.toXML(enclosingNamespace01)
        var xmlStringBuilder03=compress03.toXML(enclosingNamespace01)
        @Assert(xmlStringBuilder01.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method/></compress>")
        @Assert(xmlStringBuilder02.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methon</method></compress>")
        @Assert(xmlStringBuilder03.toXML().toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>compress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methoncompress methon</method></compress>")

    }
}
