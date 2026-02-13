import stdx.log.*
import stdx.logger.*
import std.process.*

class MyLogger <: Logger {
    init() {
        setGlobalLogger(this)
        Process.current.atExit {=> this.close()}
    }
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
    public var _level: LogLevel = LogLevel.ALL
    public mut override prop level: LogLevel {
        get() {
            _level
        }
        set(v) {
            _level = v
        }
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
        writeString(ExceptionUtil.getStackTrace(v))
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

let logger = MyLogger()
