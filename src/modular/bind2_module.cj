/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class Bind2Module <: C2sConnectionModule {
    protected init(moduleDescriptor: Bind2ModuleDescriptor, connectionInternal: C2sConnectionInternal) {
        super(moduleDescriptor, connectionInternal)
    }

    public func constructBind2State(
        bind2StateDescriptor: Bind2StateDescriptor,
        connectionInternal: C2sConnectionInternal
    ): Bind2State {
        return Bind2State(bind2StateDescriptor, connectionInternal)
    }
}

public class Bind2StateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo("Bind2State",
                {args => Bind2State((args[0] as Bind2StateDescriptor)(), (args[1] as C2sConnectionInternal)())}),
            386,
            [StateDescriptorProperty.notImplemented]
        )
        addPredeccessor(ConnectedButUnauthenticatedStateDescriptor())
        addSuccessor(AuthenticatedAndResourceBoundStateDescriptor())
        declarePrecedenceOver(SaslAuthenticationStateDescriptor())
    }

    protected override func constructState(connectionInternal: C2sConnectionInternal): Bind2State {
        let bind2Module: Bind2Module = connectionInternal.connection.getConnectionModuleFor("Bind2ModuleDescriptor")
        return bind2Module.constructBind2State(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        "Bind2StateDescriptor"
    }
}

public class Bind2State <: State {
    init(bind2StateDescriptor: Bind2StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(bind2StateDescriptor, connectionInternal)
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        return TransitionImpossibleBecauseNotImplemented(stateDescriptor)
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        throw IllegalStateException("Bind2 not implemented")
    }
}
