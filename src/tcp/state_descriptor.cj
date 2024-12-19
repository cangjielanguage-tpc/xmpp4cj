/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

class EstablishingTcpConnectionStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "EstablishingTcpConnectionState",
                {
                    args => EstablishingTcpConnectionState(
                        (args[0] as XmppTcpTransportModule)(),
                        (args[1] as EstablishingTcpConnectionStateDescriptor)(),
                        (args[2] as C2sConnectionInternal)()
                    )
                }
            )
        )
        addPredeccessor(LookupRemoteConnectionEndpointsStateDescriptor())
        addSuccessor(EstablishTlsStateDescriptor())
        addSuccessor(ConnectedButUnauthenticatedStateDescriptor())
    }

    protected override func constructState(connectionInternal: C2sConnectionInternal): EstablishingTcpConnectionState {
        let tcpTransportModule: XmppTcpTransportModule = connectionInternal
            .connection
            .getConnectionModuleFor("XmppTcpTransportModuleDescriptor")
        return tcpTransportModule.constructEstablishingTcpConnectionState(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        "EstablishingTcpConnectionStateDescriptor"
    }
}

class EstablishingTcpConnectionState <: State {
    let tcpmod: XmppTcpTransportModule

    init(
        xmppTcpTransportModule: XmppTcpTransportModule,
        stateDescriptor: EstablishingTcpConnectionStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        super(stateDescriptor, connectionInternal)
        this.tcpmod = xmppTcpTransportModule
    }

    // throws InterruptedException, IOException, Xmpp4cjException, XMPPException
    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        // The fields inetSocketAddress and failedAddresses are handed over from LookupHostAddresses to ConnectingToHost.
        let connectionAttemptState = ConnectionAttemptState(connectionInternal, tcpmod.discoveredTcpEndpoints(), this)
        let failure = connectionAttemptState.establishTcpConnection()
        if (let Some(v) <- failure) {
            return v
        }

        tcpmod.socketChannel = connectionAttemptState.socketChannel
        tcpmod.remoteAddress = connectionAttemptState.socketChannel.remoteAddress

        tcpmod.selectionKey = connectionInternal.registerWithSelector(connectionAttemptState.socketChannel,
            SelectionKey.OP_READ, tcpmod.onChannelSelected)
        tcpmod.selectionKeyAttachment = tcpmod.selectionKey().attachment() as SelectionKeyAttachment

        connectionInternal.setTransport(tcpmod.tcpNioTransport())
        connectionInternal.newStreamOpenWaitForFeaturesSequence("stream features after initial connection")

        return TcpSocketConnectedResult(tcpmod.remoteAddress())
    }

    public override func resetState(): Unit {
        tcpmod.closeSocketAndCleanup()
    }
}

class EstablishTlsStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "EstablishTlsState",
                {
                    args => EstablishTlsState(
                        (args[0] as XmppTcpTransportModule)(),
                        (args[1] as EstablishTlsStateDescriptor)(),
                        (args[2] as C2sConnectionInternal)()
                    )
                }
            ),
            "RFC 6120 § 5"
        )
        addSuccessor(ConnectedButUnauthenticatedStateDescriptor())
        declarePrecedenceOver(ConnectedButUnauthenticatedStateDescriptor())
    }

    public override func constructState(connectionInternal: C2sConnectionInternal): EstablishTlsState {
        let tcpTransportModule: XmppTcpTransportModule = connectionInternal
            .connection
            .getConnectionModuleFor("XmppTcpTransportModuleDescriptor")
        return tcpTransportModule.constructEstablishingTlsState(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        "EstablishTlsStateDescriptor"
    }
}

class EstablishTlsState <: State {
    let tcpmod: XmppTcpTransportModule

    init(
        tcpmod: XmppTcpTransportModule,
        stateDescriptor: EstablishTlsStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        super(stateDescriptor, connectionInternal)
        this.tcpmod = tcpmod
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        let startTlsFeature: ?StartTls = (connectionInternal
            .connection
            .getFeature("StartTls")
            .map {e => e as StartTls})
            .flatten()
        let securityMode = connectionInternal.connection.getConfiguration().getSecurityMode()
        match (securityMode) {
            case ConnectionConfigurationSecurityMode.required | ConnectionConfigurationSecurityMode.ifpossible =>
                if (startTlsFeature.isNone()) {
                    if (securityMode == ConnectionConfigurationSecurityMode.ifpossible) {
                        return TransitionImpossibleReason(
                            "Server does not announce support for TLS and we do not required it")
                    }
                    throw SecurityRequiredByClientException()
                }
                return None
            case ConnectionConfigurationSecurityMode.disabled =>
                if (startTlsFeature?.requiredMethod() ?? false) {
                    throw SecurityRequiredByServerException()
                }
                return TransitionImpossibleReason("TLS disabled in client settings and server does not require it")
        }
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        connectionInternal.sendAndWaitForResponse(StartTls.INSTANCE, "TlsProceed", "TlsFailure")
        let xmppTlsContext = connectionInternal.getXmppTlsContext()
        let tlsState = TlsState(tcpmod, xmppTlsContext)
        tcpmod.tlsState = tlsState
        connectionInternal.addXmppInputOutputFilter(tlsState)
        tcpmod.channelSelectedCallbackLock.lock()
        try {
            tcpmod.pendingOutputFilterData = true
            tlsState.engine.beginHandshake()
            tlsState.handshakeStatus = TlsHandshakeStatus.initiated
        } finally {
            tcpmod.channelSelectedCallbackLock.unlock()
        }
        connectionInternal.setInterestOps(tcpmod.selectionKey(), SelectionKey.OP_WRITE | SelectionKey.OP_READ)
        try {
            tlsState.waitForHandshakeFinished()
        } catch (e: CertificateException) {
            throw XmppCertificateException(e)
        }
        connectionInternal.newStreamOpenWaitForFeaturesSequence("stream features after TLS established")
        return TlsEstablishedResult(tlsState.engine)
    }

    public override func resetState(): Unit {
        tcpmod.tlsState = None
    }
}
