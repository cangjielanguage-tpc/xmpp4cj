/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.filter

/**
 * 用于过滤有效的 IQ 请求回复的数据包。
 * <p>
 * 这样的数据包必须具有相同的 stanza id，并且必须是类型为
 * <code>RESULT</code> 或 <code>ERROR</code> 的 IQ stanza。此外，还需检查
 * <code>from</code> 地址，以忽略伪造的回复。
 * <p>
 * 我们接受的 <code>from</code> 地址如果满足以下条件之一：
 * <ul>
 * <li>与请求的 <code>to</code> 地址匹配。
 * <li>请求的 <code>to</code> 地址为空，并且 <code>from</code> 地址与
 * 服务器的 bare jid 或客户端的 (bare 或 full jid) 匹配。
 * <li>请求的 <code>to</code> 是我们的 bare 地址，并且 <code>from</code> 为空。
 * </ul>
 * <p>
 * 有关问题的讨论，请参阅 2014-01 在 jdev@jabber.org 邮件列表中
 * 讨论的“IQ id 的欺骗和表现不当的服务器”主题，以及 2 月和 3 月的后续讨论。
 */
public open class IQReplyFilter <: StanzaFilter {
    private static let LOGGER: Logger = getGlobalLogger(("name", "IQReplyFilter"))

    private let iqAndIdFilter: StanzaFilter

    private let fromFilter: OrFilter

    private let to: ?Jid

    private let local: ?EntityFullJid

    private let server: DomainBareJid

    private let packetId: ?String

    /**
     * 构造一个过滤器用于处理 IQ 请求的有效回复。
     * <p>
     * 这样的数据包必须具有相同的 stanza id，并且必须是类型为
     * <code>RESULT</code> 或 <code>ERROR</code> 的 IQ stanza。此外，还需检查
     * <code>from</code> 地址，以忽略伪造的回复。
     * <p>
     * 我们接受的 <code>from</code> 地址如果满足以下条件之一：
     * <ul>
     * <li>与请求的 <code>to</code> 地址匹配。
     * <li>请求的 <code>to</code> 地址为空，并且 <code>from</code> 地址与
     * 服务器的 bare jid 或客户端的 (bare 或 full jid) 匹配。
     * <li>请求的 <code>to</code> 是我们的 bare 地址，并且 <code>from</code> 为空。
     * </ul>
     *
     * @param iqPacket 需要过滤回复的 IQ 请求。
     * @param conn 连接对象。
     */
    public init(iqPacket: IQ, connUser: ?EntityFullJid, connXmppServiceDomain: DomainBareJid) {
        if (!iqPacket.isRequestIQ()) {
            throw IllegalArgumentException("IQ must be a request IQ, i.e. of type 'get' or 'set'.")
        }
        to = iqPacket.getTo()
        local = connUser ?? throw IllegalArgumentException(
            "Must have a local (user) JID set. Either you didn't configure one or you where not connected at least once"
        )
        server = connXmppServiceDomain
        packetId = iqPacket.getStanzaId()
        let iqFilter: StanzaFilter = OrFilter([IQTypeFilter.ERROR, IQTypeFilter.RESULT])
        let idFilter: StanzaFilter = StanzaIdFilter(iqPacket)
        iqAndIdFilter = AndFilter([iqFilter, idFilter])
        fromFilter = OrFilter()
        fromFilter.addFilter(FromMatchesFilter.createFull(to))
        if (let Some(v) <- to) {
            let jid: ?Jid = (local?.asBareJid()).map {v => v}
            if (jid == v) {
                fromFilter.addFilter(FromMatchesFilter.createFull(None))
            }
        } else {
            fromFilter.addFilter(FromMatchesFilter.createBare(local.map {v => v}))
            fromFilter.addFilter(FromMatchesFilter.createFull(server))
        }
    }

    /**
     * 测试指定的 Stanza 是否应该通过过滤器。
     *
     * @param stanza 要测试的 Stanza。
     * @return 如果且仅如果 <code>stanza</code> 通过过滤器，则返回 true。
     */
    public open override func accept(packet: Stanza): Bool {
        // First filter out everything that is not an IQ stanza and does not have the correct ID set.
        if (!iqAndIdFilter.accept(packet)) {
            return false
        }
        // Second, check if the from attributes are correct and log potential IQ spoofing attempts
        if (fromFilter.accept(packet)) {
            return true
        } else {
            let msg = "Rejected potentially spoofed reply to IQ-packet. Filter settings: packetId=${packetId}, to=${to}, local=${local}, server=${server}. Received packet with from=${packet.getFrom()}"
            LOGGER.warn(msg)
            return false
        }
    }

    public open override func toString(): String {
        let sb = StringBuilder()
        sb.append("IQReplyFilter")
        sb.append(": iqAndIdFilter (")
        sb.append(iqAndIdFilter.toString())
        sb.append("), ")
        sb.append(": fromFilter (")
        sb.append(fromFilter.toString())
        sb.append(r')')
        return sb.toString()
    }
}
