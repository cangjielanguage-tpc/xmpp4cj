/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**
 * XMPP 地址类型过滤器的基类。
 */
public abstract class JidTypeAbstractJidTypeFilter <: StanzaFilter {
    /**
     * 存储 Jid 类型
     */
    protected let jidType: JidTypeAbstractJidTypeFilterJidType

    /**
     * 构造函数，确保 jidType 不能为空
     *
     * @param jidType JidTypeAbstractJidTypeFilterJidType。
     */
    protected init(jidType: JidTypeAbstractJidTypeFilterJidType) {
        this.jidType = Objects.requireNonNull(jidType, "jidType must not be null")
    }

    /**  
     * 测试指定的 Stanza 是否应该通过过滤器。
     *
     * @param stanza 要测试的 Stanza。
     * @return 如果且仅如果 <code>stanza</code> 通过过滤器，则返回 true。
     */
    public override func accept(stanza: Stanza): Bool {
        let toMatch: ?Jid = getJidToMatchFrom(stanza)
        if (let Some(v) <- toMatch) {
            return jidType.isTypeOf(v)
        } else {
            return false
        }
    }

    /**
     * 抽象方法，从 Stanza 中获取要匹配的 Jid
     *
     * @param stanza 要测试的 Stanza。
     */
    protected func getJidToMatchFrom(stanza: Stanza): ?Jid

    public open override func toString(): String {
        return "JidTypeAbstractJidTypeFilter: ${jidType}"
    }
}

/**
 * Jid 类型的枚举
 */
public enum JidTypeAbstractJidTypeFilterJidType <: ToString & Equatable<JidTypeAbstractJidTypeFilterJidType> {
    /**
     * 仅包含 Jid 的基本部分
     */
    | BareJid
    /**
     * 仅包含域的基本 Jid
     */
    | DomainBareJid
    /**
     * 完整域 Jid
     */
    | DomainFullJid
    /**
     *  域 Jid
     */
    | DomainJid
    /**
     * 实体的基本 Jid
     */
    | EntityBareJid
    /**
     * 实体的完整 Jid
     */
    | EntityFullJid
    /**
     * 实体 Jid
     */
    | EntityJid
    /**
     * 完整 Jid，包含资源
     */
    | FullJid

    public operator override func ==(that: JidTypeAbstractJidTypeFilterJidType): Bool {
        match ((this, that)) {
            case (BareJid, BareJid) => true
            case (DomainBareJid, DomainBareJid) => true
            case (DomainFullJid, DomainFullJid) => true
            case (DomainJid, DomainJid) => true
            case (EntityBareJid, EntityBareJid) => true
            case (EntityFullJid, EntityFullJid) => true
            case (EntityJid, EntityJid) => true
            case (FullJid, FullJid) => true
            case _ => false
        }
    }

    public override func toString(): String {
        match (this) {
            case BareJid => "BareJid"
            case DomainBareJid => "DomainBareJid"
            case DomainFullJid => "DomainFullJid"
            case DomainJid => "DomainJid"
            case EntityBareJid => "EntityBareJid"
            case EntityFullJid => "EntityFullJid"
            case EntityJid => "EntityJid"
            case FullJid => "FullJid"
        }
    }

    /**
     * 检查给定的 Jid 是否属于当前类型
     *
     * @param jid Jid。
     */
    public func isTypeOf(jid: Jid): Bool {
        match (this) {
            case BareJid => jid.hasNoResource()
            case DomainBareJid => jid.isDomainBareJid()
            case DomainFullJid => jid.isDomainFullJid()
            case DomainJid => throw IllegalStateException()
            case EntityBareJid => jid.isEntityBareJid()
            case EntityFullJid => jid.isEntityFullJid()
            case EntityJid => jid.isEntityJid()
            case FullJid => jid.hasResource()
        }
    }
}
