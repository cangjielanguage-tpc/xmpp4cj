/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**  
 * 实现对 Stanza 过滤器的逻辑“非”操作。
 * 换句话说，数据包仅在未通过所提供的过滤器时通过此过滤器。
 */
public class NotFilter <: StanzaFilter {
    /**
     * 存储要应用“非”操作的过滤器
     */
    private let filter: StanzaFilter

    /**  
     * 使用指定的过滤器创建一个 NOT 过滤器。
     *
     * @param filter 要应用非操作的过滤器。
     * @throws NullPointerException 如果传入的过滤器为 null。
     */
    public init(filter: StanzaFilter) {
        this.filter = Objects.requireNonNull(filter, "Parameter must not be null.")
    }

    /**  
     * 检查给定的数据包是否未通过指定的过滤器。
     *
     * @param packet 要检查的 Stanza 数据包。
     * @return 如果数据包未通过过滤器，则返回 true；否则返回 false。
     */
    public override func accept(packet: Stanza): Bool {
        return !filter.accept(packet)
    }

    public override func toString(): String {
        return "NotFilter"
    }
}
