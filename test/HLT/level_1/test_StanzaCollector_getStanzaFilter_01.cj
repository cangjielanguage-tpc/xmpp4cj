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
    func test_getStanzaFilter_01(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        var allStanza=stanzaCollector.getStanzaFilter()
        @Assert(allStanza.toString(),"Some(StanzaTypeFilter: IQ)")
    }
    @TestCase
    func test_getStanzaFilter_02(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        var allStanza=stanzaCollector.getStanzaFilter()
        @Assert(allStanza.isNone(),true)
    }
}

