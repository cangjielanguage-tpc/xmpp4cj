/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
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
    public static let ERROR_CONDITION_AND_TEXT_NAMESPACE: String = "urn:ietf:params:xml:ns:xmpp-stanzas"
    public static let ERROR: String = "error"
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

    public func getErrorGenerator(): ?String {
        return errorGenerator
    }

    public func getConditionText(): ?String {
        return conditionText
    }

    public func toString(): String {
        let sb = StringBuilder("XMPPError: ${condition} - ${typ}")

        if (let Some(v) <- getDescriptiveText()) {
            sb.append(" [${v}]")
        }

        if (let Some(v) <- errorGenerator) {
            sb.append(". Generated by ${v}")
        }
        return sb.toString()
    }

    public func getElementName(): String {
        return QNAME.getLocalPart()
    }

    public func getNamespace(): String {
        return QNAME.getNamespaceURI()
    }

    public func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
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

    public static func froms(condition: StanzaErrorCondition, descriptiveText: ?String): StanzaErrorBuilder {
        let builder = getBuilder().setCondition(condition)
        if (let Some(descriptiveText) <- descriptiveText) {
            let descriptiveTexts = HashMap<String, String>([("en", descriptiveText)])
            builder.setDescriptiveTexts(descriptiveTexts)
        }
        return builder
    }

    public static func getBuilder(): StanzaErrorBuilder {
        return StanzaErrorBuilder()
    }

    public static func getBuilder(condition: StanzaErrorCondition): StanzaErrorBuilder {
        return getBuilder().setCondition(condition)
    }

    public static func getBuilder(xmppError: StanzaError): StanzaErrorBuilder {
        return getBuilder().copyFrom(xmppError)
    }
}

public class StanzaErrorBuilder <: AbstractErrorBuilder<StanzaErrorBuilder> {
    private var condition: ?StanzaErrorCondition = None
    private var conditionText: ?String = None
    private var errorGenerator: ?String = None
    private var typ: ?StanzaErrorType = None

    init() {}

    public func setCondition(condition: StanzaErrorCondition): StanzaErrorBuilder {
        this.condition = condition
        return this
    }

    public func setType(typ: StanzaErrorType): StanzaErrorBuilder {
        this.typ = typ
        return this
    }

    public func setConditionText(conditionText: ?String): StanzaErrorBuilder {
        this.conditionText = conditionText
        return this
    }

    public func setErrorGenerator(errorGenerator: ?String): StanzaErrorBuilder {
        this.errorGenerator = errorGenerator
        return this
    }

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

    public func build(): StanzaError {
        let exts: ?Collection<ExtensionElement> = if (let Some(v) <- extensions) {
            v
        } else {
            None
        }
        return StanzaError(condition.getOrThrow(), conditionText, errorGenerator, typ, descriptiveTexts, exts)
    }

    protected func getThis(): StanzaErrorBuilder {
        return this
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
    | WAIT
    | CANCEL
    | MODIFY
    | AUTH
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

    public static func fromString(string: String): StanzaErrorType {
        match (string.toAsciiUpper()) {
            case "WAIT" => WAIT
            case "CANCEL" => CANCEL
            case "MODIFY" => MODIFY
            case "AUTH" => AUTH
            case "CONTINUE" => CONTINUE
            case _ => throw IllegalArgumentException("Not a valid typ: ${string}")
        }
    }
}

public enum StanzaErrorCondition <: ToString & Equatable<StanzaErrorCondition> & Hashable {
    bad_request
    | conflict
    | feature_not_implemented
    | forbidden
    | gone
    | internal_server_error
    | item_not_found
    | jid_malformed
    | not_acceptable
    | not_allowed
    | not_authorized
    | policy_violation
    | recipient_unavailable
    | redirect
    | registration_required
    | remote_server_not_found
    | remote_server_timeout
    | resource_constraint
    | service_unavailable
    | subscription_required
    | undefined_condition
    | unexpected_request

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

    public operator func !=(that: StanzaErrorCondition): Bool {
        return !(this == that)
    }

    public func hashCode(): Int64 {
        return toString().hashCode()
    }
}
