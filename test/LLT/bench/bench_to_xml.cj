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

class NullOut <: OutputStream {
    public func write(_: Array<UInt8>): Unit {}
}
/*
 * 匿名登录, 发消息给另一个匿名用户
 */
func bench(count: Int): Unit {
    // let conn1 = getConn()
    // let conn2 = getConn()
    // conn2.disconnect()

    let listener = BenchListener(count)
    let user2: EntityBareJid = JidCreate.entityBareFrom("unknow@xmpp.testserver")
    // let user2 = conn2.getUser().getOrThrow()
    let message: Message = MessageBuilder.buildMessage().to(user2).ofType(MessageType.chat).setBody("hello").build()
    // conn2.addSyncStanzaListener(listener, None)
    // conn1.addStanzaSendingListener(listener, None)
    let now0 = DateTime.now()
    // let fur = spawn {
    for (_ in 0..count) {
        // conn1.sendStanza(message)
        let elementXml = message.toXML()
        match (elementXml) {
            case elementXml: XmlStringBuilder => elementXml.write(ObservableWriter(NullOut()), None)
            case _ => ()
        }
    }
    // }
    // listener.counter.waitUntilZero()
    // asd.sem.acquire(amount: count)
    let dur = DateTime.now() - now0
    println("xmpp bench ${count}->${listener.counter.count} ${dur} ${dur/count} ns/op")
    // conn1.disconnect(None)
}

main(): Unit {
    bench(10)
    bench(100)
    bench(1000)
    bench(10000)
    bench(100000)
}

/*
[12-16 16:34:30] INFO - xmpp bench 10->10 155us200ns 15us520ns ns/op
[12-16 16:34:30] INFO - xmpp bench 100->100 197us 1us970ns ns/op
[12-16 16:34:30] INFO - xmpp bench 1000->1000 2ms325us101ns 2us325ns ns/op
[12-16 16:34:30] INFO - xmpp bench 10000->10000 23ms143us608ns 2us314ns ns/op
[12-16 16:34:30] INFO - xmpp bench 100000->100000 195ms389us71ns 1us953ns ns/op

[12-16 16:41:43] INFO - xmpp bench 10->10 111us600ns 11us160ns ns/op
[12-16 16:41:43] INFO - xmpp bench 100->100 852us400ns 8us524ns ns/op
[12-16 16:41:43] INFO - xmpp bench 1000->1000 11ms29us 11us29ns ns/op
[12-16 16:41:43] INFO - xmpp bench 10000->10000 92ms215us201ns 9us221ns ns/op
[12-16 16:41:43] INFO - xmpp bench 100000->100000 874ms431us413ns 8us744ns ns/op

[12-16 16:55:50] INFO - xmpp bench 10->10 125us500ns 12us550ns ns/op
[12-16 16:55:50] INFO - xmpp bench 100->100 816us300ns 8us163ns ns/op
[12-16 16:55:50] INFO - xmpp bench 1000->1000 9ms336us700ns 9us336ns ns/op
[12-16 16:55:50] INFO - xmpp bench 10000->10000 84ms992us900ns 8us499ns ns/op
[12-16 16:55:50] INFO - xmpp bench 100000->100000 713ms884us898ns 7us138ns ns/op

[12-16 17:13:40] INFO - xmpp bench 10->10 119us 11us900ns ns/op
[12-16 17:13:40] INFO - xmpp bench 100->100 874us200ns 8us742ns ns/op
[12-16 17:13:40] INFO - xmpp bench 1000->1000 7ms432us600ns 7us432ns ns/op
[12-16 17:13:40] INFO - xmpp bench 10000->10000 72ms853us 7us285ns ns/op
[12-16 17:13:40] INFO - xmpp bench 100000->100000 589ms786us700ns 5us897ns ns/op
 */
