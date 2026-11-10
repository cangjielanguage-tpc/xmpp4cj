// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 
//--filter=*.*

func getConn(): XMPPTCPConnection {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .build()
    let conn = XMPPTCPConnection(config)
    conn
}

class StanzaListener0 <: StanzaListener {
    var syncCounter: SyncCounter = SyncCounter(1)
    var conn: XMPPTCPConnection
    public init(conn: XMPPTCPConnection) {
        this.conn = conn
    }
    public override func processStanza(packet: Stanza) {
        println("StanzaListener0: processStanza: ${packet.toString()}")
        syncCounter.dec()
    }
}

class SimpleStanzaListener <: StanzaListener {
    /* customFunc : listener触发时的自定义操作 */
    public SimpleStanzaListener(let customFunc: () -> Unit) {}
    public override func processStanza(packet: Stanza) {
        customFunc()
    }
}

/*监听server退回的消息 Listener读线程同步无序执行*/
@Test
public func addStanzaListener_test(): Unit {
    let conn = getConn()

    conn.connect()
    conn.login()

    let filter1 = ToMatchesFilter.createFull(conn.getUser().getOrThrow())
    let filter2 = StanzaTypeFilter<Message>("Message")
    let filter = AndFilter([filter1, filter2]) // server退回的消息

    let res = StringBuilder()
    let counter = SyncCounter(2)

    // 第一个监听器, 休眠1s, 确保第二个监听器先于第一个监听器执行
    conn.addStanzaListener(
        SimpleStanzaListener {
            =>
            sleep(Duration.second)
            res.append("1")
            counter.dec()
        },
        filter
    )
    // 第二个监听器, 不休眠
    conn.addStanzaListener(
        SimpleStanzaListener {
            =>
            res.append("2")
            counter.dec()
        },
        filter
    )
    let message = StanzaBuilder.buildMessage().to("unknow@xmpp.testserver/1").setBody("hello").build()
    conn.sendStanza(message)

    counter.waitUntilZero(timeout: Duration.second * 5)
    @Assert(res.toString(), "21")
}

/*监听server退回的消息 Listener异步有序执行*/
@Test
public func addSyncStanzaListener_test(): Unit {
    let conn = getConn()

    conn.connect()
    conn.login()

    let filter1 = ToMatchesFilter.createFull(conn.getUser().getOrThrow())
    let filter2 = MessageWithBodiesFilter.INSTANCE
    let filter = AndFilter([filter1, filter2]) // server退回的消息

    let res = StringBuilder()
    let counter = SyncCounter(2)

    // 第一个监听器, 休眠1s
    conn.addSyncStanzaListener(
        SimpleStanzaListener {
            =>
            sleep(Duration.second)
            res.append("1")
            counter.dec()
        },
        filter
    )
    // 第二个监听器, 不休眠
    conn.addSyncStanzaListener(
        SimpleStanzaListener {
            =>
            res.append("2")
            counter.dec()
        },
        filter
    )
    let message = StanzaBuilder.buildMessage().to("unknow@xmpp.testserver/2").setBody("hello").build()
    conn.sendStanza(message)

    counter.waitUntilZero(timeout: Duration.second * 5)
    @Assert(res.toString(), "12")
}

/*监听server退回的消息 Listener异步无序执行*/
@Test
public func addAsyncStanzaListener_test(): Unit {
    let conn = getConn()

    conn.connect()
    conn.login()

    let filter1 = ToMatchesFilter.createFull(conn.getUser().getOrThrow())
    let filter2 = StanzaTypeFilter<Message>("Message")
    let filter = AndFilter([filter1, filter2]) // server退回的消息

    let res = StringBuilder()
    let counter = SyncCounter(2)

    // 第一个监听器, 休眠1s
    conn.addAsyncStanzaListener(
        SimpleStanzaListener {
            =>
            sleep(Duration.second)
            res.append("1")
            counter.dec()
        },
        filter
    )
    // 第二个监听器, 不休眠
    conn.addAsyncStanzaListener(
        SimpleStanzaListener {
            =>
            res.append("2")
            counter.dec()
        },
        filter
    )
    let message = StanzaBuilder.buildMessage().to("unknow@xmpp.testserver/3").setBody("hello").build()
    conn.sendStanza(message)

    counter.waitUntilZero(timeout: Duration.second * 5)
    @Assert(res.toString(), "21")
}

/*监听client发出的消息 Listener异步有序执行*/
@Test
public func addStanzaSendingListener_test(): Unit {
    let conn = getConn()

    conn.connect()
    conn.login()

    let filter1 = ToMatchesFilter.createFull(JidCreate.fullFrom("unknow@xmpp.testserver/4"))
    let filter2 = MessageWithBodiesFilter.INSTANCE
    let filter = AndFilter([filter1, filter2]) // client发出的消息

    let res = StringBuilder()
    let counter = SyncCounter(2)

    // 第一个监听器, 休眠1s
    conn.addStanzaSendingListener(
        SimpleStanzaListener {
            =>
            sleep(Duration.second)
            res.append("1")
            counter.dec()
        },
        filter
    )
    // 第二个监听器, 不休眠
    conn.addStanzaSendingListener(
        SimpleStanzaListener {
            =>
            res.append("2")
            counter.dec()
        },
        filter
    )

    let message = StanzaBuilder.buildMessage().to("unknow@xmpp.testserver/4").setBody("hello").build()
    conn.sendStanza(message)

    counter.waitUntilZero(timeout: Duration.second * 5)
    @Assert(res.toString(), "12")
}
