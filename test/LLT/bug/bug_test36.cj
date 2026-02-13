// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_StanzaBuilder_buildPresence02_02(): Unit {
        //public static func 	buildPresence (?String stanzaId):PresenceBuilder
        let stanzaId = Some("")
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaBuilder.buildPresence(stanzaId))
        println(e.toString())
        @Assert(e.toString(),"IllegalArgumentException: Stanza ID must not be the empty String")
    }
}
