/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * XMPP 用于绑定资源并获取服务器分配的 JID 的 IQ 节。有两种绑定资源的方法。一种是简单地发送一个空的 Bind 节，此时服务器将为这个连接分配一个新的资源。另一种选择是设置一个期望的资源，但服务器可能会返回发送的资源的修改版本。<p>
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
