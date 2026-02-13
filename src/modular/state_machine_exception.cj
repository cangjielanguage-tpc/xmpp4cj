/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.modular

/**
 * public abstract class StateMachineException <: Xmpp4cjException
 *
 */
public abstract class StateMachineException <: Xmpp4cjException {
    protected init(message: String) {
        super(message)
    }

    protected init() {
        super()
    }
}

public class XmppMandatoryStateFailedException <: StateMachineException {
    public init(state: State, failureReason: ?StateTransitionResult) {
        super()
    }
}

public class XmppStateGraphDeadEndException <: StateMachineException {
    private let walkedStateGraphPath: Collection<State>

    private let failedStates: Map<State, StateTransitionResult>

    private let deadEndState: StateDescriptor

    private init(message: String, walkStateGraphContext: WalkStateGraphContext, stateVertex: GraphVertex<State>) {
        super(message)
        this.walkedStateGraphPath = walkStateGraphContext.getWalk()
        this.failedStates = Collections.unmodifiableMap(walkStateGraphContext.getFailedStates())
        deadEndState = stateVertex.getElement().getStateDescriptor()
    }

    public func getWalkedStateGraph(): Collection<State> {
        return walkedStateGraphPath
    }

    public func getFailedStates(): Map<State, StateTransitionResult> {
        return failedStates
    }

    public func getDeadEndState(): StateDescriptor {
        return deadEndState
    }

    public static func comefrom(
        walkStateGraphContext: WalkStateGraphContext,
        stateVertex: GraphVertex<State>
    ): XmppStateGraphDeadEndException {
        let message: String = "${stateVertex.toString()} has no successor vertexes"
        return XmppStateGraphDeadEndException(message, walkStateGraphContext, stateVertex)
    }
}
