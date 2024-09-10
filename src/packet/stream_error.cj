/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Represents a stream error packet. Stream errors are unrecoverable errors where the server
 * will close the underlying TCP connection after the stream error was sent to the client.
 * These is the list of stream errors as defined in the XMPP spec:
 *
 * <table border=1>
 *      <caption>Stream Errors</caption>
 *      <tr><td><b>Code</b></td><td><b>Description</b></td></tr>
 *      <tr><td> bad-format </td><td> the entity has sent XML that cannot be processed </td></tr>
 *      <tr><td> unsupported-encoding </td><td>  the entity has sent a namespace prefix that is
 *          unsupported </td></tr>
 *      <tr><td> bad-namespace-prefix </td><td> Remote Server Timeout </td></tr>
 *      <tr><td> conflict </td><td> the server is closing the active stream for this entity
 *          because a new stream has been initiated that conflicts with the existing
 *          stream. </td></tr>
 *      <tr><td> connection-timeout </td><td> the entity has not generated any traffic over
 *          the stream for some period of time. </td></tr>
 *      <tr><td> host-gone </td><td> the value of the 'to' attribute provided by the initiating
 *          entity in the stream header corresponds to a hostname that is no longer hosted by
 *          the server. </td></tr>
 *      <tr><td> host-unknown </td><td> the value of the 'to' attribute provided by the
 *          initiating entity in the stream header does not correspond to a hostname that is
 *          hosted by the server. </td></tr>
 *      <tr><td> improper-addressing </td><td> a stanza sent between two servers lacks a 'to'
 *          or 'from' attribute </td></tr>
 *      <tr><td> internal-server-error </td><td> the server has experienced a
 *          misconfiguration. </td></tr>
 *      <tr><td> invalid-from </td><td> the JID or hostname provided in a 'from' address does
 *          not match an authorized JID. </td></tr>
 *      <tr><td> invalid-namespace </td><td> the streams namespace name is invalid. </td></tr>
 *      <tr><td> invalid-xml </td><td> the entity has sent invalid XML over the stream. </td></tr>
 *      <tr><td> not-authorized </td><td> the entity has attempted to send data before the
 *          stream has been authenticated </td></tr>
 *      <tr><td> policy-violation </td><td> the entity has violated some local service
 *          policy. </td></tr>
 *      <tr><td> remote-connection-failed </td><td> Rthe server is unable to properly connect
 *          to a remote entity. </td></tr>
 *      <tr><td> resource-constraint </td><td> Rthe server lacks the system resources necessary
 *          to service the stream. </td></tr>
 *      <tr><td> restricted-xml </td><td> the entity has attempted to send restricted XML
 *          features. </td></tr>
 *      <tr><td> see-other-host </td><td>  the server will not provide service to the initiating
 *          entity but is redirecting traffic to another host. </td></tr>
 *      <tr><td> system-shutdown </td><td> the server is being shut down and all active streams
 *          are being closed. </td></tr>
 *      <tr><td> undefined-condition </td><td> the error condition is not one of those defined
 *          by the other conditions in this list. </td></tr>
 *      <tr><td> unsupported-encoding </td><td> the initiating entity has encoded the stream in
 *          an encoding that is not supported. </td></tr>
 *      <tr><td> unsupported-stanza-type </td><td> the initiating entity has sent a first-level
 *          child of the stream that is not supported. </td></tr>
 *      <tr><td> unsupported-version </td><td> the value of the 'version' attribute provided by
 *          the initiating entity in the stream header specifies a version of XMPP that is not
 *          supported. </td></tr>
 *      <tr><td> not-well-formed </td><td> the initiating entity has sent XML that is not
 *          well-formed. </td></tr>
 * </table>
 * <p>
 * Stream error syntax:
 * <pre>
 * {@code
 * <stream:error>
 *   <defined-condition xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
 *   [<text xmlns='urn:ietf:params:xml:ns:xmpp-streams'
 *      xml:lang='langcode'>
 *   OPTIONAL descriptive text
 *   </text>]
 *   [OPTIONAL application-specific condition element]
 * </stream:error>
 * }
 * </pre>
 *
 */
public class StreamError <: AbstractError & Nonza & ToString {
    public static let ELEMENT = "stream:error"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-streams"

    private let condition: ?StreamErrorCondition

    private let conditionText: ?String

    public init(
        condition: ?StreamErrorCondition,
        conditionTextStr: ?String,
        descriptiveTexts: Map<String, String>,
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

    public operator func !=(that: StreamErrorCondition): Bool {
        return !(this == that)
    }
}
