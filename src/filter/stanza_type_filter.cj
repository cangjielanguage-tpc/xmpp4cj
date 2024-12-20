/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**
 * 用于过滤特定类型的 Stanzas 的过滤器。类型以 Class 对象的形式提供，
 * 例如类型可以是：
 * <ul>
 *      <li><code>Message.class</code></li>
 *      <li><code>IQ.class</code></li>
 *      <li><code>Presence.class</code></li>
 * </ul>
 */
public class StanzaTypeFilter<S> <: StanzaFilter where S <: Stanza {
    /** 
     * 用于过滤 Presence 类型的过滤器
     */
    public static let PRESENCE = StanzaTypeFilter<Presence>("Presence")

    /** 
     * 用于过滤 Message 类型的过滤器
     */
    public static let MESSAGE = StanzaTypeFilter<Message>("Message")

    /**
     * 用于过滤 IQ 类型的过滤器
     */
    public static let IQ = StanzaTypeFilter<IQ>("IQ")

    /**
     * 要过滤的 Stanza 类型
     */
    private let packetType: ClassId

    /**
     * 创建一个新的 Stanza 类型过滤器，该过滤器将过滤与 <code>packetType</code>
     * 相同类型的数据包。
     *
     * @param packetType 要过滤的数据包的类类型。必须和泛型类型一致
     */
    public init(packetType: ClassId) {
        this.packetType = packetType
    }

    /**
     * 检查给定数据包是否被该过滤器接受。
     *
     * @param packet 要检查的数据包
     * @return 如果数据包是指定类型，则返回 true；否则返回 false。
     */
    public override func accept(packet: Stanza): Bool {
        return packet is S
    }

    /**
     * 返回过滤器的字符串表示形式。
     *
     * @return 过滤器的字符串表示，包含类名和数据包类型。
     */
    public override func toString(): String {
        return "StanzaTypeFilter: ${packetType}"
    }
}
