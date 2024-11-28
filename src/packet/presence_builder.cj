/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**  
 * PresenceBuilder 是用于构建 XMPP Presence（状态）报文的类。
 * 该类支持设置多个状态属性，如类型、状态消息、优先级和模式。
 *
 * <p> 该类是不可变的，生产的每一个实例都依赖构建器模式来生成一个有效的 Presence 对象。</p>
 *
 * <p>使用示例：</p>
 * <pre>
 * Presence presence = new PresenceBuilder()
 *                        .ofType(Presence.Type.available)
 *                        .setStatus("Online")
 *                        .setPriority(5)
 *                        .setMode(Presence.Mode.available)
 *                        .build()
 * </pre>
 */
public class PresenceBuilder <: MessageOrPresenceBuilder & PresenceView {
    static let EMPTY = PresenceBuilder(RandomStringStanzaIdSource {=> None}) // 表示一个空的 PresenceBuilder 实例  

    var typ: PresenceType = PresenceType.available // Presence 类型，默认为 available  

    var status: ?String = None // 状态消息  

    var priority: ?UInt8 = None // 优先级值

    var mode: ?PresenceMode = None // Presence 模式 

    /**  
     * 构造一个 PresenceBuilder 实例，基于给定的 Presence 和 stanzid。
     *
     * @param presence   基于的 Presence 对象
     * @param stanzaId   stanza ID
     */
    init(presence: Presence, stanzaId: ?String) {
        super(presence, stanzaId)
        copyFromPresence(presence)
    }

    /**  
     * 构造一个 PresenceBuilder 实例，基于给定的 Presence 和 StanzaIdSource。
     *
     * @param presence        基于的 Presence 对象
     * @param stanzaIdSource  Stanza ID 来源
     */
    init(presence: Presence, stanzaIdSource: StanzaIdSource) {
        super(presence, stanzaIdSource)
        copyFromPresence(presence)
    }

    /**  
     * 构造一个 PresenceBuilder 实例，仅使用 StanzaIdSource。
     *
     * @param stanzaIdSource  Stanza ID 来源
     */
    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    /**  
     * 构造一个 PresenceBuilder 实例，仅使用 stanzaId。
     *
     * @param stanzaId  Stanza ID
     */
    init(stanzaId: ?String) {
        super(stanzaId)
    }

    /**  
     * 从已存在的 Presence 对象中复制属性值。
     *
     * @param presence  源 Presence 对象
     */
    private func copyFromPresence(presence: Presence): Unit {
        typ = presence.getType()
        status = presence.getStatus()
        priority = UInt8(presence.getPriorityByte())
        mode = presence.getMode()
    }

    /**  
     * 添加特定于 Stanza 的属性。
     *
     * @param builder 用于构建字符串的构建器。
     */
    protected override func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit {
        builder
            .addValue("type", typ)
            .addValue("mode", mode ?? None)
            .addValue("priority", priority ?? None)
            .addValue("status", status)
    }

    /**  
     * 设置 Presence 类型。
     *
     * @param type  Presence 类型
     * @return 当前的 PresenceBuilder 实例
     * @throws NullPointerException 如果类型为 null
     */
    public func ofType(typ: PresenceType): This {
        this.typ = typ
        return this
    }

    /**  
     * 设置状态消息。
     *
     * @param status  状态消息
     * @return 当前的 PresenceBuilder 实例
     */
    public func setStatus(status: String): This {
        this.status = status
        return this
    }

    /**  
     * 设置优先级值。
     *
     * @param priority  优先级值
     * @return 当前的 PresenceBuilder 实例
     * @throws IllegalArgumentException 如果优先级值不在合法范围内
     */
    public func setPriority(priority: UInt8): This {
        this.priority = priority
        return this
    }

    /**  
     * 设置 Presence 模式。
     *
     * @param mode  Presence 模式
     * @return 当前的 PresenceBuilder 实例
     */
    public func setMode(mode: PresenceMode): This {
        this.mode = mode
        return this
    }

    /**  
     * 构建并返回一个新的 Stanza 实例。
     *
     * @return 新建的 Stanza 实例
     */
    public override func build(): Presence {
        return Presence(this)
    }

    public override func getType(): PresenceType {
        return typ
    }

    public override func getStatus(): ?String {
        return status
    }

    public override func getPriority(): Int {
        return Int64(getPriorityByte())
    }

    public override func getPriorityByte(): UInt8 {
        return priority ?? 0
    }

    public override func getMode(): PresenceMode {
        return mode ?? PresenceMode.available
    }
}
