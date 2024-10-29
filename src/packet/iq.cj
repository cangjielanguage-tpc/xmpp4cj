/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

public interface IqView <: StanzaView & ToString {
    /**
     * 返回 IQ 包的类型。
     *
     * @return IQ 包的类型。
     */
    func getType(): IQType

    /**
     * 如果这是一个请求 IQ（即 IQ 类型为 {@link Type#get} 或 {@link Type#set}），则返回 true。
     *
     * @return 如果 IQ 类型是“get”或“set”，则为 true，否则为 false。
     */
    func isRequestIQ(): Bool {
        let typ = getType()
        return typ == IQType.get || typ == IQType.set
    }

    /**
     * 如果这是一个响应 IQ（即 IQ 类型为 {@link Type#result} 或 {@link Type#error}），则返回 true。
     *
     * @return 如果 IQ 类型是“result”或“error”，则为 true，否则为 false。
     */
    func isResponseIQ(): Bool {
        return !isRequestIQ()
    }
}

/**
 * 基础 IQ（信息/查询）包。IQ 包用于在服务器上获取和设置信息，包括认证、通讯录操作和创建账户。每个 IQ 节都有一个特定的类型，指示正在采取的操作类型：“get”、“set”、“result”或“error”。<p>
 *
 * IQ 包可以包含一个存在于特定 XML 命名空间中的子元素。元素名称和命名空间的组合决定了它是哪种类型的 IQ 节。一些 IQ 子包片段的示例：<ul>
 *
 *  <li>&lt;query xmlns="jabber:iq:auth"&gt; -- 一个认证 IQ。
 *  <li>&lt;query xmlns="jabber:iq:private"&gt; -- 一个私有存储 IQ。
 *  <li>&lt;pubsub xmlns="${JABBER_PROTOCAL_NAMESPACE_PREFIX}/pubsub"&gt; -- 一个发布订阅 IQ。
 * </ul>
 */
public abstract class IQ <: Stanza & IqView {
    /**
     * 不要将此字段命名为“ELEMENT”。当它从IQ变为ELEMENT时，ELEMENT是子元素！
     */
    public static let IQ_ELEMENT = "iq"

    /**
     * query常量
     */
    public static let QUERY_ELEMENT = "query"

    private let childElementQName: QName

    private let childElementName: String

    private let childElementNamespace: String

    /**
     * IQType对象
     */
    protected var typ: IQType = IQType.get

    /**  
     * 使用现有 IQ 对象初始化新 IQ 对象。
     *
     * @param iq 现有的 IQ 对象。
     */
    protected init(iq: IQ) {
        super(iq)
        typ = iq.getType()
        this.childElementName = iq.childElementName
        this.childElementNamespace = iq.childElementNamespace
        this.childElementQName = iq.childElementQName
    }

    /**  
     * 使用子元素名称和命名空间初始化 IQ 对象。
     * <p>
     * 该构造函数将被弃用，待数据包构造器准备就绪后。
     * </p>
     *
     * @param childElementName 子元素的名称
     * @param childElementNamespace 子元素的命名空间
     */
    protected init(childElementName: String, childElementNamespace: String) {
        this(IqData.EMPTY, childElementName, childElementNamespace)
    }

    /**  
     * 使用 IQ Builder 和子元素名称及命名空间初始化 IQ 对象。
     *
     * @param iqBuilder IQ 的 Builder 对象
     * @param childElementName 子元素的名称
     * @param childElementNamespace 子元素的命名空间
     */
    protected init(iqBuilder: AbstractIqBuilder, childElementName: String, childElementNamespace: String) {
        this(
            iqBuilder,
            if (childElementName == EMPTY_ELEMENT) {
                EMPTY_QNAME
            } else {
                QName(childElementNamespace, childElementName)
            }
        )
    }

    /**  
     * 使用 IQ Builder 和子元素的 QName 初始化 IQ 对象。
     *
     * @param iqBuilder IQ 的 Builder 对象
     * @param childElementQName 子元素的 QName
     */
    protected init(iqBuilder: AbstractIqBuilder, childElementQName: ?QName) {
        super(iqBuilder)
        typ = iqBuilder.typ
        if (let Some(childElementQName) <- childElementQName) {
            this.childElementQName = childElementQName
            this.childElementName = childElementQName.getLocalPart()
            this.childElementNamespace = childElementQName.getNamespaceURI()
        } else {
            this.childElementQName = EMPTY_QNAME
            this.childElementName = EMPTY_ELEMENT
            this.childElementNamespace = EMPTY_NAMESPACE
        }
    }

    /**  
     * 获取 IQ 数据包的类型。
     *
     * @return IQ 的类型。
     */
    public override func getType(): IQType {
        return typ
    }

    /**
     * 设置 IQ 包的类型。
     * <p>
     * 由于 IQ 的类型必须存在，当类型为 <code>None</code> 时，将抛出 IllegalArgumentException。
     * </p>
     *
     * @param type IQ 包的类型。
     */
    public func setType(typ: IQType): Unit {
        this.typ = typ
    }

    /**  
     * 获取子元素的QName。
     *
     * @return 子元素的QName。
     */
    public func getChildElementQName(): QName {
        return childElementQName
    }

    /**  
     * 获取子元素的名称。
     *
     * @return 子元素的名称。
     */
    public func getChildElementName(): String {
        return childElementName
    }

    /**  
     * 获取子元素的命名空间。
     *
     * @return 子元素的命名空间。
     */
    public func getChildElementNamespace(): String {
        return childElementNamespace
    }

    /**  
     * 获取当前元素的标识。
     *
     * @return 当前元素的标识。
     */
    public override func getElementName(): String {
        return IQ_ELEMENT
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("IQ Stanza (")
        sb.append(getChildElementName())
        sb.append(' ')
        sb.append(getChildElementNamespace())
        sb.append(") [")
        logCommonAttributes(sb)
        sb.append("type=")
        sb.append(typ.toString())
        sb.append(',')
        sb.append(']')
        return sb.toString()
    }

    public override func toXML(enclosingXmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let buf = XmlStringBuilder(this, enclosingXmlEnvironment)
        addCommonAttributes(buf)
        buf.attribute("type", typ.toString())
        buf.rightAngleBracket()
        appendInnerXml(buf)
        buf.closeElement(IQ_ELEMENT)
        return buf
    }

    /**
     * 返回 IQ 包的子元素 XML 部分，如果没有则返回空字符串。
     *
     * @return IQ XML 的子元素部分。
     */
    public func getChildElementXML(): XmlStringBuilder {
        let xml = XmlStringBuilder()
        appendInnerXml(xml)
        return xml
    }

    /**
     * 追加 IQ 节的子元素 XML 部分。
     *
     * @param xml 要追加的 XmlStringBuilder。
     */
    private func appendInnerXml(xml: XmlStringBuilder): Unit {
        if (typ == IQType.error) {
            appendErrorIfExists(xml)
        }
        if (childElementName.size == 0) {
            return
        }

        // Add the query section if there is one.
        let iqChildElement = if (let Some(v) <- getIQChildElementBuilder(
            IQChildElementXmlStringBuilder(getChildElementName(), getChildElementNamespace(), None,
            xml.getXmlEnvironment()))) {
            v
        } else {
            return
        }
        xml.append(iqChildElement)
        let extensionsXml = getExtensions()
        if (iqChildElement.isEmptyElement) {
            if (extensionsXml.isEmpty()) {
                xml.closeEmptyElement()
                return
            }
            xml.rightAngleBracket()
        }
        xml.append(extensionsXml)
        xml.closeElement(iqChildElement.elementName)
    }

    /**
     * 这个方法必须由 IQ 子类重写以创建它们的子内容。重要的是你不要使用构建器<b>添加最终的结束标签</b>。这将在最终存在的 {@link ExtensionElement} 被添加后由 {@link IQChildElementXmlStringBuilder} 自动完成。
     * <p>
     * 例如，要创建一个带有额外属性和一个附加子元素的 IQ：
     * </p>
     * <pre>
     * {@code
     * <iq to='foo@example.org' id='123'>
     *   <bar xmlns='example:bar' extraAttribute='blaz'>
     *      <extraElement>elementText</extraElement>
     *   </bar>
     * </iq>
     * }
     * </pre>
     * {@code getIQChildElementBuilder} 的主体如下所示：
     * <pre>
     * {@code
     * // 构建器“xml”已经添加了子元素和“xmlns”属性
     * // 所以当前构建器状态是“<bar xmlns='example:bar'”
     * xml.attribute("extraAttribute", "blaz")
     * xml.rightAngleBracket()
     * xml.element("extraElement", "elementText")
     * // 不要通过调用 xml.closeElement('bar') 关闭“bar”属性
     * }
     * </pre>
     * 如果你的 IQ 只包含属性而没有子元素，即它可以表示为空元素，那么你可以将其标记为这样。
     * <pre>
     * xml.attribute("myAttribute", "myAttributeValue")
     * xml.setEmptyElement()
     * </pre>
     * 如果你的 IQ 不包含任何属性或子元素（除了 {@link ExtensionElement} 之外），考虑继承 {@link SimpleIQ} 代替。
     *
     * @param xml 一个预先创建的构建器，已经设置了子元素和“xmlns”属性。
     * @return 创建 IQ 子内容的构建器。
     */
    protected func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder

    /**
     * 方便方法，基于 {@link Type#get IQType.get} 或 {@link Type#set IQType.set} 的 IQ 创建一个新的空 {@link Type#result IQType.result} IQ。新的节将以下列方式初始化：<ul>
     *      <li>发送者设置为原始 IQ 的接收者。
     *      <li>接收者设置为原始 IQ 的发送者。
     *      <li>类型设置为 {@link Type#result IQType.result}。
     *      <li>ID 设置为原始 IQ 的 ID。
     *      <li>IQ 元素没有子元素。
     * </ul>
     *
     * @param request {@link Type#get IQType.get} 或 {@link Type#set IQType.set} 的 IQ 包。
     * @throws IllegalArgumentException 如果 IQ 节的类型不是 {@link Type#get IQType.get} 或 {@link Type#set IQType.set}。
     * @return 基于原始 IQ 的新的 {@link Type#result IQType.result} IQ。
     */
    public static func createResultIQ(request: IQ): IQ {
        return EmptyResultIQ(request)
    }

    /**
     * 方便方法，基于 {@link Type#get IQType.get} 或 {@link Type#set IQType.set} 的 IQ 创建一个新的 {@link Type#error IQType.error} IQ。新的节将以下列方式初始化：<ul>
     *      <li>发送者设置为原始 IQ 的接收者。
     *      <li>接收者设置为原始 IQ 的发送者。
     *      <li>类型设置为 {@link Type#error IQType.error}。
     *      <li>ID 设置为原始 IQ 的 ID。
     *      <li>包含在相关原始 IQ 中的子元素。
     *      <li>提供的 {@link StanzaError XMPPError}。
     * </ul>
     *
     * @param request {@link Type#get IQType.get} 或 {@link Type#set IQType.set} 的 IQ 包。
     * @param error 与创建的 IQ 包相关联的错误。
     * @throws IllegalArgumentException 如果 IQ 节的类型不是 {@link Type#get IQType.get} 或 {@link Type#set IQType.set}。
     * @return 基于原始 IQ 的新的 {@link Type#error IQType.error} IQ。
     */
    public static func createErrorResponse(request: IQ, error: StanzaError): ErrorIQ {
        return ErrorIQ.createErrorResponse(request, error)
    }

    /**
     * 方便方法，基于 {@link Type#get IQType.get} 或 {@link Type#set IQType.set} 的 IQ 创建一个新的 {@link Type#error IQType.error} IQ。新的节将以下列方式初始化：<ul>
     *      <li>发送者设置为原始 IQ 的接收者。
     *      <li>接收者设置为原始 IQ 的发送者。
     *      <li>类型设置为 {@link Type#error IQType.error}。
     *      <li>ID 设置为原始 IQ 的 ID。
     *      <li>包含在相关原始 IQ 中的子元素。
     *      <li>提供的 {@link StanzaError XMPPError}。
     * </ul>
     *
     * @param request {@link Type#get IQType.get} 或 {@link Type#set IQType.set} 的 IQ 包。
     * @param condition StanzaErrorCondition。
     * @throws IllegalArgumentException 如果 IQ 节的类型不是 {@link Type#get IQType.get} 或 {@link Type#set IQType.set}。
     * @return 基于原始 IQ 的新的 {@link Type#error IQType.error} IQ。
     */
    public static func createErrorResponse(request: IQ, condition: StanzaErrorCondition): ErrorIQ {
        return createErrorResponse(request, StanzaError.getBuilder(condition).build())
    }
}

/**
 * 一个枚举来表示 IQ 节的类型。
 */
public enum IQType <: ToString & Equatable<IQType> {
    /**
     * IQ 节请求信息，询问为了完成进一步操作需要什么数据等。
     */
    get
    /**
     * IQ 节提供完成操作所需的数据，设置新值，替换现有值等。
     */
    | set
    /**
     * IQ 节是对成功的 get 或 set 请求的响应。
     */
    | result
    /**
     * IQ 节报告在处理或传递 get 或 set 请求时发生的错误。
     */
    | error

    /**
     * 将字符串转换为相应的类型。可以转换为类型的有效字符串值是：“get”、“set”、“result”和“error”。
     *
     * @param string 要转换的字符串值。
     * @return 相应的类型。
     * @throws IllegalArgumentException 当无法解析字符串参数时。
     */
    public static func fromString(string: String): IQType {
        match (string.toAsciiLower()) {
            case "get" => get
            case "set" => set
            case "result" => result
            case "error" => error
            case _ => throw IllegalArgumentException("Invalid IQType: ${string}")
        }
    }

    public override func toString(): String {
        return match (this) {
            case get => "get"
            case set => "set"
            case result => "result"
            case error => "error"
        }
    }

    public operator func ==(that: IQType): Bool {
        return match ((this, that)) {
            case (get, get) => true
            case (set, set) => true
            case (result, result) => true
            case (error, error) => true
            case _ => false
        }
    }
}

public enum IQResponseType <: ToString & Equatable<IQResponseType> {
    /**
     * 返回成功。
     */
    result
    /**
     * 返回失败。
     */
    | error

    func getType(): IQType {
        match (this) {
            case result => IQType.result
            case error => IQType.error
        }
    }

    public override func toString(): String {
        return match (this) {
            case result => "result"
            case error => "error"
        }
    }

    public operator func ==(that: IQResponseType): Bool {
        match ((this, that)) {
            case (result, result) => true
            case (error, error) => true
            case _ => false
        }
    }
}

/**  
 * {@code IQChildElementXmlStringBuilder} 是一个用于构建 IQ 数据包子元素的 XML 字符串构造器。
 * <p>
 * 此类扩展了 {@link XmlStringBuilder}，用于生成特定于 IQ 数据包的 XML 子元素的字符串表示。
 * 它提供了对元素名称、命名空间、语言和 XML 环境的支持，允许灵活地创建 XML 数据结构。
 * </p>
 */
public class IQChildElementXmlStringBuilder <: XmlStringBuilder {
    var elementName: String = EMPTY_ELEMENT

    var isEmptyElement: Bool = false // 指示当前构建器是否应生成一个空元素  

    /**  
     * 使用给定的扩展元素和 XML 环境初始化 {@code IQChildElementXmlStringBuilder}。
     *
     * @param extensionElement 要构建的扩展元素。
     * @param enclosingXmlEnvironment 包含的 XML 环境。
     */
    public init(extensionElement: ExtensionElement, enclosingXmlEnvironment: ?XmlEnvironment) {
        this(
            extensionElement.getElementName(),
            extensionElement.getNamespace(),
            extensionElement.getLanguage(),
            enclosingXmlEnvironment
        )
    }

    /**  
     * 使用指定的元素名称、命名空间、语言和 XML 环境初始化 {@code IQChildElementXmlStringBuilder} 实例。
     *
     * @param elementName 元素的名称。
     * @param xmlNs 元素的命名空间。
     * @param xmlLang 元素的语言。
     * @param enclosingXmlEnvironment 包含的 XML 环境，可以用于定义 XML 属性和结构。
     */
    init(elementName: String, xmlNs: String, xmlLang: ?String, enclosingXmlEnvironment: ?XmlEnvironment) {
        super(elementName, xmlNs, xmlLang, enclosingXmlEnvironment)
        this.elementName = elementName
    }

    /**  
     * 设置构建器为生成一个空元素。
     * <p>
     * 该方法被调用后，在构建 XML 时，将生成自闭合的 XML 元素。
     * </p>
     */
    public func setEmptyElement(): Unit {
        isEmptyElement = true
    }
}
