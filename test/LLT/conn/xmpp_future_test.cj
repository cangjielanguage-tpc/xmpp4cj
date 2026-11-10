/// DEPENDENCE: ../z_test.cj ../jid_test_util.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj
/// EXEC: ./main 

@Test
public class XmppFutureTest {
    @TestCase
    public func simpleXmppFutureSuccessTest() {
        let future: SimpleInternalProcessStanzaXmppFuture1 = SimpleInternalProcessStanzaXmppFuture1()
        let packet: Stanza = StanzaBuilder.buildMessage().build()
        // 仓颉不能传None，传递一个空数据
        future.processStanza(packet)
        assertTrue(future.get())
    }

    @TestCase
    public func simpleXmppFutureTimeoutTest() {
        let future: SimpleInternalProcessStanzaXmppFuture2 = SimpleInternalProcessStanzaXmppFuture2()
        let e: Exception = @AssertThrows[Exception](future.get(Duration.second * 5))
        @Assert("TimeoutException", e.toString())
    }
}

class SimpleInternalProcessStanzaXmppFuture1 <: SimpleInternalProcessStanzaXmppFuture<Bool, Exception> {
    protected override func handleStanza(stanza: Stanza) {
        setResult(true)
    }
}

class SimpleInternalProcessStanzaXmppFuture2 <: SimpleInternalProcessStanzaXmppFuture<Bool, Exception> {
    protected override func handleStanza(stanza: Stanza) {
    }
}
