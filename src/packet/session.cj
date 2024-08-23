/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * IQ stanza that will be sent to the server to establish a session.<p>
 *
 * If a server supports sessions, it MUST include a <i>session</i> element in the
 * stream features it advertises to a client after the completion of stream authentication.
 * Upon being informed that session establishment is required by the server the client MUST
 * establish a session if it desires to engage in instant messaging and presence functionality.<p>
 *
 * For more information refer to the following
 * <a href=xmpp/org/specs/rfc3921.html#session>link</a>.
 */
public class Session <: SimpleIQ {
    public static let ELEMENT = "session"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-session"

    public init() {
        super(ELEMENT, NAMESPACE)
        setType(IQType.set)
    }
}

public class SessionFeature <: ExtensionElement {
    public static let QNAME = QName(Session.NAMESPACE, Session.ELEMENT)

    public static let OPTIONAL_ELEMENT = "optional"

    private let optional: Bool

    public init(optional: Bool) {
        this.optional = optional
    }

    public func isOptional(): Bool {
        return optional
    }

    public override func getElementName(): String {
        return Session.ELEMENT
    }

    public override func getNamespace(): String {
        return Session.NAMESPACE
    }

    public override func toXML(_: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this)
        if (optional) {
            xml.rightAngleBracket()
            xml.emptyElement(OPTIONAL_ELEMENT)
            xml.closeElement(this)
        } else {
            xml.closeEmptyElement()
        }
        return xml
    }
}
