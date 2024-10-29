/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * XmppElementUtil 类提供了一些用于处理 XMPP 元素的实用方法。
 * 这个类主要用于获取 XMPP 元素的 QName，以及从存储的元素中提取特定类型的扩展元素。
 */
public open class XmppElementUtil {
    private static let CLASS_TO_QNAME_CACHE = LruCache<ClassId, QName>(512) // 用于缓存类与 QName 映射的 LRU 缓存

    /**
     * 日志记录器
     */
    public static let LOGGER = getGlobalLogger(("name", "XmppElementUtil"))

    /**
     * 根据给定的 FullyQualifiedElement 类返回对应的 QName。
     * 如果 QName 已经被缓存，则直接返回缓存中的值。
     * 如果未缓存，则尝试从类的静态字段 QNAME 获取。
     * 如果 QNAME 不存在，则使用 ELEMENT 和 NAMESPACE 字段构造 QName。
     *
     * @param fullyQualifiedElement FullyQualifiedElement 类
     * @return 对应的 QName
     */
    public static func getQNameFor(qnameFrom: ClassId): QName {
        let cid = qnameFrom
        if (let Some(qname) <- CLASS_TO_QNAME_CACHE.get(cid)) {
            return qname
        }

        if (let Some(qname) <- QNAME_MAPPING.get(qnameFrom)) {
            CLASS_TO_QNAME_CACHE.put(cid, qname)
            return qname
        }
        LOGGER.warn("The ${cid} has no static QNAME field. Consider adding one.")

        let element = ELEMENT_MAPPING.get(qnameFrom) ?? ""
        let namespace = NAMESPACE_MAPPING.get(qnameFrom) ?? ""
        if (element == "" || namespace == "") {
            throw IllegalArgumentException(
                "The ${cid} has no ELEMENT, NAMESPACE or QNAME member. Consider adding QNAME")
        }

        let qname = QName(namespace, element)
        CLASS_TO_QNAME_CACHE.put(cid, qname)
        return qname
    }

    /**
     * 从提供的 MultiMap 中获取指定类型的扩展元素列表。
     *
     * @param elementMap 存储 XMPP 元素的 MultiMap
     * @param qnameFrom 指定的扩展元素类
     * @return 指定类型的扩展元素列表
     */
    public static func getElementsFrom(elementMap: MultiMap<QName, ExtensionElement>, qnameFrom: ClassId): ArrayList<ExtensionElement> {
        let qname = XmppElementUtil.getQNameFor(qnameFrom)
        let extensionElements = elementMap.getAll(qname)
        if (extensionElements.isEmpty()) {
            return ArrayList<ExtensionElement>() // TODO
        }
        return extensionElements
    }

    /**
     * 将给定的扩展元素转换为指定类型，如果转换失败则抛出异常。
     *
     * @param extensionElement 待转换的扩展元素
     * @throws IllegalStateException 如果转换失败
     */
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
