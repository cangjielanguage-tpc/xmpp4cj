/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.modular

/**
 * public abstract class StateTransitionResult <: ToString
 *
 */
public abstract class StateTransitionResult <: ToString {
    private let message: String

    protected init(message: String) {
        this.message = message
    }

    public override func toString(): String {
        return message
    }
}

/**
 * public abstract class AttemptResult <: StateTransitionResult
 *
 */
public abstract class AttemptResult <: StateTransitionResult {
    protected init(message: String) {
        super(message)
    }
}

public open class StateTransitionResultSuccess <: AttemptResult {
    public static let EMPTY_INSTANCE = StateTransitionResultSuccess()

    private init() {
        super("")
    }

    public init(successMessage: String) {
        super(successMessage)
    }
}

public open class StateTransitionResultFailure <: AttemptResult {
    public init(failureMessage: String) {
        super(failureMessage)
    }
}

public class FailureCausedByException<E> <: StateTransitionResultFailure where E <: Exception {
    private let exception: E

    public init(exception: E) {
        super(exception.message)
        this.exception = exception
    }

    public func getException(): E {
        return exception
    }
}

public class FailureCausedByTimeout <: StateTransitionResultFailure {
    public init(failureMessage: String) {
        super(failureMessage)
    }
}

/**
 * public abstract class TransitionImpossible <: StateTransitionResult
 *
 */
public abstract class TransitionImpossible <: StateTransitionResult {
    protected init(message: String) {
        super(message)
    }
}

public open class TransitionImpossibleReason <: TransitionImpossible {
    public init(reason: String) {
        super(reason)
    }
}

public class TransitionImpossibleBecauseNotImplemented <: TransitionImpossibleReason {
    public init(stateDescriptor: StateDescriptor) {
        super("${stateDescriptor.getFullStateName(false)} is not implemented (yet)")
    }
}
