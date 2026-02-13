/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.packet

/**
 * 表示 XMPP 存在节。每个存在节都有一个类型，以下是类型的值：
 * <ul>
 *      <li>{@link PresenceType#available 可用} --（默认）表示用户可接收消息。
 *      <li>{@link PresenceType#unavailable 不可用} -- 用户不可接收消息。
 *      <li>{@link PresenceType#subscribe 订阅} -- 请求订阅接收者的存在。
 *      <li>{@link PresenceType#subscribed 已订阅} -- 同意发送者的存在订阅。
 *      <li>{@link PresenceType#unsubscribe 取消订阅} -- 请求移除对发送者存在的订阅。
 *      <li>{@link PresenceType#unsubscribed 已取消订阅} -- 同意移除对发送者存在的订阅。
 *      <li>{@link PresenceType#error 错误} -- 存在节包含错误消息。
 * </ul><p>
 *
 * 一些属性是可选的：
 * <ul>
 *      <li>状态 -- 描述用户存在的自由格式文本（例如，去吃午饭了）。
 *      <li>优先级 -- 发送者资源的非负数字优先级。最高资源优先级是未指定特定资源的数据包的默认接收者。
 *      <li>存在模式 -- 五种存在模式之一：{@link PresenceMode#available 可用}（默认）、{@link PresenceMode#chat 聊天}、{@link PresenceMode#away 离开}、{@link PresenceMode#xa 长时间离开}和{@link PresenceMode#dnd 请勿打扰}。
 * </ul><p>
 *
 * 存在节有两个用途。首先，通知服务器用户当前的存在状态。其次，它们用于在通讯录中订阅和取消订阅用户。
 */
public class Presence <: MessageOrPresence & PresenceView & ToString {
    /**
     * 元素名称。
     */
    public static let ELEMENT = "presence"

    private var typ: PresenceType = PresenceType.available

    private var status: ?String = None

    /**
     * 存在的优先级。如果原始存在节没有明确设置优先级，则为<code>None</code>。在这种情况下，优先级默认为 0。
     *
     * @see <a href="tools/ietf/org/html/rfc6121#section-4.7.2.3">RFC 6121 § 4.7.2.3.</a>
     */
    private var priority: ?UInt8 = None

    private var mode: ?PresenceMode = None

    /**
     * 构造一个 Presence 实例，基于给定的 PresenceBuilder。
     *
     * @param presenceBuilder   基于的 PresenceBuilder 对象
     */
    init(presenceBuilder: PresenceBuilder) {
        super(presenceBuilder)
        typ = presenceBuilder.typ
        status = presenceBuilder.status
        priority = presenceBuilder.priority
        mode = presenceBuilder.mode
    }

    /**
     * 复制构造函数。
     * <p>
     * 这不会执行深度克隆，因为扩展元素在新实例和旧实例之间共享。
     * </p>
     *
     * @param other Presence 对象
     */
    public init(other: Presence) {
        super(other)
        this.typ = other.typ
        this.status = other.status
        this.priority = other.priority
        this.mode = other.mode
    }

    /**
     * 如果{@link PresenceType 存在类型}是可用（在线），则返回 true，如果用户不可用（离线），或者这是一个参与订阅操作的存在包，则返回 false。这是一个方便方法，等同于<code>getType() == PresenceType.available</code>。请注意，即使用户可用，他们的存在模式也可能是{@link PresenceMode#away 离开}、{@link PresenceMode#xa 长时间离开}或{@link PresenceMode#dnd 请勿打扰}。使用{@link #isAway()}确定用户是否离开。
     *
     * @return 如果存在类型是可用，则为 true。
     */
    public func isAvailable(): Bool {
        return typ == PresenceType.available
    }

    /**
     * 如果存在类型为{@link type#available}并且存在
     * 模式为{@link mode#away}、{@link mode#xa extended away}，或
     * {@link模式#dnd请勿打扰}。当输入类型或模式时，将返回False
     * 是任何其他值，包括当前状态类型不可用（脱机）时。
     * 这是一种方便的方法，相当于
     * <code>类型==类型可用&amp；（mode==mode.away|| mode==mode.xa|| mode==mode.dnd）</code>。
     *
     * @return 如果存在类型可用，并且存在模式为away、xa或dnd，则返回true。
     */
    public func isAway(): Bool {
        return typ == PresenceType.available && (mode == PresenceMode.away || mode == PresenceMode.xa || mode == PresenceMode
            .dnd)
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

    /**
     * 设置优先级。
     */
    public func setPriority(priority: UInt8): Unit {
        this.priority = priority
    }

    public override func getMode(): PresenceMode {
        return mode ?? PresenceMode.available
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    /**
     * 返回一个构造器来构建当前的消息或存在状态。
     *
     * @return 当前消息或存在状态的构造器。
     */
    public override func asBuilder(): PresenceBuilder {
        return StanzaBuilder.buildPresenceFrom(this, getStanzaId())
    }

    /**
     * 使用指定的标识符返回一个构造器来构建当前的消息或存在状态。
     *
     * @param id 消息或存在状态的标识符。
     * @return 带有指定标识符的构造器。
     */
    public override func asBuilder(id: String): PresenceBuilder {
        return StanzaBuilder.buildPresenceFrom(this, id)
    }

    /**
     * 使用指定的{@link StanzaFactory}构建{@link PresenceBuilder}
     *
     * @param stanzaFactory 来自于{@link XMPPConnection#getStanzaFactory()}
     * @return Presence构造器
     */
    public override func asBuilder(stanzaFactory: StanzaFactory): PresenceBuilder {
        return stanzaFactory.buildPresenceStanzaFrom(this)
    }

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
        if (typ != PresenceType.available) {
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
        match (mode) {
            case Some(v) where v != PresenceMode.available => buf.element("show", v)
            case _ => ()
        }

        buf.append(extensions)

        // Add the error sub-packet, if there is one.
        appendErrorIfExists(buf)
        buf.closeElement(ELEMENT)
        return buf
    }
}

/**
 * 一个枚举来表示存在类型。请注意，存在类型经常与存在模式混淆。一般来说，如果用户登录到服务器，他们的存在类型是{@link #available 可用}，即使模式是{@link PresenceMode#away 离开}、{@link PresenceMode#dnd 请勿打扰}等。只有当用户退出服务器时，存在类型才是{@link #unavailable 不可用}。
 */
public enum PresenceType <: ToString & Equatable<PresenceType> {
    /**
     * 用户可接收消息（默认）。
     */
    available
    /**
     * 用户不可接收消息。
     */
    | unavailable
    /**
     * 请求订阅接收者的存在。
     */
    | subscribe
    /**
     * 同意发送者的存在订阅。
     */
    | subscribed
    /**
     * 请求移除对发送者存在的订阅。
     */
    | unsubscribe
    /**
     * 同意移除对发送者存在的订阅。
     */
    | unsubscribed
    /**
     * 存在节包含错误消息。
     */
    | error
    /**
     * 如 RFC 6121 第 4.3 节所定义的存在探测。
     */
    | probe

    /**
     * 将字符串转换为相应的类型。可以转换为类型的有效字符串值是：“available”、“unavailable”、“subscribe”、“subscribed”、“unsubscribe”、“unsubscribed”和“error”。
     *
     * @param string 要转换的字符串值。
     * @return 相应的存在类型。
     * @throws IllegalArgumentException 当无法解析字符串参数时。
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
}

/**
 * 一个枚举来表示存在模式。
 */
public enum PresenceMode <: ToString & Equatable<PresenceMode> {
    /**
     * 可以聊天。
     */
    chat
    /**
     * 可用（默认）。
     */
    | available
    /**
     * 离开。
     */
    | away
    /**
     * 长时间离开。
     */
    | xa
    /**
     * 请勿打扰。
     */
    | dnd

    /**
     * 将字符串转换为相应的类型。可以转换为类型的有效字符串值是：“chat”、“available”、“away”、“xa”和“dnd”。
     *
     * @param string 要转换的字符串值。
     * @return 相应的存在模式。
     * @throws IllegalArgumentException 当无法解析字符串参数时。
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
}
