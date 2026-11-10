// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjStanzaBuilderBuildMessage {
    @TestCase
    func test_StanzaBuilder_buildMessage01_01(): Unit {
        let e = StreamOpen("xmpp.server", "user1@xmpp.server", None, "zh-CN", StreamOpenStreamContentNamespace.client)
        let str = "<stream:stream xmlns='jabber:client' to='xmpp.server' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' from='user1@xmpp.server' xml:lang='zh-CN'>"
        @Assert(e.toXML().toString(), str)
    }
}
