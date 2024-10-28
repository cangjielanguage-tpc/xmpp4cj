/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * Debug抽象类
 */
public abstract class AbstractDebugger <: XmppDebugger {
    private static let LOGGER = getGlobalLogger("AbstractDebugger")

    /**
     * 是否打印解释内容的标志
     */
    public static var printInterpreted = false

    private var _connListener: ?ConnectionListener = None

    private prop connListener: ConnectionListener {
        get() {
            _connListener ?? {
                =>
                let v = AbstractDebugger_3(this, connection)
                _connListener = v
                v
            }()
        }
    }

    private var _reconnectionListener: ?ReconnectionListener = None

    private prop reconnectionListener: ReconnectionListener {
        get() {
            _reconnectionListener ??
                {
                =>
                let v = AbstractDebugger_4(this, connection)
                if (let Some(abstractXmppConnection) <- (connection as AbstractXMPPConnection)) {
                    ReconnectionManager.getInstanceFor(abstractXmppConnection).addReconnectionListener(v)
                } else {
                    LOGGER.info(
                        "The connection instance connection is not an instance of AbstractXMPPConnection, thus we can not install the ReconnectionListener"
                    )
                }
                _reconnectionListener = v
                v
            }()
        }
    }

    private var _readerListener: ?ReaderListener = None

    private prop readerListener: ReaderListener {
        get() {
            _readerListener ??
                {
                =>
                let v = ReaderListener {str => log("RECV (${connection.getConnectionCounter()}): ${str}")}
                reader.addReaderListener(readerListener)
                _readerListener = v
                v
            }()
        }
    }

    private var _writerListener: ?WriterListener = None

    private prop writerListener: WriterListener {
        get() {
            _writerListener ??
                {
                =>
                let v = WriterListener {str => log("SENT (${connection.getConnectionCounter()}): ${str}")}
                writer.addWriterListener(v)
                _writerListener = v
                v
            }()
        }
    }

    private var writer: ObservableWriter

    private var reader: ObservableReader

    /**
     * 通过XMPPConnection初始化AbstractDebugger
     *
     * @param connection XMPPConnection
     */
    public init(connection: XMPPConnection) {
        super(connection)

        this.reader = ObservableReader()
        this.writer = ObservableWriter()
    }

    /**
     * 抽象记录日志方法，子类需要实现
     *
     * @param logMessage 日志文本
     */
    protected open func log(logMessage: String): Unit

    /**
     * 抽象记录日志方法，子类需要实现，用于异常日志
     *
     * @param logMessage 日志文本
     * @param throwable 异常信息
     */
    protected open func log(logMessage: String, throwable: Exception): Unit

    /**  
     * 注意字符序列可能会被格式化为可读的形式。
     *
     * @param outgoingCharSequence 出站字符序列
     */
    public override func outgoingStreamSink(outgoingCharSequence: ToString): Unit {
        log("SENT (${connection.getConnectionCounter()}): ${outgoingCharSequence}")
    }

    /**  
     * 处理入站字符序列。
     *
     * @param incomingCharSequence 入站字符序列
     */
    public override func incomingStreamSink(incomingCharSequence: ToString): Unit {
        log("RECV (${connection.getConnectionCounter()}): ${incomingCharSequence}")
    }

    /**  
     * 当用户登录到服务器时调用。用户可以是匿名用户，即用户的形式为 host/resource，而不是 user@host/resource。
     *
     * @param user 登录的用户 @ host/resource
     */
    public open override func userHasLogged(user: EntityFullJid): Unit {
        let localpart: String = user.getLocalpart().toString()
        let isAnonymous = if ("" == localpart) {
            ""
        } else {
            localpart
        }
        var title: String = "User logged (${connection.getConnectionCounter()}): ${isAnonymous}@${connection.getXMPPServiceDomain()}:${connection.getPort()}"
        title += "/${user.getResourcepart()}"
        log(title)
        connection.addConnectionListener(connListener)
    }

    /**  
     * 由连接用于通知关于传入的顶层流元素。
     * <p>
     * 此方法在解析入站流后立即调用。
     * </p>
     *
     * @param streamElement 传入的顶层流元素
     */
    public open override func onIncomingStreamElement(streamElement: TopLevelStreamElement): Unit {
        if (printInterpreted) {
            log("RCV PKT (${connection.getConnectionCounter()}): ${streamElement.toXML()}")
        }
    }

    /**  
     * 由连接用于通知关于传出的顶层流元素。
     * <p>
     * 此方法在元素被序列化为 XML 并放入出站流之前调用。
     * </p>
     *
     * @param streamElement 传出的顶层流元素
     */
    public open override func onOutgoingStreamElement(streamElement: TopLevelStreamElement): Unit {
        // 什么都不做。
    }
}

class AbstractDebugger_3 <: ConnectionListener {
    let this_0: AbstractDebugger

    let val_connection: XMPPConnection

    init(this_0: AbstractDebugger, val_connection: XMPPConnection) {
        this.this_0 = this_0
        this.val_connection = val_connection
    }

    public override func connected(connection: XMPPConnection): Unit {
        this_0.log("XMPPConnection connected (${connection})")
    }

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {
        var logString: String = "XMPPConnection authenticated (${connection})"
        if (resumed) {
            logString += " and resumed"
        }
        this_0.log(logString)
    }

    public override func connectionClosed(): Unit {
        this_0.log("XMPPConnection closed (${val_connection})")
    }

    public override func connectionClosedOnError(e: Exception): Unit {
        this_0.log("XMPPConnection closed due to an exception (${val_connection})", e)
    }
}

class AbstractDebugger_4 <: ReconnectionListener {
    let this_0: AbstractDebugger

    let val_connection: XMPPConnection

    init(this_0: AbstractDebugger, val_connection: XMPPConnection) {
        this.this_0 = this_0
        this.val_connection = val_connection
    }

    public override func reconnectionFailed(e: Exception): Unit {
        this_0.log("Reconnection failed due to an exception (${val_connection})", e)
    }

    public override func reconnectingIn(seconds: Duration): Unit {
        this_0.log("XMPPConnection (${val_connection}) will reconnect in ${seconds}")
    }
}
