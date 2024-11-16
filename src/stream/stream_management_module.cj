/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class StreamManagementModule <: C2sConnectionModule {
    protected init(
        moduleDescriptor: StreamManagementModuleDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        super(moduleDescriptor, connectionInternal)
    }

    var useSm = true

    var useSmResumption = true

    func constructEnableStreamMangementState(
        enableStreamManagementStateDescriptor: EnableStreamManagementStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ): EnableStreamManagementState {
        return EnableStreamManagementState(this, enableStreamManagementStateDescriptor, connectionInternal)
    }

    func constructResumeStreamState(
        resumeStreamStateDescriptor: ResumeStreamStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ): ResumeStreamState {
        return ResumeStreamState(this, resumeStreamStateDescriptor, connectionInternal)
    }

    public func setStreamManagementEnabled(useSm: Bool): Unit {
        this.useSm = useSm
    }

    public func setStreamResumptionEnabled(useSmResumption: Bool): Unit {
        this.useSmResumption = useSmResumption
    }
}

public class EnableStreamManagementStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "EnableStreamManagementState",
                {
                    args => EnableStreamManagementState((args[0] as StreamManagementModule)(),
                        (args[1] as EnableStreamManagementStateDescriptor)(), (args[2] as C2sConnectionInternal)())
                }
            ),
            198,
            [StateDescriptorProperty.notImplemented]
        )
        addPredeccessor(ResourceBindingStateDescriptor())
        addSuccessor(AuthenticatedAndResourceBoundStateDescriptor())
        declarePrecedenceOver(AuthenticatedAndResourceBoundStateDescriptor())
    }

    protected override func constructState(connectionInternal: C2sConnectionInternal): EnableStreamManagementState {
        let smModule: StreamManagementModule = connectionInternal
            .connection
            .getConnectionModuleFor("StreamManagementModuleDescriptor")
        return smModule.constructEnableStreamMangementState(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        "EnableStreamManagementStateDescriptor"
    }
}

public class EnableStreamManagementState <: State {
    let smod: StreamManagementModule

    init(smod: StreamManagementModule, stateDescriptor: EnableStreamManagementStateDescriptor,
        connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.smod = smod
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        if (!smod.useSm) {
            return TransitionImpossibleReason("Stream management not enabled")
        }
        return TransitionImpossibleBecauseNotImplemented(stateDescriptor)
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        throw IllegalStateException("SM not implemented")
    }
}

public class ResumeStreamStateDescriptor <: StateDescriptor {
    init() {
        super(
            ClassInfo(
                "ResumeStreamState",
                {
                    args => ResumeStreamState((args[0] as StreamManagementModule)(),
                        (args[1] as ResumeStreamStateDescriptor)(), (args[2] as C2sConnectionInternal)())
                }
            ),
            198,
            [StateDescriptorProperty.notImplemented]
        )
        addPredeccessor(AuthenticatedButUnboundStateDescriptor())
        addSuccessor(AuthenticatedAndResourceBoundStateDescriptor())
        declarePrecedenceOver(ResourceBindingStateDescriptor())
        declareInferiorityTo(CompressionStateDescriptor())
    }

    protected override func constructState(connectionInternal: C2sConnectionInternal): ResumeStreamState {
        let smModule: StreamManagementModule = connectionInternal
            .connection
            .getConnectionModuleFor("StreamManagementModuleDescriptor")
        return smModule.constructResumeStreamState(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        "ResumeStreamStateDescriptor"
    }
}

public class ResumeStreamState <: State {
    let smod: StreamManagementModule

    init(smod: StreamManagementModule, stateDescriptor: ResumeStreamStateDescriptor,
        connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
        this.smod = smod
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        if (!smod.useSmResumption) {
            return TransitionImpossibleReason("Stream resumption not enabled")
        }
        return TransitionImpossibleBecauseNotImplemented(stateDescriptor)
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        throw Exception("Stream resumption not implemented")
    }
}
