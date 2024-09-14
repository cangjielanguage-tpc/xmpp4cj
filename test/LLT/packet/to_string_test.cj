// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// DEPENDENCE: ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj xml_test_utils.cj --test
// EXEC: ./main

@Test
public class ToStringTest {
    @TestCase
    public func messageTest(): Unit {
        let builder = StanzaBuilder.buildMessage("message-id").ofType(MessageType.headline).to(JidTestUtil.BARE_JID_1)
        let message: Message = builder.build()
        let string: String = message.toString()
        assertEquals("Message Stanza [to=one@exampleone.org,id=message-id,type=headline,]", string)
    }

    @TestCase
    public func presenceTest(): Unit {
        let presence: Presence = StanzaBuilder.buildPresence().ofType(PresenceType.subscribe).setPriority(0).setMode(
            PresenceMode.away).build()
        presence.setStanzaId("presence-id")
        let string: String = presence.toString()
        assertEquals("Presence Stanza [id=presence-id,type=subscribe,mode=away,prio=0,]", string)
    }

    @TestCase
    public func iqTest(): Unit {
        let bindIq: Bind = Bind.newResult(JidTestUtil.DUMMY_AT_EXAMPLE_ORG_SLASH_DUMMYRESOURCE)
        bindIq.setStanzaId("bind-id")
        let string: String = bindIq.toString()
        assertEquals("IQ Stanza (bind urn:ietf:params:xml:ns:xmpp-bind) [id=bind-id,type=get,]", string)
    }
}
