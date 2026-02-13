// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_StanzaBuilder_buildPresenceFrom01_02(): Unit {
        //public static func buildPresenceFrom (presence: Presence, stanzaId: ?String):PresenceBuilder
        let oriPs = StanzaBuilder.buildPresence().build()
        var stanzaId = Some("")
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaBuilder.buildPresenceFrom(oriPs,stanzaId))
        println(e.toString())
        @Assert(e.toString(),"IllegalArgumentException: Stanza ID must not be the empty String")
    }
}
