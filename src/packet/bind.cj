/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * IQ stanza used by Xmpp to bind a resource and to obtain the jid assigned by the server.
 * There are two ways to bind a resource. One is simply sending an empty Bind stanza where the
 * server will assign a new resource for this connection. The other option is to set a desired
 * resource but the server may return a modified version of the sent resource.<p>
 *
 * For more information refer to the following
 * <a href=xmpp/org/specs/rfc3920.html#bind>link</a>.
 */
public class Bind <: IQ {
    public static let ELEMENT = "bind"
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-bind"

    private let resource: ?Resourcepart
    private let jid: ?EntityFullJid

    private init(resource: ?Resourcepart, jid: ?EntityFullJid) {
        super(ELEMENT, NAMESPACE)
        this.resource = resource
        this.jid = jid
    }

    public func getResource(): ?Resourcepart {
        return resource
    }

    public func getJid(): ?EntityFullJid {
        return jid
    }

    public static func newSet(resource: Resourcepart): Bind {
        let bind = Bind(resource, None)
        bind.setType(IQType.set)
        return bind
    }

    public static func newResult(jid: EntityFullJid): Bind {
        return Bind(None, jid)
    }

    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.rightAngleBracket()
        xml.optElement("resource", resource?.toString())
        xml.optElement("jid", jid?.toString())
        return xml
    }
}

public class BindFeature <: ExtensionElement {
    public static let QNAME = QName(Bind.NAMESPACE, Bind.ELEMENT)

    public static let INSTANCE = BindFeature()

    private init() {}

    public override func getElementName(): String {
        return Bind.ELEMENT
    }

    public override func getNamespace(): String {
        return Bind.NAMESPACE
    }

    public override func toXML(_: ?XmlEnvironment): ToString {
        return "<${Bind.ELEMENT} xmlns='${Bind.NAMESPACE}'/>"
    }
}
