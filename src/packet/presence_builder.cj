/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
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
 *                        .build();
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

    protected override func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit {
        builder.addValue("type", typ).addValue("mode", mode ?? None).addValue("priority", priority ?? None).addValue(
            "status", status)
    }

    /**  
     * 设置 Presence 类型。
     *
     * @param type  Presence 类型
     * @return 当前的 PresenceBuilder 实例
     * @throws NullPointerException 如果类型为 null
     */
    public func ofType(typ: PresenceType): PresenceBuilder {
        this.typ = typ
        return getThis()
    }

    /**  
     * 设置状态消息。
     *
     * @param status  状态消息
     * @return 当前的 PresenceBuilder 实例
     */
    public func setStatus(status: String): PresenceBuilder {
        this.status = status
        return getThis()
    }

    /**  
     * 设置优先级值。
     *
     * @param priority  优先级值
     * @return 当前的 PresenceBuilder 实例
     * @throws IllegalArgumentException 如果优先级值不在合法范围内
     */
    public func setPriority(priority: UInt8): PresenceBuilder {
        this.priority = priority
        return getThis()
    }

    /**  
     * 设置 Presence 模式。
     *
     * @param mode  Presence 模式
     * @return 当前的 PresenceBuilder 实例
     */
    public func setMode(mode: PresenceMode): PresenceBuilder {
        this.mode = mode
        return getThis()
    }

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

    public override func getThis(): PresenceBuilder {
        return this
    }

    public override func to(to: String): PresenceBuilder {
        super.to(to)
        getThis()
    }

    public override func to(to: ?Jid): PresenceBuilder {
        super.to(to)
        getThis()
    }

    public override func froms(froms: String): PresenceBuilder {
        super.froms(froms)
        getThis()
    }

    public override func froms(froms: ?Jid): PresenceBuilder {
        super.froms(froms)
        getThis()
    }

    public override func setError(stanzaError: ?StanzaError): PresenceBuilder {
        super.setError(stanzaError)
        getThis()
    }

    public override func setLanguage(language: ?String): PresenceBuilder {
        super.setLanguage(language)
        getThis()
    }

    public override func addExtension(extensionElement: ExtensionElement): PresenceBuilder {
        super.addExtension(extensionElement)
        getThis()
    }

    public override func addOptExtensions(extensionElements: ?Collection<ExtensionElement>): PresenceBuilder {
        super.addOptExtensions(extensionElements)
        getThis()
    }

    public override func addExtensions(extensionElements: Collection<ExtensionElement>): PresenceBuilder {
        super.addExtensions(extensionElements)
        getThis()
    }

    public override func overrideExtension(extensionElement: ExtensionElement): PresenceBuilder {
        super.overrideExtension(extensionElement)
        getThis()
    }

    public override func removeExtension(elementName: String, namespace: String): PresenceBuilder {
        super.removeExtension(elementName, namespace)
        getThis()
    }

    public override func removeExtension(extension: ExtensionElement): PresenceBuilder {
        super.removeExtension(extension)
        getThis()
    }
}
