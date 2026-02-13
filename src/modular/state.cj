/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.modular

/**
 * public abstract class State <: ToString & Equatable<State> & Hashable
 *
 * Note that this is an non-static inner class of XmppClientToServerConnection so that states can inspect and modify
 * the connection.
 */
public abstract class State <: ToString & Equatable<State> & Hashable {
    protected let stateDescriptor: StateDescriptor

    protected let connectionInternal: C2sConnectionInternal

    protected init(stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        this.stateDescriptor = stateDescriptor
        this.connectionInternal = connectionInternal
    }

    /**
     * Check if the state should be activated.
     *
     * @param walkStateGraphContext the context of the current state graph walk.
     * @return <code>null</code> if the state should be activated.
     * @throws Xmpp4cjException in case a Xmpp exception occurs.
     */
    public open func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        return None
    }

    // throws IOException, Xmpp4cjException, InterruptedException, XMPPException
    public func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult

    public func getStateDescriptor(): StateDescriptor {
        return stateDescriptor
    }

    public open func resetState(): Unit {}

    public override func toString(): String {
        // TODO
        return "State ${stateDescriptor} ${connectionInternal.connection}"
        // return "State ${stateDescriptor}"
    }

    protected func ensureNotOnOurWayToAuthenticatedAndResourceBound(walkStateGraphContext: WalkStateGraphContext): Unit {
        if (walkStateGraphContext.isFinalStateAuthenticatedAndResourceBound()) {
            throw IllegalStateException(
                "Xmpp should never attempt to reach the authenticated and resource bound state over ${this}. This is probably a programming error within Xmpp, please report it to the develoeprs."
            )
        }
    }

    public operator override func ==(that: State): Bool {
        refEq(this, that)
    }

    public override func hashCode(): Int {
        toString().hashCode()
    }
}
