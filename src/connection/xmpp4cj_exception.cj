/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

/**
 * 当请求在所使用的连接实例的 stanza 回复超时时间内没有响应时，始终抛出的异常。
 * 您可以通过 {@link XMPPConnection#setReplyTimeout(long)} 修改（例如，增加）stanza 回复超时时间。
 */
public class NoResponseException <: Xmpp4cjException {
    private let filter: ?StanzaFilter //用于收集响应的过滤器

    /**
     * 私有构造函数，仅接受消息。
     *
     * @param message 异常消息
     */
    private init(message: String) {
        this(message, None)
    }

    /**
     * 私有构造函数，接受消息和过滤器。
     *
     * @param message 异常消息
     * @param filter 用于收集响应的 {@link StanzaFilter}
     */
    private init(message: String, filter: ?StanzaFilter) {
        super(message)
        this.filter = filter
    }

    /**
     * 获取用于收集响应的过滤器。
     *
     * @return 使用的过滤器，如果没有过滤器则返回 <code>null</code>
     */
    public func getFilter(): ?StanzaFilter {
        return filter
    }

    /**
     * 根据给定的连接实例和等待的内容创建 NoResponseException。
     *
     * @param connection XMPP连接实例
     * @param waitingFor 等待的内容描述
     * @return 创建的 NoResponseException 实例
     */
    public static func newWith(connection: XMPPConnection, waitingFor: String): NoResponseException {
        let sb = getWaitingFor(connection)
        sb.append(" While waiting for ${waitingFor} [${connection}]")
        return NoResponseException(sb.toString())
    }

    /**
     * 根据给定的超时、收集器以及是否取消收集器创建 NoResponseException。
     *
     * @param timeout 超时时间
     * @param collector Stanza Collector
     * @param stanzaCollectorCancelled 是否取消了收集器
     * @return 创建的 NoResponseException 实例
     */
    public static func newWith(timeout: Duration, collector: StanzaCollector, stanzaCollectorCancelled: Bool): NoResponseException {
        return newWith(timeout, collector.getStanzaFilter(), stanzaCollectorCancelled)
    }

    /**
     * 根据给定的连接实例和过滤器创建 NoResponseException。
     *
     * @param connection XMPP连接实例
     * @param filter 用于收集响应的 {@link StanzaFilter}
     * @return 创建的 NoResponseException 实例
     */
    public static func newWith(connection: XMPPConnection, filter: ?StanzaFilter): NoResponseException {
        return newWith(connection.getReplyTimeout(), filter, false)
    }

    /**
     * 根据给定的超时、过滤器及是否取消收集器创建 NoResponseException。
     *
     * @param timeout 超时时间
     * @param filter 用于收集响应的 {@link StanzaFilter}
     * @param stanzaCollectorCancelled 是否取消了收集器
     * @return 创建的 NoResponseException 实例
     */
    public static func newWith(timeout: Duration, filter: ?StanzaFilter, stanzaCollectorCancelled: Bool): NoResponseException {
        let sb = getWaitingFor(timeout)
        if (stanzaCollectorCancelled) {
            sb.append(" StanzaCollector has been cancelled.")
        }
        sb.append(" Waited for response using: ")
        if (let Some(filter) <- filter) {
            sb.append(filter)
        } else {
            sb.append("No filter used or filter was 'null'")
        }
        sb.append(r'.')
        return NoResponseException(sb.toString(), filter)
    }

    /**
     * 根据给定的连接实例获取等待响应的描述信息。
     *
     * @param connection XMPP连接实例
     * @return 包含等待信息的 {@link StringBuilder}
     */
    private static func getWaitingFor(connection: XMPPConnection): StringBuilder {
        return getWaitingFor(connection.getReplyTimeout())
    }

    /**
     * 根据给定的回复超时时间获取等待响应的描述信息。
     *
     * @param replyTimeout 回复超时时间
     * @return 包含等待信息的 {@link StringBuilder}
     */
    private static func getWaitingFor(replyTimeout: Duration): StringBuilder {
        let sb = StringBuilder(
            "No response received within reply timeout. Timeout was ${replyTimeout}ms (~${replyTimeout.toSeconds()}s).")
        return sb
    }
}

/**
 * 表示客户端未连接或已不再连接的异常，用于处理与 XMPP连接相关的错误。
 */
public class NotConnectedException <: Xmpp4cjException {
    /**
     * 默认构造函数。
     */
    public init() {
        this(None)
    }

    /**
     * 带有可选提示的构造函数。
     *
     * @param optionalHint 可选的提示信息
     */
    public init(optionalHint: ?String) {
        super("Client is not, or no longer, connected." + (if (let Some(v) <- optionalHint) {
            " ${v}"
        } else {
            ""
        }))
    }

    /**
     * 指定连接和详细信息的构造函数。
     *
     * @param connection 表示当前连接的 {@link XMPPConnection} 实例
     * @param details详细信息描述
     */
    public init(connection: XMPPConnection, details: String) {
        super("The connection ${connection} is no longer connected. ${details}")
    }

    /**
     * 指定连接和过滤器的构造函数。
     *
     * @param connection 表示当前连接的 {@link XMPPConnection} 实例
     * @param stanzaFilter 用于等待响应的 {@link StanzaFilter}
     */
    public init(connection: XMPPConnection, stanzaFilter: ?StanzaFilter) {
        super(
            "The connection ${connection} is no longer connected while waiting for response with ${anyToString(stanzaFilter)}"
        )
    }

    /**
     * 指定连接、过滤器和连接异常的构造函数。
     *
     * @param connection 表示当前连接的 {@link XMPPConnection} 实例
     * @param stanzaFilter 用于等待响应的 {@link StanzaFilter}
     * @param connectionException发生的连接异常
     */
    public init(connection: XMPPConnection, stanzaFilter: ?StanzaFilter, connectionException: Exception) {
        super(
            "The connection ${connection} is no longer connected while waiting for response with ${anyToString(stanzaFilter)} because of ${connectionException}",
            connectionException
        )
    }
}
