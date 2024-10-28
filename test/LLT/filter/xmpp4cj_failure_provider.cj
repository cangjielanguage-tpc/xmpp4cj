// DEPENDENCE: ../z_test.cj ./common_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj common_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjFailureProvider {
    var failureProvider = FailureProvider.INSTANCE

    @TestCase
    func test_FailureProvider_parse_01(): Unit {
        var xmppXmlString = """
<name01 xmlns="http://jabber.org/protocol/compress">
<name-02 xmlns="http://jabber.org/protocol/compress"></name-02>
<error xmlns="jabber:client"></error>
<error xmlns="jabber:server"></error>
<error01 xmlns="jabber:client"></error01>
<error02 xmlns="jabber:server"></error02>
<other xmlns="jabber:server"></other>
</name01>
"""
        var xmlpullparser = getStaxXmlPullParser(xmppXmlString)
        
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](failureProvider.parse(xmlpullparser, 10, Option<XmlEnvironment>.None))
        @Assert("IllegalArgumentException: Not a valid type: ", e.toString())
    }
}
