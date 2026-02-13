// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.compress.*
import cangjie_tpc::xmpp4cj.compression.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.modular.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.provider.*
import cangjie_tpc::xmpp4cj.proxy.*
import cangjie_tpc::xmpp4cj.sasl.*
import cangjie_tpc::xmpp4cj.stream.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.util.*
import cangjie_tpc::xmpp4cj.xml.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestXMPPConnection{
    @TestCase
    func test_addPresenceInterceptor_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect() // 连接
        conn1.login()

        conn1.addPresenceInterceptor(
            HashableConsumer<PresenceBuilder> {
                preBuilder =>
                sleep(Duration.second)
                preBuilder.to("Preintercepted1@qwe")
            },
            LambdaPredicate<Presence> {pre => pre.getType() == PresenceType.available && pre.getStatus() == "Status is available"}
        )

        let counter = SyncCounter(1)
        let res = StringBuilder()
        // 监听修改后Message
        conn1.addStanzaSendingListener(
            SimpleStanzaListener {
                stanza =>
                res.append(stanza.getTo().getOrThrow())
                counter.dec()
            },
            PresenceTypeFilter.AVAILABLE
        )

        let presence = StanzaBuilder
            .buildPresence()
            .to("unknow@xmpp.testserver/r4")
            .setStatus("Status is available")
            .ofType(PresenceType.available)
            .build()
        conn1.sendStanza(presence)

        counter.waitUntilZero(timeout: Duration.second * 5)
        @Assert(res.toString(), "preintercepted1@qwe")
    }
    @TestCase
    func test_addPresenceInterceptor_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect() // 连接
        conn1.login()

        conn1.addPresenceInterceptor(
            HashableConsumer<PresenceBuilder> {
                preBuilder =>
                sleep(Duration.second)
                preBuilder.to("Preintercepted1@qwe")
            },
            LambdaPredicate<Presence> {pre => pre.getType() == PresenceType.available && pre.getStatus() == "Status is available"}
        )

        let counter = SyncCounter(1)
        let res = StringBuilder()
        // 监听修改后Message
        conn1.addStanzaSendingListener(
            SimpleStanzaListener {
                stanza =>
                res.append(stanza.getTo().getOrThrow())
                counter.dec()
            },
            StanzaTypeFilter<Stanza>("Stanza")
        )

        let message = StanzaBuilder
            .buildMessage()
            .to("unknow@xmpp.testserver/r4")
            .setBody("hello")
            .ofType(MessageType.chat)
            .build()
        conn1.sendStanza(message)

        counter.waitUntilZero(timeout: Duration.second * 5)
        @Assert(res.toString(), "unknow@xmpp.testserver/r4")
    }
}
class SimpleStanzaListener <: StanzaListener {
    /* customFunc : listener触发时的自定义操作 */
    public SimpleStanzaListener(let customFunc: (Stanza) -> Unit) {}
    public override func processStanza(packet: Stanza) {
        customFunc(packet)
    }
}