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
    let queue = ArrayBlockingQueueWithShutdown<Element>(XMPPTCPConnectionPacketWriter.QUEUE_SIZE, true)
    let now0 = DateTime.now()
    spawn {
        for (_ in 0..count) {
            queue.put(message)
        }
    }
    spawn {
        for (_ in 0..count) {
            queue.take()
            listener.counter.dec()
        }
    }
    listener.counter.waitUntilZero()
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
[12-16 17:21:34] INFO - xmpp bench 10->0 87us600ns 8us760ns ns/op
[12-16 17:21:34] INFO - xmpp bench 100->0 118us900ns 1us189ns ns/op
[12-16 17:21:34] INFO - xmpp bench 1000->0 675us600ns 675ns ns/op
[12-16 17:21:34] INFO - xmpp bench 10000->0 4ms736us 473ns ns/op
[12-16 17:21:34] INFO - xmpp bench 100000->0 50ms331us299ns 503ns ns/op
 */
