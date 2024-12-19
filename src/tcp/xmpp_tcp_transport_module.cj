/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public class XmppTcpTransportModule <: C2sConnectionModule {
    static let LOGGER = getGlobalLogger(("name", "XmppTcpTransportModule"))

    private static let CALLBACK_MAX_BYTES_READ = 10 * 1024 * 1024
    private static let CALLBACK_MAX_BYTES_WRITEN = CALLBACK_MAX_BYTES_READ

    private static let MAX_ELEMENT_SIZE = 64 * 1024

    var tcpNioTransport: ?XmppTcpNioTransport = None

    var selectionKey: ?SelectionKey = None
    var selectionKeyAttachment: ?SelectionKeyAttachment = None
    var socketChannel: ?SocketChannel = None
    var remoteAddress: ?IPSocketAddress = None

    var tlsState: ?TlsState = None

    private var outgoingCharSequenceIterator: ?ListIterator<String> = None

    private let currentlyOutgoingElements = ArrayList<TopLevelStreamElement>()
    private let bufferToElementMap: Map<ByteArrayStreamHashKey, ArrayList<TopLevelStreamElement>> = HashMap()

    private var outgoingBuffer: ?ByteBuffer = None
    private var filteredOutgoingBuffer: ?ByteBuffer = None
    private let networkOutgoingBuffers = ArrayList<ByteBuffer>()
    private var networkOutgoingBuffersBytes: Int64 = 0

    private let incomingBuffer = ByteBuffer(2 * 4096)

    let channelSelectedCallbackLock = ReentrantMutex()

    var totalBytesRead: Int64 = 0
    var totalBytesWritten: Int64 = 0
    var totalBytesReadAfterFilter: Int64 = 0
    var totalBytesWrittenBeforeFilter: Int64 = 0
    var handledChannelSelectedCallbacks: Int64 = 0
    var callbackPreemtBecauseBytesWritten: Int64 = 0
    var callbackPreemtBecauseBytesRead: Int64 = 0
    var sslEngineDelegatedTasks: Int = 0
    var maxPendingSslEngineDelegatedTasks: Int = 0

    let setWriteInterestAfterChannelSelectedCallback = AtomicInt64(0)
    let reactorThreadAlreadyRacing = AtomicInt64(0)
    let afterOutgoingElementsQueueModifiedSetInterestOps = AtomicInt64(0)
    let rejectedChannelSelectedCallbacks = AtomicInt64(0)

    private var lastDestinationAddress: ?Jid = None

    var pendingInputFilterData: Bool = false
    var pendingOutputFilterData: Bool = false

    private var pendingWriteInterestAfterRead: Bool = false

    private var splitter: Utf8ByteXmppXmlSplitter

    private var outputDebugSplitter: ?XmppXmlSplitter = None

    static let STREAM_OPEN_CLOSE_DEBUG_LOG_LEVEL = LogLevel.TRACE

    let tcpModDescriptor: XmppTcpTransportModuleDescriptor

    init(
        moduleDescriptor: XmppTcpTransportModuleDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        super(moduleDescriptor, connectionInternal)
        this.tcpModDescriptor = moduleDescriptor

        var incomingDebugPrettyPrinter: ?XmlPrinter = None
        let debugger = if (let Some(debugger) <- connectionInternal.xmppDebugger) {
            // Incoming stream debugging.
            incomingDebugPrettyPrinter = XmlPrettyPrinter
                .builder()
                .setPrettyWriter(PrettyPrintedXmlChunkSink {sb => debugger.incomingStreamSink(sb)})
                .build()
            // Outgoing stream debugging.
            let outgoingDebugPrettyPrinter = XmlPrettyPrinter
                .builder()
                .setPrettyWriter(PrettyPrintedXmlChunkSink {sb => debugger.outgoingStreamSink(sb)})
                .build()
            this.outputDebugSplitter = XmppXmlSplitter(outgoingDebugPrettyPrinter)
        }

        let xmppXmlSplitter = XmppXmlSplitter(MAX_ELEMENT_SIZE, xmppElementCallback, incomingDebugPrettyPrinter)
        this.splitter = Utf8ByteXmppXmlSplitter(xmppXmlSplitter)

        this.tcpNioTransport = XmppTcpNioTransport(this, connectionInternal)
        xmppElementCallback.tcpmod = this
    }

    private let xmppElementCallback: TcpmodXmppElementCallback = TcpmodXmppElementCallback()

    func onChannelSelected(selectedChannel: SelectableChannel, selectedSelectionKey: SelectionKey): Unit {
        assert(selectionKey.isNone() || selectionKey.filter {v => refEq(v, selectedSelectionKey)}.isSome())

        let selectedSocketChannel = (selectedChannel as SocketChannel)()
        var newInterestedOps = SelectionKey.OP_READ
        var newPendingOutputFilterData = false

        if (!channelSelectedCallbackLock.tryLock()) {
            rejectedChannelSelectedCallbacks.fetchAdd(1)
            return
        }

        handledChannelSelectedCallbacks++
        var callbackBytesRead = 0
        var callbackBytesWritten = 0

        try {
            var destinationAddressChanged = false
            var isLastPartOfElement = false
            var currentlyOutgonigTopLevelStreamElement: ?TopLevelStreamElement = None
            var outgoingStreamForDebugger: ?StringBuilder = None
            // writeLoop
            while (true) {
                let moreDataAvailable = !isLastPartOfElement || !connectionInternal.outgoingElementsQueue.isEmpty()
                if (filteredOutgoingBuffer.isSome() || !networkOutgoingBuffers.isEmpty()) {
                    if (let Some(out) <- filteredOutgoingBuffer) {
                        networkOutgoingBuffers.append(out)
                        networkOutgoingBuffersBytes += out.remainLength
                        filteredOutgoingBuffer = None
                        if (moreDataAvailable && networkOutgoingBuffersBytes < 8096) {
                            continue
                        }
                    }
                    let output = networkOutgoingBuffers.toArray()
                    let bytesWritten: Int64
                    try {
                        bytesWritten = selectedSocketChannel.write(output)
                    } catch (e: Exception) {
                        handleReadWriteIoException(e)
                        break
                    }
                    if (bytesWritten == 0) {
                        newInterestedOps |= SelectionKey.OP_WRITE
                        break
                    }
                    callbackBytesWritten += bytesWritten
                    networkOutgoingBuffersBytes -= bytesWritten
                    let prunedBuffers = pruneBufferList(networkOutgoingBuffers)
                    for (prunedBuffer in prunedBuffers) {
                        let sendElements = bufferToElementMap.remove(ByteArrayStreamHashKey(prunedBuffer)) ?? continue
                        for (elementJustSend in sendElements) {
                            connectionInternal.fireFirstLevelElementSendListeners(elementJustSend)
                        }
                    }
                    if (callbackBytesWritten > CALLBACK_MAX_BYTES_WRITEN) {
                        newInterestedOps |= SelectionKey.OP_WRITE
                        callbackPreemtBecauseBytesWritten++
                        break
                    }
                } else if (outgoingBuffer.isSome() || pendingOutputFilterData) {
                    pendingOutputFilterData = false
                    if (let Some(out) <- outgoingBuffer) {
                        totalBytesWrittenBeforeFilter += out.remainLength
                        if (isLastPartOfElement) {
                            assert(currentlyOutgonigTopLevelStreamElement.isSome())
                            currentlyOutgoingElements.append(currentlyOutgonigTopLevelStreamElement())
                        }
                    }
                    var outputFilterInputData = outgoingBuffer
                    outgoingBuffer = None
                    var breakWriteLoop = false

                    for (inputOutputFilter in connectionInternal.getXmppInputOutputFilterBeginIterator()) {
                        let outputResult: XmppInputOutputFilterOutputResult
                        try {
                            outputResult = inputOutputFilter.output(outputFilterInputData, isLastPartOfElement,
                                destinationAddressChanged, moreDataAvailable)
                        } catch (e: IOException) {
                            connectionInternal.notifyConnectionError(e)
                            breakWriteLoop = true
                            break
                        }
                        newPendingOutputFilterData = newPendingOutputFilterData || outputResult.pendingFilterData
                        outputFilterInputData = outputResult.filteredOutputData
                    }
                    if (breakWriteLoop) {
                        break
                    }

                    match (outputFilterInputData) {
                        case Some(v) where v.remainLength > 0 => filteredOutgoingBuffer = outputFilterInputData
                        case _ => filteredOutgoingBuffer = None
                    }

                    if (filteredOutgoingBuffer.isNone() && newPendingOutputFilterData) {
                        pendingWriteInterestAfterRead = true
                    }
                    if (filteredOutgoingBuffer.isSome() && isLastPartOfElement) {
                        bufferToElementMap.put(ByteArrayStreamHashKey(filteredOutgoingBuffer()),
                            ArrayList<TopLevelStreamElement>(currentlyOutgoingElements))
                        currentlyOutgoingElements.clear()
                    }
                    if (destinationAddressChanged) {
                        destinationAddressChanged = false
                    }
                } else if (let Some(iter) <- outgoingCharSequenceIterator) {
                    let nextCharSequence = iter.next()
                    outgoingBuffer = {
                        =>
                        let buf = ByteBuffer()
                        if (let Some(v) <- nextCharSequence) {
                            buf.write(unsafe { v.rawData() })
                        }
                        buf
                    }()
                    if (!iter.hasNext()) {
                        outgoingCharSequenceIterator = None
                        isLastPartOfElement = true
                    } else {
                        isLastPartOfElement = false
                    }
                    let debugger = connectionInternal.xmppDebugger
                    if (let Some(debugger) <- debugger) {
                        let outDebugger = if (let Some(v) <- outgoingStreamForDebugger) {
                            v
                        } else {
                            let v = StringBuilder()
                            outgoingStreamForDebugger = v
                            v
                        }
                        outDebugger.append(nextCharSequence ?? "")
                        if (isLastPartOfElement) {
                            try {
                                outputDebugSplitter?.append(outDebugger.toString())
                            } catch (e: IOException) {
                                throw AssertionError(e)
                            }
                            debugger.onOutgoingElementCompleted()
                            outgoingStreamForDebugger = None
                        }
                    }
                } else if (let Some(e) <- connectionInternal.outgoingElementsQueue.poll()) {
                    currentlyOutgonigTopLevelStreamElement = e
                    if (let Some(currentlyOutgoingStanza) <- (e as Stanza)) {
                        let currentDestinationAddress = currentlyOutgoingStanza.getTo()
                        destinationAddressChanged = !JidUtil.equals(lastDestinationAddress, currentDestinationAddress)
                        lastDestinationAddress = currentDestinationAddress
                    }
                    let nextCharSequence = e.toXML(StreamOpen.CLIENT_NAMESPACE)
                    if (let Some(xmlStringBuilder) <- (nextCharSequence as XmlStringBuilder)) {
                        let outgoingStreamXmlEnvironment = connectionInternal.getOutgoingStreamXmlEnvironment()
                        outgoingCharSequenceIterator = ListIterator(
                            xmlStringBuilder.toList(outgoingStreamXmlEnvironment) |> map {v => v.toString()})
                    } else {
                        outgoingCharSequenceIterator = ListIterator([nextCharSequence.toString()].iterator())
                    }
                    assert(outgoingCharSequenceIterator.isSome())
                } else {
                    break
                }
            }
            pendingOutputFilterData = newPendingOutputFilterData
            if (!pendingWriteInterestAfterRead && pendingOutputFilterData) {
                newInterestedOps |= SelectionKey.OP_WRITE
            }
            // readLoop
            while (true) {
                if (callbackBytesRead > CALLBACK_MAX_BYTES_READ) {
                    callbackPreemtBecauseBytesRead++
                    break
                }
                incomingBuffer.clear()
                let bytesRead: Int
                try {
                    bytesRead = selectedSocketChannel.read(incomingBuffer)
                } catch (e: IOException) {
                    handleReadWriteIoException(e)
                    return
                }
                if (bytesRead < 0) {
                    LOGGER.trace(
                        "NIO read() returned ${bytesRead} for ${"XmppTcpTransportModule"}. This probably means that the TCP connection was terminated."
                    )
                    return
                }
                if (!pendingInputFilterData) {
                    if (bytesRead == 0) {
                        break
                    }
                } else {
                    pendingInputFilterData = false
                }
                if (pendingWriteInterestAfterRead) {
                    pendingWriteInterestAfterRead = false
                    newInterestedOps |= SelectionKey.OP_WRITE
                }
                callbackBytesRead += bytesRead
                var filteredIncomingBuffer = incomingBuffer
                let it = connectionInternal.getXmppInputOutputFilterEndIterator()

                var breakReadLoop = false
                while (it.hasPrevious()) {
                    let newFilteredIncomingBuffer: ?ByteBuffer
                    try {
                        newFilteredIncomingBuffer = (it.previous()?.input(filteredIncomingBuffer)).flatten()
                    } catch (e: IOException) {
                        connectionInternal.notifyConnectionError(e)
                        return
                    }
                    if (let Some(v) <- newFilteredIncomingBuffer) {
                        filteredIncomingBuffer = v
                    } else {
                        breakReadLoop = true
                        break
                    }
                }
                if (breakReadLoop) {
                    break
                }

                let bytesReadAfterFilter = filteredIncomingBuffer.remainLength
                totalBytesReadAfterFilter += bytesReadAfterFilter
                try {
                    splitter.write(filteredIncomingBuffer)
                } catch (e: IOException) {
                    connectionInternal.notifyConnectionError(e)
                    return
                }
            }
        } finally {
            totalBytesWritten += callbackBytesWritten
            totalBytesRead += callbackBytesRead
            channelSelectedCallbackLock.unlock()
        }

        let selectionKeyAttachment = this.selectionKeyAttachment
        selectionKeyAttachment?.resetReactorThreadRacing()

        if (!connectionInternal.outgoingElementsQueue.isEmpty()) {
            setWriteInterestAfterChannelSelectedCallback.fetchAdd(1)
            newInterestedOps |= SelectionKey.OP_WRITE
        }
        connectionInternal.setInterestOps(selectionKey(), newInterestedOps)
    }

    private func handleReadWriteIoException(e: Exception): Unit {
        if (e is ClosedChannelException && !tcpNioTransport().isConnected()) {
            return
        }
        connectionInternal.notifyConnectionError(e)
    }

    /**
     * This is the interface between the "lookup remote connection endpoints" state and the "establish TCP connection"
     * state. The field is indirectly populated by {@link XmppTcpNioTransport#lookupConnectionEndpoints()} and consumed
     * by {@link ConnectionAttemptState}.
     */
    var discoveredTcpEndpoints: ?DiscoveredTcpEndpoints = None

    func afterOutgoingElementsQueueModified(): Unit {
        let selectionKeyAttachment = this.selectionKeyAttachment
        if (selectionKeyAttachment?.isReactorThreadRacing() ?? false) {
            reactorThreadAlreadyRacing.fetchAdd(1)
            return
        }
        afterOutgoingElementsQueueModifiedSetInterestOps.fetchAdd(1)
        connectionInternal.setInterestOps(selectionKey(), SelectionKey.OP_WRITE | SelectionKey.OP_READ)
    }

    protected override func getTransport(): ?C2sTransport {
        return if (let Some(v) <- tcpNioTransport) {
            v
        } else {
            None
        }
    }

    func constructEstablishingTcpConnectionState(
        stateDescriptor: EstablishingTcpConnectionStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ): EstablishingTcpConnectionState {
        return EstablishingTcpConnectionState(this, stateDescriptor, connectionInternal)
    }

    func constructEstablishingTlsState(
        stateDescriptor: EstablishTlsStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ): EstablishTlsState {
        return EstablishTlsState(this, stateDescriptor, connectionInternal)
    }

    private static let SSL_ENGINE_DEBUG_LOG_LEVEL = LogLevel.DEBUG

    static func debugLogSslEngineResult(operation: String, result: SSLEngineResult): Unit {
        if (!LOGGER.isLoggable(SSL_ENGINE_DEBUG_LOG_LEVEL)) {
            return
        }
        LOGGER.log(SSL_ENGINE_DEBUG_LOG_LEVEL, "SSLEngineResult of ${operation}(): ${result}")
    }

    func callChannelSelectedCallback(setPendingInputFilterData: Bool, setPendingOutputFilterData: Bool): Unit {
        let channel = socketChannel
        let key = selectionKey
        if (channel.isNone() || key.isNone()) {
            LOGGER.info("Not calling channel selected callback because the connection was eventually disconnected")
            return
        }
        channelSelectedCallbackLock.lock()
        try {
            if (setPendingInputFilterData) {
                pendingInputFilterData = true
            }
            if (setPendingOutputFilterData) {
                pendingOutputFilterData = true
            }
            onChannelSelected(channel(), key())
        } finally {
            channelSelectedCallbackLock.unlock()
        }
    }

    func closeSocketAndCleanup(): Unit {
        let selectionKey = this.selectionKey
        selectionKey?.cancel()

        let socketChannel = this.socketChannel
        if (socketChannel.isSome()) {
            try {
                socketChannel?.close()
            } catch (_: IOException) {}
        }
        this.selectionKey = None
        this.socketChannel = None
        selectionKeyAttachment = None
        remoteAddress = None
    }

    static func pruneBufferList(buffers: ArrayList<ByteBuffer>): ArrayList<ByteBuffer> {
        let collector = ArrayList<ByteBuffer>()
        var start = false
        var i = 0
        while (i < buffers.size) {
            let b = buffers[i]
            if (b.remainLength > 0) {
                break
            }
            collector.append(b)
            i++
        }
        buffers.remove(0..i)
        collector
    }

    public func getStats(): XmppTcpTransportModuleStats {
        return XmppTcpTransportModuleStats(this)
    }
}

class ByteArrayStreamHashKey <: Hashable & Equatable<ByteArrayStreamHashKey> {
    ByteArrayStreamHashKey(let data: ByteBuffer) {}
    public override func hashCode(): Int64 {
        0
    }
    public operator override func ==(that: ByteArrayStreamHashKey): Bool {
        refEq(this.data, that.data)
    }
}
