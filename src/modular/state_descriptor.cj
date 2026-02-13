/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.modular

/**
 * public abstract class StateDescriptor <: ToString & Hashable & Equatable<StateDescriptor> & ClassIdentify
 *
 */
public abstract class StateDescriptor <: ToString & Hashable & Equatable<StateDescriptor> & ClassIdentify {
    private static let LOGGER = getGlobalLogger(("name", "StateDescriptor"))

    private var stateName: ?String = None

    private let xepNum: Int64

    private let rfcSection: ?String

    private let properties: Set<StateDescriptorProperty>

    private let stateClass: ClassInfo<State>

    private let stateClassConstructor: (Array<Object>) -> State

    private let successors: HashSet<StateDescriptor> = HashSet()

    private let predecessors: HashSet<StateDescriptor> = HashSet()

    private let precedenceOver: HashSet<StateDescriptor> = HashSet()

    private let inferiorTo: HashSet<StateDescriptor> = HashSet()

    protected init() {
        this(
            ClassInfo(
                "NoOpState",
                {
                    args => NoOpState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            ),
            None
        )
    }

    protected init(properties: Array<StateDescriptorProperty>) {
        this(
            ClassInfo(
                "NoOpState",
                {
                    args => NoOpState((args[0] as C2sConnection)(), (args[1] as StateDescriptor)(),
                        (args[2] as C2sConnectionInternal)())
                }
            ),
            properties
        )
    }

    protected init(stateClass: ClassInfo<State>) {
        this(stateClass, -1, None, HashSet<StateDescriptorProperty>())
    }

    protected init(stateClass: ClassInfo<State>, properties: Array<StateDescriptorProperty>) {
        this(stateClass, -1, None, HashSet<StateDescriptorProperty>(properties))
    }

    protected init(stateClass: ClassInfo<State>, xepNum: Int64) {
        this(stateClass, xepNum, None, HashSet<StateDescriptorProperty>())
    }

    protected init(stateClass: ClassInfo<State>, xepNum: Int64, properties: Array<StateDescriptorProperty>) {
        this(stateClass, xepNum, None, HashSet<StateDescriptorProperty>(properties))
    }

    protected init(stateClass: ClassInfo<State>, rfcSection: ?String) {
        this(stateClass, -1, rfcSection, HashSet<StateDescriptorProperty>())
    }

    private init(
        stateClass: ClassInfo<State>,
        xepNum: Int64,
        rfcSection: ?String,
        properties: Set<StateDescriptorProperty>
    ) {
        this.stateClass = stateClass
        if (rfcSection.isSome() && xepNum > 0) {
            throw IllegalArgumentException("Must specify either RFC or XEP")
        }
        this.xepNum = xepNum
        this.rfcSection = rfcSection
        this.properties = properties

        this.stateClassConstructor = stateClass.constructor
    }

    protected func addSuccessor(successor: StateDescriptor): Unit {
        addAndCheckNonExistent(successors, successor)
    }

    public func addPredeccessor(predeccessor: StateDescriptor): Unit {
        addAndCheckNonExistent(predecessors, predeccessor)
    }

    protected func declarePrecedenceOver(subordinate: StateDescriptor): Unit {
        addAndCheckNonExistent(precedenceOver, subordinate)
    }

    protected func declareInferiorityTo(superior: StateDescriptor): Unit {
        addAndCheckNonExistent(inferiorTo, superior)
    }

    // private static func addAndCheckNonExistent(set: Set<ClassId>, clazzName: ClassId): Unit {
    //     // check clazzName is subclass of StateDescriptor
    //     addAndCheckNonExistent(set, clazzName)
    // }

    private static func addAndCheckNonExistent(set: HashSet<StateDescriptor>, e: StateDescriptor): Unit {
        let newElement = set.add(e)
        if (!newElement) {
            throw IllegalArgumentException("Element already exists in set")
        }
    }

    public func getSuccessors(): Set<StateDescriptor> {
        return HashSet(successors)
    }

    public func getPredeccessors(): Set<StateDescriptor> {
        return HashSet(predecessors)
    }

    public func getSubordinates(): Set<StateDescriptor> {
        return HashSet(precedenceOver)
    }

    public func getSuperiors(): Set<StateDescriptor> {
        return HashSet(inferiorTo)
    }

    public func getStateName(): String {
        return stateName ??
            {
            =>
            let thisclass = this.getClass().replace("StateDescriptor", "")
            stateName = thisclass
            thisclass
        }()
    }

    public func getFullStateName(breakStateName: Bool): String {
        let reference = getReference()
        if (let Some(ref) <- reference) {
            let sep: Rune = if (breakStateName) {
                r'\n'
            } else {
                r' '
            }
            return "${getStateName()}${sep}(${ref})"
        } else {
            return getStateName()
        }
        return ""
    }

    private var referenceCache: ?String = None

    public func getReference(): ?String {
        if (referenceCache.isNone()) {
            if (xepNum > 0) {
                referenceCache = "XEP-${xepNum.format("04")}"
            } else if (let Some(v) <- rfcSection) {
                referenceCache = v
            }
        }
        return referenceCache
    }

    public func getStateClass(): String {
        return stateClass.classId
    }

    public func isMultiVisitState(): Bool {
        return properties.contains(StateDescriptorProperty.multiVisitState)
    }

    public func isNotImplemented(): Bool {
        return properties.contains(StateDescriptorProperty.notImplemented)
    }

    public func isFinalState(): Bool {
        return properties.contains(StateDescriptorProperty.finalState)
    }

    protected open func constructState(connectionInternal: C2sConnectionInternal): State {
        let connection = connectionInternal.connection
        return stateClassConstructor(connection, this, connectionInternal)
    }

    public override func toString(): String {
        return "StateDescriptor ${getStateName()}"
    }

    public override func hashCode(): Int64 {
        return getClass().hashCode()
    }

    public operator func ==(that: StateDescriptor): Bool {
        return this.getClass() == that.getClass()
    }

    public static func getClassId(): ClassId {
        "StateDescriptor"
    }
}

public enum StateDescriptorProperty <: ToString & Equatable<StateDescriptorProperty> & Hashable {
    | multiVisitState
    | finalState
    | notImplemented

    public override func toString(): String {
        return match (this) {
            case multiVisitState => "multiVisitState"
            case finalState => "finalState"
            case notImplemented => "notImplemented"
        }
    }

    public override func hashCode(): Int64 {
        return toString().hashCode()
    }

    public operator func ==(that: StateDescriptorProperty): Bool {
        this.toString() == that.toString()
    }
}
