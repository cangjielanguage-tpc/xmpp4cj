/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**  
 * 一个用于匹配 STANZA 的过滤器，检查 STANZA 的目标地址是否为空。
 */
public class EmptyToMatcher <: StanzaFilter {
    /**
     * 单例实例
     */
    public static let INSTANCE = EmptyToMatcher()

    // 私有构造函数，防止外部实例化  
    private init() {
    }

    /**  
     * 检查给定的 STANZA 是否接受。
     *
     * @param packet 要检查的 STANZA 数据包。
     * @return 如果 STANZA 的目标地址为 null，则返回 true；否则返回 false。
     */
    public override func accept(packet: Stanza): Bool {
        let packetTo: ?Jid = packet.getTo() // 获取 STANZA 的目标地址  
        return packetTo.isNone() // 判断目标地址是否为None
    }

    /**  
     * 返回类的字符串表示，通常为类名。
     *
     * @return 类的简单名称
     */
    public override func toString(): String {
        return "EmptyToMatcher"
    }
}
