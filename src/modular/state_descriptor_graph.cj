/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

/**
 * Xmpp's utility API for Finite State Machines (FSM).
 */
public class StateDescriptorGraph {
    private static let LOGGER = getGlobalLogger(("name", "StateDescriptorGraph"))

    // throws InstantiationException, IllegalAccessException, IllegalArgumentException, InvocationTargetException, NoSuchMethodException, SecurityException
    static func addNewStateDescriptorGraphVertex(
        stateDescriptorClass: StateDescriptor,
        graphVertexes: Map<StateDescriptor, GraphVertex<StateDescriptor>>
    ): GraphVertex<StateDescriptor> {
        let stateDescriptor = stateDescriptorClass
        let graphVertexStateDescriptor = GraphVertex<StateDescriptor>(stateDescriptor)
        let previous = graphVertexes.add(stateDescriptorClass, graphVertexStateDescriptor)
        assert(previous.isNone())
        return graphVertexStateDescriptor
    }

    // throws InstantiationException, IllegalAccessException, IllegalArgumentException, InvocationTargetException, NoSuchMethodException, SecurityException
    private static func handleStateDescriptorGraphVertex(
        node: GraphVertex<StateDescriptor>,
        context: HandleStateDescriptorGraphVertexContext
    ): Unit {
        let stateDescriptorClass: ClassId = node.element.getClass()
        let alreadyHandled = context.recurseInto(stateDescriptorClass)
        if (alreadyHandled) {
            return
        }

        let successorClasses = node.element.getSuccessors()
        let numSuccessors = successorClasses.size

        let successorStateDescriptors: Map<StateDescriptor, GraphVertex<StateDescriptor>> = HashMap(numSuccessors)
        for (successorClass in successorClasses) {
            let successorGraphNode = context.getOrConstruct(successorClass)
            successorStateDescriptors.add(successorClass, successorGraphNode)
        }

        match (numSuccessors) {
            case 0 => throw IllegalStateException("State ${stateDescriptorClass} has no successor")
            case 1 => for ((_, soleSuccessorNode) in successorStateDescriptors) {
                node.addOutgoingEdge(soleSuccessorNode)
                handleStateDescriptorGraphVertex(soleSuccessorNode, context)
                return
            }
            case _ => ()
        }
        let preferenceGraph: Map<StateDescriptor, GraphVertex<StateDescriptor>> = HashMap(numSuccessors)

        for (successorStateDescriptorGraphNode in successorStateDescriptors.values()) {
            let successorStateDescriptor = successorStateDescriptorGraphNode.element
            let successorStateDescriptorClass: StateDescriptor = successorStateDescriptor
            for (subordinateClass in successorStateDescriptor.getSubordinates()) {
                if (!successorClasses.contains(subordinateClass)) {
                    LOGGER.error(
                        "${successorStateDescriptor} points to a subordinate '${subordinateClass}' which is not part of the successor set"
                    )
                    continue
                }
                let superiorClassNode = lookupAndCreateIfRequired(preferenceGraph, successorStateDescriptorClass)
                let subordinateClassNode = lookupAndCreateIfRequired(preferenceGraph, subordinateClass)
                superiorClassNode.addOutgoingEdge(subordinateClassNode)
            }
            for (superiorClass in successorStateDescriptor.getSuperiors()) {
                if (!successorClasses.contains(superiorClass)) {
                    LOGGER.error(
                        "${successorStateDescriptor} points to a superior '${superiorClass}' which is not part of the successor set"
                    )
                    continue
                }
                let subordinateClassNode = lookupAndCreateIfRequired(preferenceGraph, successorStateDescriptorClass)
                let superiorClassNode = lookupAndCreateIfRequired(preferenceGraph, superiorClass)
                superiorClassNode.addOutgoingEdge(subordinateClassNode)
            }
        }

        let sortedSuccessors = topologicalSort(preferenceGraph.values())

        for (successorStateDescriptor in successorClasses) {
            var continueOuterLoop = false
            for (sortedSuccessor in sortedSuccessors) {
                if (sortedSuccessor.getElement().getClass() == successorStateDescriptor.getClass()) {
                    continueOuterLoop = true
                    break
                }
            }
            if (continueOuterLoop) {
                continue
            }
            sortedSuccessors.add(GraphVertex<StateDescriptor>(successorStateDescriptor))
        }

        for (successor in sortedSuccessors) {
            let successorVertex = successorStateDescriptors.get(successor.element).getOrThrow()
            node.addOutgoingEdge(successorVertex)
            // Recurse further.
            handleStateDescriptorGraphVertex(successorVertex, context)
        }
    }

    public static func constructStateDescriptorGraph(backwardEdgeStateDescriptors: Set<StateDescriptor>): GraphVertex<StateDescriptor> {
        let graphVertexes: Map<StateDescriptor, GraphVertex<StateDescriptor>> = HashMap()

        let initialStatedescriptorClass = DisconnectedStateDescriptor()
        let initialNode = addNewStateDescriptorGraphVertex(initialStatedescriptorClass, graphVertexes)

        let inferredForwardEdges = MultiMap<StateDescriptor, StateDescriptor>()
        for (backwardsEdge in backwardEdgeStateDescriptors) {
            let graphVertexStateDescriptor = addNewStateDescriptorGraphVertex(backwardsEdge, graphVertexes)
            for (predecessor in graphVertexStateDescriptor.getElement().getPredeccessors()) {
                inferredForwardEdges.put(predecessor, backwardsEdge)
            }
        }
        for (inferredSuccessorOfInitialStateDescriptor in inferredForwardEdges.getAll(initialStatedescriptorClass)) {
            initialNode.getElement().addSuccessor(inferredSuccessorOfInitialStateDescriptor)
        }

        let context = HandleStateDescriptorGraphVertexContext(graphVertexes, inferredForwardEdges)
        handleStateDescriptorGraphVertex(initialNode, context)

        return initialNode
    }

    private static func convertToStateGraph(
        stateDescriptorVertex: GraphVertex<StateDescriptor>,
        connectionInternal: C2sConnectionInternal,
        handledStateDescriptors: Map<StateDescriptor, GraphVertex<State>>
    ): GraphVertex<State> {
        let stateDescriptor = stateDescriptorVertex.getElement()
        return handledStateDescriptors.get(stateDescriptor) ??
            {
            =>
            let state = stateDescriptor.constructState(connectionInternal)
            let stateVertex = GraphVertex<State>(state)
            handledStateDescriptors.add(stateDescriptor, stateVertex)
            for (successorStateDescriptorVertex in stateDescriptorVertex.getOutgoingEdges()) {
                let successorStateVertex = convertToStateGraph(successorStateDescriptorVertex, connectionInternal,
                    handledStateDescriptors)
                stateVertex.addOutgoingEdge(successorStateVertex)
            }
            stateVertex
        }()
    }

    public static func convertToStateGraph(
        initialStateDescriptor: GraphVertex<StateDescriptor>,
        connectionInternal: C2sConnectionInternal
    ): GraphVertex<State> {
        let handledStateDescriptors: Map<StateDescriptor, GraphVertex<State>> = HashMap()
        let initialState = convertToStateGraph(initialStateDescriptor, connectionInternal, handledStateDescriptors)
        return initialState
    }

    private static func lookupAndCreateIfRequired(
        map: Map<StateDescriptor, GraphVertex<StateDescriptor>>,
        clazz: StateDescriptor
    ): GraphVertex<StateDescriptor> {
        map.get(clazz) ?? {
            =>
            let vertex = GraphVertex<StateDescriptor>(clazz)
            map.add(clazz, vertex)
            vertex
        }()
    }

    private static func topologicalSort<E>(vertexes: Collection<GraphVertex<E>>): ArrayList<GraphVertex<E>> {
        let res = ArrayList<GraphVertex<E>>()
        dfs(vertexes, {v => res.add(v, at: 0)}, None)
        return res
    }

    private static func dfsVisit<E>(vertex: GraphVertex<E>, dfsFinishedVertex: Consumer<GraphVertex<E>>,
        dfsEdgeFound: ?DfsEdgeFound<E>): Unit {
        vertex.color = VertexColor.grey
        let totalEdgeCount: Int64 = vertex.getOutgoingEdges().size
        var edgeCount = 0
        for (successorVertex in vertex.getOutgoingEdges()) {
            edgeCount++
            dfsEdgeFound?(vertex, successorVertex, edgeCount, totalEdgeCount)
            if (successorVertex.color == VertexColor.white) {
                dfsVisit(successorVertex, dfsFinishedVertex, dfsEdgeFound)
            }
        }
        vertex.color = VertexColor.black
        dfsFinishedVertex(vertex)
    }

    private static func dfs<E>(vertexes: Collection<GraphVertex<E>>, dfsFinishedVertex: Consumer<GraphVertex<E>>,
        dfsEdgeFound: ?DfsEdgeFound<E>): Unit {
        for (vertex in vertexes) {
            if (vertex.color == VertexColor.white) {
                dfsVisit(vertex, dfsFinishedVertex, dfsEdgeFound)
            }
        }
    }

    public static func stateDescriptorGraphToDot(vertexes: Collection<GraphVertex<StateDescriptor>>,
        dotOut: StringBuilder, breakStateName: Bool): Unit {
        dotOut.append("digraph {\n")
        dfs(
            vertexes,
            {
                finishedVertex =>
                let isMultiVisitState: Bool = finishedVertex.element.isMultiVisitState()
                let isFinalState: Bool = finishedVertex.element.isFinalState()
                let isNotImplemented: Bool = finishedVertex.element.isNotImplemented()

                let style: String = if (isMultiVisitState) {
                    "bold"
                } else if (isFinalState) {
                    "filled"
                } else if (isNotImplemented) {
                    "dashed"
                } else {
                    return
                }

                dotOut.append('"')
                dotOut.append(finishedVertex.element.getFullStateName(breakStateName))
                dotOut.append("\" [ ")
                dotOut.append("style=")
                dotOut.append(style)
                dotOut.append(" ]\n")
            },
            {
                from, to, edgeId, totalEdgeCount =>
                dotOut.append("  \"")
                dotOut.append(from.element.getFullStateName(breakStateName))
                dotOut.append("\" -> \"")
                dotOut.append(to.element.getFullStateName(breakStateName))
                dotOut.append('"')
                if (totalEdgeCount > 1) {
                    // Note that 'dot' requires *double* quotes to enclose the value.
                    dotOut.append(" [xlabel=\"")
                    dotOut.append(edgeId)
                    dotOut.append("\"]")
                }
                dotOut.append(";\n")
            }
        )
        dotOut.append("}\n")
    }
}

class HandleStateDescriptorGraphVertexContext {
    private let handledStateDescriptors: Set<ClassId> = HashSet<ClassId>()
    let graphVertexes: Map<StateDescriptor, GraphVertex<StateDescriptor>>
    let inferredForwardEdges: MultiMap<StateDescriptor, StateDescriptor>

    init(
        graphVertexes: Map<StateDescriptor, GraphVertex<StateDescriptor>>,
        inferredForwardEdges: MultiMap<StateDescriptor, StateDescriptor>
    ) {
        this.graphVertexes = graphVertexes
        this.inferredForwardEdges = inferredForwardEdges
    }

    public func recurseInto(stateDescriptorClass: ClassId): Bool {
        let wasAdded = handledStateDescriptors.add(stateDescriptorClass)
        let alreadyHandled = !wasAdded
        return alreadyHandled
    }

    public func getOrConstruct(stateDescriptorClass: StateDescriptor): GraphVertex<StateDescriptor> {
        graphVertexes.get(stateDescriptorClass) ??
            {
            =>
            let graphVertexStateDescriptor = StateDescriptorGraph.addNewStateDescriptorGraphVertex(stateDescriptorClass,
                graphVertexes)
            for (inferredSuccessor in inferredForwardEdges.getAll(stateDescriptorClass)) {
                graphVertexStateDescriptor.getElement().addSuccessor(inferredSuccessor)
            }
            graphVertexStateDescriptor
        }()
    }
}

public class GraphVertex<E> <: ToString & Equatable<GraphVertex<E>> {
    let element: E

    private let outgoingEdges = ArrayList<GraphVertex<E>>()

    var color: VertexColor = VertexColor.white

    init(element: E) {
        this.element = element
    }

    public func addOutgoingEdge(vertex: GraphVertex<E>): Unit {
        if (outgoingEdges.contains(vertex)) {
            throw IllegalArgumentException("This ${this} already has an outgoing edge to ${vertex}")
        }
        outgoingEdges.add(vertex)
    }

    public func getElement(): E {
        return element
    }

    public func getOutgoingEdges(): ArrayList<GraphVertex<E>> {
        return (outgoingEdges)
    }

    public override func toString(): String {
        return toString(true)
    }

    public func toString(includeOutgoingEdges: Bool): String {
        let sb = StringBuilder()
        sb.append(
            "GraphVertex ${anyToString(element)} [color=${color}, identityHashCode=${outgoingEdges.toString().hashCode()}, outgoingEdgeCount=${outgoingEdges.size}"
        )
        if (includeOutgoingEdges) {
            sb.append(", outgoingEdges={")
            let outgoing = outgoingEdges |> map {e => e.toString(false)} |> collectString<String>(delimiter: ", ")
            sb.append(outgoing)
            sb.append(r'}')
        }
        sb.append(r']')
        return sb.toString()
    }

    public operator func ==(that: GraphVertex<E>): Bool {
        refEq(this, that)
    }
}

enum VertexColor <: ToString & Equatable<VertexColor> {
    | white
    | grey
    | black

    public override func toString(): String {
        return match (this) {
            case white => "white"
            case grey => "grey"
            case black => "black"
        }
    }

    public operator func ==(that: VertexColor): Bool {
        this.toString() == that.toString()
    }
}

// (from, to, edgeCount, totalEdgeCount) -> Unit
type DfsEdgeFound<E> = (GraphVertex<E>, GraphVertex<E>, Int64, Int64) -> Unit
