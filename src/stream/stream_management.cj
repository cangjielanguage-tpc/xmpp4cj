/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class StreamManagement {
    public static let NAMESPACE = "urn:xmpp:sm:3"
}

public class StreamManagementFeature <: ExtensionElement {
    public static let ELEMENT = "sm"

    public static let INSTANCE = StreamManagementFeature()

    static init() {
        ELEMENT_MAPPING.put("StreamManagementFeature", ELEMENT)
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return StreamManagement.NAMESPACE
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.closeEmptyElement()
        return xml
    }
}

abstract sealed class StreamManagementAbstractEnable <: Nonza {
    protected var max = Duration.second * -1

    protected var resume = false

    protected func maybeAddResumeAttributeTo(xml: XmlStringBuilder): Unit {
        if (resume) {
            xml.attribute("resume", "true")
        }
    }

    protected func maybeAddMaxAttributeTo(xml: XmlStringBuilder): Unit {
        if (max > Duration.Zero) {
            xml.attribute("max", max.toString())
        }
    }

    public func isResumeSet(): Bool {
        return resume
    }

    /**
     * Return the max resumption time in seconds.
     * @return the max resumption time in seconds
     */
    public func getMaxResumptionTime(): Duration {
        return max
    }

    public override func getNamespace(): String {
        return StreamManagement.NAMESPACE
    }
}

public class StreamManagementEnable <: StreamManagementAbstractEnable {
    public static let ELEMENT = "enable"

    public static let INSTANCE = StreamManagementEnable()

    static init() {
        ELEMENT_MAPPING.put("StreamManagementEnable", ELEMENT)
    }

    private init() {
        super()
    }

    public init(resume: Bool) {
        super()
        this.resume = resume
    }

    public init(resume: Bool, max: Duration) {
        this(resume)
        this.max = max
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        maybeAddResumeAttributeTo(xml)
        maybeAddMaxAttributeTo(xml)
        xml.closeEmptyElement()
        return xml
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}

/**
 * A Stream Management 'enabled' element.
 * <p>
 * Here is a full example, all attributes besides 'xmlns' are optional.
 * </p>
 * <pre>
 * {@code
 * <enabled xmlns='urn:xmpp:sm:3'
 *      id='some-long-sm-id'
 *      location='[2001:41D0:1:A49b::1]:9222'
 *      resume='true'/>
 * }
 * </pre>
 */
public class StreamManagementEnabled <: StreamManagementAbstractEnable {
    public static let ELEMENT = "enabled"

    static init() {
        ELEMENT_MAPPING.put("StreamManagementEnabled", ELEMENT)
    }

    /**
     * The stream id ("SM-ID")
     */
    private let id: ?String

    /**
     * The location where the server prefers reconnection.
     */
    private let location: ?String

    public init(id: String, resume: Bool) {
        this(id, resume, None, Duration.second * -1)
    }

    public init(id: ?String, resume: Bool, location: ?String, max: Duration) {
        super()
        this.id = id
        this.resume = resume
        this.location = location
        this.max = max
    }

    public func getId(): ?String {
        return id
    }

    public func getLocation(): ?String {
        return location
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.optAttribute("id", id)
        maybeAddResumeAttributeTo(xml)
        xml.optAttribute("location", location)
        maybeAddMaxAttributeTo(xml)
        xml.closeEmptyElement()
        return xml
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}

public class StreamManagementFailed <: Nonza {
    public static let ELEMENT = "failed"

    static init() {
        ELEMENT_MAPPING.put("StreamManagementFailed", ELEMENT)
    }

    private let condition: ?StanzaErrorCondition

    private let textElements: Collection<StanzaErrorTextElement>

    public init() {
        this(None, None)
    }

    public init(condition: ?StanzaErrorCondition, textElements: ?ArrayList<StanzaErrorTextElement>) {
        this.condition = condition
        this.textElements = textElements ?? []
    }

    public func getStanzaErrorCondition(): ?StanzaErrorCondition {
        return condition
    }

    public func getTextElements(): Collection<StanzaErrorTextElement> {
        return textElements
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        if (condition.isNone() && textElements.isEmpty()) {
            xml.closeEmptyElement()
        } else {
            if (let Some(condition) <- condition) {
                xml.rightAngleBracket()
                xml.append(condition.toString())
                xml.xmlnsAttribute(StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE)
                xml.closeEmptyElement()
            }
            xml.append(textElements)
            xml.closeElement(ELEMENT)
        }
        return xml
    }

    public override func getNamespace(): String {
        return StreamManagement.NAMESPACE
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}

abstract sealed class StreamManagementAbstractResume <: Nonza {
    private let handledCount: Int64

    private let previd: String

    init(handledCount: Int64, previd: String) {
        this.handledCount = handledCount
        this.previd = previd
    }

    public func getHandledCount(): Int64 {
        return handledCount
    }

    public func getPrevId(): String {
        return previd
    }

    public override func getNamespace(): String {
        return StreamManagement.NAMESPACE
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.attribute("h", handledCount.toString())
        xml.attribute("previd", previd)
        xml.closeEmptyElement()
        return xml
    }
}

public class StreamManagementResume <: StreamManagementAbstractResume {
    public static let ELEMENT = "resume"

    static init() {
        ELEMENT_MAPPING.put("StreamManagementResume", ELEMENT)
    }

    public init(handledCount: Int64, previd: String) {
        super(handledCount, previd)
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}

public class StreamManagementResumed <: StreamManagementAbstractResume {
    public static let ELEMENT = "resumed"

    static init() {
        ELEMENT_MAPPING.put("StreamManagementResumed", ELEMENT)
    }

    public init(handledCount: Int64, previd: String) {
        super(handledCount, previd)
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}

public class StreamManagementAckAnswer <: Nonza {
    public static let ELEMENT = "a"

    static init() {
        ELEMENT_MAPPING.put("StreamManagementAckAnswer", ELEMENT)
    }

    private let handledCount: Int64

    public init(handledCount: Int64) {
        this.handledCount = handledCount
    }

    public func getHandledCount(): Int64 {
        return handledCount
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.attribute("h", handledCount.toString())
        xml.closeEmptyElement()
        return xml
    }

    public override func getNamespace(): String {
        return StreamManagement.NAMESPACE
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}

public class StreamManagementAckRequest <: Nonza {
    public static let ELEMENT = "r"

    static init() {
        ELEMENT_MAPPING.put("StreamManagementAckRequest", ELEMENT)
    }

    public static let INSTANCE = StreamManagementAckRequest()

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<${ELEMENT} xmlns='${StreamManagement.NAMESPACE}'/>"
    }

    public override func getNamespace(): String {
        return StreamManagement.NAMESPACE
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}
