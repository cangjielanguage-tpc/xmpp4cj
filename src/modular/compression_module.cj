/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.modular

public class CompressionModule <: C2sConnectionModule {
    protected init(
        moduleDescriptor: CompressionModuleDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        super(moduleDescriptor, connectionInternal)
    }

    public func constructCompressionState(
        compressionStateDescriptor: CompressionStateDescriptor,
        connectionInternal: C2sConnectionInternal
    ): CompressionState {
        return CompressionState(compressionStateDescriptor, connectionInternal)
    }
}

public class CompressionStateDescriptor <: StateDescriptor {
    public init() {
        super(
            ClassInfo("CompressionState",
                {args => CompressionState((args[0] as StateDescriptor)(), (args[1] as C2sConnectionInternal)())}),
            138
        )
        addPredeccessor(AuthenticatedButUnboundStateDescriptor())
        addSuccessor(AuthenticatedButUnboundStateDescriptor())
        declarePrecedenceOver(ResourceBindingStateDescriptor())
    }

    protected override func constructState(connectionInternal: C2sConnectionInternal): CompressionState {
        let compressionModule: CompressionModule = connectionInternal
            .connection
            .getConnectionModuleFor("CompressionModuleDescriptor")
        return compressionModule.constructCompressionState(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        return "CompressionStateDescriptor"
    }
}

public class CompressionState <: State {
    private var selectedCompressionFactory: ?XmppCompressionFactory = None
    private var usedXmppInputOutputCompressionFitler: ?XmppInputOutputFilter = None

    init(stateDescriptor: StateDescriptor, connectionInternal: C2sConnectionInternal) {
        super(stateDescriptor, connectionInternal)
    }

    public override func isTransitionToPossible(walkStateGraphContext: WalkStateGraphContext): ?TransitionImpossible {
        let config = connectionInternal.connection.getConfiguration()
        if (!config.isCompressionEnabled()) {
            return TransitionImpossibleReason("Stream compression disabled by connection configuration")
        }
        let compressFeature: CompressFeature = match (connectionInternal.connection.getFeature("CompressFeature")) {
            case Some(f: CompressFeature) => f
            case _ => return TransitionImpossibleReason("Stream compression not supported or enabled by service")
        }

        selectedCompressionFactory = XmppCompressionManager.getBestFactory(compressFeature)
        if (selectedCompressionFactory.isNone()) {
            return TransitionImpossibleReason(
                "No matching compression factory for ${compressFeature.getMethods().toArray()}")
        }
        usedXmppInputOutputCompressionFitler = selectedCompressionFactory?.fabricate(config)
        return None
    }

    public override func transitionInto(walkStateGraphContext: WalkStateGraphContext): AttemptResult {
        let compressionMethod = selectedCompressionFactory().getCompressionMethod()
        connectionInternal.sendAndWaitForResponse(Compress(compressionMethod), "Compressed", "Failure")
        connectionInternal.addXmppInputOutputFilter(usedXmppInputOutputCompressionFitler())
        connectionInternal.newStreamOpenWaitForFeaturesSequence("server stream features after compression enabled")
        connectionInternal.setCompressionEnabled(true)
        return CompressionTransitionSuccessResult(compressionMethod)
    }

    public override func resetState(): Unit {
        selectedCompressionFactory = None
        usedXmppInputOutputCompressionFitler = None
        connectionInternal.setCompressionEnabled(false)
    }
}

public class CompressionTransitionSuccessResult <: StateTransitionResultSuccess {
    private let compressionMethod: String

    init(compressionMethod: String) {
        super((compressionMethod) + " compression enabled")
        this.compressionMethod = compressionMethod
    }

    public func getCompressionMethod(): String {
        return compressionMethod
    }
}
