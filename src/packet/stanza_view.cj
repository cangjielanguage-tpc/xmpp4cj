/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public interface StanzaView <: XmlLangElement {
    /**
     * 返回节的唯一 ID。返回值可能为<code>None</code>。
     *
     * @return 数据包的唯一 ID，如果不可用则为<code>None</code>。
     */
    func getStanzaId(): ?String

    /**
     * 返回节要发送给谁，或者如果未设置该值则为<code>None</code>。XMPP 协议通常使“to”属性是可选的，所以它并不总是需要被设置。<p>
     *
     * @return 节要发送给谁，如果未设置该值则为<code>None</code>。
     */
    func getTo(): ?Jid

    /**
     * 返回节从谁那里发送，或者如果未设置该值则为<code>None</code>。XMPP 协议通常使“from”属性是可选的，所以它并不总是需要被设置。<p>
     *
     * @return 节从谁那里发送，如果未设置该值则为<code>None</code>。
     */
    func getFrom(): ?Jid

    /**
     * 返回与此数据包相关联的错误，或者如果没有错误则为<code>None</code>。
     *
     * @return 错误子包，如果没有错误则为<code>None</code>。
     */
    func getError(): ?StanzaError

    func getExtension(qname: QName): ?ExtensionElement

    func hasExtension(qname: QName): Bool {
        return getExtension(qname).isSome()
    }

    func hasExtensionByType(qnameFrom: ClassId): Bool {
        return getExtensionByType(qnameFrom).isSome()
    }

    /**
     * 检查具有给定命名空间的扩展元素是否存在。
     *
     * @param namespace 要检查的扩展元素的命名空间。
     * @return 如果存在节扩展则为 true，否则为 false。
     */
    func hasExtension(namespace: String): Bool {
        for (packetExtension in getExtensions()) {
            if (packetExtension.getNamespace() == namespace) {
                return true
            }
        }
        return false
    }

    func getExtensionByType(extensionElementClass: ClassId): ?ExtensionElement {
        let qname: QName = XmppElementUtil.getQNameFor(extensionElementClass)
        let extensionElement: ?ExtensionElement = getExtension(qname)
        extensionElement
    }
    static func castExt<E>(extensionElement: ?ExtensionElement): ?E where E <: ExtensionElement & ClassIdentify {
        if (let Some(extensionElement) <- extensionElement) {
            return XmppElementUtil.castOrThrow<E>(extensionElement)
        } else {
            return None
        }
    }

    /**
     * 返回此节的所有扩展元素列表。
     */
    func getExtensions(): ArrayList<ExtensionElement>

    func getExtensions(qname: QName): ArrayList<ExtensionElement>

    /**
     * 返回给定类型的所有扩展元素。如果没有则返回空列表。
     *
     * @param extensionElementClass 扩展元素类型的类。
     * @return 该类型的扩展元素列表，可能为空。
     */
    func getExtensionsByType(extensionElementClass: ClassId): ArrayList<ExtensionElement>

    static func castExt<E>(iter: ArrayList<ExtensionElement>): ArrayList<E> where E <: ExtensionElement & ClassIdentify {
        let res = ArrayList<E>(iter.size)
        for (extensionElement in iter) {
            let e = XmppElementUtil.castOrThrow<E>(extensionElement)
            res.append(e)
        }
        return res
    }
}
