/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**
 * 过滤器，用于检查 Stanza 的源 JID 类型是否符合特定条件。
 * 该过滤器继承自 AbstractPossibleJidTypeFilter。
 */
public class PossibleFromTypeFilter <: AbstractPossibleJidTypeFilter {
    /**
     * 完整实体 JID
     */
    public static let ENTITY_FULL_JID = PossibleFromTypeFilter(AbstractJidTypeFilterJidType.entityFull)

    /**
     * 裸露实体 JID
     */
    public static let ENTITY_BARE_JID = PossibleFromTypeFilter(AbstractJidTypeFilterJidType.entityBare)

    /**
     * 完整域名 JID
     */
    public static let DOMAIN_FULL_JID = PossibleFromTypeFilter(AbstractJidTypeFilterJidType.domainFull)

    /**
     * 裸露域名 JID
     */
    public static let DOMAIN_BARE_JID = PossibleFromTypeFilter(AbstractJidTypeFilterJidType.domainBare)

    /**
     * 任何类型的 JID
     */
    public static let FROM_ANY_JID = PossibleFromTypeFilter(AbstractJidTypeFilterJidType.any)

    /**
     * 私有构造函数，用于创建一个新的可能源 JID 类型过滤器。
     *
     * @param jidType 需要匹配的 JID 类型。
     */
    private init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    /**
     * 获取 Stanza 中待检查的源 JID。
     *
     * @param stanza 要检查的 Stanza 对象。
     * @return Stanza 的源 JID。
     */
    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return stanza.getFrom()
    }

    public override func toString(): String {
        return if (let Some(v) <- jidType) {
            "PossibleFromTypeFilter: ${v}"
        } else {
            "PossibleFromTypeFilter: None"
        }
    }
}
