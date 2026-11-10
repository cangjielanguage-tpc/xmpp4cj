// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStanzaBuilderBuildIqData {
    @TestCase
    func test_StanzaBuilder_buildIqData_01(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let stanzaId = Some("")
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaBuilder.buildMessage(stanzaId))
        @Assert("IllegalArgumentException: Stanza ID must not be the empty String", e.toString())
    }

    @TestCase
    func test_StanzaBuilder_buildIqData_03(): Unit {
        //public static func buildIqData(stanzaId :?String):IqData
        let stanzaId = None<String>
        StanzaBuilder.buildIqData(stanzaId)
        @Assert(true)
    }
}
