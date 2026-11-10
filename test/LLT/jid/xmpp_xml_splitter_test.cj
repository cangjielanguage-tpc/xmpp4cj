// DEPENDENCE: z_test.cj xml_splitter_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_splitter_test_util.cj --test
// EXEC: ./main 
@Test
public class XmppXmlSplitterTest {
    @TestCase
    public func simpleXmppTest(): Unit {
        let stanza = "<message from=\'foo\' to=\'bar\'><body>Hi</body></message>"
        XmlSplitterTestUtil.xmppSplitterTest([stanza])
    }
    @TestCase
    public func multipleStanzasTest(): Unit {
        let stanza1 = "<message><empty/></message>"
        let stanza2 = "<message from=\'foo\' to=\'bar\'><body>Hi</body></message>"
        let stanza3 = "<iq from=\'foo\' to=\'bar\'><ping><inner3>foo</inner3><inner3/></ping></iq>"
        XmlSplitterTestUtil.xmppSplitterTest([stanza1, stanza2, stanza3])
    }
    @TestCase
    public func multipleStanzasWithStreamTest(): Unit {
        let stanza1 = "<message><empty/></message>"
        let stream1 = "<stream:stream from=\'juliet@im.example.com\' to=\'foo@bar.com\' xmlns:stream=\'http://etherx.jabber.org/streams\'>"
        let stanza2 = "<iq from=\'foo\' to=\'bar\'><ping></ping></iq>"
        let stream2 = "</stream:stream>"
        XmlSplitterTestUtil.xmppSplitterTest([stanza1, stream1, stanza2, stream2])
    }
}
