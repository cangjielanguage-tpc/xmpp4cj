/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class PresenceBuilder <: MessageOrPresenceBuilder & PresenceView {
    static let EMPTY = PresenceBuilder(RandomStringStanzaIdSource {=> None})

    var typ: PresenceType = PresenceType.available
    var status: ?String = None
    var priority: ?UInt8 = None
    var mode: ?PresenceMode = None

    init(presence: Presence, stanzaId: ?String) {
        super(presence, stanzaId)
        copyFromPresence(presence)
    }

    init(presence: Presence, stanzaIdSource: StanzaIdSource) {
        super(presence, stanzaIdSource)
        copyFromPresence(presence)
    }

    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    init(stanzaId: ?String) {
        super(stanzaId)
    }

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

    public func ofType(typ: PresenceType): PresenceBuilder {
        this.typ = typ
        return getThis()
    }

    public func setStatus(status: String): PresenceBuilder {
        this.status = status
        return getThis()
    }

    public func setPriority(priority: UInt8): PresenceBuilder {
        this.priority = priority
        return getThis()
    }

    public func setMode(mode: PresenceMode): PresenceBuilder {
        this.mode = mode
        return getThis()
    }

    public override func getThis(): PresenceBuilder {
        return this
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
}
