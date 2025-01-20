/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.sasl

/**
 * SASL 接口，扩展了 Nonza 接口。
 * <p>
 * 此接口定义了 SASL 的命名空间常量，并提供了获取命名空间的方法。
 * </p>
 */
public interface SaslNonza <: Nonza {
    /**
     * 定义 SASL 的 XML 命名空间
     */
    static prop NAMESPACE: String {
        get() {
            "urn:ietf:params:xml:ns:xmpp-sasl"
        }
    }

    /**
     * 获取命名空间。
     *
     * @return 返回 SASL 的命名空间字符串
     */
    override func getNamespace(): String {
        return NAMESPACE
    }
}

/**
 * 启动 SASL 认证，通过选择认证机制。
 */
public class SaslNonzaAuthMechanism <: SaslNonza {
    /**
     *  定义 XML 元素名称
     */
    public static let ELEMENT = "auth"

    /**
     * 定义 QName，用于指定命名空间和元素名称
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    static init() {
        QNAME_MAPPING.add("SaslNonzaAuthMechanism", QNAME)
        ELEMENT_MAPPING.add("SaslNonzaAuthMechanism", ELEMENT)
        NAMESPACE_MAPPING.add("SaslNonzaAuthMechanism", NAMESPACE)
    }

    /**
     * 认证机制
     */
    private let mechanism: String

    /**
     * 认证文本
     */
    private let authenticationText: String

    /**
     * 构造函数，用于初始化 AuthMechanism 实例。
     *
     * @param mechanism         SASL 认证机制
     * @param authenticationText  SASL 认证文本
     * @throws IllegalArgumentException  如果 authenticationText 为 null 或为空
     */
    public init(mechanism: String, authenticationText: String) {
        this.mechanism = mechanism
        this.authenticationText = StringUtils.requireNotNullNorEmpty(authenticationText,
            "SASL authenticationText must not be null nor empty (RFC6120 6.4.2)")
    }

    /**
     * 将 XmlEnvironment 转换为 XML 字符串。
     *
     * @param xmlEnvironment XML 环境
     * @return              返回表示该实例的 XML 字符串
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, xmlEnvironment)
        xml.attribute("mechanism", mechanism).rightAngleBracket()
        xml.escape(authenticationText)
        xml.closeElement(this)
        return xml
    }

    /**
     * 获取 SASL 认证机制。
     *
     * @return 返回 SASL 认证机制
     */
    public func getMechanism(): String {
        return mechanism
    }

    /**
     * 获取 SASL 认证文本。
     *
     * @return 返回 SASL 认证文本
     */
    public func getAuthenticationText(): String {
        return authenticationText
    }

    /**
     * 获取元素名称。
     *
     * @return 返回元素名称
     */
    public override func getElementName(): String {
        return ELEMENT
    }
}

/**
 * SASL 流元素。
 */
public class SaslNonzaChallenge <: SaslNonza {
    /**
     * 定义 XML 元素名称。
     */
    public static let ELEMENT = "challenge"

    /**
     * 定义 QName，用于指定命名空间和元素名称 。
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    static init() {
        QNAME_MAPPING.add("SaslNonzaChallenge", QNAME)
        ELEMENT_MAPPING.add("SaslNonzaChallenge", ELEMENT)
        NAMESPACE_MAPPING.add("SaslNonzaChallenge", NAMESPACE)
    }

    /**
     * 数据。
     */
    private let data: ?String

    /**
     * 构造函数，用于初始化 Challenge 实例。
     *
     * @param data 挑战数据
     */
    public init(data: ?String) {
        this.data = StringUtils.returnIfNotEmptyTrimmed(data)
    }

    /**
     * 获取数据。
     *
     * @return 返回数据
     */
    public func getData(): ?String {
        return data
    }

    /**
     * 将 XmlEnvironment 转换为 XML 字符串。
     *
     * @param xmlEnvironment XML 环境
     * @return              返回表示该实例的 XML 字符串
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, xmlEnvironment)
        xml.optTextChild(data ?? None, this)
        return xml
    }

    /**
     * 获取元素名称。
     *
     * @return 返回元素名称
     */
    public override func getElementName(): String {
        return ELEMENT
    }
}

/**
 * SASL 响应流元素.
 */
public class SaslNonzaResponse <: SaslNonza {
    /**
     * 定义 XML 元素名称.
     */
    public static let ELEMENT = "response"

    /**
     * 定义 QName，用于指定命名空间和元素名称.
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    static init() {
        QNAME_MAPPING.add("SaslNonzaResponse", QNAME)
        ELEMENT_MAPPING.add("SaslNonzaResponse", ELEMENT)
        NAMESPACE_MAPPING.add("SaslNonzaResponse", NAMESPACE)
    }

    /**
     * 认证文本.
     */
    private let authenticationText: ?String

    /**
     * 无参构造函数，初始化 Response 实例。
     * 认证文本将设为 None
     */
    public init() {
        authenticationText = None
    }

    /**
     * 带参数的构造函数，用于初始化 Response 实例。
     *
     * @param authenticationText SASL 认证文本
     */
    public init(authenticationText: ?String) {
        this.authenticationText = StringUtils.returnIfNotEmptyTrimmed(authenticationText)
    }

    /**
     * 将 XmlEnvironment 转换为 XML 字符串。
     *
     * @param xmlEnvironment XML 环境
     * @return              返回表示该实例的 XML 字符串
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, xmlEnvironment)
        xml.optTextChild(authenticationText ?? None, this)
        return xml
    }

    /**
     * 获取 SASL 认证文本。
     *
     * @return 返回 SASL 认证文本
     */
    public func getAuthenticationText(): ?String {
        return authenticationText
    }

    /**
     * 获取元素名称。
     *
     * @return 返回元素名称
     */
    public override func getElementName(): String {
        return ELEMENT
    }
}

/**
 * SASL 成功流元素.
 */
public class SaslNonzaSuccess <: SaslNonza {
    /**
     * 定义 XML 元素名称
     */
    public static let ELEMENT = "success"

    /**
     * 定义 QName，用于指定命名空间和元素名称
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    static init() {
        QNAME_MAPPING.add("SaslNonzaSuccess", QNAME)
        ELEMENT_MAPPING.add("SaslNonzaSuccess", ELEMENT)
        NAMESPACE_MAPPING.add("SaslNonzaSuccess", NAMESPACE)
    }

    /**
     * 附加数据
     */
    private let data: ?String

    /**
     * 构造一个新的 SASL 成功流元素，可以包含 SASL 层的可选附加数据。(RFC6120 6.3.10)
     *
     * @param data SASL 层的附加数据，或 <code>None</code>
     */
    public init(data: ?String) {
        this.data = StringUtils.returnIfNotEmptyTrimmed(data)
    }

    /**
     * 返回 SASL 层的附加数据或 <code>None</code>。
     *
     * @return 附加数据或 <code>None</code>
     */
    public func getData(): ?String {
        return data
    }

    /**
     * 将 XmlEnvironment 转换为 XML 字符串。
     *
     * @param xmlEnvironment XML 环境
     * @return              返回表示该实例的 XML 字符串
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, xmlEnvironment)
        xml.optTextChild(data ?? None, this)
        return xml
    }

    /**
     * 获取元素名称。
     *
     * @return 返回元素名称
     */
    public override func getElementName(): String {
        return ELEMENT
    }
}

/**
 * 表示 SASL 失败的流元素，也称为 "SASL 错误"。
 *
 * @see <a href="xmpp/org/rfcs/rfc6120.html#sasl-errors">RFC 6120 6.5 SASL Errors</a>
 */
public class SaslNonzaSASLFailure <: AbstractError & SaslNonza & ToString {
    /**
     * 元素名称
     */
    public static let ELEMENT = "failure"

    /**
     * XML 名称查询
     */
    public static let QNAME = QName(NAMESPACE, ELEMENT)

    static init() {
        QNAME_MAPPING.add("SaslNonzaSASLFailure", QNAME)
        ELEMENT_MAPPING.add("SaslNonzaSASLFailure", ELEMENT)
        NAMESPACE_MAPPING.add("SaslNonzaSASLFailure", NAMESPACE)
    }

    private let saslError: SASLError // SASL 错误类型

    private let saslErrorString: String // SASL 错误的字符串表示  

    /**
     * 根据给定的 SASL 错误字符串构造 SASLFailure 对象。
     *
     * @param saslError SASL 错误字符串
     */
    public init(saslError: String) {
        this(saslError, None)
    }

    /**
     * 根据给定的 SASL 错误字符串及描述性文本构造 SASLFailure 对象。
     *
     * @param saslError SASL 错误字符串
     * @param descriptiveTexts 描述性文本的 Map
     */
    public init(saslError: String, descriptiveTexts: ?Map<String, String>) {
        super(descriptiveTexts)
        let error = SASLError.fromString(saslError)
        this.saslError = error ?? SASLError.not_authorized
        this.saslErrorString = saslError
    }

    /**
     * 获取与 SASL 相关的错误条件。
     *
     * @return 与 SASL 相关的错误条件
     */
    public func getSASLError(): SASLError {
        return saslError
    }

    /**
     * 获取 SASL 错误的字符串表示。
     *
     * @return SASL 错误的字符串
     */
    public func getSASLErrorString(): ?String {
        return saslErrorString
    }

    /**
     * 将 XmlEnvironment 转换为 XML 字符串。
     *
     * @param xmlEnvironment XML 环境
     * @return              返回表示该实例的 XML 字符串
     */
    public override func toXML(xmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder()
        xml.halfOpenElement(ELEMENT)
        xml.xmlnsAttribute(NAMESPACE)
        xml.rightAngleBracket()
        xml.emptyElement(saslErrorString)
        addDescriptiveTextsAndExtensions(xml)
        xml.closeElement(ELEMENT)
        return xml
    }

    public override func toString(): String {
        return toXML().toString()
    }

    /**
     * 获取元素名称。
     *
     * @return 返回元素名称
     */
    public override func getElementName(): String {
        return ELEMENT
    }
}
