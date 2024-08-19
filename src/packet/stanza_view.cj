/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public interface StanzaView <: XmlLangElement {
    /**
     * Returns the unique ID of the stanza. The returned value could be <code>None</code>.
     *
     * @return the packet's unique ID or <code>None</code> if the id is not available.
     */
    func getStanzaId(): ?String

    /**
     * Returns who the stanza is being sent "to", or <code>None</code> if
     * the value is not set. The XMPP protocol often makes the "to"
     * attribute optional, so it does not always need to be set.<p>
     *
     * @return who the stanza is being sent to, or <code>None</code> if the
     *      value has not been set.
     */
    func getTo(): ?Jid

    /**
     * Returns who the stanza is being sent "from" or <code>None</code> if
     * the value is not set. The XMPP protocol often makes the "from"
     * attribute optional, so it does not always need to be set.<p>
     *
     * @return who the stanza is being sent from, or <code>None</code> if the
     *      value has not been set.
     */
    func getFrom(): ?Jid

    /**
     * Returns the error associated with this packet, or <code>None</code> if there are no errors.
     *
     * @return the error sub-packet or <code>None</code> if there isn't an error.
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
     * Check if a extension element with the given namespace exists.
     *
     * @param namespace the namespace of the extension element to check for.
     * @return true if a stanza extension exists, false otherwise.
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
     * Returns a list of all extension elements of this stanza.
     */
    func getExtensions(): ArrayList<ExtensionElement>

    func getExtensions(qname: QName): ArrayList<ExtensionElement>

    /**
     * Return all extension elements of the given type. Returns the empty list if there a none.
     *
     * @param extensionElementClass the class of the type of extension elements.
     * @return a list of extension elements of that type, which may be empty.
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
