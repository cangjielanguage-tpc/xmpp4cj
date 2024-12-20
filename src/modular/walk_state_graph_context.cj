/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class WalkStateGraphContext {
    private let initialStateClass: ClassId
    private let finalStateClass: ClassId
    private let mandatoryIntermediateState: ClassId
    private let loginContext: ?LoginContext

    private let walkedStateGraphPath = ArrayList<State>()

    let failedStates: Map<State, StateTransitionResult> = HashMap<State, StateTransitionResult>() // no need LinkedMap

    var mandatoryIntermediateStateHandled: Bool = false

    init(builder: WalkStateGraphContextBuilder) {
        initialStateClass = builder.initialStateClass
        finalStateClass = builder.finalStateClass
        mandatoryIntermediateState = builder.mandatoryIntermediateState
        loginContext = builder.loginContext
    }

    public func recordWalkTo(state: State): Unit {
        walkedStateGraphPath.append(state)
    }

    public func isWalksFinalState(stateDescriptor: StateDescriptor): Bool {
        return stateDescriptor.getClass() == finalStateClass
    }

    public func isFinalStateAuthenticatedAndResourceBound(): Bool {
        return finalStateClass == "ModularXmppClientToServerConnectionAuthenticatedAndResourceBoundStateDescriptor"
    }

    public func maybeReturnMandatoryImmediateState(outgoingStateEdges: ArrayList<GraphVertex<State>>): ?GraphVertex<State> {
        for (outgoingStateVertex in outgoingStateEdges) {
            if (outgoingStateVertex.getElement().getStateDescriptor().getClass() == mandatoryIntermediateState) {
                mandatoryIntermediateStateHandled = true
                return outgoingStateVertex
            }
        }
        return None
    }

    public func getWalk(): ArrayList<State> {
        return ArrayList(walkedStateGraphPath)
    }

    public func getWalkLength(): Int {
        return walkedStateGraphPath.size
    }

    public func appendWalkTo(walk: ArrayList<State>): Unit {
        walk.appendAll(walkedStateGraphPath)
    }

    public func getLoginContext(): ?LoginContext {
        return loginContext
    }

    public func stateAlreadyVisited(state: State): Bool {
        return walkedStateGraphPath.contains(state)
    }

    public func recordFailedState(state: State, stateTransitionResult: StateTransitionResult): Unit {
        failedStates.put(state, stateTransitionResult)
    }

    public func getFailedStates(): Map<State, StateTransitionResult> {
        return HashMap<State, StateTransitionResult>(failedStates)
    }

    /**
     * Check if the way to the final state via the given successor state that would loop, i.e., lead over the initial state and
     * thus from a cycle.
     *
     * @param successorStateVertex the successor state to use on the way.
     * @return <code>true</code> if it would loop, <code>false</code> otherwise.
     */
    public func wouldCauseCycle(successorStateVertex: GraphVertex<State>): Bool {
        let visited: Set<ClassId> = HashSet<ClassId>()
        return wouldCycleRecursive(successorStateVertex, visited)
    }

    private func wouldCycleRecursive(stateVertex: GraphVertex<State>, visited: Set<ClassId>): Bool {
        let stateVertexClass: ClassId = stateVertex.getElement().getStateDescriptor().getClass()
        if (stateVertexClass == initialStateClass) {
            return true
        }
        if (finalStateClass == stateVertexClass || visited.contains(stateVertexClass)) {
            return false
        }
        visited.put(stateVertexClass)
        for (successorStateVertex in stateVertex.getOutgoingEdges()) {
            let cycle = wouldCycleRecursive(successorStateVertex, visited)
            if (cycle) {
                return true
            }
        }
        return false
    }

    public static func builder(initialStateClass: ClassId, finalStateClass: ClassId): WalkStateGraphContextBuilder {
        return WalkStateGraphContextBuilder(initialStateClass, finalStateClass)
    }
}

public class WalkStateGraphContextBuilder {
    let initialStateClass: ClassId
    let finalStateClass: ClassId
    var mandatoryIntermediateState: ClassId = ""
    var loginContext: ?LoginContext = None

    init(initialStateClass: ClassId, finalStateClass: ClassId) {
        this.initialStateClass = Objects.requireNonNull(initialStateClass)
        this.finalStateClass = Objects.requireNonNull(finalStateClass)
    }

    public func withMandatoryIntermediateState(mandatoryIntermedidateState: ClassId): WalkStateGraphContextBuilder {
        this.mandatoryIntermediateState = mandatoryIntermedidateState
        return this
    }

    public func withLoginContext(username: ?String, password: ?String, resource: ?Resourcepart): WalkStateGraphContextBuilder {
        let loginContext = LoginContext(username, password, resource)
        return withLoginContext(loginContext)
    }

    public func withLoginContext(loginContext: LoginContext): WalkStateGraphContextBuilder {
        this.loginContext = loginContext
        return this
    }

    public func build(): WalkStateGraphContext {
        return WalkStateGraphContext(this)
    }
}
