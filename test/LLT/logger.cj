import stdx.log.*
import stdx.logger.*
import std.process.Process
import std.time.DateTime
import cangjie_tpc::xmpp4cj.util.ExceptionUtil

/*
 * 设置全局logger 异常堆栈更直观
 * 如果使用了ConsoleDebugger 可以不启用此logger
 */
let logger = {
    =>
    let logger = MyLogger()
    logger.level = LogLevel.ALL
    setGlobalLogger(logger)
    Process.current.atExit {=> logger.close()}
    logger
}()

class MyLogger <: Logger {
    let myLogWriter = MyLogWriter()
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
    public func endArray(): Unit {}
    public func endObject(): Unit {}
    public func startArray(): Unit {}
    public func startObject(): Unit {}
    public func writeBool(v: Bool): Unit {}
    public func writeDateTime(v: DateTime): Unit {}
    public func writeDuration(v: Duration): Unit {}
    public func writeException(v: Exception): Unit {
        println(ExceptionUtil.getStackTrace(v))
    }
    public func writeFloat(v: Float64): Unit {}
    public func writeInt(v: Int64): Unit {}
    public func writeKey(v: String): Unit {}
    public func writeNone(): Unit {}
    public func writeString(v: String): Unit {
        println(v)
    }
    public func writeUInt(v: UInt64): Unit {}
    public func writeValue(v: LogValue): Unit {
        v.writeTo(this)
    }
}

/* 设置全局logger 使用SimpleLogger 异常堆栈格式不方便 */
func setGlobalLoggerWithSimple() {
    let logger = SimpleLogger(Process.current.stdOut)
    logger.level = LogLevel.ALL
    setGlobalLogger(logger)
    Process.current.atExit {=> logger.close()}
}
