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
public class TestUser{
    @TestCase
    func test_queryFriend_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect() // 连接
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        conn1.login("friend03", "123456") // 登录
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))
        var iqQuery= ElementListFriend()
        conn1.sendStanza(iqQuery)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        var iqmove=ElementUnRegister()
        conn1.sendStanza(iqmove)
        conn1.disconnect() // 从服务器断开连接
        verifySendContent(lisener01.logContent,"friend03")
    }
    func verifySendContent(listener:StringBuilder,curUser:String){
        var msgRegex01="<iq xmlns='jabber:client' to='${curUser}@xmpp.testserver/.*' type='result'><query xmlns='jabber:iq:roster'>&lt;query xmlns=&apos;jabber:iq:roster&apos; ver=.*</query></iq>"
        var matcherMag01 = Regex(msgRegex01).matcher(listener.toString())
        var res=matcherMag01.findAll().getOrThrow()
        @Assert(res[0].matchString().contains("to='${curUser}@xmpp.testserver/"),true)
    }
}

//注册
class ElementRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>friend03</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
//查询
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




