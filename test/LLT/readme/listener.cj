// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main 
import std.sync.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.tcp.*

/*监听报文*/
@Test
func listener(): Unit {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain("xmpp.testserver") // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication() // 匿名登陆
        .build()
    let conn = XMPPTCPConnection(config)

    let l = SimpleStanzaListener {
        stanza, _ =>
        println("got staza ${stanza.toXML()}")
    }
    // 监听server发来的stanza
    conn.addStanzaListener(l, StanzaTypeFilter<Stanza>("Stanza"))

    conn.connect()
    conn.login()
    conn.disconnect()
}
