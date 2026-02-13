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
import stdx.net.tls.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter
@Test
public class TestAbstractXMPPConnection{    
    @TestCase
    func test_trySendStanza01_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        let conn1=getConnection()
        conn1.connect() // 连接
        conn1.login() // 登录
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口      //StanzaTypeFilter<Message>.MESSAGE
        var iq03=ElementListFriend()
        var status=conn1.trySendStanza(iq03)
        @Assert(status,true)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        @Assert(lisener01.logContent.toString().isEmpty(),false)
    }
    func getConnection():XMPPTCPConnection{
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return  conn1
    }
}

//定义查询当前用户,联系人列表
class ElementListFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' type='set'><query xmlns='jabber:iq:roster'/></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}



