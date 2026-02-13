// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.feature.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection{
    @TestCase
    func test_nextResultOrThrow02_01(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        var nextResult01=stanzaCollector.nextResultOrThrow(Duration.second*3).toString()
        @Assert(nextResult01.contains("IQ Stanza (bind urn:ietf:params:xml:ns:xmpp-bind) [to=xmpp.testserver/"),true)
        @Assert(nextResult01.contains("type=result"),true)
    }
    @TestCase
    func test_nextResultOrThrow02_02(): Unit {
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        var nextResult01=stanzaCollector.nextResultOrThrow(Duration.second*3).toString()
        @Assert(nextResult01.contains("IQ Stanza (bind urn:ietf:params:xml:ns:xmpp-bind) [to=xmpp.testserver/"),true)
        @Assert(nextResult01.contains("type=result"),true)
    }
    @TestCase
    func test_nextResultOrThrow02_03(): Unit {
        var stanzaCollector=getStanzaCollectorByFilter()
        let e:Xmpp4cjException=@AssertThrows[Xmpp4cjException](stanzaCollector.nextResultOrThrow(Duration.second*0))
        @Assert(e.toString().contains("Xmpp4cjException: The connection XMPPTCPConnection"),true)
        @Assert(e.toString().contains("is no longer connected while waiting for response with StanzaTypeFilter: IQ"),true)
    }
    @TestCase
    func test_nextResultOrThrow02_04(): Unit {   
        var stanzaCollector=getStanzaCollectorBynewConfiguration()
        let e:Xmpp4cjException=@AssertThrows[Xmpp4cjException](stanzaCollector.nextResultOrThrow(Duration.second*0))
        @Assert(e.toString().contains("Xmpp4cjException: The connection XMPPTCPConnection"),true)
        @Assert(e.toString().contains("is no longer connected while waiting for response with None"),true)
    }
}

