/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.tcp

class TlsState <: XmppInputOutputFilter {
    let tcpmod: XmppTcpTransportModule

    private static let MAX_PENDING_OUTPUT_BYTES = 8096

    private let xmppTlsContext: XmppTlsContext

    let engine: SSLEngine
    var TlsSession: ?TlsSession = None

    var handshakeStatus: TlsHandshakeStatus = TlsHandshakeStatus.initial

    private var handshakeException: ?SSLException = None

    private var myNetData: ByteBuffer
    private var peerAppData: ByteBuffer

    private let pendingOutputData = ArrayList<ByteBuffer>()

    private var pendingOutputBytes: Int64 = 0

    var pendingInputData: ?ByteBuffer = None

    private let pendingDelegatedTasks = AtomicInt64(0)

    var wrapInBytes: Int64 = 0

    var wrapOutBytes: Int64 = 0

    var unwrapInBytes: Int64 = 0

    var unwrapOutBytes: Int64 = 0

    init(tcpmod: XmppTcpTransportModule, xmppTlsContext: XmppTlsContext) {
        this.tcpmod = tcpmod
        this.xmppTlsContext = xmppTlsContext

        let peerHost: String = tcpmod
            .connectionInternal
            .connection
            .getConfiguration()
            .getXMPPServiceDomain()
            .toString()
        engine = xmppTlsContext.createSSLEngine(peerHost, tcpmod.remoteAddress().port)

        // TODO
        // let session = engine.getSession()
        // let applicationBufferSize = session.getApplicationBufferSize()
        // let packetBufferSize = session.getPacketBufferSize()
        myNetData = ByteBuffer()
        peerAppData = ByteBuffer()
    }

    public func output(outputData: ?ByteBuffer, isFinalDataOfElement: Bool, destinationAddressChanged: Bool,
        moreDataAvailable: Bool): XmppInputOutputFilterOutputResult {
        // if (let Some(outputData) <- outputData) {
        //     pendingOutputData.append(outputData)
        //     pendingOutputBytes += outputData.remainLength
        //     if (moreDataAvailable && pendingOutputBytes < MAX_PENDING_OUTPUT_BYTES) {
        //         return XmppInputOutputFilterOutputResult.NO_OUTPUT
        //     }
        // }
        // let outputDataArray = pendingOutputData.toArray()
        // myNetData.clear()
        // while (true) {
        //     let result: SSLEngineResult
        //     try {
        //         result = engine.wrap(outputDataArray, myNetData)
        //     } catch (e: SSLException) {
        //         handleSslException(e)
        //         throw e
        //     }
        //     XmppTcpTransportModule.debugLogSslEngineResult("wrap", result)
        //     let engineResultStatus = result.getStatus()
        //     pendingOutputBytes -= result.bytesConsumed()
        //     if (engineResultStatus == SSLEngineResultStatus.OK) {
        //         wrapInBytes += result.bytesConsumed()
        //         wrapOutBytes += result.bytesProduced()
        //         let handshakeStatus = handleHandshakeStatus(result)
        //         match (handshakeStatus) {
        //             case NEED_UNWRAP => ()
        //             case NEED_WRAP | NEED_TASK => return OutputResult(true, myNetData)
        //             case _ => ()
        //         }
        //     }
        //     match (engineResultStatus) {
        //         case OK =>
        //             pruneBufferList(pendingOutputData)
        //             return OutputResult(!pendingOutputData.isEmpty(), myNetData)
        //         case CLOSED =>
        //             pendingOutputData.clear()
        //             return OutputResult.NO_OUTPUT
        //         case BUFFER_OVERFLOW =>
        //             LOGGER.warning("SSLEngine status BUFFER_OVERFLOW, this is hopefully uncommon")
        //             let outputDataRemaining = outputData?.remainLength ?? 0
        //             let newCapacity = Int64(1.3 * Float64(outputDataRemaining))
        //             // If newCapacity would not increase myNetData, then double it.
        //             if (newCapacity <= myNetData.capacity()) {
        //                 newCapacity = 2 * myNetData.capacity()
        //             }
        //             let newMyNetData = ByteBuffer(newCapacity)
        //             newMyNetData.put(myNetData)
        //             myNetData = newMyNetData
        //             continue
        //         case BUFFER_UNDERFLOW => throw IllegalStateException(
        //             "Buffer underflow as result of SSLEngine.wrap() should never happen")
        //     }
        // }
        throw Exception("TODO")
    }

    public override func input(inputData: ByteBuffer): ?ByteBuffer {
        let accumulatedData: ByteBuffer
        // if (pendingInputData.isEmpty()) {
        //     accumulatedData = inputData
        // } else {
        //     if (!(!refEq(pendingInputData, inputData))) {
        //         throw AssertionError()
        //     }
        //     let accumulatedDataBytes = pendingInputData.remainLength + inputData.remainLength
        //     accumulatedData = ByteBuffer(accumulatedDataBytes)
        //     accumulatedData.put(pendingInputData).put(inputData).flip()
        //     pendingInputData = None
        // }
        // peerAppData.clear()
        // while (true) {
        //     let result: SSLEngineResult
        //     try {
        //         result = engine.unwrap(accumulatedData, peerAppData)
        //     } catch (e: SSLException) {
        //         handleSslException(e)
        //         throw e
        //     }
        //     XmppTcpTransportModule.debugLogSslEngineResult("unwrap", result)
        //     let engineResultStatus = result.getStatus()
        //     if (refEq(engineResultStatus, SSLEngineResult_Status.OK)) {
        //         unwrapInBytes += result.bytesConsumed()
        //         unwrapOutBytes += result.bytesProduced()
        //         let handshakeStatus = handleHandshakeStatus(result)
        //     }
        // }
        throw Exception("TODO")
    }

    private func addAsPendingInputData(byteBuffer: ByteBuffer): Unit {
        let pendingInputData = ByteBuffer(byteBuffer.remainLength)
        this.pendingInputData = pendingInputData
        copy(byteBuffer, to: pendingInputData)
        tcpmod.pendingInputFilterData = pendingInputData.remainLength > 0
    }

    private func handleHandshakeStatus(sslEngineResult: SSLEngineResult): HandshakeStatus {
        let handshakeStatus = sslEngineResult.getHandshakeStatus()
        match (handshakeStatus) {
            case NEED_TASK => while (true) {
                let delegatedTask: Runnable = engine.getDelegatedTask() ?? break
                tcpmod.sslEngineDelegatedTasks++
                let currentPendingDelegatedTasks = pendingDelegatedTasks.fetchAdd(1)
                if (currentPendingDelegatedTasks > tcpmod.maxPendingSslEngineDelegatedTasks) {
                    tcpmod.maxPendingSslEngineDelegatedTasks = currentPendingDelegatedTasks
                }

                let wrappedDelegatedTask: Runnable = {
                    =>
                    delegatedTask()
                    let wrappedCurrentPendingDelegatedTasks = pendingDelegatedTasks.fetchSub(1)
                    if (wrappedCurrentPendingDelegatedTasks == 0) {
                        tcpmod.callChannelSelectedCallback(true, true)
                    }
                }
                tcpmod.connectionInternal.asyncGo(wrappedDelegatedTask)
            }
            case FINISHED => onHandshakeFinished()
            case _ => ()
        }
        let afterHandshakeStatus = engine.getHandshakeStatus()
        return afterHandshakeStatus
    }

    private func handleSslException(e: SSLException): Unit {
        handshakeException = e
        handshakeStatus = TlsHandshakeStatus.failed
        tcpmod.connectionInternal.notifyWaitingThreads()
    }

    private func onHandshakeFinished(): Unit {
        handshakeStatus = TlsHandshakeStatus.successful
        tcpmod.connectionInternal.notifyWaitingThreads()
    }

    func isHandshakeFinished(): Bool {
        return handshakeStatus == TlsHandshakeStatus.successful || handshakeStatus == TlsHandshakeStatus.failed
    }

    // throws InterruptedException, CertificateException, SSLException, XmppException, XMPPException
    public func waitForHandshakeFinished(): Unit {
        tcpmod
            .connectionInternal
            .waitForConditionOrThrowConnectionException({=> isHandshakeFinished()}, "TLS handshake to finish")
        if (handshakeStatus == TlsHandshakeStatus.failed) {
            throw handshakeException()
        }
        assert(handshakeStatus == TlsHandshakeStatus.successful)

        xmppTlsContext.daneVerifier?.finish(engine.getSession())
    }

    public override func getStats(): Object {
        return TlsStateStats(this)
    }

    public override func closeInputOutput(): Unit {
        engine.closeOutbound()
        try {
            engine.closeInbound()
        } catch (e: SSLException) {
            XmppTcpTransportModule
                .LOGGER
                .log(
                    LogLevel.TRACE,
                    "SSLException when closing inbound TLS session. This can likely be ignored if a possible truncation attack is suggested. You may want to ask your XMPP server vendor to implement a clean TLS session shutdown sending close_notify after </stream>",
                    e
                )
        }
    }

    public override func waitUntilInputOutputClosed(): Unit {
        waitForHandshakeFinished()
    }

    public override func getFilterName(): String {
        return "TLS (${engine})"
    }
}

public class TlsStateStats <: ToString {
    public let wrapInBytes: Int64

    public let wrapOutBytes: Int64

    public let wrapRatio: Float64

    public let unwrapInBytes: Int64

    public let unwrapOutBytes: Int64

    public let unwrapRatio: Float64

    init(tlsState: TlsState) {
        wrapOutBytes = tlsState.wrapOutBytes
        wrapInBytes = tlsState.wrapInBytes
        wrapRatio = Float64(wrapOutBytes) / Float64(wrapInBytes)
        unwrapOutBytes = tlsState.unwrapOutBytes
        unwrapInBytes = tlsState.unwrapInBytes
        unwrapRatio = Float64(unwrapInBytes) / Float64(unwrapOutBytes)
    }

    private var toStringCache: ?String = None

    public override func toString(): String {
        toStringCache ??
            {
            =>
            let str = "wrap-in-bytes: ${wrapInBytes}\nwrap-out-bytes: ${wrapOutBytes}\nwrap-ratio: ${wrapRatio}\nunwrap-in-bytes: ${unwrapInBytes}\nunwrap-out-bytes: ${unwrapOutBytes}\nunwrap-ratio: ${unwrapRatio}\n"
            toStringCache = str
            str
        }()
    }
}

public enum TlsHandshakeStatus <: ToString & Equatable<TlsHandshakeStatus> {
    | initial
    | initiated
    | successful
    | failed

    public operator override func ==(that: TlsHandshakeStatus): Bool {
        match ((this, that)) {
            case (initial, initial) => true
            case (initiated, initiated) => true
            case (successful, successful) => true
            case (failed, failed) => true
            case _ => false
        }
    }

    public override func toString(): String {
        match (this) {
            case initial => "initial"
            case initiated => "initiated"
            case successful => "successful"
            case failed => "failed"
        }
    }
}
