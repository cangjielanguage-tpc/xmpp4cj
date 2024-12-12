/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**  
 * XMPPConnection 接口提供了与 XMPP 服务器连接的接口，并实现了不同类型连接（例如
 * <code>XMPPTCPConnection</code> 或 <code>XMPPBOSHConnection</code>）使用的共享方法。
 * 要创建与 XMPP 服务器的连接，简单的使用示例如下：
 *
 * <pre>
 * // 创建与 XMPP 服务器的连接。
 * let con: XMPPTCPConnection = XMPPTCPConnection("user","password","xmpptestserver")
 * // 连接到服务器
 * con.connect()
 * // 大多数服务器要求您在执行其他任务之前登录。
 * con.login("jsmith", "mypass")
 * // 开始与 John Doe 的新对话并发送消息。
 * let chatManager: ChatManager = ChatManager.getInstanceFor(con)
 * chatManager.addIncomingListener(IncomingChatMessageListener() {
 *     public void newIncomingMessage(from: EntityBareJid, message: Message, chat: Chat) {
 *         // 打印我们收到的任何消息到标准输出。
 *         println("Received message: ${message}")
 *     }
 * })
 * let chat: Chat = chatManager.chatWith("jdoe@xmpptestserver")
 * chat.send("Howdy!")
 * // 从服务器断开连接
 * con.disconnect()
 * </pre>
 * <p>
 * 请注意，XMPPConnection 接口故意不声明任何操作连接状态的方法，例如 <code>connect()</code>、<code>disconnect()</code>。
 * 您应该使用最具体的连接类型，例如 <code>XMPPTCPConnection</code> 作为声明类型，并在不需要操作连接状态时使用 XMPPConnection 接口。
 * </p>
 * <p>
 * XMPPConnections 可以在连接之间重复使用。这意味着一个连接可以连接、断开然后再次连接。
 * XMPPConnection 的监听器将在连接之间保留。
 * </p>
 * <h2>传入 Stanza 监听器</h2>
 * 您可以添加到连接的大多数回调（监听器、处理程序等）有三种不同的变体：
 * <ul>
 * <li>异步 - 例如 {@link #addAsyncStanzaListener(StanzaListener, StanzaFilter)}</li>
 * <li>同步  - 例如 {@link #addSyncStanzaListener(StanzaListener, StanzaFilter)}</li>
 * <li>其他    - 例如 {@link #addStanzaListener(StanzaListener, StanzaFilter)}</li>
 * </ul>
 * <p>
 * 异步回调与连接的主事件循环解耦。因此，由 stanza B 触发的回调可能（看起来）在 stanza A 之前被调用，
 * 尽管 stanza A 在 stanza B 之前到达。
 * </p>
 * <p>
 * 同步回调是并发调用的，但确保同一个回调不会并发运行，并且按顺序执行。
 * 也就是说，如果 stanza A 和 B 都触发了同一个回调，并且 A 在 B 之前到达，那么回调将首先使用 A 调用，
 * 然后是 B。此外，这些回调不会在主循环中执行。然而，建议这些回调不要阻塞或仅短暂阻塞。
 * </p>
 * <p>
 * 其他回调与连接的主事件循环同步运行，并在主循环中执行。
 * <b>这意味着如果这样的回调阻塞，主事件循环也会阻塞，这很容易导致死锁。
 * 因此，除非您知道自己在做什么，否则应避免使用这些回调。</b>
 * </p>
 */
public interface XMPPConnection <: ToString & Hashable & Equatable<XMPPConnection> {
    /**  
     * 获取 XMPP 服务的域名（不带资源）。
     *
     * @return XMPP 服务的域名（不带资源）
     */
    func getXMPPServiceDomain(): DomainBareJid

    /**  
     * 获取连接的主机名。
     *
     * @return 连接的主机名
     */
    func getHost(): ?String

    /**  
     * 获取连接的端口号。
     *
     * @return 连接的端口号
     */
    func getPort(): Int

    /**  
     * 获取用户的完整 JID。
     *
     * @return 用户的完整 JID。
     */
    func getUser(): ?EntityFullJid

    /**  
     * 获取当前流的 ID。
     *
     * @return 当前流的 ID。
     * @see <a href="xmpp/org/rfcs/rfc6120.html#streams-attr-id">RFC 6120 § 4.7.3. id</a>
     */
    func getStreamId(): ?String

    /**  
     * 检查连接是否已建立。
     *
     * @return 连接是否已建立
     */
    func isConnected(): Bool

    /**  
     * 检查用户是否已通过身份验证。
     *
     * @return 用户是否已通过身份验证。
     */
    func isAuthenticated(): Bool

    /**  
     * 检查当前连接是否为匿名连接。
     *
     * @return 当前连接是否为匿名连接。
     */
    func isAnonymous(): Bool

    /**  
     * 检查连接是否为安全连接。
     *
     * @return 连接是否为安全连接。
     */
    func isSecureConnection(): Bool

    /**  
     * 检查是否正在使用压缩。
     *
     * @return 是否正在使用压缩。
     */
    func isUsingCompression(): Bool

    /**  
     * 获取用于创建 Stanza 的工厂。
     *
     * @return 创建 Stanza 的工厂。
     */
    func getStanzaFactory(): StanzaFactory

    /**  
     * 发送 Stanza。
     *
     * @param stanza 要发送的 Stanza
     * @throws NotConnectedException 如果连接未建立
     * @throws InterruptedException 如果发送过程中被中断
     */
    func sendStanza(stanza: Stanza): Unit

    /**  
     * 尝试发送 Stanza。
     *
     * @param stanza 要发送的 Stanza
     * @return 如果成功发送则返回 true
     * @throws NotConnectedException 如果连接未建立
     */
    func trySendStanza(stanza: Stanza): Bool

    /**  
     * 尝试发送 Stanza，并指定超时时间。
     *
     * @param stanza 要发送的 Stanza
     * @param timeout 超时时间
     * @return 如果成功发送则返回 true
     * @throws NotConnectedException 如果连接未建立
     * @throws InterruptedException 如果发送过程中被中断
     */
    func trySendStanza(stanza: Stanza, timeout: Duration): Bool

    /**  
     * 发送 Nonza。
     *
     * @param nonza 要发送的 Nonza
     * @throws NotConnectedException 如果连接未建立
     * @throws InterruptedException 如果发送过程中被中断
     */
    func sendNonza(nonza: Nonza): Unit

    /**  
     * 添加连接监听器。
     *
     * @param connectionListener 连接监听器
     */
    func addConnectionListener(connectionListener: ConnectionListener): Unit

    /**  
     * 移除连接监听器。
     *
     * @param connectionListener 要移除的连接监听器
     */
    func removeConnectionListener(connectionListener: ConnectionListener): Unit

    /**  
     * 发送 IQ 请求并等待响应。
     *
     * @param request 要发送的 IQ 请求
     * @return IQ 响应
     * @throws NoResponseException 如果没有响应
     * @throws XMPPErrorException 如果发生 XMPP 错误
     * @throws NotConnectedException 如果连接未建立
     * @throws InterruptedException 如果发送过程中被中断
     */
    func sendIqRequestAndWaitForResponse(request: IQ): IQ

    /**  
     * 创建 Stanza 收集器并发送 IQ 请求。
     *
     * @param request 要发送的 IQ 请求
     * @return Stanza 收集器
     * @throws NotConnectedException 如果连接未建立
     * @throws InterruptedException 如果发送过程中被中断
     */
    func createStanzaCollectorAndSend(request: IQ): StanzaCollector

    /**  
     * 创建 Stanza 收集器并发送 Stanza。
     *
     * @param stanzaFilter Stanza 过滤器
     * @param stanza 要发送的 Stanza
     * @return Stanza 收集器
     * @throws NotConnectedException 如果连接未建立
     * @throws InterruptedException 如果发送过程中被中断
     */
    func createStanzaCollectorAndSend(stanzaFilter: StanzaFilter, stanza: Stanza): StanzaCollector

    /**  
     * 创建 Stanza 收集器。
     *
     * @param stanzaFilter Stanza 过滤器
     * @return Stanza 收集器
     */
    func createStanzaCollector(stanzaFilter: StanzaFilter): StanzaCollector

    /**  
     * 创建 Stanza 收集器，使用指定的配置。
     *
     * @param configuration 收集器配置
     * @return Stanza 收集器
     */
    func createStanzaCollector(configuration: StanzaCollectorConfiguration): StanzaCollector

    /**  
     * 移除 Stanza 收集器。
     *
     * @param collector 要移除的 Stanza 收集器
     */
    func removeStanzaCollector(collector: StanzaCollector): Unit

    /**  
     * 添加 Stanza 监听器。
     *
     * @param stanzaListener Stanza 监听器
     * @param stanzaFilter Stanza 过滤器
     */
    func addStanzaListener(stanzaListener: StanzaListener, stanzaFilter: StanzaFilter): Unit

    /**  
     * 移除 Stanza 监听器。
     *
     * @param stanzaListener 要移除的 Stanza 监听器
     * @return 如果成功移除则返回 true
     */
    func removeStanzaListener(stanzaListener: StanzaListener): Bool

    /**  
     * 添加同步 Stanza 监听器。
     *
     * @param stanzaListener Stanza 监听器
     * @param stanzaFilter Stanza 过滤器
     */
    func addSyncStanzaListener(stanzaListener: StanzaListener, stanzaFilter: StanzaFilter): Unit

    /**  
     * 移除同步 Stanza 监听器。
     *
     * @param stanzaListener 要移除的 Stanza 监听器
     * @return 如果成功移除则返回 true
     */
    func removeSyncStanzaListener(stanzaListener: StanzaListener): Bool

    /**  
     * 添加异步 Stanza 监听器。
     *
     * @param stanzaListener Stanza 监听器
     * @param stanzaFilter Stanza 过滤器
     */
    func addAsyncStanzaListener(stanzaListener: StanzaListener, stanzaFilter: StanzaFilter): Unit

    /**  
     * 移除异步 Stanza 监听器。
     *
     * @param stanzaListener 要移除的 Stanza 监听器
     * @return 如果成功移除则返回 true
     */
    func removeAsyncStanzaListener(stanzaListener: StanzaListener): Bool

    /**  
     * 添加 Stanza 发送监听器。
     *
     * @param stanzaListener Stanza 监听器
     * @param stanzaFilter Stanza 过滤器
     */
    func addStanzaSendingListener(stanzaListener: StanzaListener, stanzaFilter: StanzaFilter): Unit

    /**  
     * 移除 Stanza 发送监听器。
     *
     * @param stanzaListener 要移除的 Stanza 监听器
     */
    func removeStanzaSendingListener(stanzaListener: StanzaListener): Unit

    /**  
     * 添加消息拦截器。
     *
     * @param messageInterceptor 消息拦截器
     * @param messageFilter 消息过滤器
     */
    func addMessageInterceptor(messageInterceptor: HashableConsumer<MessageBuilder>, messageFilter: ?Predicate<Message>): Unit

    /**  
     * 移除消息拦截器。
     *
     * @param messageInterceptor 要移除的消息拦截器
     */
    func removeMessageInterceptor(messageInterceptor: HashableConsumer<MessageBuilder>): Unit

    /**  
     * 添加状态拦截器。
     *
     * @param presenceInterceptor 状态拦截器
     * @param presenceFilter 状态过滤器
     */
    func addPresenceInterceptor(
        presenceInterceptor: HashableConsumer<PresenceBuilder>,
        presenceFilter: ?Predicate<Presence>
    ): Unit

    /**  
     * 移除状态拦截器。
     *
     * @param presenceInterceptor 要移除的状态拦截器
     */
    func removePresenceInterceptor(presenceInterceptor: HashableConsumer<PresenceBuilder>): Unit

    /**  
     * 获取回复超时时间。
     *
     * @return 回复超时时间（毫秒）
     */
    func getReplyTimeout(): Duration

    /**  
     * 设置回复超时时间。
     *
     * @param timeout 超时时间（毫秒）
     */
    func setReplyTimeout(timeout: Duration): Unit

    /**  
     * 获取连接计数器。
     *
     * @return 连接计数器
     */
    func getConnectionCounter(): Int

    /**  
     * 设置发件人模式。
     *
     * @param fromMode 发件人模式
     */
    func setFromMode(fromMode: XMPPConnectionFromMode): Unit

    /**  
     * 获取发件人模式。
     *
     * @return 发件人模式
     */
    func getFromMode(): XMPPConnectionFromMode

    /**  
     * 获取指定特性的元素。
     *
     * @param qname 特性的 QName
     * @param <F> 特性元素的类型
     * @return 指定特性的元素，如果不存在则返回 null
     */
    func getFeature(qname: QName): ?FullyQualifiedElement

    /**  
     * 根据特性类获取特性的元素。
     *
     * @param featureClass 特性类
     * @param <F> 特性元素的类型
     * @return 指定特性的元素，如果不存在则返回 null
     */
    func getFeature(featureClass: ClassId): ?FullyQualifiedElement {
        let qname = XmppElementUtil.getQNameFor(featureClass)
        return getFeature(qname)
    }

    /**  
     * 检查是否具有指定的特性。
     *
     * @param element 特性元素名称
     * @param namespace 特性元素的命名空间
     * @return 如果具有指定特性则返回 true，否则返回 false
     */
    func hasFeature(element: String, namespace: String): Bool {
        let qname = QName(namespace, element)
        return hasFeature(qname)
    }

    /**  
     * 检查是否具有指定的特性。
     *
     * @param qname 特性的 QName
     * @return 如果具有指定特性则返回 true，否则返回 false
     */
    func hasFeature(qname: QName): Bool

    /**  
     * 异步发送 IQ 请求并返回一个未来对象以处理响应。
     *
     * @param request 要发送的 IQ 请求
     * @return 一个 XmppFuture 对象，表示异步操作的结果
     */
    func sendIqRequestAsync(request: IQ): XmppFuture<IQ, Exception>

    /**  
     * 异步发送 IQ 请求并返回一个未来对象以处理响应，指定超时时间。
     *
     * @param request 要发送的 IQ 请求
     * @param timeout 超时时间（毫秒）
     * @return 一个 XmppFuture 对象，表示异步操作的结果
     */
    func sendIqRequestAsync(request: IQ, timeout: Duration): XmppFuture<IQ, Exception>

    /**  
     * 异步发送 Stanza，并指定回复过滤器。
     *
     * @param stanza 要发送的 Stanza
     * @param replyFilter 回复过滤器
     * @param <S> Stanza 的类型
     * @return 一个 XmppFuture 对象，表示异步操作的结果
     */
    func sendAsync(stanza: Stanza, replyFilter: StanzaFilter): XmppFuture<Stanza, Exception>

    /**  
     * 异步发送 Stanza，并指定回复过滤器和超时时间。
     *
     * @param stanza 要发送的 Stanza
     * @param replyFilter 回复过滤器
     * @param timeout 超时时间（毫秒）
     * @param <S> Stanza 的类型
     * @return 一个 XmppFuture 对象，表示异步操作的结果
     */
    func sendAsync(stanza: Stanza, replyFilter: StanzaFilter, timeout: Duration): XmppFuture<Stanza, Exception>

    /**  
     * 添加一次性同步回调。
     *
     * @param callback 要添加的 Stanza 监听器
     * @param stanzaFilter Stanza 过滤器
     */
    func addOneTimeSyncCallback(callback: StanzaListener, stanzaFilter: StanzaFilter): Unit

    /**  
     * 注册 IQ 请求处理器。
     *
     * @param iqRequestHandler 要注册的 IQ 请求处理器
     * @return 注册的 IQ 请求处理器
     */
    func registerIQRequestHandler(iqRequestHandler: IQRequestHandler): ?IQRequestHandler

    /**  
     * 注销 IQ 请求处理器。
     *
     * @param iqRequestHandler 要注销的 IQ 请求处理器
     * @return 注销的 IQ 请求处理器
     */
    func unregisterIQRequestHandler(iqRequestHandler: IQRequestHandler): ?IQRequestHandler

    /**  
     * 根据元素名称、命名空间和类型注销 IQ 请求处理器。
     *
     * @param element 元素名称
     * @param namespace 命名空间
     * @param type IQ 类型
     * @return 注销的 IQ 请求处理器
     */
    func unregisterIQRequestHandler(element: String, namespace: String, Type: IQType): ?IQRequestHandler

    /**  
     * 获取最后接收的 Stanza 的时间戳。
     *
     * @return 最后接收的 Stanza 的时间戳（毫秒）
     */
    func getLastStanzaReceived(): Duration
}

public enum XMPPConnectionFromMode <: ToString & Equatable<XMPPConnectionFromMode> {
    /**
     *  保持 'from' 属性不变。这是 Xmmp < 4.0 的行为。
     */
    | UNCHANGED
    /**
     * 忽略 'from' 属性。根据 RFC 6120 第 8.1.2.1 条，XMPP 服务器 "必须 (...)
     * 重写由客户端指定的 'from' 属性"。因此，在这里指定 FromMode.OMITTED 是安全的。
     */
    | OMITTED
    /**
     * 将 'from' 设置为客户端的完整 JID。通常情况下，这并不是必需的。
     */
    | USER

    public override func toString(): String {
        return match (this) {
            case UNCHANGED => "UNCHANGED"
            case OMITTED => "OMITTED"
            case USER => "USER"
        }
    }

    public operator func ==(that: XMPPConnectionFromMode): Bool {
        return match ((this, that)) {
            case (UNCHANGED, UNCHANGED) => true
            case (OMITTED, OMITTED) => true
            case (USER, USER) => true
            case _ => false
        }
    }
}
