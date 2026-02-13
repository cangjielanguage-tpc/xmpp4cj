// EXEC: cjc %import-path %L %l %f
/// EXEC: ./main

import stdx.log.*
import stdx.logger.*
import std.collection.*
import std.fs.*
import std.io.*
import std.process.*
import std.sync.*
import std.time.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.util.*

class MyLogger <: Logger {
    init() {
        setGlobalLogger(this)
        Process.current.atExit {=> this.close()}
    }
    let myLogWriter = MyLogWriter(Process.current.stdOut)
    // let myLogWriter = MyLogWriter(File("xmpp4cj_bench.log", Write))
    public override func close() {}
    public override func isClosed() {
        false
    }
    public override func log(record: LogRecord): Unit {
        myLogWriter.writeString("${record.time.format("HH:mm:ss")} ${record.level} ${record.message} ")
        for (tup in record.attrs) {
            myLogWriter.writeString("${tup[0]} : ")
            myLogWriter.writeValue(tup[1])
        }
    }
    public override func withAttrs(attrs: Array<Attr>) {
        this
    }
    public mut override prop level: LogLevel {
        get() {
            LogLevel.ALL
        }
        set(v) {}
    }
}

class MyLogWriter <: LogWriter {
    MyLogWriter(let out: OutputStream) {}
    public func endArray(): Unit {}
    public func endObject(): Unit {}
    public func startArray(): Unit {}
    public func startObject(): Unit {}
    public func writeBool(v: Bool): Unit {}
    public func writeDateTime(v: DateTime): Unit {}
    public func writeDuration(v: Duration): Unit {}
    public func writeException(v: Exception): Unit {
        writeString(ExceptionUtil.getStackTrace(v))
    }
    public func writeFloat(v: Float64): Unit {}
    public func writeInt(v: Int64): Unit {}
    public func writeKey(v: String): Unit {}
    public func writeNone(): Unit {}
    public func writeString(v: String): Unit {
        out.write(unsafe { (v + '\n').rawData() })
    }
    public func writeUInt(v: UInt64): Unit {}
    public func writeValue(v: LogValue): Unit {
        v.writeTo(this)
    }
}

let logger = getGlobalLogger()
// let logger = MyLogger()

func getConn(user: String, pwd: String): XMPPTCPConnection {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setUsernameAndPassword(user, pwd)
        .setResource(user)
        .setXmppDomain("xmpp.testserver")
        .setHost("xmpp.testserver")
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    // .enableDefaultDebugger()
    let connection = XMPPTCPConnection(configBuilder.build())
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
            if (let Some(v) <- (packet as Message)) {
                counter.dec()
            }
        }
    }
}

/* conn1死循环发送消息到conn2, conn2接收1000条结束 */
func bench(count: Int): Unit {
    let conn1 = getConn("11", "123456")
    let conn2 = getConn("12", "123456")

    let listener = BenchListener(count)
    let entityBareJid: EntityBareJid = JidCreate.entityBareFrom("12@xmpp.testserver")
    let message: Message = MessageBuilder
        .buildMessage()
        .to(entityBareJid)
        .ofType(MessageType.chat)
        .setBody("11@xmpp.testserver to 12@xmpp.testserver")
        .build()
    let now0 = DateTime.now()
    conn2.addSyncStanzaListener(listener, StanzaTypeFilter<Stanza>("Stanza"))
    let fur = spawn {
        let t = Thread.currentThread
        for (_ in 0..count) {
            if (t.hasPendingCancellation) {
                break
            }
            conn1.sendStanza(message)
        }
    }
    listener.counter.waitUntilZero(timeout: Duration.second * 100)
    let dur = DateTime.now() - now0
    println("xmpp bench ${count}->${listener.counter.count} ${dur} ${dur/count} ns/op")
    fur.cancel()
    conn1.disconnect()
    conn2.disconnect()
}

main(): Unit {
    try {
        bench(100)
    } catch (e: Exception) {
        logger.error("maine0 ", ("", e))
    } catch (e: Error) {
        logger.error("maine1 ", ("", e.toString()))
    }
}
