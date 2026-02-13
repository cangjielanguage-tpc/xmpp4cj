// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.filter.*

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

class SimpleStanzaListener <: StanzaListener {
    /* customFunc : listener触发时的自定义操作 */
    public SimpleStanzaListener(let customFunc: (Stanza) -> Unit) {}
    public override func processStanza(packet: Stanza) {
        customFunc(packet)
    }
}

/*拦截client发出的Message*/
@Test
public func addMessageInterceptor_test(): Unit {
    let conn = getConn()

    conn.connect()
    conn.login()

    conn.addMessageInterceptor(
        HashableConsumer<MessageBuilder> {
            msgBuilder =>
            sleep(Duration.second)
            msgBuilder.to("intercepted1@qwe")
        },
        LambdaPredicate<Message> {msg => msg.getType() == MessageType.chat && msg.getBody() == "hello"}
    )

    let counter = SyncCounter(1)
    let res = StringBuilder()
    // 监听修改后Message
    conn.addStanzaSendingListener(
        SimpleStanzaListener {
            stanza =>
            res.append(stanza.getTo().getOrThrow())
            counter.dec()
        },
        MessageWithBodiesFilter.INSTANCE
    )

    let message = StanzaBuilder
        .buildMessage()
        .to("unknow@xmpp.testserver/r4")
        .setBody("hello")
        .ofType(MessageType.chat)
        .build()
    conn.sendStanza(message)

    counter.waitUntilZero(timeout: Duration.second * 5)
    @Assert(res.toString(), "intercepted1@qwe")
}

/*拦截client发出的Presence*/
@Test
public func addPresenceInterceptor_test(): Unit {
    let conn = getConn()

    conn.connect()
    conn.login()

    conn.addPresenceInterceptor(
        HashableConsumer<PresenceBuilder> {
            preBuilder =>
            sleep(Duration.second)
            preBuilder.setStatus("im back")
        },
        LambdaPredicate<Presence> {p => p.getMode() == PresenceMode.away}
    )

    let counter = SyncCounter(1)
    let res = StringBuilder()
    // 监听修改后Message
    conn.addStanzaSendingListener(
        SimpleStanzaListener {
            stanza =>
            let p = (stanza as Presence).getOrThrow()
            res.append(p.getStatus().getOrThrow())
            counter.dec()
        },
        StanzaTypeFilter<Presence>.PRESENCE
    )

    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(PresenceMode.away)
        .build()
    conn.sendStanza(presence)

    counter.waitUntilZero(timeout: Duration.second * 5)
    @Assert(res.toString(), "im back")
}
