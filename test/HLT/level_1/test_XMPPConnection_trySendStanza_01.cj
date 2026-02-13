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
    func test_trySendStanza01_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect()
        conn1.login()
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01,StanzaTypeFilter<IQ>("IQ"))
        var iq03=ElementListFriend()
        conn1.trySendStanza(iq03)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var curUser=conn1.getUser().getOrThrow()
        verifySendContent(lisener01.logContent,curUser)
    }
    func verifySendContent(listener:StringBuilder,curUser:EntityFullJid){
        var msgRegex01="<iq xmlns='jabber:client' to='${curUser.toString()}' from='${curUser.getLocalpartOrThrow().toString()}@xmpp.testserver' type='result'><query xmlns='jabber:iq:roster'>&lt;query xmlns=&apos;jabber:iq:roster&apos;/&gt;</query></iq>"
        var matcherMag01 = Regex(msgRegex01).matcher(listener.toString())
        var res=matcherMag01.findAll().getOrThrow()
        @Assert(res.size,1)

        var msgRegex02="<presence.*</presence>"
        var matcherMag02 = Regex(msgRegex02).matcher(listener.toString())
        @Assert(matcherMag02.findAll().isNone(),true)

        var msgRegex03="<message.*</message>"
        var matcherMag03 = Regex(msgRegex03).matcher(listener.toString())
        @Assert(matcherMag03.findAll().isNone(),true)

    }
}

class ElementListFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' type='get'><query xmlns='jabber:iq:roster'/></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}