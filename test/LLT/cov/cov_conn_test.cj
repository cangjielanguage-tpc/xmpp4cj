// DEPENDENCE: ../z_test.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*

class ConnectionListener0 <: ConnectionListener {
    public override func connectionClosed(): Unit {}

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {}

    public override func connectionClosedOnError(e: Exception): Unit {}
}

public class TestIQ <: SimpleIQ {
    public init() {
        this("test-iq", XmppConfiguration.XMPP_URL_STRING)
    }

    public init(element: String, namespace: String) {
        super(StanzaBuilder.buildIqData("42"), element, namespace)
    }

    protected func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        return super.getIQChildElementBuilder(xml)
    }
}

public class StanzaListener0 <: StanzaListener {
    public func processStanza(packet: Stanza): Unit {}
}

class PingRequestHandler <: AbstractIqRequestHandler {
    init() {
        super("ping", "urn:xmpp:ping", IQType.get, IQRequestHandlerMode.async)
    }
    public func handleIQRequest(iqRequest: IQ): ?IQ {
        // Ping ping = (Ping) iqRequest
        // return ping.getPong()
        None
    }
}

class IqSetRequestHandler <: AbstractIqRequestHandler {
    init() {
        super("ping", "urn:xmpp:ping", IQType.set, IQRequestHandlerMode.async)
    }
    public func handleIQRequest(iqRequest: IQ): ?IQ {
        // Ping ping = (Ping) iqRequest
        // return ping.getPong()
        None
    }
}

class ParsingExceptionCallback0 <: ParsingExceptionCallback {
    public func handleUnparsableStanza(stanzaData: UnparseableStanza): Unit {}
}

class StanzaFilter0 <: StanzaFilter {
    public func accept(stanza: Stanza): Bool {
        return true
    }
    public func toString(): String {
        "StanzaFilter0"
    }
}

@Test
func conn1(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)

    connection.removeConnectionListener(ConnectionListener0())

    connection.connect()
    try {
        @AssertThrows[IllegalArgumentException](connection.sendIqRequestAndWaitForResponse(TestIQ()))
        let iq = connection.sendIqRequestAndWaitForResponse(TestIQ())
    } catch (e: IllegalArgumentException) {
        @Assert(e.message,"Must have a local (user) JID set. Either you didn't configure one or you where not connected at least once")
    }
    connection.login()
    try {
        let iq = connection.sendIqRequestAndWaitForResponse(Bind.newSet(Resourcepart.froms("asdasdas")))
        println(iq)
    } catch (e: XMPPErrorException) {
        println(e.getMessage())
    }

    connection.addStanzaListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeStanzaListener(StanzaListener0())
    connection.addSyncStanzaListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeSyncStanzaListener(StanzaListener0())
    connection.addAsyncStanzaListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeAsyncStanzaListener(StanzaListener0())
    connection.addStanzaSendingListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeStanzaSendingListener(StanzaListener0())

    connection.addMessageInterceptor(HashableConsumer {_ => ()}, None)
    connection.removeMessageInterceptor(HashableConsumer {_ => ()})

    connection.addPresenceInterceptor(HashableConsumer {_ => ()}, None)
    connection.removePresenceInterceptor(HashableConsumer {_ => ()})

    connection.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.doNotReply)

    let iq1 = connection.sendIqRequestAndWaitForResponse(Bind.newSet(Resourcepart.froms("aaa")))
    let iq2 = connection.sendIqRequestAsync(Bind.newSet(Resourcepart.froms("aaa")))
    let iq3 = connection.sendIqRequestAsync(Bind.newSet(Resourcepart.froms("aaa")), Duration.second)
    let request4 = Bind.newSet(Resourcepart.froms("aaa"))
    let filter4 = IQReplyFilter(request4, connection.getUser(), connection.getXMPPServiceDomain())
    let iq4 = connection.sendAsync(request4, filter4)
    let iq5 = connection.sendAsync(request4, filter4, Duration.second)
    // let iq6 = connection.sendAsyncGeneric(request4, filter4, Duration.second)
    // iq6.getOrThrow()

    connection.addOneTimeSyncCallback(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))

    let iqRequestHandler1 = connection.registerIQRequestHandler(PingRequestHandler())
    let iqRequestHandler2 = connection.registerIQRequestHandler(IqSetRequestHandler())
    let iqRequestHandler3 = connection.unregisterIQRequestHandler(PingRequestHandler())
    let iqRequestHandler4 = connection.unregisterIQRequestHandler("Ping1", "urn:xmpp:ping", IQType.get)
    let iqRequestHandler5 = connection.unregisterIQRequestHandler("Ping2", "urn:xmpp:ping", IQType.set)

    let dur1 = connection.getLastStanzaReceived()
    let dur2 = connection.getAuthenticatedConnectionInitiallyEstablishedTimestamp()

    connection.setParsingExceptionCallback(ParsingExceptionCallback0())
    let parsingExceptionCallback = connection.getParsingExceptionCallback()

    connection.setMaxAsyncOperations(128)

    @Assert(AbstractXMPPConnection.getClassId(), "AbstractXmppConnection")
    @Assert(connection==connection)

    connection.sendIqRequestAsync(Bind.newSet(Resourcepart.froms("asdasdas")))
}

@Test
func conn2(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        // .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)
    connection.connect()
    @AssertThrows[SASLErrorException](connection.login("1","1sknvosn"))
}

class ErrStanza <: Stanza {
    let msg: Message = StanzaBuilder.buildMessage().build();

    public func toString(): String {
        return msg.toString();
    }

    public func getElementName(): String {
        return msg.getElementName();
    }

    public func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        throw Exception("stop")
    }
}

@Test
func conn3(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        // .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)
    @Assert(connection.getStreamId().isNone())
    @AssertThrows[NotConnectedException](connection.login("1","1sknvosn"))

    connection.connect()
    @AssertThrows[AlreadyConnectedException](connection.connect())

    connection.login("1", "123456")
    @AssertThrows[AlreadyLoggedInException](connection.login("1","123456"))

    connection.disconnect()
    connection.disconnect()
    connection.disconnect(None)

    // connection.notifyConnectionError(Exception())
    connection.connect()
    connection.sendStanza(ErrStanza())
    // connection.waitForClosingStreamTagFromServer()
    sleep(Duration.second)

    connection.createStanzaCollector(StanzaFilter0())

    connection.addMessageInterceptor(HashableConsumer {_ => ()}, LambdaPredicate {_ => true})
    connection.addPresenceInterceptor(HashableConsumer {_ => ()}, LambdaPredicate {_ => true})
    connection.connect()
    connection.login("1", "123456")

    @AssertThrows[IllegalArgumentException](connection.setReplyTimeout(Duration.millisecond*Int64.Max))
}

@Test
func conn4(): Unit {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write("<a/>".toArray())
    let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
    parser.next()

    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    // connection.parseAndProcessNonza(parser)
}

@Test
func conn5(): Unit {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write("<compressed xmlns='${Compress.NAMESPACE}'/>".toArray())
    let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
    parser.next()

    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    // connection.parseAndProcessNonza(parser)
}

public class Nonza0 <: Nonza {
    static init() {
        ELEMENT_MAPPING.add("Nonza0", "Nonza0")
        NAMESPACE_MAPPING.add("Nonza0", "Nonza0ns")
        QNAME_MAPPING.add("Nonza0", QName("Nonza0ns", "Nonza0"))
    }
    public override func getElementName(): String {
        return "Nonza0"
    }
    public override func getNamespace(): String {
        return "Nonza0ns"
    }
    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml: XmlStringBuilder = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()
        xml.emptyElement("Nonza0")
        xml.closeElement(this)
        return xml
    }
}

public class NonzaProvider0 <: NonzaProvider<Nonza0> {
    init() {
        super("Nonza0")
    }
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): Nonza0 {
        Nonza0()
    }
}

@Test
func conn6(): Unit {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write("<Nonza0 xmlns='Nonza0ns'/>".toArray())
    let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
    parser.next()

    ProviderManager.addNonzaProvider(NonzaProvider0())

    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    // connection.parseAndProcessNonza(parser)
}

class VersionRequestHandler <: AbstractIqRequestHandler {
    let latch = SyncCounter(1)
    init() {
        super("query", "jabber:iq:version", IQType.get, IQRequestHandlerMode.sync)
    }
    public func handleIQRequest(iqRequest: IQ): ?IQ {
        latch.dec()
        Version.createResultFor(iqRequest)
    }
}

public class Version <: IQ {
    public static let ELEMENT: String = QUERY_ELEMENT
    public static let NAMESPACE: String = "jabber:iq:version"
    private let name: String
    private let version: String
    private let os: String
    public Version(name: String, version: String, os: String) {
        super(ELEMENT, NAMESPACE)
        this.name = name
        this.version = version
        this.os = os
        this.setType(IQType.result)
    }

    protected func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.rightAngleBracket()
        xml.element("name", name)
        xml.element("version", version)
        xml.element("os", os)
        return xml
    }

    public static func createResultFor(request: Stanza): Version {
        let result = Version("xmpp4cj", "0.0.1", "linux")
        result.setStanzaId(request.getStanzaId())
        result.setTo(request.getFrom())
        return result
    }
}

@Test
func conn7(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .build()
    let connection = XMPPTCPConnection(config)

    let handler = VersionRequestHandler()
    connection.registerIQRequestHandler(handler)

    connection.connect()
    connection.login()

    handler.latch.waitUntilZero(timeout: Duration.second * 5)
}

class VerListener <: StanzaListener {
    let counter = SyncCounter(1)
    public override func processStanza(packet: Stanza): Unit {
        match (packet) {
            case iq: IQ where iq.getType() == IQType.get => counter.dec()
            case _ => ()
        }
    }
}

@Test
func conn8(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .build()
    let connection = XMPPTCPConnection(config)

    connection.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.doNotReply)
    let ver = VerListener()
    connection.addSyncStanzaListener(ver, StanzaTypeFilter<Stanza>("Stanza"))

    connection.connect()
    connection.login()

    ver.counter.waitUntilZero(timeout: Duration.second * 5)
}

@Test
func conn9(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .build()
    let connection = XMPPTCPConnection(config)

    connection.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.replyServiceUnavailable)
    let ver = VerListener()
    connection.addSyncStanzaListener(ver, StanzaTypeFilter<Stanza>("Stanza"))

    connection.connect()
    connection.login()

    ver.counter.waitUntilZero(timeout: Duration.second * 5)
}

@Test
func conn10(): Unit {
    let obj = HashableConsumer<Int> {_ => ()}
    obj.accept(0)
}

@Test
func conn11(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    @AssertThrows[IllegalArgumentException](connection.setMaxAsyncOperations(0))

    if (true) {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write("<a xmlns='jabber:client' id='123' from='from@sss'>sdf</a>".toArray())
        let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
        parser.next()

        // connection.onStreamOpen(parser)
    }

    if (true) {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write("<a xmlns='jabber:client' id='123' from='123@'>sdf</a>".toArray())
        let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
        parser.next()

        // connection.onStreamOpen(parser)
    }
}

@Test
func conn12(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)
    let connection2 = XMPPTCPConnection(config)

    @Assert(connection!=connection2)
}
