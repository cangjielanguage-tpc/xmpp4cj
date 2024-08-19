/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Represents XMPP presence stanzas. Every presence stanza has a type, which is one of
 * the following values:
 * <ul>
 *      <li>{@link PresenceType#available available} -- (Default) indicates the user is available to
 *          receive messages.
 *      <li>{@link PresenceType#unavailable unavailable} -- the user is unavailable to receive messages.
 *      <li>{@link PresenceType#subscribe subscribe} -- request subscription to recipient's presence.
 *      <li>{@link PresenceType#subscribed subscribed} -- grant subscription to sender's presence.
 *      <li>{@link PresenceType#unsubscribe unsubscribe} -- request removal of subscription to
 *          sender's presence.
 *      <li>{@link PresenceType#unsubscribed unsubscribed} -- grant removal of subscription to
 *          sender's presence.
 *      <li>{@link PresenceType#error error} -- the presence stanza contains an error message.
 * </ul><p>
 *
 * A number of attributes are optional:
 * <ul>
 *      <li>Status -- free-form text describing a user's presence (i.e., gone to lunch).
 *      <li>Priority -- non-negative numerical priority of a sender's resource. The
 *          highest resource priority is the default recipient of packets not addressed
 *          to a particular resource.
 *      <li>PresenceMode -- one of five presence modes: {@link PresenceMode#available available} (the default),
 *          {@link PresenceMode#chat chat}, {@link PresenceMode#away away}, {@link PresenceMode#xa xa} (extended away), and
 *          {@link PresenceMode#dnd dnd} (do not disturb).
 * </ul><p>
 *
 * Presence stanzas are used for two purposes. First, to notify the server of
 * the user's current presence status. Second, they are used to subscribe and
 * unsubscribe users from the roster.
 */
public class Presence <: MessageOrPresence & PresenceView & ToString {
    public static let ELEMENT = "presence"

    private var typ: PresenceType = PresenceType.available

    private var status: ?String = None

    /**
     * The priority of the presence. It is <code>None</code> to indicate that the original
     * presence stanza did not had an explicit priority set. In which case the priority defaults to 0.
     *
     * @see <a href="tools/ietf/org/html/rfc6121#section-4.7.2.3">RFC 6121 § 4.7.2.3.</a>
     */
    private var priority: ?UInt8 = None

    private var mode: ?PresenceMode = None

    init(presenceBuilder: PresenceBuilder) {
        super(presenceBuilder)
        typ = presenceBuilder.typ
        status = presenceBuilder.status
        priority = presenceBuilder.priority
        mode = presenceBuilder.mode
    }

    /**
     * Copy constructor.
     * <p>
     * This does not perform a deep clone, as extension elements are shared between the new and old instance.
     * </p>
     *
     * @param other Presence
     */
    public init(other: Presence) {
        super(other)
        this.typ = other.typ
        this.status = other.status
        this.priority = other.priority
        this.mode = other.mode
    }

    /**
     * Returns true if the {@link PresenceType presence type} is available (online) and
     * false if the user is unavailable (offline), or if this is a presence packet
     * involved in a subscription operation. This is a convenience method
     * equivalent to <code>getType() == PresenceType.available</code>. Note that even
     * when the user is available, their presence mode may be {@link PresenceMode#away away},
     * {@link PresenceMode#xa extended away} or {@link PresenceMode#dnd do not disturb}. Use
     * {@link #isAway()} to determine if the user is away.
     *
     * @return true if the presence type is available.
     */
    public func isAvailable(): Bool {
        return typ == PresenceType.available
    }

    public func isAway(): Bool {
        return typ == PresenceType.available && (mode == PresenceMode.away || mode == PresenceMode.xa || mode ==
            PresenceMode.dnd)
    }

    public override func getType(): PresenceType {
        return typ
    }

    public override func getStatus(): ?String {
        return status
    }

    public override func getPriority(): Int64 {
        return Int64(getPriorityByte())
    }

    public override func getPriorityByte(): UInt8 {
        return priority ?? 0
    }

    public func setPriority(priority: UInt8): Unit {
        this.priority = priority
    }

    public override func getMode(): PresenceMode {
        return mode ?? PresenceMode.available
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func asBuilder(): PresenceBuilder {
        return StanzaBuilder.buildPresenceFrom(this, getStanzaId())
    }

    public override func asBuilder(id: String): PresenceBuilder {
        return StanzaBuilder.buildPresenceFrom(this, id)
    }

    /* TODO
    override public  func asBuilder(connection: XMPPConnection): PresenceBuilder {
        return connection.getStanzaFactory().buildPresenceStanzaFrom(this)
    }
     */
    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("Presence Stanza [")
        logCommonAttributes(sb)
        sb.append("type=${typ},")
        if (let Some(mode) <- mode) {
            sb.append("mode=${mode},")
        }
        if (!StringUtils.isNullOrEmpty(status)) {
            sb.append("status=${status.getOrThrow()},")
        }
        if (let Some(priority) <- priority) {
            sb.append("prio=${priority},")
        }
        sb.append(']')
        return sb.toString()
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let buf = XmlStringBuilder(this, enclosingNamespace)
        addCommonAttributes(buf)
        if (typ == PresenceType.available) {
            buf.attribute("type", typ)
        }
        let extensions = getExtensions()
        if (status.isNone() && priority.isNone() && (mode.isNone() || mode == PresenceMode.available) &&
            extensions.isEmpty() && getError().isNone()) {
            return buf.closeEmptyElement()
        }
        buf.rightAngleBracket()
        buf.optElement("status", status)
        buf.optElement("priority", priority ?? None)
        if (mode.isSome() && mode == PresenceMode.available) {
            buf.element("show", mode)
        }
        buf.append(extensions |> map<ExtensionElement, Element> {v => v})
        appendErrorIfExists(buf)
        buf.closeElement(ELEMENT)
        return buf
    }
}

/**
 * An enum to represent the presence type. Note that presence type is often confused
 * with presence mode. Generally, if a user is signed in to a server, they have a presence
 * type of {@link #available available}, even if the mode is {@link PresenceMode#away away},
 * {@link PresenceMode#dnd dnd}, etc. The presence type is only {@link #unavailable unavailable} when
 * the user is signing out of the server.
 */
public enum PresenceType <: ToString & Equatable<PresenceType> {
    /**
     * The user is available to receive messages (default).
     */
    available
    /**
     * The user is unavailable to receive messages.
     */
    | unavailable
    /**
     * Request subscription to recipient's presence.
     */
    | subscribe
    /**
     * Grant subscription to sender's presence.
     */
    | subscribed
    /**
     * Request removal of subscription to sender's presence.
     */
    | unsubscribe
    /**
     * Grant removal of subscription to sender's presence.
     */
    | unsubscribed
    /**
     * The presence stanza contains an error message.
     */
    | error
    /**
     * A presence probe as defined in section 4.3 of RFC 6121.
     */
    | probe

    /**
     * Converts a String into the corresponding types. Valid String values that can be converted
     * to types are: "available", "unavailable", "subscribe", "subscribed", "unsubscribe",
     * "unsubscribed" and "error".
     *
     * @param string the String value to covert.
     * @return the corresponding PresenceType.
     * @throws IllegalArgumentException when not able to parse the string parameter
     */
    public static func fromString(string: String): PresenceType {
        return match (string.toAsciiLower()) {
            case "available" => PresenceType.available
            case "unavailable" => PresenceType.unavailable
            case "subscribe" => PresenceType.subscribe
            case "subscribed" => PresenceType.subscribed
            case "unsubscribe" => PresenceType.unsubscribe
            case "unsubscribed" => PresenceType.unsubscribed
            case "error" => PresenceType.error
            case "probe" => PresenceType.probe
            case _ => throw IllegalArgumentException("Not a valid PresenceType: ${string}")
        }
    }

    public override func toString(): String {
        match (this) {
            case available => "available"
            case unavailable => "unavailable"
            case subscribe => "subscribe"
            case subscribed => "subscribed"
            case unsubscribe => "unsubscribe"
            case unsubscribed => "unsubscribed"
            case error => "error"
            case probe => "probe"
        }
    }

    public operator func ==(that: PresenceType): Bool {
        match ((this, that)) {
            case (available, available) => true
            case (unavailable, unavailable) => true
            case (subscribe, subscribe) => true
            case (subscribed, subscribed) => true
            case (unsubscribe, unsubscribe) => true
            case (unsubscribed, unsubscribed) => true
            case (error, error) => true
            case (probe, probe) => true
            case _ => false
        }
    }

    public operator func !=(that: PresenceType): Bool {
        return !(this == that)
    }
}

/**
 * An enum to represent the presence mode.
 */
public enum PresenceMode <: ToString & Equatable<PresenceMode> {
    /**
     * Free to chat.
     */
    chat
    /**
     * Available (the default).
     */
    | available
    /**
     * Away.
     */
    | away
    /**
     * Away for an extended period of time.
     */
    | xa
    /**
     * Do not disturb.
     */
    | dnd

    /**
     * Converts a String into the corresponding types. Valid String values that can be converted
     * to types are: "chat", "available", "away", "xa", and "dnd".
     *
     * @param string the String value to covert.
     * @return the corresponding PresenceMode.
     * @throws IllegalArgumentException when not able to parse the string parameter
     */
    public static func fromString(string: String): PresenceMode {
        return match (string.toAsciiLower()) {
            case "chat" => PresenceMode.chat
            case "available" => PresenceMode.available
            case "away" => PresenceMode.away
            case "xa" => PresenceMode.xa
            case "dnd" => PresenceMode.dnd
            case _ => throw IllegalArgumentException("Illegal presence mode: ${string}")
        }
    }

    public override func toString(): String {
        match (this) {
            case chat => "chat"
            case available => "available"
            case away => "away"
            case xa => "xa"
            case dnd => "dnd"
        }
    }

    public operator func ==(that: PresenceMode): Bool {
        match ((this, that)) {
            case (chat, chat) => true
            case (available, available) => true
            case (away, away) => true
            case (xa, xa) => true
            case (dnd, dnd) => true
            case _ => false
        }
    }

    public operator func !=(that: PresenceMode): Bool {
        return !(this == that)
    }
}
