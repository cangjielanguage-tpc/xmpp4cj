/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 表示 XMPP 错误子包。
 * 通常，服务器通过将节回传并包含一个错误包来响应有问题的请求。每个错误都有一个类型、错误条件以及一个可选的文本解释。典型的错误有：

 * <table border=1>
 *      <caption>XMPP Errors</caption>
 *      <tr>  <th>XMPP Error StanzaErrorCondition</th> <th>StanzaErrorType</th> <th>RFC 6120 Section</th>  </tr>
 *      <tr> <td>bad-request</td>                      <td>MODIFY</td>          <td>8.3.3.1</td>           </tr>
 *      <tr> <td>conflict</td>                         <td>CANCEL</td>          <td>8.3.3.2</td>           </tr>
 *      <tr> <td>feature-not-implemented</td>          <td>CANCEL</td>          <td>8.3.3.3</td>           </tr>
 *      <tr> <td>forbidden</td>                        <td>AUTH</td>            <td>8.3.3.4</td>           </tr>
 *      <tr> <td>gone</td>                             <td>CANCEL</td>          <td>8.3.3.5</td>           </tr>
 *      <tr> <td>internal-server-error</td>            <td>WAIT</td>            <td>8.3.3.6</td>           </tr>
 *      <tr> <td>item-not-found</td>                   <td>CANCEL</td>          <td>8.3.3.7</td>           </tr>
 *      <tr> <td>jid-malformed</td>                    <td>MODIFY</td>          <td>8.3.3.8</td>           </tr>
 *      <tr> <td>not-acceptable</td>                   <td>MODIFY</td>          <td>8.3.3.9</td>           </tr>
 *      <tr> <td>not-allowed</td>                      <td>CANCEL</td>          <td>8.3.3.10</td>          </tr>
 *      <tr> <td>not-authorized</td>                   <td>AUTH</td>            <td>8.3.3.11</td>          </tr>
 *      <tr> <td>policy-violation</td>                 <td>MODIFY</td>          <td>8.3.3.12</td>          </tr>
 *      <tr> <td>recipient-unavailable</td>            <td>WAIT</td>            <td>8.3.3.13</td>          </tr>
 *      <tr> <td>redirect</td>                         <td>MODIFY</td>          <td>8.3.3.14</td>          </tr>
 *      <tr> <td>registration-required</td>            <td>AUTH</td>            <td>8.3.3.15</td>          </tr>
 *      <tr> <td>remote-server-not-found</td>          <td>CANCEL</td>          <td>8.3.3.16</td>          </tr>
 *      <tr> <td>remote-server-timeout</td>            <td>WAIT</td>            <td>8.3.3.17</td>          </tr>
 *      <tr> <td>resource-constraint</td>              <td>WAIT</td>            <td>8.3.3.18</td>          </tr>
 *      <tr> <td>service-unavailable</td>              <td>CANCEL</td>          <td>8.3.3.19</td>          </tr>
 *      <tr> <td>subscription-required</td>            <td>AUTH</td>            <td>8.3.3.20</td>          </tr>
 *      <tr> <td>undefined-condition</td>              <td>MODIFY</td>          <td>8.3.3.21</td>          </tr>
 *      <tr> <td>unexpected-request</td>               <td>WAIT</td>            <td>8.3.3.22</td>          </tr>
 * </table>

 * @see <a href="xmpp/org/rfcs/rfc6120.html#stanzas-error-syntax">RFC 6120 - 8.3.2 Syntax: The Syntax of XMPP error stanzas</a>
 */
public class StanzaError <: AbstractError & ExtensionElement & ToString {
    /**
     * 命名空间
     */
    public static let ERROR_CONDITION_AND_TEXT_NAMESPACE: String = "urn:ietf:params:xml:ns:xmpp-stanzas"

    /**
     * 错误常量
     */
    public static let ERROR: String = "error"

    /**
     * QName对象
     */
    public static let QNAME: QName = QName(StreamOpen.CLIENT_NAMESPACE, ERROR)

    private static let LOGGER: Logger = getGlobalLogger(("name", "StanzaError"))

    static let CONDITION_TO_TYPE: HashMap<StanzaErrorCondition, StanzaErrorType> = HashMap<StanzaErrorCondition, StanzaErrorType>(
        [
            (StanzaErrorCondition.bad_request, StanzaErrorType.MODIFY),
            (StanzaErrorCondition.conflict, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.feature_not_implemented, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.forbidden, StanzaErrorType.AUTH),
            (StanzaErrorCondition.gone, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.internal_server_error, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.item_not_found, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.jid_malformed, StanzaErrorType.MODIFY),
            (StanzaErrorCondition.not_acceptable, StanzaErrorType.MODIFY),
            (StanzaErrorCondition.not_allowed, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.not_authorized, StanzaErrorType.AUTH),
            (StanzaErrorCondition.policy_violation, StanzaErrorType.MODIFY),
            (StanzaErrorCondition.recipient_unavailable, StanzaErrorType.WAIT),
            (StanzaErrorCondition.redirect, StanzaErrorType.MODIFY),
            (StanzaErrorCondition.registration_required, StanzaErrorType.AUTH),
            (StanzaErrorCondition.remote_server_not_found, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.remote_server_timeout, StanzaErrorType.WAIT),
            (StanzaErrorCondition.resource_constraint, StanzaErrorType.WAIT),
            (StanzaErrorCondition.service_unavailable, StanzaErrorType.CANCEL),
            (StanzaErrorCondition.subscription_required, StanzaErrorType.AUTH),
            (StanzaErrorCondition.undefined_condition, StanzaErrorType.MODIFY),
            (StanzaErrorCondition.unexpected_request, StanzaErrorType.WAIT)
        ]
    )

    private let condition: StanzaErrorCondition

    private let conditionText: ?String

    private let errorGenerator: ?String

    private let typ: StanzaErrorType

    /**
     * 用指定的类型、条件和消息创建一个新的错误。
     * 当 XMPPError 不能自动识别条件时，即没有定义的错误条件实例或它不适用默认规范时，使用这个构造函数。
     *
     * @param typ 错误类型。
     * @param condition 错误条件。
     * @param conditionText
     * @param errorGenerator
     * @param descriptiveTexts
     * @param extensions 节扩展列表。
     */
    public init(
        condition: StanzaErrorCondition,
        conditionTextString: ?String,
        errorGenerator: ?String,
        typ: ?StanzaErrorType,
        descriptiveTexts: ?Map<String, String>,
        extensions: ?Collection<ExtensionElement>
    ) {
        super(descriptiveTexts, ERROR_CONDITION_AND_TEXT_NAMESPACE, extensions)
        this.condition = condition // condition must not be None

        // Some implementations may send the condition as non-empty element containing the empty string,
        // that is <condition xmlns='foo'></condition>,
        // in this case the parser may calls this constructor with the empty string as conditionText,
        // therefore reset it to None if it's the empty string
        let conditionText: ?String = if (StringUtils.isNullOrEmpty(conditionTextString)) {
            None
        } else {
            conditionTextString
        }
        if (conditionText.isSome()) {
            match (condition) {
                case gone | redirect => ()
                case _ => throw IllegalArgumentException(
                    "StanzaErrorCondition text can only be set with condtion types 'gone' and 'redirect', not ${condition}"
                )
            }
        }
        this.conditionText = conditionText
        this.errorGenerator = errorGenerator
        this.typ = if (let Some(v) <- typ) {
            v
        } else {
            if (let Some(v) <- CONDITION_TO_TYPE.get(condition)) {
                v
            } else {
                LOGGER.warn("Could not determine typ for condition: ${condition}")
                StanzaErrorType.CANCEL
            }
        }
    }

    /**
     * 返回错误条件。
     *
     * @return 错误条件。
     */
    public func getCondition(): StanzaErrorCondition {
        return condition
    }

    /**
     * 返回错误类型。
     *
     * @return 错误类型。
     */
    public func getType(): StanzaErrorType {
        return typ
    }

    /**
     * 返回错误生成器。
     *
     * @return 错误生成器。
     */
    public func getErrorGenerator(): ?String {
        return errorGenerator
    }

    /**
     * 返回条件文本。
     *
     * @return 条件文本。
     */
    public func getConditionText(): ?String {
        return conditionText
    }

    public override func toString(): String {
        let sb = StringBuilder("XMPPError: ${condition} - ${typ}")

        if (let Some(v) <- getDescriptiveText()) {
            sb.append(" [${v}]")
        }

        if (let Some(v) <- errorGenerator) {
            sb.append(". Generated by ${v}")
        }
        return sb.toString()
    }

    /**
     * 返回节点元素名称。
     *
     * @return 节点元素名称。
     */
    public override func getElementName(): String {
        return QNAME.getLocalPart()
    }

    /**
     * 返回节点元素命名空间。
     *
     * @return 节点元素命名空间。
     */
    public override func getNamespace(): String {
        return QNAME.getNamespaceURI()
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.attribute("type", typ.toString())
        xml.optAttribute("by", errorGenerator)
        xml.rightAngleBracket()

        xml.halfOpenElement(condition.toString())
        xml.xmlnsAttribute(ERROR_CONDITION_AND_TEXT_NAMESPACE)
        if (conditionText.isSome()) {
            xml.rightAngleBracket()
            xml.escape(conditionText)
            xml.closeElement(condition.toString())
        } else {
            xml.closeEmptyElement()
        }

        addDescriptiveTextsAndExtensions(xml)

        xml.closeElement(this)
        return xml
    }

    /**
     * 通过StanzaErrorCondition对象和描述文本生成StanzaErrorBuilder对象
     *
     * @param condition StanzaErrorCondition对象
     * @param descriptiveText 描述文本
     * @return StanzaErrorBuilder对象
     */
    public static func froms(condition: StanzaErrorCondition, descriptiveText: ?String): StanzaErrorBuilder {
        let builder = getBuilder().setCondition(condition)
        if (let Some(descriptiveText) <- descriptiveText) {
            let descriptiveTexts = HashMap<String, String>([("en", descriptiveText)])
            builder.setDescriptiveTexts(descriptiveTexts)
        }
        return builder
    }

    /**
     * 生成一个空的StanzaErrorBuilder对象
     *
     * @return 空的StanzaErrorBuilder对象
     */
    public static func getBuilder(): StanzaErrorBuilder {
        return StanzaErrorBuilder()
    }

    /**
     * 通过StanzaErrorCondition对象生成StanzaErrorBuilder对象
     *
     * @param condition StanzaErrorCondition对象
     * @return StanzaErrorBuilder对象
     */
    public static func getBuilder(condition: StanzaErrorCondition): StanzaErrorBuilder {
        return getBuilder().setCondition(condition)
    }

    /**
     * 通过StanzaError对象生成StanzaErrorBuilder对象
     *
     * @param xmppError StanzaError对象
     * @return StanzaErrorBuilder
     */
    public static func getBuilder(xmppError: StanzaError): StanzaErrorBuilder {
        return getBuilder().copyFrom(xmppError)
    }
}

public class StanzaErrorBuilder <: AbstractErrorBuilder {
    private var condition: ?StanzaErrorCondition = None // 错误条件
    private var conditionText: ?String = None // 条件文本
    private var errorGenerator: ?String = None // 错误生成器
    private var typ: ?StanzaErrorType = None // 错误类型

    init() {}

    /**
     * 设置错误条件
     *
     * @param condition 错误条件
     * @return 当前 Builder 实例
     */
    public func setCondition(condition: StanzaErrorCondition): StanzaErrorBuilder {
        this.condition = condition
        return this
    }

    /**
     * 设置错误类型
     *
     * @param type 错误类型
     * @return 当前 Builder 实例
     */
    public func setType(typ: StanzaErrorType): StanzaErrorBuilder {
        this.typ = typ
        return this
    }

    /**
     * 设置条件文本
     *
     * @param conditionText 条件文本
     * @return 当前 Builder 实例
     */
    public func setConditionText(conditionText: ?String): StanzaErrorBuilder {
        this.conditionText = conditionText
        return this
    }

    /**
     * 设置错误生成器
     *
     * @param errorGenerator 错误生成器
     * @return 当前 Builder 实例
     */
    public func setErrorGenerator(errorGenerator: ?String): StanzaErrorBuilder {
        this.errorGenerator = errorGenerator
        return this
    }

    /**
     * 从给定的 StanzaError 对象复制属性到当前 Builder
     *
     * @param xmppError 源 StanzaError 对象
     * @return 当前 Builder 实例
     */
    public func copyFrom(xmppError: StanzaError): StanzaErrorBuilder {
        setCondition(xmppError.getCondition())
        setType(xmppError.getType())
        setConditionText(xmppError.getConditionText())
        setErrorGenerator(xmppError.getErrorGenerator())
        setDescriptiveTexts(xmppError.descriptiveTexts)
        setTextNamespace(xmppError.textNamespace)
        setExtensions(xmppError.extensions)
        return this
    }

    /**
     * 构建并返回一个 StanzaError 对象
     *
     * @return 新创建的 StanzaError 对象
     */
    public func build(): StanzaError {
        let exts: ?Collection<ExtensionElement> = if (let Some(v) <- extensions) {
            v
        } else {
            None
        }
        return StanzaError(condition.getOrThrow(), conditionText, errorGenerator, typ, descriptiveTexts, exts)
    }
}

/**
 * 一个表示错误类型的类。类型有：

 * <ul>
 *      <li>XMPPErrorType.WAIT - 等待后重试（错误是暂时的）
 *      <li>XMPPErrorType.CANCEL - 不要重试（错误不可恢复）
 *      <li>XMPPErrorType.MODIFY - 在更改发送的数据后重试
 *      <li>XMPPErrorType.AUTH - 在提供凭证后重试
 *      <li>XMPPErrorType.CONTINUE - 继续（条件只是一个警告）
 * </ul>
 */
public enum StanzaErrorType <: ToString {
    /**
     * 等待后重试（错误是暂时的）
     */
    | WAIT
    /**
     * 不要重试（错误不可恢复）
     */
    | CANCEL
    /**
     * 在更改发送的数据后重试
     */
    | MODIFY
    /**
     * 在提供凭证后重试
     */
    | AUTH
    /**
     * 继续（条件只是一个警告）
     */
    | CONTINUE

    public func toString(): String {
        match (this) {
            case WAIT => "wait"
            case CANCEL => "cancel"
            case MODIFY => "modify"
            case AUTH => "auth"
            case CONTINUE => "continue"
        }
    }

    /**
     * 通过传入参数获取枚举值。
     *
     * #param string 文本
     * @return 枚举值
     */
    public static func fromString(string: String): StanzaErrorType {
        match (string.toAsciiUpper()) {
            case "WAIT" => WAIT
            case "CANCEL" => CANCEL
            case "MODIFY" => MODIFY
            case "AUTH" => AUTH
            case "CONTINUE" => CONTINUE
            case _ => throw IllegalArgumentException("Not a valid type: ${string}")
        }
    }
}

/**
 * 枚举类 Condition，表示 XMPP 错误条件。
 */
public enum StanzaErrorCondition <: ToString & Equatable<StanzaErrorCondition> & Hashable {
    /**
     * 错误请求
     */
    bad_request
    /**
     * 冲突
     */
    | conflict
    /**
     * 功能未实现
     */
    | feature_not_implemented
    /**
     * 禁止
     */
    | forbidden
    /**
     * 已消失
     */
    | gone
    /**
     * 服务器内部错误
     */
    | internal_server_error
    /**
     * 找不到项目
     */
    | item_not_found
    /**
     * JID 格式错误
     */
    | jid_malformed
    /**
     * 不可接受
     */
    | not_acceptable
    /**
     * 不允许
     */
    | not_allowed
    /**
     * 未授权
     */
    | not_authorized
    /**
     * 政策违规
     */
    | policy_violation
    /**
     * 收件人不可用
     */
    | recipient_unavailable
    /**
     * 重定向
     */
    | redirect
    /**
     * 需要注册
     */
    | registration_required
    /**
     * 找不到远程服务器
     */
    | remote_server_not_found
    /**
     * 远程服务器超时
     */
    | remote_server_timeout
    /**
     * 资源限制
     */
    | resource_constraint
    /**
     * 服务不可用
     */
    | service_unavailable
    /**
     * 需要订阅
     */
    | subscription_required
    /**
     * 未定义条件
     */
    | undefined_condition
    /**
     * 意外请求
     */
    | unexpected_request

    /**
     * 从字符串创建对应的 Condition 枚举常量。
     *
     * @param string 要转换的字符串，使用连字符
     * @return 对应的 Condition 枚举常量
     * @throws IllegalStateException 如果无法转换字符串为 Condition
     */
    public static func fromString(string: String): StanzaErrorCondition {
        return match (string.replace('-', '_')) {
            case "bad_request" => StanzaErrorCondition.bad_request
            case "conflict" => StanzaErrorCondition.conflict
            case "feature_not_implemented" => StanzaErrorCondition.feature_not_implemented
            case "forbidden" => StanzaErrorCondition.forbidden
            case "gone" => StanzaErrorCondition.gone
            case "internal_server_error" => StanzaErrorCondition.internal_server_error
            case "item_not_found" => StanzaErrorCondition.item_not_found
            case "jid_malformed" => StanzaErrorCondition.jid_malformed
            case "not_acceptable" => StanzaErrorCondition.not_acceptable
            case "not_allowed" => StanzaErrorCondition.not_allowed
            case "not_authorized" => StanzaErrorCondition.not_authorized
            case "policy_violation" => StanzaErrorCondition.policy_violation
            case "recipient_unavailable" => StanzaErrorCondition.recipient_unavailable
            case "redirect" => StanzaErrorCondition.redirect
            case "registration_required" => StanzaErrorCondition.registration_required
            case "remote_server_not_found" => StanzaErrorCondition.remote_server_not_found
            case "remote_server_timeout" => StanzaErrorCondition.remote_server_timeout
            case "resource_constraint" => StanzaErrorCondition.resource_constraint
            case "service_unavailable" => StanzaErrorCondition.service_unavailable
            case "subscription_required" => StanzaErrorCondition.subscription_required
            case "undefined_condition" => StanzaErrorCondition.undefined_condition
            case "unexpected_request" => StanzaErrorCondition.unexpected_request
            case v => throw IllegalArgumentException("Could not transform string '${v}' to XMPPErrorCondition")
        }
    }

    public override func toString(): String {
        return match (this) {
            case StanzaErrorCondition.bad_request => "bad-request"
            case StanzaErrorCondition.conflict => "conflict"
            case StanzaErrorCondition.feature_not_implemented => "feature-not-implemented"
            case StanzaErrorCondition.forbidden => "forbidden"
            case StanzaErrorCondition.gone => "gone"
            case StanzaErrorCondition.internal_server_error => "internal-server-error"
            case StanzaErrorCondition.item_not_found => "item-not-found"
            case StanzaErrorCondition.jid_malformed => "jid-malformed"
            case StanzaErrorCondition.not_acceptable => "not-acceptable"
            case StanzaErrorCondition.not_allowed => "not-allowed"
            case StanzaErrorCondition.not_authorized => "not-authorized"
            case StanzaErrorCondition.policy_violation => "policy-violation"
            case StanzaErrorCondition.recipient_unavailable => "recipient-unavailable"
            case StanzaErrorCondition.redirect => "redirect"
            case StanzaErrorCondition.registration_required => "registration-required"
            case StanzaErrorCondition.remote_server_not_found => "remote-server-not-found"
            case StanzaErrorCondition.remote_server_timeout => "remote-server-timeout"
            case StanzaErrorCondition.resource_constraint => "resource-constraint"
            case StanzaErrorCondition.service_unavailable => "service-unavailable"
            case StanzaErrorCondition.subscription_required => "subscription-required"
            case StanzaErrorCondition.undefined_condition => "undefined-condition"
            case StanzaErrorCondition.unexpected_request => "unexpected-request"
        }
    }

    public operator func ==(that: StanzaErrorCondition): Bool {
        return if (this.toString() == that.toString()) {
            true
        } else {
            false
        }
    }

    public override func hashCode(): Int64 {
        return toString().hashCode()
    }
}
