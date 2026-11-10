// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_Xmpp4cjException1(): Unit {
    let xmpp4cjException0: TestXmpp4cjException = TestXmpp4cjException(TestXmpp4cjException())
    @Assert("Xmpp4cjException", xmpp4cjException0.toString())

    let xmpp4cjException1: TestXmpp4cjException = TestXmpp4cjException("ERROR")
    @Assert("Xmpp4cjException: ERROR", xmpp4cjException1.toString())

    let xmpp4cjException2: TestXmpp4cjException = TestXmpp4cjException("ERROR", TestXmpp4cjException())
    @Assert("Xmpp4cjException: ERROR", xmpp4cjException2.toString())

    let xmpp4cjException3: TestXmpp4cjException = TestXmpp4cjException()
    @Assert("Xmpp4cjException", xmpp4cjException3.toString())
}

class TestXmpp4cjException <: Xmpp4cjException {
    init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }

    init(message: String) {
        super(message)
    }

    init(message: String, wrappedThrowable: ?Exception) {
        super(message, wrappedThrowable)
    }

    init() {
        super()
    }
}

@Test
public func test_NotLoggedInException1(): Unit {
    let notLoggedInException: NotLoggedInException = NotLoggedInException()
    @Assert("NotLoggedInException: Client is not logged in", notLoggedInException.toString())
}

@Test
public func test_AlreadyLoggedInException1(): Unit {
    let alreadyLoggedInException: AlreadyLoggedInException = AlreadyLoggedInException()
    @Assert("AlreadyLoggedInException: Client is already logged in", alreadyLoggedInException.toString())
}

@Test
public func test_AlreadyConnectedException1(): Unit {
    let alreadyConnectedException: AlreadyConnectedException = AlreadyConnectedException()
    @Assert("AlreadyConnectedException: Client is already connected", alreadyConnectedException.toString())
}

@Test
public func test_IllegalStateChangeException1(): Unit {
    let illegalStateChangeException: IllegalStateChangeException = IllegalStateChangeException()
    @Assert("IllegalStateChangeException", illegalStateChangeException.toString())
}

@Test
public func test_SecurityRequiredException1(): Unit {
    let securityRequiredException: TestSecurityRequiredException = TestSecurityRequiredException("ERROR")
    @Assert("SecurityRequiredException: ERROR", securityRequiredException.toString())
}

class TestSecurityRequiredException <: SecurityRequiredException {
    init(message: String) {
        super(message)
    }
}

@Test
public func test_SecurityRequiredByClientException1(): Unit {
    let securityRequiredByClientException: SecurityRequiredByClientException = SecurityRequiredByClientException()
    @Assert("SecurityRequiredByClientException: SSL/TLS required by client but not supported by server", securityRequiredByClientException.toString())
}

@Test
public func test_SecurityRequiredByServerException1(): Unit {
    let securityRequiredByServerException: SecurityRequiredByServerException = SecurityRequiredByServerException()
    @Assert("SecurityRequiredByServerException: SSL/TLS required by server but disabled in client", securityRequiredByServerException.toString())
}

@Test
public func test_SecurityNotPossibleException1(): Unit {
    let securityNotPossibleException: SecurityNotPossibleException = SecurityNotPossibleException("ERROR")
    @Assert("SecurityNotPossibleException: ERROR", securityNotPossibleException.toString())
}

@Test
public func test_ConnectionException1(): Unit {
    let connectionException0: TestConnectionException = TestConnectionException(TestConnectionException("ERROR"))
    @Assert("ConnectionException: ERROR", connectionException0.toString())
    let connectionException1: TestConnectionException = TestConnectionException("ERROR")
    @Assert("ConnectionException: ERROR", connectionException1.toString())
}

class TestConnectionException <: ConnectionException {
    init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }

    init(message: String) {
        super(message)
    }
}

@Test
public func test_GenericConnectionException1(): Unit {
    let genericConnectionException: GenericConnectionException = GenericConnectionException(
        SecurityNotPossibleException("ERROR"))
    @Assert("GenericConnectionException: ERROR", genericConnectionException.toString())
}

@Test
public func test_EndpointConnectionException1(): Unit {
    let e0 = EndpointConnectionException.comefrom(
        ArrayList<RemoteConnectionEndpointLookupFailure>(),
        ArrayList<RemoteConnectionException<RemoteConnectionEndpoint>>()
    )
}

@Test
public func test_FeatureNotSupportedException1(): Unit {
    let featureNotSupportedException0: FeatureNotSupportedException = FeatureNotSupportedException("ERROR")
    @Assert("FeatureNotSupportedException: ERROR not supported", featureNotSupportedException0.toString())
    @Assert("ERROR", featureNotSupportedException0.getFeature())
    @Assert(None, featureNotSupportedException0.getJid())
    let featureNotSupportedException1: FeatureNotSupportedException = FeatureNotSupportedException("ERROR", None)
    @Assert("FeatureNotSupportedException: ERROR not supported", featureNotSupportedException1.toString())
    @Assert("ERROR", featureNotSupportedException1.getFeature())
    @Assert(None, featureNotSupportedException1.getJid())
    let domain = "foo.bar."
    let jid = JidCreate.domainBareFrom(domain)
    let featureNotSupportedException2: FeatureNotSupportedException = FeatureNotSupportedException("ERROR", jid)
    @Assert("ERROR", featureNotSupportedException2.getFeature())
    @Assert("foo.bar.", featureNotSupportedException2.getJid().getOrThrow().toString())
}

@Test
public func test_ResourceBindingNotOfferedException1(): Unit {
    let resourceBindingNotOfferedException: ResourceBindingNotOfferedException = ResourceBindingNotOfferedException()
    @Assert("ResourceBindingNotOfferedException: Resource binding was not offered by server", resourceBindingNotOfferedException.toString())
}

@Test
public func test_XmppWrappedException1(): Unit {
    let xmppWrappedException0: XmppWrappedException = XmppWrappedException(FeatureNotSupportedException("ERROR"))
    @Assert("XmppWrappedException: ERROR not supported", xmppWrappedException0.toString())
    let xmppWrappedException1: XmppWrappedException = XmppWrappedException("ERROR",
        FeatureNotSupportedException("ERROR"))
    @Assert("XmppWrappedException: ERROR", xmppWrappedException1.toString())
}

@Test
public func test_XmppMessageException1(): Unit {
    let xmppMessageException: XmppMessageException = XmppMessageException("ERROR")
    @Assert("XmppMessageException: ERROR", xmppMessageException.toString())
}

@Test
public func test_XmppSaslException1(): Unit {
    let xmppSaslException0: XmppSaslException = XmppSaslException(XmppMessageException("ERROR"))
    @Assert("XmppSaslException: ERROR", xmppSaslException0.toString())
    let xmppSaslException1: XmppSaslException = XmppSaslException("ERROR", XmppMessageException("ERROR"))
    @Assert("XmppSaslException: ERROR", xmppSaslException1.toString())
    @Assert("XmppMessageException: ERROR", xmppSaslException1.getCause().getOrThrow().toString())
    let xmppSaslException2: XmppSaslException = XmppSaslException("ERROR")
    @Assert("XmppSaslException: ERROR", xmppSaslException2.toString())
}

@Test
public func test_XmppCertificateException1(): Unit {
    let certificateException: CertificateException = CertificateException("CertificateException")
    let xmppCertificateException: XmppCertificateException = XmppCertificateException(certificateException)
    @Assert("XmppCertificateException", xmppCertificateException.toString())
}

@Test
public func test_XMPPException1(): Unit {
    let xmppException0: TestXMPPException = TestXMPPException()
    @Assert("XMPPException", xmppException0.toString())
    @Assert("", xmppException0.getMessage())
    let xmppException1: TestXMPPException = TestXMPPException("ERROR")
    @Assert("XMPPException: ERROR", xmppException1.toString())
    @Assert("ERROR", xmppException1.getMessage())
    let xmppException2: TestXMPPException = TestXMPPException("ERROR", TestXMPPException())
    @Assert("XMPPException: ERROR", xmppException2.toString())
    @Assert("ERROR", xmppException2.getMessage())
}

class TestXMPPException <: XMPPException {
    init() {
        super()
    }

    init(message: String) {
        super(message)
    }

    init(message: String, wrappedThrowable: ?Exception) {
        super(message, wrappedThrowable)
    }
}

@Test
public func test_XMPPErrorException1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let error: StanzaError = StanzaError.getBuilder().setCondition(StanzaErrorCondition.bad_request).build()
    let xmppErrorException0: XMPPErrorException = XMPPErrorException(packet, error)
    @Assert(None, xmppErrorException0.getStanzaError().getErrorGenerator())
    match (xmppErrorException0.getStanza()) {
        case None => @Assert(false)
        case _ => @Assert(true)
    }
    match (xmppErrorException0.getRequest()) {
        case None => @Assert(true)
        case _ => @Assert(false)
    }
    @Assert("XMPPError: bad-request - modify", xmppErrorException0.getMessage())
    @Assert("XMPPErrorException", xmppErrorException0.toString())
    XMPPErrorException.ifHasErrorThenThrow(packet)

    let xmppErrorException1: XMPPErrorException = XMPPErrorException(packet, error, packet)
    @Assert("XMPPError: bad-request - modify as result of the following request: Message Stanza []", xmppErrorException1.getMessage())
    @Assert("XMPPErrorException", xmppErrorException1.toString())

    XMPPErrorException.ifHasErrorThenThrow(packet, packet)
}

@Test
public func test_FailedNonzaException1(): Unit {
    let failedNonzaException0: FailedNonzaException = FailedNonzaException(Compress("Compress"))
    @Assert("FailedNonzaException", failedNonzaException0.toString())
    @Assert(None, failedNonzaException0.getCondition())
    @Assert("compress", failedNonzaException0.getNonza().getElementName())
    let failedNonzaException1: FailedNonzaException = FailedNonzaException(Compress("Compress"), None)
    @Assert("FailedNonzaException", failedNonzaException1.toString())
    @Assert(None, failedNonzaException1.getCondition())
    @Assert("compress", failedNonzaException1.getNonza().getElementName())
}

@Test
public func test_StreamErrorException1(): Unit {
    let streamErrorException: StreamErrorException = StreamErrorException(
        StreamError(None, None, None, ArrayList<ExtensionElement>()))
    @Assert("StreamErrorException: None You can read more about the meaning of this stream error at http://xmpp.org/rfcs/rfc6120.html#streams-error-conditions\n<stream:error><None xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error>", streamErrorException.toString())
    @Assert("<stream:error><None xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error>", streamErrorException.getStreamError().toString())
}
