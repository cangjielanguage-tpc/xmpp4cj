/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 表示 XMPP 消息包。消息可以是以下几种类型之一：
 *
 * <ul>
 *      <li>MessageType.NORMAL --（默认）用于类似电子邮件界面的普通文本消息。
 *      <li>MessageType.CHAT -- 用于逐行聊天界面的通常较短的文本消息。
 *      <li>MessageType.GROUP_CHAT -- 发送到群聊服务器的群聊消息。
 *      <li>MessageType.HEADLINE -- 用于滚动字幕显示的文本消息。
 *      <li>MessageType.ERROR -- 表示消息错误。
 * </ul>
 *
 * 对于每种消息类型，通常不同的消息字段如下使用：
 * <table border="1">
 * <caption>消息类型</caption>
 * <tr><td>&nbsp;</td><td colspan="5"><b>消息类型</b></td></tr>
 * <tr><td><i>字段</i></td><td><b>普通</b></td><td><b>聊天</b></td><td><b>群聊</b></td><td><b>头条</b></td><td><b>XMPP 错误</b></td></tr>
 * <tr><td><i>主题</i></td><td>应该</td><td>不应该</td><td>不应该</td><td>不应该</td><td>不应该</td></tr>
 * <tr><td><i>线程</i></td><td>可选</td><td>应该</td><td>可选</td><td>可选</td><td>不应该</td></tr>
 * <tr><td><i>正文</i></td><td>应该</td><td>应该</td><td>应该</td><td>应该</td><td>不应该</td></tr>
 * <tr><td><i>错误</i></td><td>不应该</td><td>不应该</td><td>不应该</td><td>不应该</td><td>必须</td></tr>
 * </table>
 */
public class Message <: MessageOrPresence & MessageView & ToString {
    /**
     * message常量
     */
    public static let ELEMENT = "message"

    /**
     * body常量
     */
    public static let BODY = "body"

    private var typ: ?MessageType = None

    init(messageBuilder: MessageBuilder) {
        super(messageBuilder)
        typ = messageBuilder.typ
    }

    /**
     * 复制构造函数。
     * <p>
     * 这不会执行深度克隆，因为扩展元素在新实例和旧实例之间共享。
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

    /**
     * 返回一个构造器来构建当前的消息或存在状态。
     *
     * @return 当前消息或存在状态的构造器。
     */
    public override func asBuilder(): MessageBuilder {
        return StanzaBuilder.buildMessageFrom(this, getStanzaId())
    }

    /**
     * 使用指定的标识符返回一个构造器来构建当前的消息或存在状态。
     *
     * @param id 消息或存在状态的标识符。
     * @return 带有指定标识符的构造器。
     */
    public override func asBuilder(id: String): MessageBuilder {
        return StanzaBuilder.buildMessageFrom(this, id)
    }

    /**
     * 使用指定的{@link StanzaFactory}构建{@link PresenceBuilder}
     *
     * @param stanzaFactory 来自于{@link XMPPConnection#getStanzaFactory()}
     * @return Presence构造器
     */
    public override func asBuilder(stanzaFactory: StanzaFactory): MessageBuilder {
        return stanzaFactory.buildMessageStanzaFrom(this)
    }

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
        buf.append(getExtensions())
        buf.closeElement(ELEMENT)
        return buf
    }
}

/**
 * 表示消息的类型。
 */
public enum MessageType <: Equatable<MessageType> & ToString {
    /**
     * （默认）用于类似电子邮件界面的普通文本消息。
     */
    | normal
    /**
     * 用于逐行聊天界面的通常较短的文本消息。
     */
    | chat
    /**
     * 发送到群聊服务器的群聊消息。
     */
    | groupchat
    /**
     * 用于滚动字幕显示的文本消息。
     */
    | headline
    /**
     * 表示消息错误。
     */
    | error

    /**
     * 将字符串转换为相应的类型。
     * 可以转换为类型的有效字符串值是：“normal”、“chat”、“groupchat”、“headline”和“error”。
     *
     * @param string 要转换的字符串值。
     * @return 相应的类型。
     * @throws IllegalArgumentException 当无法解析字符串参数时。
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
}

/**
 * 表示消息主题、其语言以及主题内容。
 */
public class MessageSubject <: ExtensionElement & Hashable & Equatable<MessageSubject> {
    /**
     * 元素名称。
     */
    public static let ELEMENT = "subject"

    /**
     * 命名空间。
     */
    public static let NAMESPACE = StreamOpen.CLIENT_NAMESPACE

    /**
     * QNAME对象。
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private let subject: String

    let language: ?String

    /**
     * 构造方法。
     *
     * @param language 语言。
     * @param subject 主题。
     */
    public init(language: ?String, subject: String) {
        this.language = language
        this.subject = subject
    }

    public override func getLanguage(): ?String {
        return language
    }

    /**
     * 返回主题内容。
     *
     * @return 主题的内容。
     */
    public func getSubject(): String {
        return subject
    }

    private let hashCodeCache = HashCodeCache()

    public override func hashCode(): Int64 {
        return hashCodeCache.getHashCode {c => c.append(language ?? None).append<String>(subject)}
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
 * 表示消息正文、其语言以及消息内容。
 */
public class MessageBody <: ExtensionElement & Hashable & Equatable<MessageBody> {
    /**
     * body名称。
     */
    public static let ELEMENT: String = "body"

    /**
     * 命名空间。
     */
    public static let NAMESPACE: String = StreamOpen.CLIENT_NAMESPACE

    /**
     * QNAME对象。
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    private let message: String

    private let language: ?String

    private let namespace: MessageBodyElementNamespace

    /**
     * 构造方法。
     *
     * @param language 语言。
     * @param subject 主题。
     */
    public init(language: ?String, message: String) {
        this(language, message, MessageBodyElementNamespace.client)
    }

    /**
     * 构造方法。
     *
     * @param language 语言。
     * @param message 消息信息。
     * @param namespace 命名空间。
     */
    public init(language: ?String, message: String, namespace: MessageBodyElementNamespace) {
        this.language = language
        this.message = message
        this.namespace = namespace
    }

    public override func getLanguage(): ?String {
        return language
    }

    /**
     * 返回消息内容。
     *
     * @return 消息的内容。
     */
    public func getMessage(): String {
        return message
    }

    private let hashCodeCache = HashCodeCache()

    public override func hashCode(): Int64 {
        let hashable: ?Hashable = language ?? None
        return Int64(hashCodeCache.getHashCode({c => c.append(hashable).append<String>(message)}))
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
    /**
     * 客户端
     */
    | client
    /**
     * 服务端
     */
    | server

    /**
     * 通过枚举获取具体哪个端
     */
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
    /**
     * thread常量
     */
    public static let ELEMENT: String = "thread"

    /**
     * 命名空间
     */
    public static let NAMESPACE: String = StreamOpen.CLIENT_NAMESPACE

    /**
     * QNAME对象
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    /**
     * parent常量
     */
    public static let PARENT_ATTRIBUTE_NAME = "parent"

    private let thread: String

    private let parent: ?String

    /**
     * 通过线程名称构造当前对象。
     *
     * @param thread 线程名称。
     */
    public init(thread: String) {
        this(thread, None)
    }

    /**
     * 通过线程名称和父类名称构造当前对象。
     *
     * @param thread 线程名称。
     * @param parent 父类名称。
     */
    public init(thread: String, parent: ?String) {
        this.thread = StringUtils.requireNotNullNorEmpty(thread, "thread must not be None nor empty")
        this.parent = StringUtils.requireNullOrNotEmpty(parent, "parent must be None or not empty")
    }

    /**
     * 获取线程名称。
     *
     * @return 线程名称。
     */
    public func getThread(): String {
        return thread
    }

    /**
     * 获取父类名称。
     *
     * @return 父类名称。
     */
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
        xml.optAttribute(PARENT_ATTRIBUTE_NAME, parent)
        xml.rightAngleBracket()
        xml.escape(thread)
        xml.closeElement(this)
        return xml
    }
}
