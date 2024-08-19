/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Interface to represent a XML element. This is similar to {@link ExtensionElement},
 * but does not carry a namespace and is usually included as child element of an stanza extension.
 */
public interface Element {
    func toXML(xmlEnvironment: ?XmlEnvironment): ToString

    /**
     * Returns the XML representation of this Element.
     * This method takes an optional argument for the enclosing namespace
     * which may be None or the empty String if the value is not known.
     *
     * @param enclosingNamespace the enclosing namespace or {@code None}.
     * @return the stanza extension as XML.
     */
    func toXML(enclosingNamespace: String): ToString {
        var xmlEnvironment: XmlEnvironment = XmlEnvironment(enclosingNamespace)
        return toXML(xmlEnvironment)
    }

    func toXML(): ToString {
        return toXML(XML_ENVIRONMENT_EMPTY)
    }
}

public interface XmlLangElement {
    /**
     * Returns the xml:lang of this XML element, or None if one has not been set.
     *
     * @return the xml:lang of this XML element, or None.
     */
    func getLanguage(): ?String
}

/**
 * Interface to represent a XML element. This is similar to {@link ExtensionElement}, but does not carry a single
 * namespace, but instead is used with multiple namespaces. Examples for this include MUC's &ltdestroy/&gt element.
 * <p>
 * Please note that usage of this is <b>discouraged</b>. The reason is that every XML element is fully
 * qualified, i.e., it is qualified by a namespace. The namespace may not be explicitly given, but instead, is inherited
 * from an outer element. Use {@link FullyQualifiedElement} instead when possible.
 * </p>
 */
public interface NamedElement <: Element {
    /**
     * Returns the root element name.
     *
     * @return the element name.
     */
    func getElementName(): String
}

public interface FullyQualifiedElement <: NamedElement & XmlLangElement {
    /**
     * Returns the root element XML namespace.
     *
     * @return the namespace.
     */
    func getNamespace(): String

    func getQName(): QName {
        let namespaceURI = getNamespace()
        let localPart = getElementName()
        return QName(namespaceURI, localPart)
    }

    func getLanguage(): ?String {
        return None
    }
}

/**
 * Interface to represent extension elements.
 * <p>
 * An extension element is an XML subdocument
 * with a root element name and namespace. Extension elements are used to provide
 * extended functionality beyond what is in the base XMPP specification. Examples of
 * extensions elements include message events, message properties, and extra presence data.
 * IQ stanzas have limited support for extension elements.
 * <p>
 * This class is used primarily for extended content in XMPP Stanzas, to act as so called "extension elements". For more
 * information see <a href="tools/ietf/org/html/rfc6120#section-8.4">RFC 6120 § 8.4 Extended Content</a>.
 * </p>
 *
 * @see ExtensionElementProvider
 */
public interface ExtensionElement <: FullyQualifiedElement {}

/**
 * A XMPP top level stream element. This is either a stanza ({@link Stanza}) or
 * just a plain stream element ({@link Nonza}).
 */
public interface TopLevelStreamElement <: FullyQualifiedElement {}

public interface PresenceView <: StanzaView {
    /**
     * Returns the type of this presence stanza.
     *
     * @return the type of the presence stanza.
     */
    func getType(): PresenceType

    /**
     * Returns the status message of the presence update, or <code>None</code> if there
     * is not a status. The status is free-form text describing a user's presence
     * (i.e., "gone to lunch").
     *
     * @return the status message.
     */
    func getStatus(): ?String

    /**
     * Returns the priority of the presence.
     *
     * @return the priority.
     * @see <a href="tools/ietf/org/html/rfc6121#section-4.7.2.3">RFC 6121 § 4.7.2.3. Priority Element</a>
     */
    func getPriority(): Int64

    /**
     * Returns the priority of the presence.
     *
     * @return the priority.
     * @see <a href="tools/ietf/org/html/rfc6121#section-4.7.2.3">RFC 6121 § 4.7.2.3. Priority Element</a>
     */
    func getPriorityByte(): Byte

    /**
     * Returns the mode of the presence update.
     *
     * @return the mode.
     */
    func getMode(): PresenceMode
}
