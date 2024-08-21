/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * The stream open <b>tag</b>.
 */
public class StreamOpen <: Nonza {
    public static let ELEMENT = "stream:stream"
    public static let CLIENT_NAMESPACE = "jabber:client"
    public static let SERVER_NAMESPACE = "jabber:server"
    /**
     * RFC 6120 § 4.7.5.
     */
    public static let VERSION = "1.0"
    /**
     * RFC 6120 § 4.7.1.
     */
    private let froms: ?String
    /**
     * RFC 6120 § 4.7.2.
     */
    private let to: ?String
    /**
     * RFC 6120 § 4.7.3.
     */
    private let id: ?String
    /**
     * RFC 6120 § 4.7.4.
     */
    private let lang: ?String
    /**
     * RFC 6120 § 4.8.2.
     */
    private let contentNamespace: String

    public init(to: ?String) {
        this(to, None, None, None, StreamOpenStreamContentNamespace.client)
    }

    public init(to: ?String, froms: ?String, id: ?String) {
        this(to, froms, id, "en", StreamOpenStreamContentNamespace.client)
    }

    public init(to: ?String, froms: ?String, id: ?String, lang: ?String, ns: StreamOpenStreamContentNamespace) {
        this.to = StringUtils.maybeToString(to)
        this.froms = StringUtils.maybeToString(froms)
        this.id = id
        this.lang = lang
        this.contentNamespace = match (ns) {
            case StreamOpenStreamContentNamespace.client => CLIENT_NAMESPACE
            case StreamOpenStreamContentNamespace.server => SERVER_NAMESPACE
        }
    }

    public override func getNamespace(): String {
        return contentNamespace
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func toXML(enclosingXmlEnvironment: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder()
        xml.halfOpenElement(getElementName())
        var namespace: ?String = CLIENT_NAMESPACE
        // We always want to state 'xmlns' for stream open tags.
        if (let Some(enclosingXmlEnvironment) <- enclosingXmlEnvironment) {
            namespace = enclosingXmlEnvironment.getEffectiveNamespaceOrUse(CLIENT_NAMESPACE)
        }
        xml.attribute("xmlns", namespace)
        xml.attribute("to", to)
        xml.attribute("xmlns:stream", ETHERX_JABBER_STREAMS_NAMESPACE)
        xml.attribute("version", VERSION)
        xml.optAttribute("from", froms)
        xml.optAttribute("id", id)
        xml.xmllangAttribute(lang)
        xml.rightAngleBracket()
        return xml
    }
}

public enum StreamOpenStreamContentNamespace {
    | client
    | server
}
