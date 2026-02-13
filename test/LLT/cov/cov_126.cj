// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main
import std.net.*

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
public func covIQReplyFilter(): Unit {
    let emptyResultIQ = EmptyResultIQ()
    let domainBareJid = JidCreate.domainBareFromOrThrowUnchecked("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](IQReplyFilter(emptyResultIQ, None, domainBareJid))

    let session = Session()
    let user = JidCreate.entityFullFromOrThrowUnchecked("juliet@shakespeare.lit/asd")
    session.setTo(user)

    let local: ?EntityFullJid = user
    let jid = local?.asBareJid()
    println(jid)
    println(session.getTo())
    println(jid.getOrThrow() == session.getTo().getOrThrow())

    session.setTo(conn.getUser().getOrThrow())
    let iqReplyFilter = IQReplyFilter(session, conn.getUser(), conn.getXMPPServiceDomain())

    @AssertThrows[IllegalArgumentException](ErrorIQ.builder(None).build())

    let stanzaError = StanzaError(StanzaErrorCondition.gone, Some("conditionTextString"), Some("errorGenerator"),
        StanzaErrorType.WAIT, HashMap<String, String>(), Array<ExtensionElement>())
    let err = ErrorIQ.builder(stanzaError).build()
    err.setStanzaId(session.getStanzaId())

    println(iqReplyFilter.accept(err))
    println(session.getStanzaId())
    println(iqReplyFilter.toString())
}

@Test
public func covIQResultReplyFilter(): Unit {
    let iqPacket = Session()
    let obj = IQResultReplyFilter(iqPacket, conn.getUser(), conn.getXMPPServiceDomain())
    println(obj.toString())
    obj.accept(EmptyResultIQ())
}

@Test
public func covXmppTlsContext(): Unit {
    let obj = XmppTlsContext(TlsClientConfig(), None)
    try {
        obj.createSSLEngine("", 5222)
    } catch (_) {}
}

@Test
public func covCertificateException(): Unit {
    @Assert(CertificateException("asd").toString(),"CertificateException: asd")
}

@Test
public func covXMPPInputOutputStream(): Unit {
    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    @Assert(XMPPInputOutputStream.getFlushMethod(),XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
}

@Test
public func covXMPPInputOutputStreamFlushMethod(): Unit {
    @Assert(XMPPInputOutputStreamFlushMethod.FULL_FLUSH,XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    @Assert(XMPPInputOutputStreamFlushMethod.SYNC_FLUSH,XMPPInputOutputStreamFlushMethod.SYNC_FLUSH)
    @Assert(XMPPInputOutputStreamFlushMethod.FULL_FLUSH!=XMPPInputOutputStreamFlushMethod.SYNC_FLUSH)
}

class RemoteConnectionEndpoint1 <: RemoteConnectionEndpoint {
    public func getHost(): String {
        "host"
    }
    public func getPort(): UInt16 {
        0
    }
    public func getInetAddresses(): Collection<IPSocketAddress> {
        []
    }
    public func getDescription(): String {
        "desc"
    }
}

@Test
public func covEndpointConnectionException(): Unit {
    let fails: Collection<RemoteConnectionEndpointLookupFailure> = [DnsLookupFailure("asd", Exception("e"))]
    let es: Collection<RemoteConnectionException<RemoteConnectionEndpoint>> = [RemoteConnectionException(
        RemoteConnectionEndpoint1(), None, Exception("2"))]
    let obj = EndpointConnectionException.comefrom(fails, es)

    obj.getLookupFailures()
    obj.getConnectionExceptions()
    obj.toString()
}

@Test
public func covFeatureNotSupportedException(): Unit {
    let e = FeatureNotSupportedException("asd", None)
}

@Test
public func covXmppSaslException(): Unit {
    let e = XmppSaslException("asd").toString()
}

@Test
public func covXmppCertificateException(): Unit {
    let e = XmppCertificateException(CertificateException("cer"))
    e.toString()
    e.getCertificateException()
}

struct StanzaListenerStruct <: StanzaListener {
    public func processStanza(packet: Stanza): Unit {}
}

@Test
public func covStanzaListener(): Unit {
    let e = SimpleStanzaListener {_, _ => ()}
    let obj = StanzaListenerStruct()
    try {
        obj == e
    } catch (_) {}
}

@Test
public func covInetSocketAddressCoupling(): Unit {
    let rce = RemoteConnectionEndpoint1()
    let obj = InetSocketAddressCoupling(rce, None)
    obj.getRemoteConnectionEndpoint()
}

@Test
public func covRemoteConnectionEndpointLookupFailure(): Unit {
    let obj: RemoteConnectionEndpointLookupFailure = DnsLookupFailure("asd", Exception("e"))
    obj.getDescription()
    obj.getException()
    obj.getErrorMessage()
}

@Test
public func covDnsLookupFailure(): Unit {
    let o = DnsLookupFailure("asd", Exception("e"))
    @Assert(o.getDnsName(), "asd")
}

@Test
public func covRemoteConnectionException(): Unit {
    let o = RemoteConnectionException(RemoteConnectionEndpoint1(), None, Exception("2"))
    o.getAddress()
    o.getException()
    o.getErrorMessage()
    o.toString()
}

@Test
public func covIQRequestHandlerMode(): Unit {
    @Assert(IQRequestHandlerMode.sync.toString(), "sync")
    @Assert(IQRequestHandlerMode.async.toString(), "async")
    @Assert(IQRequestHandlerMode.sync,IQRequestHandlerMode.sync)
    @Assert(IQRequestHandlerMode.async, IQRequestHandlerMode.async)
    @Assert(IQRequestHandlerMode.async!=IQRequestHandlerMode.sync)
}

@Test
public func covDnssecMode(): Unit {
    DnssecMode.needsDnssec.toString()
    @Assert(DnssecMode.needsDnssec, DnssecMode.needsDnssec)
    DnssecMode.needsDnssecAndDane.toString()
    @Assert(DnssecMode.needsDnssecAndDane, DnssecMode.needsDnssecAndDane)
}

class DNSResolver0 <: DNSResolver {
    init(b: Bool) {
        super(b)
    }
    protected open func lookupHostAddress0(
        name: DnsName,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>,
        dnssecMode: DnssecMode
    ): ?Collection<IPAddress> {
        super.lookupHostAddress0(name, lookupFailures, dnssecMode)
    }
    protected static func shouldContinue(name: String, hostname: String, hostAddresses: ?Collection<IPAddress>): Bool {
        DNSResolver.shouldContinue(name, hostname, hostAddresses)
    }
}

@Test
public func covDNSResolver(): Unit {
    let o = DNSResolver0(false)
    @AssertThrows[UnsupportedException](o.lookupHostAddress0("asd",ArrayList(),DnssecMode.needsDnssec))
    @AssertThrows[UnsupportedException](o.lookupHostAddress("asd",ArrayList(),DnssecMode.needsDnssec))
    o.lookupHostAddress0("127.0.0", ArrayList(), DnssecMode.disabled)

    let arr: Collection<IPAddress> = []
    @Assert(DNSResolver0.shouldContinue("","", None))
    @Assert(DNSResolver0.shouldContinue("","", arr))
    @Assert(DNSResolver0.shouldContinue("","", IPAddress.resolve("localhost")),false)
}

@Test
public func covDNSUtil(): Unit {
    DNSUtil.setDNSResolver(DNSResolver0(true))
    DNSUtil.setDaneProvider({=> None})
    DNSUtil.getDaneProvider()
}

let config = XMPPTCPConnectionConfiguration
    .builder()
    .setXmppDomain(XmppTestServerHostName)
    .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    .performSaslAnonymousAuthentication()
    .build()

@Test
public func covZlibXmppInputOutputFilter(): Unit {
    let zlibXmppInputOutputFilter = ZlibXmppCompressionFactory.INSTANCE.fabricate(config)

    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.SYNC_FLUSH)
    zlibXmppInputOutputFilter.output(None, true, false, true) // XmppInputOutputFilterOutputResult.NO_OUTPUT
    zlibXmppInputOutputFilter.output(None, true, true, true) // XmppInputOutputFilterOutputResult.NO_OUTPUT

    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    @AssertThrows[Exception](zlibXmppInputOutputFilter.output(None, true, true, true))

    @Assert(zlibXmppInputOutputFilter.input(ByteBuffer()).isNone())
    @Assert(zlibXmppInputOutputFilter.getFilterName(),"Compression (zlib)")

    let stats = (zlibXmppInputOutputFilter.getStats() as ZlibXmppCompressionFactoryStats).getOrThrow()
    stats.toString()
    stats.toString()
    @Assert(stats==stats)
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
}

@Test
public func covReactor(): Unit {
    let o = AbstractXMPPConnection0(config)
    let reactor = o.getReactor0()
    @AssertThrows[IllegalArgumentException](reactor.setReactorThreadCount(-1))
}

class XmppInitializer0 <: XmppInitializer {}

@Test
public func covXmppInitializer(): Unit {
    let o = XmppInitializer0()
    @AssertThrows[UnsupportedException](o.initialize())
}

class XmppInitializer1 <: XmppInitializer {
    XmppInitializer1(let c: Int) {}
    public func initialize(): Collection<Exception> {
        let arr = ArrayList<Exception>()
        for (_ in 0..c) {
            arr.add(Exception("e"))
        }
        arr
    }
}

@Test
public func covXmppInitialization(): Unit {
    XMPP_CONFIG_STARTUP_CLASSES.add(("1", {=> Object()}))
    XMPP_CONFIG_OPTIONAL_STARTUP_CLASSES.add(("2", {=> Object()}))

    XmppInitialization.processConfigFile(ArrayList())

    XmppConfiguration.addDisabledXmppClass("3")
    XMPP_CONFIG_OPTIONAL_STARTUP_CLASSES.add(("3", {=> Object()}))
    XmppInitialization.processConfigFile(None)

    XMPP_CONFIG_STARTUP_CLASSES.add(("4", {=> throw Exception()}))
    XmppInitialization.processConfigFile(ArrayList())
    @AssertThrows[Exception](XmppInitialization.processConfigFile(None))

    XMPP_CONFIG_STARTUP_CLASSES.clear()
    XMPP_CONFIG_STARTUP_CLASSES.add(("5", {=> XmppInitializer1(0)}))
    XmppInitialization.processConfigFile(None)

    XMPP_CONFIG_STARTUP_CLASSES.clear()
    XMPP_CONFIG_STARTUP_CLASSES.add(("6", {=> XmppInitializer1(1)}))
    XmppInitialization.processConfigFile(None)
}

class ExceptionCallback0 <: ExceptionCallback<Exception> {
    public func processException(e: Exception): Unit {
        e.printStackTrace()
    }
}

@Test
public func covXmppFuture(): Unit {
    let f = InternalXmppFuture<Int, Exception>()
    @Assert(f.isCancelled(),false)
    @Assert(f.isDone(),false)
    f.onSuccess({_ => println(1)})
    f.onError(ExceptionCallback0())
    spawn {
        f.setResult(1)
    }
    @Assert(f.get(),1)

    let f2 = XmppFuture.comefrom(2)
    @Assert(f2.cancel(true),false)

    let f3 = InternalXmppFuture<Int, Exception>()
    @Assert(f3.cancel(true))
    @AssertThrows[CancellationException](f3.get())
    @AssertThrows[CancellationException](f3.getOrThrow())
    // @AssertThrows[CancellationException](f3.get(Duration.second))

    f3.setException(Exception())
    @AssertThrows[Exception](f3.get())
    @AssertThrows[Exception](f3.get(Duration.second))

    @AssertThrows[Exception](f3.get(Duration.second*-5))

    f3.setResult(3)
    @AssertThrows[Exception](f3.get(Duration.second))
}

@Test
public func covStanzaCollector(): Unit {
    let c = conn.createStanzaCollector(StanzaCollector.newConfiguration())
    c.getStanzaFilter()
    c.pollResult()
    c.nextResult()
    c.toString()
    spawn{c.pollResultOrThrow()}
    spawn{c.nextResultBlockForever()}
    c.getCollectedCount()
    c.close()
}

@Test
public func covStanzaCollectorConfiguration(): Unit {
    let c = StanzaCollector.newConfiguration()
    c.setSize(10)
    
    let c1 = conn.createStanzaCollector(StanzaCollector.newConfiguration())
    c.setCollectorToReset(c1)
}