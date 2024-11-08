/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public abstract class C2sTransport <: Hashable & Equatable<C2sTransport> {
    protected let connectionInternal: C2sConnectionInternal

    protected init(connectionInternal: C2sConnectionInternal) {
        this.connectionInternal = connectionInternal
    }

    protected func resetDiscoveredConnectionEndpoints(): Unit

    protected func lookupConnectionEndpoints(): Collection<XmppFuture<LookupConnectionEndpointsResult, Exception>>

    protected func loadConnectionEndpoints(lookupConnectionEndpointsSuccess: LookupConnectionEndpointsSuccess): Unit

    /**
     * Notify the transport that new outgoing data is available. Usually this method does not need to be called
     * explicitly, only if the filters are modified so that they potentially produced new data.
     */
    protected func afterFiltersClosed(): Unit

    /**
     * Called by the CloseConnection state.
     */
    protected func disconnect(): Unit

    protected func notifyAboutNewOutgoingElements(): Unit

    public func getSslSession(): ?TlsSession

    public func isConnected(): Bool

    public open func isTransportSecured(): Bool {
        return getSslSession().isSome()
    }

    public func getStats(): C2sTransportStats

    private var cachedHashCode: ?Int64 = None
    public open override func hashCode(): Int64 {
        if (let Some(v) <- cachedHashCode) {
            return v
        } else {
            let v = RandomUtil.nextSecureRandomInt()
            cachedHashCode = v
            v
        }
    }
    public open operator override func ==(that: C2sTransport): Bool {
        refEq(this, that)
    }
}

public abstract class C2sTransportStats {}

public interface LookupConnectionEndpointsResult {}

public interface LookupConnectionEndpointsSuccess <: LookupConnectionEndpointsResult {}

public interface LookupConnectionEndpointsFailed <: LookupConnectionEndpointsResult {}
