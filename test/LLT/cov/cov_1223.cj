// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main
import std.net.*

func getParser(xml: String): XmlPullParser {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write(xml.toArray())
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let staxXmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
    staxXmlPullParser
}

// @Test
public func covParserUtils(): Unit {
    var parser = getParser("<p/>")
    parser.next()
    ParserUtils.assertAtStartTag(parser, "p")

    parser = getParser("<p jid='a@asd/res'/>")
    parser.next()
    ParserUtils.getJidAttribute(parser)
    ParserUtils.getBareJidAttribute(parser)
    ParserUtils.getFullJidAttribute(parser)
    ParserUtils.getEntityJidAttribute(parser, "jid")
    ParserUtils.getResourcepartAttribute(parser, "jid")

    ParserUtils.parseXmlBool("0")
    ParserUtils.parseXmlBool("false")
    @AssertThrows[IllegalArgumentException](ParserUtils.parseXmlBool("f"))

    parser = getParser("<p i='1'/>")
    parser.next()
    @Assert(ParserUtils.getIntegerAttributeOrThrow(parser, "i", "asd"),1)
    @Assert(ParserUtils.getUInt16Attribute(parser, "i"),1)
    @Assert(ParserUtils.getRequiredUInt16Attribute(parser, "i"),1)
    @Assert(ParserUtils.getLongAttribute(parser, "i", 3),1)
    @Assert(ParserUtils.getUIntAttribute(parser, "i"),1)
    @Assert(ParserUtils.getDoubleAttribute(parser, "i"),1.0)
    @Assert(ParserUtils.getDoubleAttribute(parser, "i", 2),1.0)
    @Assert(ParserUtils.getShortAttribute(parser, "i"),1)
    @Assert(ParserUtils.getShortAttribute(parser, "i",16),1)

    parser = getParser("<p i='1'>2</p>")
    parser.next()
    @Assert(ParserUtils.getIntegerFromNextText(parser),2)

    parser = getParser("<p i='1'>2.1</p>")
    parser.next()
    @Assert(ParserUtils.getDoubleFromNextText(parser),2.1)

    ParserUtils.getDateFromOptionalXep82String("1969-07-21T02:56:15Z")
    ParserUtils.getDateFromXep82String("1969-07-20T21:56:15-05:00")
    ParserUtils.getDateFromString("1969-07-20T21:56:15-05:00")

    parser = getParser("<p i='1'>1969-07-21T02:56:15Z</p>")
    parser.next()
    ParserUtils.getDateFromNextText(parser)

    parser = getParser("<p i='1'>http://qwe.com</p>")
    parser.next()
    ParserUtils.getUriFromNextText(parser)

    parser = getParser("<p i='1'>http://qwe.com</p>")
    parser.next()
    ParserUtils.getRequiredAttribute(parser, "i")
    ParserUtils.getRequiredNextText(parser)

    parser = getParser("<p i='127.0.0.1'>http://qwe.com</p>")
    parser.next()
    ParserUtils.getInternetAddressIngoringZoneIdAttribute(parser, "i")
}

@Test
public func covConnectionListenerBuilder(): Unit {
    let builder = ConnectionListenerBuilder()
    builder.connecting {_ =>}
    builder.connected {_ =>}
    builder.authenticated {_, _ =>}
    builder.connectionClosed {=>}

    @Assert(ConnectionCreationListener({_=>})==ConnectionCreationListener({_=>}), false)
}

@Test
public func covLambdaDebuggerFactory(): Unit {
    LambdaDebuggerFactory.setDebuggerClass(None)
    LambdaDebuggerFactory.setDebuggerClass("None")
    LambdaDebuggerFactory.getDebuggerClass()
}

@Test
public func covSASLXOauth2Mechanism(): Unit {
    let sasl = SASLXOauth2Mechanism()
    sasl.newInstance()
    sasl.checkIfSuccessfulOrThrow()
}

class AbstractXMPPConnection0 <: AbstractXMPPConnection {
    init(config: ConnectionConfiguration) {
        super(config)
    }
    public override func isSecureConnection(): Bool {
        return false;
    }
    protected override func sendStanzaInternal(packet: Stanza): Unit {
    }
    public override func sendNonza(element: Nonza): Unit {
    }
    public override func isUsingCompression(): Bool {
        return false;
    }
    protected override func connectInternal(): Unit {
    }
    protected override func loginInternal(username: ?String, password: ?String, resource: ?Resourcepart): Unit {
    }
    public override func instantShutdown(): Unit {
    }
    protected override func shutdown(): Unit {
    }
    public func getClass(): String {
        "AbstractXMPPConnection0"
    }
    protected func getReactor0(): XmppReactor {
        return super.getReactor()
    }
    protected func throwCurrentConnectionException1(): Unit {
        super.throwCurrentConnectionException()
    }
    protected func setCurrentConnectionExceptionAndNotify1(exception: Exception): Unit {
        super.setCurrentConnectionExceptionAndNotify(exception)
    }
    protected func getConnectionLock1(): Monitor {
        super.getConnectionLock()
    }
    protected func initDebugger1(): Unit {
        super.initDebugger()
    }
    protected func parseAndProcessNonza1(parser: XmlPullParser): Unit {
        super.parseAndProcessNonza(parser)
    }
    protected func parseAndProcessStanza1(parser: XmlPullParser): Unit {
        super.parseAndProcessStanza(parser)
    }
    protected func onStreamOpen1(parser: XmlPullParser): Unit {
        super.onStreamOpen(parser)
    }
}

let config = XMPPTCPConnectionConfiguration
    .builder()
    .setXmppDomain(XmppTestServerHostName)
    .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    .performSaslAnonymousAuthentication()
    .build()
let conn = {
    =>
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()
    conn.login()
    conn
}()

@Test
public func covScheduledAction(): Unit {
    let o = AbstractXMPPConnection0(config)
    let reactor = o.getReactor0()
    let scheduledAction = reactor.schedule({=>}, Duration.Zero, ScheduledActionKind.NonBlocking)
    scheduledAction.cancel()
    scheduledAction.isDue()
    scheduledAction.compare(reactor.schedule({=>}, Duration.Zero, ScheduledActionKind.NonBlocking))
}

@Test
public func covXmpp(): Unit {
    Xmpp.getVersion()
    try {
        Xmpp.getNoticeStream()
    } catch (_) {}
    Xmpp.ensureInitialized()
}

@Test
public func covXmpp4cjException(): Unit {
    let c = conn.createStanzaCollector(StanzaCollector.newConfiguration())
    c.getStanzaFilter()
    NoResponseException.newWith(Duration.Zero, c, true)
    let e = NoResponseException.newWith(conn, None)
    e.getFilter()

    NotConnectedException()
    NotConnectedException(conn, None, Exception())
}

@Test
public func covXmppCompressionManager(): Unit {
    XmppCompressionManager.registerXmppCompressionFactory(ZlibXmppCompressionFactory.INSTANCE)
    XmppCompressionManager.registerXmppCompressionFactory(ZlibXmppCompressionFactory.INSTANCE)
}

@Test
public func covXMPPConnectionRegistry(): Unit {
    let obj = ConnectionCreationListener({_ =>})
    XMPPConnectionRegistry.removeConnectionCreationListener(obj)
}

@Test
public func covSocketFuture(): Unit {
    let addr = IPAddress.resolve("localhost")[0]
    let saddr = IPSocketAddress(addr, 80)
    let obj = SocketFuture(SocketFactory.DEFAULT, saddr)
    obj.closeSocket()
}

@Test
public func covExecutionException(): Unit {
    var e = ExecutionException(Exception())
    e.toString()
    var e1 = CancellationException()
    e1.toString()
}

@Test
public func covC2sConnectionConfiguration(): Unit {
    var builder = C2sConnectionConfiguration.builder()
    builder.removeModule("asd")
    builder.removeAllModules()

    builder = C2sConnectionConfiguration.builder()
    builder.setXmppDomain("asd")
    let obj = builder.build()
    obj.getStateGraphInDotFormat()
}

public class ModuleDescriptor0 <: ModuleDescriptor {
    protected func getStateDescriptors(): Set<StateDescriptor> {
        HashSet<StateDescriptor>()
    }
    protected func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): C2sConnectionModule {
        throw Exception()
    }
    public func getClass(): ClassId {
        "ModuleDescriptor0"
    }
}

public class ModuleDescriptorBuilder0 <: ModuleDescriptorBuilder {
    protected init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        super(connectionConfigurationBuilder)
    }
    protected func build(): ModuleDescriptor {
        ModuleDescriptor0()
    }
}

@Test
public func covModuleDescriptor(): Unit {
    ModuleDescriptor.getClassId()

    let builder = ModuleDescriptorBuilder0(C2sConnectionConfiguration.builder())
    builder.buildModule()
    let d = builder.build()
    let d1 = builder.build()
    @Assert(d,d1)
}

@Test
public func covClassInfo(): Unit {
    let info = ClassInfo<String>("String", {_ => ""})
    info.hashCode()
    info.toString()
    @Assert(info==ClassInfo<String>("String", {_ => "asd"}))
}

@Test
public func covStateDescriptor(): Unit {
    StateDescriptor.getClassId()
}

/* 
public class Bind2StateDescriptor0 <: StateDescriptor {
    init() {
        super(
            ClassInfo("Bind2State0",
                {args => Bind2State0((args[0] as Bind2StateDescriptor0)(), (args[1] as C2sConnectionInternal)())}),
            386,
            [StateDescriptorProperty.notImplemented]
        )
        // addPredeccessor(ConnectedButUnauthenticatedStateDescriptor())
        // addSuccessor(AuthenticatedAndResourceBoundStateDescriptor())
        // declarePrecedenceOver(SaslAuthenticationStateDescriptor())
    }

    protected override func constructState(connectionInternal: C2sConnectionInternal): Bind2State {
        let bind2Module: Bind2Module = connectionInternal.connection.getConnectionModuleFor("Bind2ModuleDescriptor")
        return bind2Module.constructBind2State(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        "Bind2StateDescriptor"
    }
}
public class Bind2State0 <: State {
    init(bind2StateDescriptor: Bind2StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(bind2StateDescriptor, connectionInternal)
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        return TransitionImpossibleBecauseNotImplemented(stateDescriptor)
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        throw IllegalStateException("Bind2 not implemented")
    }
}
 */
@Test
public func covStateMachineException(): Unit {
    XmppMandatoryStateFailedException(unsafe { zeroValue<State>() }, None)
}

@Test
public func covStateTransitionResult(): Unit {
    StateTransitionResultFailure("")
    let e = FailureCausedByException<Exception>(Exception())
    e.getException()
    FailureCausedByTimeout("")
}

class LookupConnectionEndpointsFailed0 <: LookupConnectionEndpointsFailed {}

@Test
public func covNoEndpointsDiscoveredException(): Unit {
    NoEndpointsDiscoveredException.comefrom([])
    NoEndpointsDiscoveredException.comefrom([LookupConnectionEndpointsFailed0()])
}

@Test
public func covExceptionLoggingCallback(): Unit {
    let e = ExceptionLoggingCallback()
    e.handleUnparsableStanza(UnparseableStanza("", Exception()))
}

@Test
public func covExceptionThrowingCallbackWithHint(): Unit {
    let e = ExceptionThrowingCallbackWithHint()
    @AssertThrows[Exception](e.handleUnparsableStanza(UnparseableStanza("", Exception())))
}

@Test
public func covXmlStringBuilder(): Unit {
    let e = XmlStringBuilder()
    let dt: ?DateTime = DateTime.now()
    e.optElement("dt", dt)
    e.optAttribute("dt", dt)
    let i: Int = 4
    e.optElement("i", i)
    e.optIntAttribute("i", i)
    let b: Bool = true
    // e.attribute("b", b)
    e.optBooleanAttribute("b", b)
    let tostring: ToString = "Some(asdasd)"
    e.attribute("tostring", tostring)
    let oi: ?Int64 = 7
    e.optAttribute("oi", oi)
    let os: ?String = "aad"
    e.xmlnsAttribute(os)
    let ots: ?ToString = None
    e.optEscape(ots)
}

class ExtensionElement3 <: ExtensionElement & ClassIdentify {
    public static func getClassId(): ClassId {
        "ExtensionElement3"
    }
    public func getClass(): ClassId {
        "ExtensionElement3"
    }
    public func getElementName(): String {
        ""
    }
    public func getNamespace(): String {
        ""
    }
    public func toXML(env: ?XmlEnvironment): ToString {
        ""
    }
}

@Test
public func covXmppElementUtil(): Unit {
    @AssertThrows[Exception](XmppElementUtil.getQNameFor("aaa"))

    let appSpecificElement: ExtensionElement = CompressFeature(ArrayList<String>())
    @AssertThrows[Exception](XmppElementUtil.castOrThrow<ExtensionElement3>(appSpecificElement))
}

@Test
public func covXmppParsingException(): Unit {
    XmppParsingException("asd").toString()
    XmppUriSyntaxParsingException(Exception()).toString()
    XmppRequiredValueMissingException("").toString()
    XmppRequiredAttributeMissingException("").toString()
}

@Test
public func covIntrospectionProvider(): Unit {
    IntrospectionProvider.parseWithIntrospection<Element>
}

@Test
public func covIQProviderInfo(): Unit {
    let o = IQProviderInfo("", "", unsafe { zeroValue<IqProvider<IQ>>() })
    o.getProvider()
}

@Test
public func covProxyException(): Unit {
    let o = ProxyException(ProxyInfoProxyType.HTTP, "")
    ProxyException(ProxyInfoProxyType.SOCKS5)
    o.toString()
}

@Test
public func covProxyInfo(): Unit {
    ProxyInfo.forHttpProxy("asd", 80, "", "")
    let o = ProxyInfo.forSocks5Proxy("asd", 80, "", "")
    o.getProxyType()
    o.getProxyAddress()
    o.getProxyPort()
    o.getProxyUsername()
    o.getProxyPassword()
}

@Test
public func covProxyInfoProxyType(): Unit {
    @Assert(ProxyInfoProxyType.HTTP.toString(),"HTTP")
    @Assert(ProxyInfoProxyType.SOCKS4.toString(),"SOCKS4")
    @Assert(ProxyInfoProxyType.SOCKS5.toString(),"SOCKS5")
    @Assert(ProxyInfoProxyType.HTTP,ProxyInfoProxyType.HTTP)
    @Assert(ProxyInfoProxyType.SOCKS4,ProxyInfoProxyType.SOCKS4)
    @Assert(ProxyInfoProxyType.SOCKS5,ProxyInfoProxyType.SOCKS5)
    @Assert(ProxyInfoProxyType.SOCKS5!=ProxyInfoProxyType.SOCKS4)
}

@Test
public func covProxyType(): Unit {
    @Assert(ProxyType.HTTP.toString(),"HTTP")
    @Assert(ProxyType.SOCKS.toString(),"SOCKS")
    @Assert(ProxyType.DIRECT.toString(),"DIRECT")
    @Assert(ProxyType.HTTP,ProxyType.HTTP)
    @Assert(ProxyType.SOCKS,ProxyType.SOCKS)
    @Assert(ProxyType.DIRECT,ProxyType.DIRECT)
    @Assert(ProxyType.DIRECT!=ProxyType.SOCKS)
}

@Test
public func covSASLErrorException(): Unit {
    let o = SASLErrorException("", SaslNonzaSASLFailure(""), HashMap<String, String>())
    o.getSASLFailure()
    o.getMechanism()
    o.getTexts()
}

@Test
public func covAfterXStanzas(): Unit {
    let o = AfterXStanzas(2)
    o.toString()
}

@Test
public func covForEveryMessage(): Unit {
    ForEveryMessage.INSTANCE.toString()
}

@Test
public func covForEveryStanza(): Unit {
    let o = ForEveryStanza.INSTANCE
    o.accept(unsafe { zeroValue<Stanza>() })
    o.toString()
}

@Test
public func covForMatchingPredicateOrAfterXStanzas(): Unit {
    let o = ForMatchingPredicateOrAfterXStanzas(unsafe { zeroValue<StanzaFilter>() }, 2)
    o.toString()
}

@Test
public func covStreamPredicate(): Unit {
    let o = StreamPredicate.after5Stanzas()
}

@Test
public func covShortcutPredicates(): Unit {
    let o = ShortcutPredicates([])
    o.toString()
    o.addPredicate(StanzaIdFilter("asd"))
    o.removePredicate(StanzaIdFilter("zxc"))
    o.accept(StanzaBuilder.buildMessage().build())
}

@Test
public func covStreamManagementFeature(): Unit {
    let o = StreamManagementFeature.INSTANCE
    o.toXML(None)
}

@Test
public func covStreamManagementEnabled(): Unit {
    let o = StreamManagementEnabled("", true)
    o.getLocation()
    o.getElementName()
    o.toXML(None)
}

@Test
public func covStreamManagementFailed(): Unit {
    let o = StreamManagementFailed()
    o.getStanzaErrorCondition()
    o.getElementName()
    o.getNamespace()
    o.toXML(None)
}

@Test
public func covStreamManagementResumed(): Unit {
    let o = StreamManagementResumed(2, "")
    o.getElementName()
    o.getHandledCount()
    o.getPrevId()
}

@Test
public func covStreamManagementAckRequest(): Unit {
    let o = StreamManagementAckRequest.INSTANCE
    o.getElementName()
    o.getNamespace()
}

@Test
public func covStreamManagementException(): Unit {
    // StreamManagementException()
    // StreamManagementException("")

    StreamManagementNotEnabledException().toString()
    StreamIdDoesNotMatchException("", "").toString()

    let o = StreamManagementCounterError(1, 1, 1, ArrayList<Stanza>())
    o.toString()
    o.getHandledCount()
    o.getPreviousServerHandledCount()
    o.getAckedStanzaCount()
    o.getOutstandingStanzasCount()
    o.getAckedStanzas()
    o.getClassName()

    let q = StreamManagementUnacknowledgedQueueFullException.newWith(1, ArrayList<Element>(),
        CollectionBlockingQueue<Stanza>(1))
    q.toString()
    q.getOverflowElementNum()
    q.getDroppedElements()
    q.getElements()
    q.getUnacknowledgesStanzas()
    q.getClassName()
}

@Test
public func covOnceForThisStanza(): Unit {
    let o = OnceForThisStanza.setup(conn, StanzaBuilder.buildMessage("asd").build())
    // o.toString()
    // o.accept(StanzaBuilder.buildMessage().build())
}

@Test
public func covRemoteXmppTcpConnectionEndpointsDomainType(): Unit {
    // let server = RemoteXmppTcpConnectionEndpointsDomainType.server
    // let client = RemoteXmppTcpConnectionEndpointsDomainType.client
    // @Assert(server,server)
    // @Assert(client,client)
    // @Assert(server!=client)
    // server.fromString()
    // client.fromString()
    // server.toString()
    // client.toString()
}

@Test
public func covRemoteXmppTcpConnectionEndpoints(): Unit {
    let o = RemoteXmppTcpConnectionEndpoints.resolveXmppServerDomain("",
        ArrayList<RemoteConnectionEndpointLookupFailure>(), DnssecMode.disabled)
}

@Test
public func covPacketParserUtils(): Unit {
    var parser = getParser("<p/>")
    parser.next()
    @AssertThrows[IllegalArgumentException](PacketParserUtils.parseStanza(parser, XmlEnvironment.EMPTY))

    PacketParserUtils.parseElementText(parser)

    parser = getParser("<p><p>")
    parser.next()
    @AssertThrows[XmlPullParserException](PacketParserUtils.parseElementText(parser))

    parser = getParser("<p>asd<p>")
    parser.next()
    @AssertThrows[XmlPullParserException](PacketParserUtils.parseElementText(parser))

    parser = getParser("<p>asd</p>")
    PacketParserUtils.parseContentDepth(parser, 1)

    parser = getParser("<body>asd</body>")
    parser.next()
    PacketParserUtils.parseExtensionElement(MessageBody.ELEMENT, MessageBody.NAMESPACE, parser, None)

    parser = getParser("<body>asd</body>")
    parser.next()
    PacketParserUtils.parseExtensionElement("", "", parser, None)

    parser = getParser('<required xmlns="urn:ietf:params:xml:ns:xmpp-tls"><a>asd</a></required>')
    parser.next()
    PacketParserUtils.parseStartTlsFeature(parser)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage(), parser, None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage(), parser, "", "", None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage().build(), parser, None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage().build(), parser, "", "", None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(ArrayList<ExtensionElement>(), parser, None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(ArrayList<ExtensionElement>(), parser, "", "", None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.parseDescriptiveTexts(parser, HashMap<String, String>())
}

@Test
public func covConn3(): Unit {
    let conn = AbstractXMPPConnection0(config)
    conn.trySendStanza(StanzaBuilder.buildMessage().build())
    @AssertThrows[AssertionError](conn.throwCurrentConnectionException1())
    conn.setCurrentConnectionExceptionAndNotify1(FailedNonzaException(Compressed.INSTANCE))
    @AssertThrows[FailedNonzaException](conn.throwCurrentConnectionException1())
    conn.getConnectionLock1()
    @AssertThrows[NoneValueException](conn.initDebugger1())
    
    var parser = getParser("<p/>")
    parser.next()
    conn.parseAndProcessNonza1(parser)
    @AssertThrows[Exception](conn.parseAndProcessStanza1(parser))
}
