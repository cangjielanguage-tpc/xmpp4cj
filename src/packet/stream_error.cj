/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * 表示流错误数据包。流错误是不可恢复的错误，在将流错误发送给客户端后，服务器将关闭底层的 TCP 连接。
 * 以下是 XMPP 规范中定义的流错误列表：

 * <table border=1>
 *      <caption>流错误</caption>
 *      <tr><td><b>代码</b></td><td><b>描述</b></td></tr>
 *      <tr><td>bad-format</td><td>实体发送了无法处理的 XML</td></tr>
 *      <tr><td>unsupported-encoding</td><td>实体发送了不支持的命名空间前缀</td></tr>
 *      <tr><td>bad-namespace-prefix</td><td>远程服务器超时</td></tr>
 *      <tr><td>conflict</td><td>服务器正在关闭此实体的活动流，因为已启动的新流与现有流冲突</td></tr>
 *      <tr><td>connection-timeout</td><td>实体在一段时间内未在流上生成任何流量</td></tr>
 *      <tr><td>host-gone</td><td>流头中发起实体提供的“to”属性的值对应于不再由服务器托管的主机名</td></tr>
 *      <tr><td>host-unknown</td><td>流头中发起实体提供的“to”属性的值与服务器托管的主机名不对应</td></tr>
 *      <tr><td>improper-addressing</td><td>在两个服务器之间发送的节缺少“to”或“from”属性</td></tr>
 *      <tr><td>internal-server-error</td><td>服务器遇到了配置错误</td></tr>
 *      <tr><td>invalid-from</td><td>“from”地址中提供的 JID 或主机名与授权的 JID 不匹配</td></tr>
 *      <tr><td>invalid-namespace</td><td>流的命名空间名称无效</td></tr>
 *      <tr><td>invalid-xml</td><td>实体在流上发送了无效的 XML</td></tr>
 *      <tr><td>not-authorized</td><td>实体在流进行身份验证之前尝试发送数据</td></tr>
 *      <tr><td>policy-violation</td><td>实体违反了一些本地服务策略</td></tr>
 *      <tr><td>remote-connection-failed</td><td>服务器无法正确连接到远程实体</td></tr>
 *      <tr><td>resource-constraint</td><td>服务器缺乏为流提供服务所需的系统资源</td></tr>
 *      <tr><td>restricted-xml</td><td>实体尝试发送受限制的 XML 特性</td></tr>
 *      <tr><td>see-other-host</td><td>服务器不会为发起实体提供服务，而是将流量重定向到另一个主机</td></tr>
 *      <tr><td>system-shutdown</td><td>服务器正在关闭，所有活动流都在被关闭</td></tr>
 *      <tr><td>undefined-condition</td><td>错误条件不是此列表中其他条件所定义的那些之一</td></tr>
 *      <tr><td>unsupported-encoding</td><td>发起实体已使用不支持的编码对流进行编码</td></tr>
 *      <tr><td>unsupported-stanza-type</td><td>发起实体已发送流的不支持的一级子元素</td></tr>
 *      <tr><td>unsupported-version</td><td>流头中发起实体提供的“version”属性的值指定了不支持的 XMPP 版本</td></tr>
 *      <tr><td>not-well-formed</td><td>发起实体发送了格式不正确的 XML</td></tr>
 * </table>
 * <p>
 * 流错误语法：
 * <pre>
 * {@code
 * <stream:error>
 *   <defined-condition xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
 *   [<text xmlns='urn:ietf:params:xml:ns:xmpp-streams'
 *      xml:lang='langcode'>
 *   可选的描述性文本
 *   </text>]
 *   [可选的特定于应用程序的条件元素]
 * </stream:error>
 * }
 * </pre>
 */
public class StreamError <: AbstractError & Nonza & ToString {
    public static let ELEMENT = "stream:error"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-streams"

    private let condition: ?StreamErrorCondition

    private let conditionText: ?String

    public init(
        condition: ?StreamErrorCondition,
        conditionTextStr: ?String,
        descriptiveTexts: ?Map<String, String>,
        extensions: ArrayList<ExtensionElement>
    ) {
        super(descriptiveTexts, extensions)
        var conditionText = conditionTextStr
        // Some implementations may send the condition as non-empty element containing the empty string,
        //  that is <condition xmlns='foo'></condition>,
        // in this case the parser may calls this constructor with the empty string as conditionText,
        // therefore reset it to None if it's the empty string
        if (StringUtils.isNullOrEmpty(conditionText)) {
            conditionText = None
        }
        if (conditionText.isSome()) {
            match (condition) {
                case Some(StreamErrorCondition.see_other_host) => ()
                case _ => throw IllegalArgumentException(
                    "The given condition '${condition}' can not contain a conditionText")
            }
        }
        this.condition = condition
        this.conditionText = conditionText
    }

    public func getCondition(): ?StreamErrorCondition {
        return condition
    }

    public func getConditionText(): ?String {
        return conditionText
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func toXML(_: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder()
        xml.openElement(ELEMENT)
        xml.halfOpenElement(condition.toString()).xmlnsAttribute(NAMESPACE).closeEmptyElement()
        addDescriptiveTextsAndExtensions(xml)
        xml.closeElement(ELEMENT)
        return xml
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public override func getElementName(): String {
        return ELEMENT
    }
}

/**
 * The defined stream error conditions, see RFC 6120 § 4.9.3.
 */
public enum StreamErrorCondition <: ToString & Equatable<StreamErrorCondition> {
    bad_format
    | bad_namespace_prefix
    | conflict
    | connection_timeout
    | host_gone
    | host_unknown
    | improper_addressing
    | internal_server_error
    | invalid_from
    | invalid_namespace
    | invalid_xml
    | not_authorized
    | not_well_formed
    | policy_violation
    | remote_connection_failed
    | reset
    | resource_constraint
    | restricted_xml
    | see_other_host
    | system_shutdown
    | undefined_condition
    | unsupported_encoding
    | unsupported_feature
    | unsupported_stanza_type
    | unsupported_version

    public static func fromString(string: String): StreamErrorCondition {
        // Backwards compatibility for older implementations still using RFC 3920.
        // RFC 6120 changed 'xml-not-well-formed' to 'not-well-formed'.
        var str = string
        if ("xml-not-well-formed" == string) {
            str = "not-well-formed"
        }
        str = str.replace('-', '_')
        return match (str) {
            case "bad_format" => StreamErrorCondition.bad_format
            case "bad_namespace_prefix" => StreamErrorCondition.bad_namespace_prefix
            case "conflict" => StreamErrorCondition.conflict
            case "connection_timeout" => StreamErrorCondition.connection_timeout
            case "host_gone" => StreamErrorCondition.host_gone
            case "host_unknown" => StreamErrorCondition.host_unknown
            case "improper_addressing" => StreamErrorCondition.improper_addressing
            case "internal_server_error" => StreamErrorCondition.internal_server_error
            case "invalid_from" => StreamErrorCondition.invalid_from
            case "invalid_namespace" => StreamErrorCondition.invalid_namespace
            case "invalid_xml" => StreamErrorCondition.invalid_xml
            case "not_authorized" => StreamErrorCondition.not_authorized
            case "not_well_formed" => StreamErrorCondition.not_well_formed
            case "policy_violation" => StreamErrorCondition.policy_violation
            case "remote_connection_failed" => StreamErrorCondition.remote_connection_failed
            case "reset" => StreamErrorCondition.reset
            case "resource_constraint" => StreamErrorCondition.resource_constraint
            case "restricted_xml" => StreamErrorCondition.restricted_xml
            case "see_other_host" => StreamErrorCondition.see_other_host
            case "system_shutdown" => StreamErrorCondition.system_shutdown
            case "undefined_condition" => StreamErrorCondition.undefined_condition
            case "unsupported_encoding" => StreamErrorCondition.unsupported_encoding
            case "unsupported_feature" => StreamErrorCondition.unsupported_feature
            case "unsupported_stanza_type" => StreamErrorCondition.unsupported_stanza_type
            case "unsupported_version" => StreamErrorCondition.unsupported_version
            case _ => throw IllegalArgumentException("Could not transform string '${str}' to XMPPErrorCondition")
        }
    }

    public override func toString(): String {
        match (this) {
            case bad_format => "bad-format"
            case bad_namespace_prefix => "bad-namespace-prefix"
            case conflict => "conflict"
            case connection_timeout => "connection-timeout"
            case host_gone => "host-gone"
            case host_unknown => "host-unknown"
            case improper_addressing => "improper-addressing"
            case internal_server_error => "internal-server-error"
            case invalid_from => "invalid-from"
            case invalid_namespace => "invalid-namespace"
            case invalid_xml => "invalid-xml"
            case not_authorized => "not-authorized"
            case not_well_formed => "not-well-formed"
            case policy_violation => "policy-violation"
            case remote_connection_failed => "remote-connection-failed"
            case reset => "reset"
            case resource_constraint => "resource-constraint"
            case restricted_xml => "restricted-xml"
            case see_other_host => "see-other-host"
            case system_shutdown => "system-shutdown"
            case undefined_condition => "undefined-condition"
            case unsupported_encoding => "unsupported-encoding"
            case unsupported_feature => "unsupported-feature"
            case unsupported_stanza_type => "unsupported-stanza-type"
            case unsupported_version => "unsupported-version"
        }
    }

    public operator func ==(that: StreamErrorCondition): Bool {
        this.toString() == that.toString()
    }
}
