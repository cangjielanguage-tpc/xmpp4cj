/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class PacketUtil {

    /**
     * Get a extension element from a collection.
     *
     * @param collection Collection of ExtensionElements.
     * @param element name of the targeted ExtensionElement.
     * @param namespace namespace of the targeted ExtensionElement.
     * @param <PE> Type of the ExtensionElement
     *
     * @return the extension element
     */
    public static func extensionElementFrom<PE>(
        collection: Collection<ExtensionElement>,
        element: ?String,
        namespace: String
    ): ?PE where PE <: ExtensionElement {
        for (packetExtension in collection) {
            if ((element.isNone() || element == packetExtension.getElementName()) && packetExtension.getNamespace() ==
                namespace) {
                return packetExtension as PE
            }
        }
        return None
    }
}
