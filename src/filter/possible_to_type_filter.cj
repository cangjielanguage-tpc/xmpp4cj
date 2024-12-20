/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**
 * 过滤器，用于检查 Stanza 的目标 JID 类型是否符合特定条件。
 * 该过滤器继承自 AbstractPossibleJidTypeFilter。
 */
public class PossibleToTypeFilter <: AbstractPossibleJidTypeFilter {
    /**
     * 定义一个过滤器，可以接受完整的实体 JID
     */
    public static let ENTITY_FULL_JID = PossibleToTypeFilter(AbstractJidTypeFilterJidType.entityFull)

    /**
     * 定义一个过滤器，可以接受裸露的实体 JID
     */
    public static let ENTITY_BARE_JID = PossibleToTypeFilter(AbstractJidTypeFilterJidType.entityBare)

    /**
     * 定义一个过滤器，可以接受完整的域名 JID
     */
    public static let DOMAIN_FULL_JID = PossibleToTypeFilter(AbstractJidTypeFilterJidType.domainFull)

    /**
     * 定义一个过滤器，可以接受裸露的域名 JID
     */
    public static let DOMAIN_BARE_JID = PossibleToTypeFilter(AbstractJidTypeFilterJidType.domainBare)

    /**
     * 定义一个过滤器，可以接收任何 JID
     */
    public static let TO_ANY_JID = PossibleToTypeFilter(AbstractJidTypeFilterJidType.any)

    /**
     * 定义一个过滤器，可以接受完整或裸露的实体 JID
     */
    public static let ENTITY_FULL_OR_BARE_JID: StanzaFilter = OrFilter([ENTITY_FULL_JID, ENTITY_BARE_JID])

    /**
     * 私有构造函数，用于创建一个新的可能目标 JID 类型过滤器。
     *
     * @param jidType 需要匹配的 JID 类型。
     */
    private init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    /**
     * 获取 Stanza 中待检查的目标 JID。
     *
     * @param stanza 要检查的 Stanza 对象。
     * @return Stanza 的目标 JID。
     */
    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return stanza.getTo()
    }

    public override func toString(): String {
        return if (let Some(v) <- jidType) {
            "PossibleToTypeFilter: ${v}"
        } else {
            "PossibleToTypeFilter: None"
        }
    }
}
