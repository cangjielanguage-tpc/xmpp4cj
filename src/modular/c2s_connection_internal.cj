/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public abstract class C2sConnectionInternal <: Equatable<C2sConnectionInternal> {
    private let reactor: XmppReactor

    public let connection: C2sConnection

    public let xmppDebugger: ?XmppDebugger

    public let outgoingElementsQueue: ArrayBlockingQueueWithShutdown<TopLevelStreamElement>

    public init(connection: C2sConnection, reactor: XmppReactor, xmppDebugger: ?XmppDebugger,
        outgoingElementsQueue: ArrayBlockingQueueWithShutdown<TopLevelStreamElement>) {
        this.connection = connection
        this.reactor = reactor
        this.xmppDebugger = xmppDebugger
        this.outgoingElementsQueue = outgoingElementsQueue
    }

    public open func registerWithSelector(channel: SelectableChannel, ops: Int,
        callback: XmppReactorChannelSelectedCallback): SelectionKey {
        return reactor.registerWithSelector(channel, ops, callback)
    }

    public open func setInterestOps(selectionKey: SelectionKey, interestOps: Int): Unit {
        reactor.setInterestOps(selectionKey, interestOps)
    }

    public func withXmppDebugger(xmppDebuggerConsumer: Consumer<XmppDebugger>): Unit {
        if (let Some(xmppDebugger) <- xmppDebugger) {
            xmppDebuggerConsumer(xmppDebugger)
        }
    }

    public open func getOutgoingStreamXmlEnvironment(): ?XmlEnvironment

    public open func parseAndProcessElement(wrappedCompleteIncomingElement: String): Unit

    public open func notifyConnectionError(e: Exception): Unit

    public open func onStreamOpen(parser: XmlPullParser): Unit

    public open func onStreamClosed(): Unit

    public open func fireFirstLevelElementSendListeners(element: TopLevelStreamElement): Unit

    public open func invokeConnectionStateMachineListener(connectionStateEvent: ConnectionStateEvent): Unit

    public open func addXmppInputOutputFilter(xmppInputOutputFilter: XmppInputOutputFilter): Unit

    public open func getXmppInputOutputFilterBeginIterator(): Iterator<XmppInputOutputFilter>

    public open func getXmppInputOutputFilterEndIterator(): ListIterator<XmppInputOutputFilter>

    public open func newStreamOpenWaitForFeaturesSequence(waitFor: String): Unit

    public open func getXmppTlsContext(): XmppTlsContext

    public open func sendAndWaitForResponse(nonza: Nonza, successNonzaClass: ClassId, failedNonzaClass: ClassId): ?Nonza

    public open func asyncGo(runnable: Runnable): Unit

    public open func waitForConditionOrThrowConnectionException(condition: Supplier<Bool>, waitFor: String): Unit

    public open func notifyWaitingThreads(): Unit

    public open func setCompressionEnabled(compressionEnabled: Bool): Unit

    /**
     * Set the active transport (TCP, BOSH, WebSocket, …) to be used for the XMPP connection. Also marks the connection
     * as connected.
     *
     * @param xmppTransport the active transport.
     */
    public open func setTransport(xmppTransport: ?C2sTransport): Unit

    public operator func ==(that: C2sConnectionInternal): Bool {
        return refEq(this, that)
    }
}
