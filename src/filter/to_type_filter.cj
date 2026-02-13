/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.filter

/**
 * ToTypeFilter 是一个用于过滤不同类型 JID（Jabber ID）的筛选器。
 * 该类扩展了 AbstractExactJidTypeFilter，并提供了几种预定义的 JID 类型过滤器。
 */
public class ToTypeFilter <: AbstractExactJidTypeFilter {
    /** 
     * 对应实体全 JID 的筛选器
     */
    public static let ENTITY_FULL_JID = ToTypeFilter(AbstractJidTypeFilterJidType.entityFull)

    /**
     * 对应实体裸 JID 的筛选器
     */
    public static let ENTITY_BARE_JID = ToTypeFilter(AbstractJidTypeFilterJidType.entityBare)

    /** 
     * 对应域全 JID 的筛选器
     */
    public static let DOMAIN_FULL_JID = ToTypeFilter(AbstractJidTypeFilterJidType.domainFull)

    /**
     * 对应域裸 JID 的筛选器
     */
    public static let DOMAIN_BARE_JID = ToTypeFilter(AbstractJidTypeFilterJidType.domainBare)

    /** 
     * 对应任意 JID 的筛选器
     */
    public static let TO_ANY_JID = ToTypeFilter(AbstractJidTypeFilterJidType.any)

    /** 
     * 筛选器，匹配实体全 JID 或者实体裸 JID
     */
    public static let ENTITY_FULL_OR_BARE_JID: StanzaFilter = OrFilter([ENTITY_FULL_JID, ENTITY_BARE_JID])

    /**
     * 构造一个 ToTypeFilter 实例。
     *
     * @param jidType 要过滤的 JID 类型
     */
    private init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    /**
     * 获取要检查的 JID。
     *
     * @param stanza 要检查的 Stanza
     * @return 该 Stanza 的目标 JID
     */
    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return stanza.getTo()
    }

    public override func toString(): String {
        return if (let Some(v) <- jidType) {
            "ToTypeFilter: ${v}"
        } else {
            "ToTypeFilter: None"
        }
    }
}
