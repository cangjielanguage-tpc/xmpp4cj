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
public class TestStanzaCollector{
    @TestCase
    func test_isclosed_01(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        @Assert(stanzaCollector.isClosed(),false)
    }
    @TestCase
    func test_isclosed_02(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        @Assert(stanzaCollector.isClosed(),false)
    }
    @TestCase
    func test_isclosed_03(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        stanzaCollector.close()
        @Assert(stanzaCollector.isClosed(),true)
    }
    @TestCase
    func test_isclosed_04(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        stanzaCollector.close()
        @Assert(stanzaCollector.isClosed(),true)
    }
}