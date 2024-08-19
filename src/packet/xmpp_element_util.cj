/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public open class XmppElementUtil {
    private static let CLASS_TO_QNAME_CACHE = LruCache<ClassId, QName>(512)
    public static let LOGGER = getGlobalLogger(("name", "XmppElementUtil"))

    public static func getQNameFor(qnameFrom: ClassId): QName {
        let cid = qnameFrom
        if (let Some(qname) <- CLASS_TO_QNAME_CACHE.get(cid)) {
            return qname
        }

        if (let Some(qname) <- getQnameFromClassid(qnameFrom)) {
            CLASS_TO_QNAME_CACHE.put(cid, qname)
            return qname
        }
        LOGGER.warn("The ${cid} has no static QNAME field. Consider adding one.")

        let element = getElementFromClassid(qnameFrom) ?? ""
        let namespace = getNamespaceFromClassid(qnameFrom) ?? ""
        if (element == "" || namespace == "") {
            throw IllegalArgumentException(
                "The ${cid} has no ELEMENT, NAMESPACE or QNAME member. Consider adding QNAME")
        }

        let qname = QName(namespace, element)
        CLASS_TO_QNAME_CACHE.put(cid, qname)
        return qname
    }

    public static func getElementsFrom(elementMap: MultiMap<QName, ExtensionElement>, qnameFrom: ClassId): ArrayList<ExtensionElement> {
        let qname = XmppElementUtil.getQNameFor(qnameFrom)
        let extensionElements = elementMap.getAll(qname)
        if (extensionElements.isEmpty()) {
            return ArrayList<ExtensionElement>() // TODO
        }
        return extensionElements
    }

    public static func castOrThrow<E>(extensionElement: ExtensionElement): E where E <: ExtensionElement & ClassIdentify {
        match (extensionElement) {
            case v: E => v
            case _ =>
                let qname = E.getClassId()
                let detailMessage = if (extensionElement is StandardExtensionElement) {
                    "because there is no according extension element provider registered with ProviderManager for ${qname}. warn: This indicates a serious problem with your Xmpp setup, probably causing Xmpp not being able to properly initialize itself."
                } else {
                    // let provider = ProviderManager.getExtensionProvider(qname)
                    // "because there is an inconsistency with the provider registered with ProviderManager: the active provider for ${qname} '${provider.getClassId()}' does not return instances of type ${E.getClassId()}, but instead returns instances of type ${extensionElement.getClassId()}."
                    throw Exception("TODO")
                }
                let message = "Extension element is not of expected class '${E.getClassId()}', ${detailMessage}"
                throw IllegalStateException(message)
        }
    }
}
