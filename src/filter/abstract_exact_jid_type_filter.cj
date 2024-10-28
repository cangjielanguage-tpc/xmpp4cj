/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**  
 * 抽象类 AbstractExactJidTypeFilter 是具体 JID 类型过滤器的基类。
 * <p>
 * 该类用于根据给定的 JID 类型对 XMPP 数据包（Stanza）进行过滤。
 * </p>
 */
public abstract class AbstractExactJidTypeFilter <: AbstractJidTypeFilter {
    /**  
     * 构造函数，初始化 JID 类型。
     *
     * @param jidType 要接受的 JID 类型。
     */
    protected init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    /**  
     * 接受方法，根据消息的 JID 类型判断是否接受该 Stanza。
     *
     * @param stanza 要检查的 XMPP 数据包（Stanza）。
     * @return 如果该 Stanza 的 JID 类型符合过滤器的定义，则返回 true；否则返回 false。
     */
    public override func accept(stanza: Stanza): Bool {
        let jid: ?Jid = getJidToInspect(stanza)
        if (let Some(v) <- jid) {
            match (jidType) {
                case Some(AbstractJidTypeFilterJidType.entityFull) => return v.isEntityFullJid()
                case Some(AbstractJidTypeFilterJidType.entityBare) => return v.isEntityBareJid()
                case Some(AbstractJidTypeFilterJidType.domainFull) => return v.isDomainFullJid()
                case Some(AbstractJidTypeFilterJidType.domainBare) => return v.isDomainBareJid()
                case Some(AbstractJidTypeFilterJidType.any) => return true
                case _ => return false
            }
        } else {
            return false
        }
    }

    public open override func toString(): String {
        return if (let Some(v) <- jidType) {
            "AbstractExactJidTypeFilter: ${v}"
        } else {
            "AbstractExactJidTypeFilter: None"
        }
    }
}
