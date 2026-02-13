// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjQName{
    var localPart="localPart"
    var namespaceURI="namespaceURI"
    var prefix="prefix"
    var qname=QName(localPart,namespaceURI,prefix)
    @TestCase
    func test_QName_allFunc01_01_1(): Unit {
        localPart="localPart"
        namespaceURI="namespaceURI"
        prefix="prefix"
        qname=QName(localPart,namespaceURI,prefix)
        @Assert(qname.getNamespaceURI(),"localPart")
        @Assert(qname.getPrefix(),"prefix")
        @Assert(qname.getLocalPart(),"namespaceURI")
        @Assert(qname.toString(),"{localPart}namespaceURI")
        var qnameCur=QName("", "namespaceURI", "prefix")
        @Assert(qname==qnameCur,false)
        @Assert(qname.getFullName(),"prefix:namespaceURI")//java没有该api
    }
    @TestCase
    func test_QName_allFunc01_01_2(): Unit {
        localPart=""
        namespaceURI=""
        prefix=""
        qname=QName(localPart,namespaceURI,prefix)
        @Assert(qname.getNamespaceURI(),"")
        @Assert(qname.getPrefix(),"")
        @Assert(qname.getLocalPart(),"")
        @Assert(qname.toString(),"")
        var qnameCur=QName("", "namespaceURI", "prefix")
        @Assert(qname==qnameCur,false)
        @Assert(qname.getFullName(),"")//java没有该api
    }
    @TestCase
    func test_QName_allFunc01_01_3(): Unit {
        localPart=" "
        namespaceURI=" "
        prefix=" "
        qname=QName(localPart,namespaceURI,prefix)
        @Assert(qname.getNamespaceURI()," ")
        @Assert(qname.getPrefix()," ")
        @Assert(qname.getLocalPart()," ")
        @Assert(qname.toString(),"{ } ")
        var qnameCur=QName("", " ", " ")
        @Assert(qname==qnameCur,false)
        @Assert(qname.getFullName()," : ")//java没有该api
    }
}
