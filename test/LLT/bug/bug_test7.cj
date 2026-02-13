// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStanzaBuilderBuildIqData {
    @TestCase
    func test_StanzaBuilder_buildIqData_02(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let stanzaId = Some("IqData.stanzaId")
        let iqData = StanzaBuilder.buildIqData(stanzaId)
        let e: UnsupportedException = @AssertThrows[UnsupportedException](iqData.build())
        @Assert("UnsupportedException", e.toString())
    }
}
