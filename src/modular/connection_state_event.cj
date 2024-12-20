/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public open class ConnectionStateEvent <: ToString {
    private let currentStateDescriptor: StateDescriptor

    private let successorStateDescriptor: ?StateDescriptor

    private let timestamp: Duration

    public init(currentStateDescriptor: StateDescriptor) {
        this(currentStateDescriptor, None)
    }

    public init(currentStateDescriptor: StateDescriptor, successorStateDescriptor: ?StateDescriptor) {
        this.currentStateDescriptor = currentStateDescriptor
        this.successorStateDescriptor = successorStateDescriptor
        this.timestamp = DateTime.now().toUnixTimeStamp()
    }

    public func getStateDescriptor(): StateDescriptor {
        return currentStateDescriptor
    }

    public open override func toString(): String {
        return if (let Some(v) <- successorStateDescriptor) {
            "${currentStateDescriptor.getStateName()} ConnectionStateEvent ${v.getStateName()}"
        } else {
            "ConnectionStateEvent:  ${currentStateDescriptor.getStateName()}"
        }
    }

    public func getTimestamp(): Duration {
        return timestamp
    }
}

public class ConnectionStateEventStateRevertBackwardsWalk <: ConnectionStateEvent {
    public init(state: State) {
        super(state.getStateDescriptor())
    }
}

public class ConnectionStateEventFinalStateReached <: ConnectionStateEvent {
    public init(state: State) {
        super(state.getStateDescriptor())
    }
}

public class ConnectionStateEventTransitionNotPossible <: ConnectionStateEvent {
    private let transitionImpossibleReason: TransitionImpossible

    public init(currentState: State, successorState: State, reason: TransitionImpossible) {
        super(currentState.getStateDescriptor(), successorState.getStateDescriptor())
        this.transitionImpossibleReason = reason
    }

    public override func toString(): String {
        return "${super.toString()}: ${transitionImpossibleReason.toString()}"
    }
}

public class ConnectionStateEventAboutToTransitionInto <: ConnectionStateEvent {
    public init(currentState: State, successorState: State) {
        super(currentState.getStateDescriptor(), successorState.getStateDescriptor())
    }
}

public class ConnectionStateEventTransitionFailed <: ConnectionStateEvent {
    private let transitionFailedReason: StateTransitionResultFailure

    public init(currentState: State, failedSuccessorState: State, transitionFailedReason: StateTransitionResultFailure) {
        super(currentState.getStateDescriptor(), failedSuccessorState.getStateDescriptor())
        this.transitionFailedReason = transitionFailedReason
    }

    public override func toString(): String {
        return "${super.toString()}: ${transitionFailedReason.toString()}"
    }
}

public class ConnectionStateEventTransitionIgnoredDueCycle <: ConnectionStateEvent {
    public init(
        currentStateVertex: GraphVertex<State>,
        successorStateVertexCausingCycle: GraphVertex<State>
    ) {
        super(currentStateVertex.getElement().getStateDescriptor(),
            successorStateVertexCausingCycle.getElement().getStateDescriptor())
    }
}

public class ConnectionStateEventSuccessfullyTransitionedInto <: ConnectionStateEvent {
    private let transitionSuccessResult: StateTransitionResultSuccess

    public init(state: State, transitionSuccessResult: StateTransitionResultSuccess) {
        super(state.getStateDescriptor())
        this.transitionSuccessResult = transitionSuccessResult
    }

    public override func toString(): String {
        return "${super.toString()}: ${transitionSuccessResult.toString()}"
    }
}

/**
 * public abstract class ConnectionStateEventDetailedTransitionIntoInformation <: ConnectionStateEvent
 *
 */
public abstract class ConnectionStateEventDetailedTransitionIntoInformation <: ConnectionStateEvent {
    protected init(state: State) {
        super(state.getStateDescriptor())
    }
}
