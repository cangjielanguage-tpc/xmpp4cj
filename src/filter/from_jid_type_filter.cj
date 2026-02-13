/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.filter

/**
 * 基于 'from' XMPP 地址类型的过滤器。
 */
public class FromJidTypeFilter <: JidTypeAbstractJidTypeFilter {
    /**
     * 创建一个匹配实体裸 JID 的过滤器
     */
    public static let ENTITY_BARE_JID = FromJidTypeFilter(JidTypeAbstractJidTypeFilterJidType.EntityBareJid)

    /**
     * 构造函数，用于创建一个基于指定 JID 类型的过滤器。
     *
     * @param jidType 要匹配的 JID 类型。
     */
    public init(jidType: JidTypeAbstractJidTypeFilterJidType) {
        super(jidType) // 调用父类构造函数  
    }

    /**
     * 从数据包中获取要匹配的 JID，这里是 “from” 字段的地址。
     *
     * @param stanza 要检查的 STANZA 数据包。
     * @return 返回数据包的 “from” 地址。
     */
    protected override func getJidToMatchFrom(stanza: Stanza): ?Jid {
        return stanza.getFrom() // 获取并返回数据包的 “from” 地址  
    }

    public override func toString(): String {
        return "FromJidTypeFilter: ${jidType}"
    }
}
