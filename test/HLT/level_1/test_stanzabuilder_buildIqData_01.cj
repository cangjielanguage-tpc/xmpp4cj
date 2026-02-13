// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj
@Test
public class TestXmpp4cjStanzaBuilderBuildIqData {
    @TestCase
    func test_StanzaBuilder_buildIqData_01(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let stanzaId=Some("")
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](StanzaBuilder.buildIqData(stanzaId))
        @Assert(e.toString(),"IllegalArgumentException: Stanza ID must not be the empty String")

    }
    @TestCase
    func test_StanzaBuilder_buildIqData_02(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let stanzaId=Some("IqData.stanzaId")
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let e:UnsupportedException=@AssertThrows[UnsupportedException](iqData.build())
        @Assert(e.toString(),"UnsupportedException")
    }
    @TestCase
    func test_StanzaBuilder_buildIqData_03(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let stanzaId=None<String>
        let iqData=StanzaBuilder.buildIqData(stanzaId)
        let e:UnsupportedException=@AssertThrows[UnsupportedException](iqData.build())
        @Assert(e.toString(),"UnsupportedException")

    }
}