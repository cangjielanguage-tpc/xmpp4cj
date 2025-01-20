/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

class XmppTcpNioTransport <: C2sTransport {
    let tcpMod: XmppTcpTransportModule

    init(tcpMod: XmppTcpTransportModule, connectionInternal: C2sConnectionInternal) {
        super(connectionInternal)
        this.tcpMod = tcpMod
    }

    protected override func resetDiscoveredConnectionEndpoints(): Unit {
        tcpMod.discoveredTcpEndpoints = None
    }

    protected override func lookupConnectionEndpoints(): ArrayList<XmppFuture<LookupConnectionEndpointsResult, Exception>> {
        assert(tcpMod.discoveredTcpEndpoints.isNone())

        let futures = ArrayList<XmppFuture<LookupConnectionEndpointsResult, Exception>>(2)
        let tcpEndpointsLookupFuture = InternalXmppFuture<LookupConnectionEndpointsResult, Exception>()
        connectionInternal.asyncGo(
            {
                =>
                let result = RemoteXmppTcpConnectionEndpoints.lookup(connectionInternal.connection.getConfiguration())
                let endpointsResult: LookupConnectionEndpointsResult = if (result
                    .discoveredRemoteConnectionEndpoints
                    .isEmpty()) {
                    TcpEndpointDiscoveryFailed(result)
                } else {
                    DiscoveredTcpEndpoints(result)
                }
                tcpEndpointsLookupFuture.setResult(endpointsResult)
            }
        )
        futures.add(tcpEndpointsLookupFuture)
        if (tcpMod.tcpModDescriptor.isDirectTlsEnabled()) {
            throw IllegalArgumentException("DirectTLS is not implemented yet")
        }
        return futures
    }

    protected override func loadConnectionEndpoints(lookupConnectionEndpointsSuccess: LookupConnectionEndpointsSuccess): Unit {
        tcpMod.discoveredTcpEndpoints = lookupConnectionEndpointsSuccess as DiscoveredTcpEndpoints
    }

    protected override func afterFiltersClosed(): Unit {
        tcpMod.pendingOutputFilterData = true
        tcpMod.pendingInputFilterData = true
        tcpMod.afterOutgoingElementsQueueModified()
    }

    protected override func disconnect(): Unit {
        tcpMod.closeSocketAndCleanup()
    }

    protected override func notifyAboutNewOutgoingElements(): Unit {
        tcpMod.afterOutgoingElementsQueueModified()
    }

    public override func getSslSession(): ?TlsSession {
        tcpMod.tlsState?.tlsSession ?? None
    }

    public override func isConnected(): Bool {
        tcpMod.socketChannel.isSome() // TODO
    }

    public override func isTransportSecured(): Bool {
        let tlsState = tcpMod.tlsState
        return tlsState?.handshakeStatus == TlsHandshakeStatus.successful
    }

    public override func getStats(): XmppTcpTransportModuleStats {
        return tcpMod.getStats()
    }
}

public class XmppTcpTransportModuleStats <: C2sTransportStats & ToString {
    public let totalBytesWritten: Int64

    public let totalBytesWrittenBeforeFilter: Int64

    public let writeRatio: Float64

    public let totalBytesRead: Int64

    public let totalBytesReadAfterFilter: Int64

    public let readRatio: Float64

    public let handledChannelSelectedCallbacks: Int64

    public let setWriteInterestAfterChannelSelectedCallback: Int64

    public let reactorThreadAlreadyRacing: Int64

    public let afterOutgoingElementsQueueModifiedSetInterestOps: Int64

    public let rejectedChannelSelectedCallbacks: Int64

    public let totalCallbackRequests: Int64

    public let callbackPreemtBecauseBytesWritten: Int64

    public let callbackPreemtBecauseBytesRead: Int64

    public let sslEngineDelegatedTasks: Int

    public let maxPendingSslEngineDelegatedTasks: Int

    init(connection: XmppTcpTransportModule) {
        super()
        totalBytesWritten = connection.totalBytesWritten
        totalBytesWrittenBeforeFilter = connection.totalBytesWrittenBeforeFilter
        writeRatio = Float64(totalBytesWritten) / Float64(totalBytesWrittenBeforeFilter)
        totalBytesReadAfterFilter = connection.totalBytesReadAfterFilter
        totalBytesRead = connection.totalBytesRead
        readRatio = Float64(totalBytesRead) / Float64(totalBytesReadAfterFilter)
        handledChannelSelectedCallbacks = connection.handledChannelSelectedCallbacks
        setWriteInterestAfterChannelSelectedCallback = connection.setWriteInterestAfterChannelSelectedCallback.load()
        reactorThreadAlreadyRacing = connection.reactorThreadAlreadyRacing.load()
        afterOutgoingElementsQueueModifiedSetInterestOps = connection
            .afterOutgoingElementsQueueModifiedSetInterestOps
            .load()
        rejectedChannelSelectedCallbacks = connection.rejectedChannelSelectedCallbacks.load()
        totalCallbackRequests = handledChannelSelectedCallbacks + rejectedChannelSelectedCallbacks
        callbackPreemtBecauseBytesRead = connection.callbackPreemtBecauseBytesRead
        callbackPreemtBecauseBytesWritten = connection.callbackPreemtBecauseBytesWritten
        sslEngineDelegatedTasks = connection.sslEngineDelegatedTasks
        maxPendingSslEngineDelegatedTasks = connection.maxPendingSslEngineDelegatedTasks
    }

    private var toStringCache: ?String = None

    public override func toString(): String {
        return if (let Some(v) <- toStringCache) {
            v
        } else {
            toStringCache = "Total bytes\nrecv: ${totalBytesRead}\nsend: ${totalBytesWritten}\nrecv-aft-filter: ${totalBytesReadAfterFilter}\nsend-bef-filter: ${totalBytesWrittenBeforeFilter}\nread-ratio: ${readRatio}\nwrite-ratio: ${writeRatio}\nEvents\ntotal-callback-requests: ${totalCallbackRequests}\nhandled-channel-selected-callbacks: ${handledChannelSelectedCallbacks}\nrejected-channel-selected-callbacks: ${rejectedChannelSelectedCallbacks}\nset-write-interest-after-callback: ${setWriteInterestAfterChannelSelectedCallback}\nreactor-thread-already-racing: ${reactorThreadAlreadyRacing}\nafter-queue-modified-set-interest-ops: ${afterOutgoingElementsQueueModifiedSetInterestOps}\ncallback-preemt-because-bytes-read: ${callbackPreemtBecauseBytesRead}\ncallback-preemt-because-bytes-written: ${callbackPreemtBecauseBytesWritten}\nssl-engine-delegated-tasks: ${sslEngineDelegatedTasks}\nmax-pending-ssl-engine-delegated-tasks: ${maxPendingSslEngineDelegatedTasks}\n"
            toStringCache.getOrThrow()
        }
    }
}

class DiscoveredTcpEndpoints <: LookupConnectionEndpointsSuccess {
    let result: RemoteXmppTcpConnectionEndpointsResult<Rfc6120TcpRemoteConnectionEndpoint>

    init(result: RemoteXmppTcpConnectionEndpointsResult<Rfc6120TcpRemoteConnectionEndpoint>) {
        this.result = result
    }
}

class TcpEndpointDiscoveryFailed <: LookupConnectionEndpointsFailed {
    let lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>

    init(result: RemoteXmppTcpConnectionEndpointsResult<Rfc6120TcpRemoteConnectionEndpoint>) {
        lookupFailures = result.lookupFailures
    }
}
