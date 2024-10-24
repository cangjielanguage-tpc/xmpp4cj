/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 用于过滤有效的 IQ 请求的结果回复的数据包。
 * <p>
 * 这个类扩展了 {@link IQReplyFilter} 类，并重写了接受方法，确保只接受
 * 类型为 <code>RESULT</code> 的 IQ 数据包。
 * </p>
 */
public class IQResultReplyFilter <: IQReplyFilter {
    /**  
     * 构造一个 IQ 结果回复过滤器。
     *
     * @param iqPacket 需要过滤回复的 IQ 请求。
     * @param user 连接对象。
     * @param xmppServiceDomain DomainBareJid
     */
    public init(iqPacket: IQ, user: ?EntityFullJid, xmppServiceDomain: DomainBareJid) {
        super(iqPacket, user, xmppServiceDomain)
    }

    /**  
     * 测试指定的 Stanza 是否应该通过过滤器。
     *
     * @param stanza 要测试的 Stanza。
     * @return 如果且仅如果 <code>stanza</code> 通过过滤器，则返回 true。
     */
    public override func accept(packet: Stanza): Bool {
        if (!super.accept(packet)) {
            return false
        }
        return IQTypeFilter.RESULT.accept(packet)
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("IQResultReplyFilter")
        sb.append(" (${super.toString()}${r')'.toString()}")
        return sb.toString()
    }
}
