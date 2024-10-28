/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * Packet 工具类
 */
public class PacketUtil {
    /**
     * 从集合中获取扩展元素。
     *
     * @param collection 集合扩展元素的集合。
     * @param element 元素名称。
     * @param namespace 命名空间。
     * @param <PE> 扩展元素的类型。
     *
     * @return 扩展元素的类型
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
