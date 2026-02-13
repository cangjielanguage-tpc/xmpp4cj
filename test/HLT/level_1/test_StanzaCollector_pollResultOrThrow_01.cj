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
    func test_pollResultOrThrow_01(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        var pullresult02=stanzaCollector.pollResultOrThrow()
        var getResult=pullresult02.getOrThrow().toString()
        @Assert(getResult.contains("IQ Stanza (bind urn:ietf:params:xml:ns:xmpp-bind) [to=xmpp.testserver/"),true)
        @Assert(getResult.contains("type=result"),true)
    }
    @TestCase
    func test_pollResultOrThrow_02(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        var pullresult02=stanzaCollector.pollResultOrThrow()
        var getResult=pullresult02.getOrThrow().toString()
        @Assert(getResult.contains("IQ Stanza (bind urn:ietf:params:xml:ns:xmpp-bind) [to=xmpp.testserver/"),true)
        @Assert(getResult.contains("type=result"),true)
    }
}

