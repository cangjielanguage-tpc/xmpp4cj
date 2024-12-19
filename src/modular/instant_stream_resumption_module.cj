/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class InstantStreamResumptionModule <: C2sConnectionModule {
    protected init(
        instantStreamResumptionModuleDescriptor: InstantStreamResumptionModuleDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        super(instantStreamResumptionModuleDescriptor, connectionInternal)
    }

    var useIsr = true

    public func setInstantStreamResumptionEnabled(useIsr: Bool): Unit {
        this.useIsr = useIsr
    }

    public func constructInstantStreamResumptionState(
        instantStreamResumptionStateDescriptor: InstantStreamResumptionStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ): InstantStreamResumptionState {
        return InstantStreamResumptionState(this, instantStreamResumptionStateDescriptor, connectionInternal)
    }
}

public class InstantStreamResumptionStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "InstantStreamResumptionState",
                {
                    args => InstantStreamResumptionState((args[0] as InstantStreamResumptionModule)(),
                        (args[1] as InstantStreamResumptionStateDescriptor)(), (args[2] as C2sConnectionInternal)())
                }
            ),
            397,
            [StateDescriptorProperty.notImplemented]
        )
        addSuccessor(AuthenticatedAndResourceBoundStateDescriptor())
        addPredeccessor(ConnectedButUnauthenticatedStateDescriptor())
        declarePrecedenceOver(SaslAuthenticationStateDescriptor())
    }

    protected override func constructState(connectionInternal: C2sConnectionInternal): InstantStreamResumptionState {
        let isrModule: InstantStreamResumptionModule = connectionInternal
            .connection
            .getConnectionModuleFor("InstantStreamResumptionModuleDescriptor")
        return isrModule.constructInstantStreamResumptionState(this, connectionInternal)
    }

    public override func getClass(): String {
        "InstantStreamResumptionStateDescriptor"
    }
}

public class InstantStreamResumptionState <: State {
    let this_0: InstantStreamResumptionModule

    init(
        this_0: InstantStreamResumptionModule,
        instantStreamResumptionStateDescriptor: InstantStreamResumptionStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        super(instantStreamResumptionStateDescriptor, connectionInternal)
        this.this_0 = this_0
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        if (!this_0.useIsr) {
            return TransitionImpossibleReason("Instant stream resumption not enabled nor implemented")
        }
        return TransitionImpossibleBecauseNotImplemented(stateDescriptor)
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        throw IllegalStateException("Instant stream resumption not implemented")
    }
}
