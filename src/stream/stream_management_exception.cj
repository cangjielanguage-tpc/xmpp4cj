/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

/**
 * public abstract class StreamManagementException <: Xmpp4cjException
 *
 */
public abstract class StreamManagementException <: Xmpp4cjException {
    public init() {}

    public init(message: String) {
        super(message)
    }
}

public class StreamManagementNotEnabledException <: StreamManagementException {
    public override func getClassName(): String {
        "StreamManagementNotEnabledException"
    }
}

public class StreamIdDoesNotMatchException <: StreamManagementException {
    public init(expected: String, got: String) {
        super("Stream IDs do not match. Expected '${expected}', but got '${got}'")
    }
    public override func getClassName(): String {
        "StreamIdDoesNotMatchException"
    }
}

public class StreamManagementCounterError <: StreamManagementException {
    private let handledCount: Int
    private let previousServerHandledCount: Int
    private let ackedStanzaCount: Int
    private let outstandingStanzasCount: Int
    private let ackedStanzas: Collection<Stanza>

    public init(handledCount: Int, previousServerHandlerCount: Int, ackedStanzaCount: Int,
        ackedStanzas: ArrayList<Stanza>) {
        super(
            "There was an error regarding the Stream Management counters. Server reported ${handledCount} handled stanzas, which means that the ${ackedStanzaCount} recently send stanzas by client are now acked by the server. But Xmpp had only ${ackedStanzas.size} to acknowledge. The stanza id of the last acked outstanding stanza is ${if (ackedStanzas.isEmpty()) {"<no acked stanzas>"} else {ackedStanzas[ackedStanzas.size - 1].getStanzaId()}}"
        )
        this.handledCount = handledCount
        this.previousServerHandledCount = previousServerHandlerCount
        this.ackedStanzaCount = ackedStanzaCount
        this.outstandingStanzasCount = ackedStanzas.size
        this.ackedStanzas = ackedStanzas
    }

    public func getHandledCount(): Int {
        return handledCount
    }

    public func getPreviousServerHandledCount(): Int {
        return previousServerHandledCount
    }

    public func getAckedStanzaCount(): Int {
        return ackedStanzaCount
    }

    public func getOutstandingStanzasCount(): Int {
        return outstandingStanzasCount
    }

    public func getAckedStanzas(): Collection<Stanza> {
        return ackedStanzas
    }

    public override func getClassName(): String {
        "StreamManagementCounterError"
    }
}

public class StreamManagementUnacknowledgedQueueFullException <: StreamManagementException {
    private let overflowElementNum: Int
    private let droppedElements: Int
    private let elements: ArrayList<Element>

    private let unacknowledgesStanzas: ArrayList<Stanza>

    private init(message: String, overflowElementNum: Int, droppedElements: Int, elements: ArrayList<Element>,
        unacknowledgesStanzas: ArrayList<Stanza>) {
        super(message)
        this.overflowElementNum = overflowElementNum
        this.droppedElements = droppedElements
        this.elements = elements
        this.unacknowledgesStanzas = unacknowledgesStanzas
    }

    public func getOverflowElementNum(): Int {
        return overflowElementNum
    }

    public func getDroppedElements(): Int {
        return droppedElements
    }

    public func getElements(): ArrayList<Element> {
        return elements
    }

    public func getUnacknowledgesStanzas(): ArrayList<Stanza> {
        return unacknowledgesStanzas
    }

    public override func getClassName(): String {
        "StreamManagementUnacknowledgedQueueFullException"
    }

    public static func newWith(
        overflowElementNum: Int,
        elements: ArrayList<Element>,
        unacknowledgedStanzas: CollectionBlockingQueue<Stanza>
    ): StreamManagementUnacknowledgedQueueFullException {
        let unacknowledgesStanzasQueueSize = unacknowledgedStanzas.size
        let localUnacknowledgesStanzas = ArrayList<Stanza>(unacknowledgesStanzasQueueSize)
        localUnacknowledgesStanzas.add(all: unacknowledgedStanzas)
        let droppedElements = elements.size - overflowElementNum - 1

        let message: String = "The queue size ${unacknowledgesStanzasQueueSize} is not able to fit another ${droppedElements} potential stanzas type top-level stream-elements."
        return StreamManagementUnacknowledgedQueueFullException(message, overflowElementNum, droppedElements, elements,
            localUnacknowledgesStanzas)
    }
}
