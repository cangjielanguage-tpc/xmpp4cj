// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.net.*
import std.time.*
import std.sync.SyncCounter

@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setCompressionEnabled_01(): Unit {
          let syncCounter: SyncCounter = SyncCounter(1)
            // 接收消息
          let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
                .builder()
                .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
                .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
                .setPort(5222) // 设置端口号
                .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
                .build()
            let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
            conn1.addSyncStanzaListener(StanzaListener1(syncCounter, conn1), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
            conn1.connect() // 连接
            var iq01=ElementRegister10()
            conn1.sendStanza(iq01)
            conn1.login("test10", "123456") // 登录


            // 发送消息
            let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
                .builder()
                .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
                .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
                .setPort(5222) // 设置端口号
                .setCompressionEnabled(true) // 设置连接是否将使用压缩
                .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
                .build()
            let conn2: XMPPTCPConnection = XMPPTCPConnection(config2)
            conn2.addSyncStanzaListener(StanzaListener2(syncCounter, conn1), StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
            conn2.connect() // 连接
            var iq02=ElementRegister12()
            conn2.sendStanza(iq02)
            conn2.login("test12", "123456") // 登录
            let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("test10@xmpp.testserver")
            let message2: Message = MessageBuilder
                .buildMessage()
                .to(entityBareJid2) // 设置消息的接收方地址
                .ofType(MessageType.chat) // 设置消息类型
                .setBody("message: test12@xmpp.testserver to test10@xmpp.testserver") // 设置消息正文
                .build()
            conn2.trySendStanza(message2) // 发送消息
            syncCounter.waitUntilZero(timeout: Duration.second * 2)
            var iq03=ElementUnRegister()
            conn1.sendStanza(iq03)
            conn2.sendStanza(iq03)
            conn1.disconnect() // 从服务器断开连接
            conn2.disconnect() // 从服务器断开连接
        }
}
//定义查询当前用户添加联系人
class ElementRegister12 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test12</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
//定义查询当前用户添加联系人
class ElementRegister10 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test10</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
