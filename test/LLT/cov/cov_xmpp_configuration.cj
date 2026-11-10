// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_XmppConfiguration1(): Unit {
    let xmppConfigurationUnknownIqRequestReplyMode1 = XmppConfigurationUnknownIqRequestReplyMode.doNotReply
    let xmppConfigurationUnknownIqRequestReplyMode2 = XmppConfigurationUnknownIqRequestReplyMode.replyFeatureNotImplemented
    let xmppConfigurationUnknownIqRequestReplyMode3 = XmppConfigurationUnknownIqRequestReplyMode.replyServiceUnavailable
    @Assert(true, xmppConfigurationUnknownIqRequestReplyMode1 == xmppConfigurationUnknownIqRequestReplyMode1)
    @Assert(true, xmppConfigurationUnknownIqRequestReplyMode2 == xmppConfigurationUnknownIqRequestReplyMode2)
    @Assert(true, xmppConfigurationUnknownIqRequestReplyMode3 == xmppConfigurationUnknownIqRequestReplyMode3)
    @Assert("doNotReply", xmppConfigurationUnknownIqRequestReplyMode1.toString())
    @Assert("replyFeatureNotImplemented", xmppConfigurationUnknownIqRequestReplyMode2.toString())
    @Assert("replyServiceUnavailable", xmppConfigurationUnknownIqRequestReplyMode3.toString())
    @Assert(false, xmppConfigurationUnknownIqRequestReplyMode1 == xmppConfigurationUnknownIqRequestReplyMode3)
}
