// EXEC: cjc %import-path %L %l %f -O2
/// EXEC: ./main
package xmpptest

import std.collection.*
import std.io.*
import std.sync.*
import std.time.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.util.*

func getConn(): XMPPTCPConnection {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .performSaslAnonymousAuthentication()
        .setXmppDomain("xmpp.testserver")
        .setHost("xmpp.testserver")
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    // .enableDefaultDebugger()
    let connection = XMPPTCPConnection(configBuilder.build())
    connection.setUseStreamManagement(false)
    connection.connect()
    connection.login()
    connection
}

class BenchListener <: StanzaListener {
    let counter: SyncCounter
    BenchListener(let count: Int64) {
        counter = SyncCounter(count)
    }
    public override func processStanza(packet: Stanza) {
        counter.dec()
    }
}

/*
 * 匿名登录, 发消息给另一个匿名用户
 */
func bench(count: Int): Unit {
    let conn1 = getConn()
    let conn2 = getConn()

    let listener = BenchListener(count)
    // let user2: EntityBareJid = JidCreate.entityBareFrom("unknow@xmpp.testserver")
    let user2 = conn2.getUser().getOrThrow()
    let message: Message = MessageBuilder.buildMessage().to(user2).ofType(MessageType.chat).setBody("hello").build()
    conn2.addSyncStanzaListener(listener, None)
    // conn1.addStanzaSendingListener(listener,None)
    let now0 = DateTime.now()
    let fur = spawn {
        for (_ in 0..count) {
            conn1.sendStanza(message)
        }
    }
    listener.counter.waitUntilZero()
    let dur = DateTime.now() - now0
    println("xmpp bench ${count}->${listener.counter.count} ${dur} ${dur/count} ns/op")
    conn1.disconnect(None)
}

main(): Unit {
    bench(10)
    bench(100)
    bench(1000)
    bench(10000)
    bench(100000)
}

/*
[12-17 09:44:35] INFO - xmpp bench 10->0 1ms716us946ns 171us694ns ns/op
[12-17 09:44:35] INFO - xmpp bench 100->0 4ms975us908ns 49us759ns ns/op
[12-17 09:44:35] INFO - xmpp bench 1000->0 39ms580us817ns 39us580ns ns/op
[12-17 09:44:35] INFO - xmpp bench 10000->0 352ms502us343ns 35us250ns ns/op
[12-17 09:44:35] INFO - xmpp bench 100000->0 4s205ms719us828ns 42us57ns ns/op
*/