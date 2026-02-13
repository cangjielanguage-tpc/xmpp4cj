// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection{
    @TestCase
    func test_getCollectedStanzasAfterCancelled_01(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        stanzaCollector.cancel()
        var allStanza=stanzaCollector.getCollectedStanzasAfterCancelled()
        @Assert(allStanza.size,1)
        @Assert(allStanza[0].toString().contains("IQ Stanza"),true)
    }
    @TestCase
    func test_getCollectedStanzasAfterCancelled_02(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        stanzaCollector.cancel()
        var allStanza=stanzaCollector.getCollectedStanzasAfterCancelled()
        @Assert(allStanza.size,3)
        @Assert(allStanza[0].toString().contains("IQ Stanza"),true)
        @Assert(allStanza[1].toString().contains("Presence Stanza"),true)
        @Assert(allStanza[2].toString().contains("Presence Stanza"),true)
    }

}

