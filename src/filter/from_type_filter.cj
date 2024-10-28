/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**  
 * 从特定类型的 JID 进行过滤的类。
 * 该过滤器用于检查接收的数据包的发件人 JID 类型。
 */
public class FromTypeFilter <: AbstractExactJidTypeFilter {
    /**   
     * 实体完整 JID
     */
    public static let ENTITY_FULL_JID = FromTypeFilter(AbstractJidTypeFilterJidType.entityFull)

    /**  
     * 实体裸 JID
     */
    public static let ENTITY_BARE_JID = FromTypeFilter(AbstractJidTypeFilterJidType.entityBare)

    /**  
     *  域完整 JID
     */
    public static let DOMAIN_FULL_JID = FromTypeFilter(AbstractJidTypeFilterJidType.domainFull)

    /**  
     * 域裸 JID
     */
    public static let DOMAIN_BARE_JID = FromTypeFilter(AbstractJidTypeFilterJidType.domainBare)

    /**  
     * 任意类型的 JID
     */
    public static let FROM_ANY_JID = FromTypeFilter(AbstractJidTypeFilterJidType.any)

    /**  
     * 使用指定的 JID 类型创建一个新的从类型过滤器。
     *
     * @param jidType 要检查的 JID 类型。
     */
    private init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType) // 调用父类构造函数 
    }

    /**  
     * 获取要检查的 JID，通常来自数据包的“从”字段。
     *
     * @param stanza 要检查的 STANZA 数据包。
     * @return 返回数据包的发件人 JID。
     */
    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return stanza.getFrom() // 获取并返回数据包的发件人 JID  
    }

    public override func toString(): String {
        return if (let Some(v) <- jidType) {
            "FromTypeFilter: ${v}"
        } else {
            "FromTypeFilter: None"
        }
    }
}
