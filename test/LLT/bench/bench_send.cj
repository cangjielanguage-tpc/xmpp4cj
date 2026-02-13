/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.compress.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.compression.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.connection.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.feature.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.filter.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.jid.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.modular.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.packet.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.provider.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.proxy.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.sasl.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.stream.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.tcp.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.util.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.xml.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.proxy.so
/// DEPENDENCE: ../../../target/release/xmpp4cj/libxmpp4cj.so
/// DEPENDENCE: flame.sh
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
        if (packet is Message) {
            counter.dec()
        }
    }
}

class CountSend <: ExtensionElement {
    let perm: Semaphore = {
        =>
        let p = Semaphore(Int64.Max)
        p.acquire(amount: Int64.Max)
        p
    }()
    public override func getNamespace(): String {
        ""
    }
    public override func getElementName(): String {
        "q"
    }
    public override func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        perm.release()
        "<q/>"
    }
}

/*
 * 匿名登录, 发消息给不存在的用户, 消息在服务端会丢弃
 */
func bench(count: Int): Unit {
    let conn1 = getConn()

    let listener = BenchListener(count)
    let user2: EntityBareJid = JidCreate.entityBareFrom("unknow@xmpp.testserver")
    let message: Message = MessageBuilder.buildMessage().to(user2).ofType(MessageType.chat).setBody("hello").build()

    let countSend = CountSend()
    message.addExtension(countSend)

    let now0 = DateTime.now()
    let fur = spawn {
        for (_ in 0..count) {
            conn1.sendStanza(message)
        }
    }
    countSend.perm.acquire(amount: count)
    let dur = DateTime.now() - now0

    println("xmpp bench ${count}->${listener.counter.count} ${dur} ${dur/count} ns/op")
    // println("queue.put ${' '*count.toString().size}     ${conn1.putTime} ${conn1.putTime/count} ns/op")
    // println("queue.take ${' '*count.toString().size}    ${conn1.takeTime} ${conn1.takeTime/count} ns/op")

    conn1.disconnect(None)
}

main(): Unit {
    bench(10)
    bench(100)
    bench(1000)
    bench(10000)
    bench(100000)
}
