// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStanzaBuilderBuildPresence {
    @TestCase
    func test_StanzaBuilder_buildPresence01_01(): Unit {
        //public static func buildPresence ():PresenceBuilder
        let psBuilder = StanzaBuilder.buildPresence()
        let actPs = psBuilder.build()
        let actPsString = actPs.toString()
        @Assert(actPsString,"Presence Stanza [type=available,]")
    }

    @TestCase
    func test_StanzaBuilder_buildPresence02_01(): Unit {
        //public static func 	buildPresence (?String stanzaId):PresenceBuilder
        let stanzaId = None<String>
        let msgBuilder = StanzaBuilder.buildPresence(stanzaId)
        let actPs = msgBuilder.build()
        let actPsString = actPs.toString()
        @Assert(actPsString,"Presence Stanza [type=available,]")
    }

    @TestCase
    func test_StanzaBuilder_buildPresence02_02(): Unit {
        //public static func 	buildPresence (?String stanzaId):PresenceBuilder
        let stanzaId = Some("")
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaBuilder.buildPresence(stanzaId))
        @Assert("IllegalArgumentException: Stanza ID must not be the empty String", e.toString())
    }

    @TestCase
    func test_StanzaBuilder_buildPresence02_03(): Unit {
        //public static func 	buildPresence (?String stanzaId):PresenceBuilder
        let stanzaId = Some("jabber:iq:roster")
        let msgBuilder = StanzaBuilder.buildPresence(stanzaId)
        let actPs = msgBuilder.build()
        let actPsString = actPs.toString()
        @Assert(actPsString,"Presence Stanza [id=jabber:iq:roster,type=available,]")
    }
}
