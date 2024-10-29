/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * XMPP 用于绑定资源并获取服务器分配的 JID 的 IQ 节。有两种绑定资源的方法。一种是简单地发送一个空的 Bind 节，此时服务器将为这个连接分配一个新的资源。另一种选择是设置一个期望的资源，但服务器可能会返回发送的资源的修改版本。<p>
 */
public class Bind <: IQ {
    /**
     * bind常量，元素名称。
     */
    public static let ELEMENT = "bind"

    /**
     * 命名空间。
     */
    public static let NAMESPACE = "urn:ietf:params:xml:ns:xmpp-bind"

    private let resource: ?Resourcepart

    private let jid: ?EntityFullJid

    /**
     * 构造方法。
     *
     * @param xmlEnvironment xml标签节点。
     * @param xmlEnvironment xml标签节点。
     * @return xml文本信息。
     */
    private init(resource: ?Resourcepart, jid: ?EntityFullJid) {
        super(ELEMENT, NAMESPACE)
        this.resource = resource
        this.jid = jid
    }

    /**
     * 获取资源部分。
     *
     * @return 资源数据。
     */
    public func getResource(): ?Resourcepart {
        return resource
    }

    /**
     * 获取完整的实体 JID。
     *
     * @return EntityFullJid对象。
     */
    public func getJid(): ?EntityFullJid {
        return jid
    }

    /**
     * 静态方法，通过资源创建新的 Bind 对象 。
     *
     * @param resource 资源对象。
     * @return 新的 Bind 对象。
     */
    public static func newSet(resource: ?Resourcepart): Bind {
        let bind = Bind(resource, None)
        bind.setType(IQType.set)
        return bind
    }

    /**
     * 静态方法，通过实体JID创建新的 Bind 对象 。
     *
     * @param jid 实体JID。
     * @return 新的 Bind 对象。
     */
    public static func newResult(jid: EntityFullJid): Bind {
        return Bind(None, jid)
    }

    /**
     * 处理IQChildElementXmlStringBuilder字符串，添加resource和jid，并返回 。
     *
     * @param xml 实体JID。
     * @return 处理了过后的字符串。
     */
    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.rightAngleBracket()
        xml.optElement("resource", resource?.toString())
        xml.optElement("jid", jid?.toString())
        return xml
    }
}

/**
 * 绑定功能
 */
public class BindFeature <: ExtensionElement {
    /**
     * QNAME对象
     */
    public static let QNAME = QName(Bind.NAMESPACE, Bind.ELEMENT)

    /**
     * 默认创建BindFeature对象
     */
    public static let INSTANCE = BindFeature()

    /**
     * 空的构造方法
     */
    private init() {}

    /**
     * 获取标签节点名称。
     *
     * @return 标签节点名称，返回值为"bind"。
     */
    public override func getElementName(): String {
        return Bind.ELEMENT
    }

    /**
     * 获取命名空间。
     *
     * @return 命名空间，返回值为"urn:ietf:params:xml:ns:xmpp-bind"。
     */
    public override func getNamespace(): String {
        return Bind.NAMESPACE
    }

    /**
     * 返回xml文本信息。
     *
     * @param _ xml标签节点。
     * @return xml文本信息。
     */
    public override func toXML(_: ?XmlEnvironment): ToString {
        return "<${Bind.ELEMENT} xmlns='${Bind.NAMESPACE}'/>"
    }
}
