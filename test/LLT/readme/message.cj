// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main 
import std.sync.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.tcp.*

func getConn(): XMPPTCPConnection {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain("xmpp.testserver") // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication() // 匿名登陆
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()
    conn.login()
    conn
}

/*两个用户发消息*/
@Test
func message(): Unit {
    let conn1 = getConn()
    let conn2 = getConn()

    let counter = SyncCounter(1)
    let l = SimpleStanzaListener {
        stanza, _ =>
        println("got message ${stanza.toXML()}")
        counter.dec()
    }
    // 监听server发来的message
    conn2.addStanzaListener(l, StanzaTypeFilter<Message>.MESSAGE)

    let message: Message = MessageBuilder
        .buildMessage()
        .to(conn2.getUser().getOrThrow())
        .ofType(MessageType.chat)
        .setBody("hello")
        .build()
    // conn1发送message给conn2
    conn1.sendStanza(message)

    counter.waitUntilZero(timeout: Duration.second)
}