// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.time.*

@Test
public class TestXmppConfiguration{
    @TestCase
    func test_XmppConfiguration_setUnknownIqRequestReplyMode_01(): Unit {
        XmppConfiguration.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.doNotReply)
        @Assert(XmppConfiguration.getUnknownIqRequestReplyMode(),XmppConfigurationUnknownIqRequestReplyMode.doNotReply)
    }
    @TestCase
    func test_XmppConfiguration_setUnknownIqRequestReplyMode_02(): Unit {
        XmppConfiguration.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.replyFeatureNotImplemented)
        @Assert(XmppConfiguration.getUnknownIqRequestReplyMode(),XmppConfigurationUnknownIqRequestReplyMode.replyFeatureNotImplemented)
    }
    @TestCase
    func test_XmppConfiguration_setUnknownIqRequestReplyMode_03(): Unit {
        XmppConfiguration.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.replyServiceUnavailable)
        @Assert(XmppConfiguration.getUnknownIqRequestReplyMode(),XmppConfigurationUnknownIqRequestReplyMode.replyServiceUnavailable)
    }
}