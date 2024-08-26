/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Represents XMPP message packets. A message can be one of several types:
 *
 * <ul>
 *      <li>MessageType.NORMAL -- (Default) a normal text message used in email like interface.
 *      <li>MessageType.CHAT -- a typically short text message used in line-by-line chat interfaces.
 *      <li>MessageType.GROUP_CHAT -- a chat message sent to a groupchat server for group chats.
 *      <li>MessageType.HEADLINE -- a text message to be displayed in scrolling marquee displays.
 *      <li>MessageType.ERROR -- indicates a messaging error.
 * </ul>
 *
 * For each message type, different message fields are typically used as follows:
 * <table border="1">
 * <caption>Message Types</caption>
 * <tr><td>&nbsp;</td><td colspan="5"><b>Message type</b></td></tr>
 * <tr><td><i>Field</i></td><td><b>Normal</b></td><td><b>Chat</b></td><td><b>Group Chat</b></td><td><b>Headline</b></td><td><b>XMPPError</b></td></tr>
 * <tr><td><i>subject</i></td> <td>SHOULD</td><td>SHOULD NOT</td><td>SHOULD NOT</td><td>SHOULD NOT</td><td>SHOULD NOT</td></tr>
 * <tr><td><i>thread</i></td>  <td>OPTIONAL</td><td>SHOULD</td><td>OPTIONAL</td><td>OPTIONAL</td><td>SHOULD NOT</td></tr>
 * <tr><td><i>body</i></td>    <td>SHOULD</td><td>SHOULD</td><td>SHOULD</td><td>SHOULD</td><td>SHOULD NOT</td></tr>
 * <tr><td><i>error</i></td>   <td>MUST NOT</td><td>MUST NOT</td><td>MUST NOT</td><td>MUST NOT</td><td>MUST</td></tr>
 * </table>
 */
public class Message <: MessageOrPresence & MessageView & ToString {
    public static let ELEMENT = "message"
    public static let BODY = "body"

    private var typ: ?MessageType = None

    init(messageBuilder: MessageBuilder) {
        super(messageBuilder)
        typ = messageBuilder.typ
    }

    /**
     * Copy constructor.
     * <p>
     * This does not perform a deep clone, as extension elements are shared between the new and old instance.
     * </p>
     */
    public init(other: Message) {
        super(other)
        this.typ = other.typ
    }

    public override func getType(): ?MessageType {
        return typ ?? MessageType.normal
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func asBuilder(): MessageBuilder {
        return StanzaBuilder.buildMessageFrom(this, getStanzaId())
    }

    public override func asBuilder(id: String): MessageBuilder {
        return StanzaBuilder.buildMessageFrom(this, id)
    }

    /* TODO
    public override func asBuilder(connection: XMPPConnection): MessageBuilder {
        return connection.getStanzaFactory().buildMessageStanzaFrom(this)
    }
     */
    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("Message Stanza [")
        logCommonAttributes(sb)
        if (let Some(typ) <- typ) {
            sb.append("type=${typ},")
        }
        sb.append(']')
        return sb.toString()
    }

    public override func toXML(enclosingXmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let buf = XmlStringBuilder(this, enclosingXmlEnvironment)
        addCommonAttributes(buf)
        buf.optAttribute("type", typ?.toString())
        buf.rightAngleBracket()

        // Append the error subpacket if the message type is an error.
        if (typ == MessageType.error) {
            appendErrorIfExists(buf)
        }

        // Add extension elements, if any are defined.
        buf.append(getExtensions() |> map<ExtensionElement, Element> {v => v})
        buf.closeElement(ELEMENT)
        return buf
    }
}

/**
 * Represents the type of a message.
 */
public enum MessageType <: Equatable<MessageType> & ToString {
    /**
     * (Default) a normal text message used in email like interface.
     */
    | normal
    /**
     * Typically short text message used in line-by-line chat interfaces.
     */
    | chat
    /**
     * Chat message sent to a groupchat server for group chats.
     */
    | groupchat
    /**
     * Text message to be displayed in scrolling marquee displays.
     */
    | headline
    /**
     * indicates a messaging error.
     */
    | error

    /**
     * Converts a String into the corresponding types.
     * Valid String values that can be converted to types are: "normal", "chat", "groupchat", "headline" and "error".
     *
     * @param string the String value to covert.
     * @return the corresponding Type.
     * @throws IllegalArgumentException when not able to parse the string parameter
     */
    public static func fromString(string: String): MessageType {
        match (string.toAsciiLower()) {
            case "normal" => normal
            case "chat" => chat
            case "groupchat" => groupchat
            case "headline" => headline
            case "error" => error
            case _ => throw IllegalArgumentException("Not a valid MessageType: ${string}")
        }
    }

    public func toString(): String {
        match (this) {
            case normal => "normal"
            case chat => "chat"
            case groupchat => "groupchat"
            case headline => "headline"
            case error => "error"
        }
    }

    public operator func ==(that: MessageType): Bool {
        match ((this, that)) {
            case (normal, normal) => true
            case (chat, chat) => true
            case (groupchat, groupchat) => true
            case (headline, headline) => true
            case (error, error) => true
            case _ => false
        }
    }
    public operator func !=(that: MessageType): Bool {
        return !(this == that)
    }
}

/**
 * Represents a message subject, its language and the content of the subject.
 */
public class MessageSubject <: ExtensionElement & Hashable & Equatable<MessageSubject> {
    public static let ELEMENT = "subject"
    public static let NAMESPACE = StreamOpen.CLIENT_NAMESPACE
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private let subject: String
    let language: ?String

    public init(language: ?String, subject: String) {
        this.language = language
        this.subject = subject
    }

    public override func getLanguage(): ?String {
        return language
    }

    /**
     * Returns the subject content.
     *
     * @return the content of the subject.
     */
    public func getSubject(): String {
        return subject
    }

    private let hashCodeCache = HashCodeCache()

    public override func hashCode(): Int64 {
        return hashCodeCache.getHashCode {c => c.append(language ?? None).append(subject)}
    }

    public operator override func ==(other: MessageSubject): Bool {
        return EqualsUtil.equals(this, other, {e, o => e.append(language, o.language).append(subject, o.subject)})
    }
    public operator override func !=(other: MessageSubject): Bool {
        return !(this == other)
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()
        xml.escape(subject)
        xml.closeElement(getElementName())
        return xml
    }
}

/**
 * Represents a message body, its language and the content of the message.
 */
public class MessageBody <: ExtensionElement & Hashable & Equatable<MessageBody> {
    public static let ELEMENT: String = "body"
    public static let NAMESPACE: String = StreamOpen.CLIENT_NAMESPACE
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private let message: String
    private let language: ?String
    private let namespace: MessageBodyElementNamespace

    public init(language: ?String, message: String) {
        this(language, message, MessageBodyElementNamespace.client)
    }

    public init(language: ?String, message: String, namespace: MessageBodyElementNamespace) {
        this.language = language
        this.message = message
        this.namespace = namespace
    }

    public override func getLanguage(): ?String {
        return language
    }

    /**
     * Returns the message content.
     *
     * @return the content of the message.
     */
    public func getMessage(): String {
        return message
    }

    private let hashCodeCache = HashCodeCache()

    public override func hashCode(): Int64 {
        let hashable: ?Hashable = language ?? None
        return Int64(hashCodeCache.getHashCode({c => c.append(hashable).append(message)}))
    }

    public operator override func ==(obj: MessageBody): Bool {
        return EqualsUtil.equals(this, obj, {e, o => e.append(language, o.language).append(message, o.message)})
    }
    public operator override func !=(obj: MessageBody): Bool {
        return !(this == obj)
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return namespace.xmlNamespace
    }

    public override func toXML(enclosingXmlEnvironment: ?XmlEnvironment): ToString {
        let xml = XmlStringBuilder(this, enclosingXmlEnvironment)
        xml.rightAngleBracket()
        xml.text(message)
        xml.closeElement(getElementName())
        return xml
    }
}

public enum MessageBodyElementNamespace {
    | client
    | server

    prop xmlNamespace: String {
        get() {
            match (this) {
                case client => StreamOpen.CLIENT_NAMESPACE
                case server => StreamOpen.SERVER_NAMESPACE
            }
        }
    }
}

public class MessageThread <: ExtensionElement {
    public static let ELEMENT: String = "thread"
    public static let NAMESPACE: String = StreamOpen.CLIENT_NAMESPACE
    public static let QNAME = QName(NAMESPACE, ELEMENT)
    public static let PARENTATTRIBUTENAME = "parent"

    private let thread: String
    private let parent: ?String

    public init(thread: String) {
        this(thread, None)
    }

    public init(thread: String, parent: ?String) {
        this.thread = StringUtils.requireNotNullNorEmpty(thread, "thread must not be None nor empty")
        this.parent = StringUtils.requireNullOrNotEmpty(parent, "parent must be None or not empty")
    }

    public func getThread(): String {
        return thread
    }

    public func getParent(): ?String {
        return parent
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func getQName(): QName {
        return QNAME
    }

    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, xmlEnvironment)
        xml.optAttribute(PARENTATTRIBUTENAME, parent)
        xml.rightAngleBracket()
        xml.escape(thread)
        xml.closeElement(this)
        return xml
    }
}
