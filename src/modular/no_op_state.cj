/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public open class NoOpState <: State {
    /**
     * Constructs a NoOpState. Note that the signature of this constructor is designed so that it mimics States which
     * are non-static inner classes of ModularXmppClientToServerConnection. That is why the first argument is not used.
     *
     * @param connection the connection.
     * @param stateDescriptor the related state descriptor
     * @param connectionInternal the internal connection API.
     */
    protected init(connection: C2sConnection, stateDescriptor: StateDescriptor,
        connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): StateTransitionResultSuccess {
        // Transition into a NoOpState always succeeds.
        return StateTransitionResultSuccess.EMPTY_INSTANCE
    }
}
