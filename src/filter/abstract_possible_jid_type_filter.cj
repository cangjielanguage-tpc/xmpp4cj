/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**  
 * 抽象类，表示可能的 JID 类型过滤器，继承自 AbstractJidTypeFilter。
 * 该类用于过滤 STANZA 数据包中 JID 的类型。
 */
public abstract class AbstractPossibleJidTypeFilter <: AbstractJidTypeFilter {
    /**  
     * 构造函数，初始化 JID 类型。
     *
     * @param jidType 要检查的 JID 类型。
     */
    protected init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    /**  
     * 检查给定的 STANZA 是否被接受。基于 JID 的类型判断其是否符合要求。
     *
     * @param stanza 要检查的 STANZA 数据包。
     * @return 如果 STANZA 中的 JID 符合指定的类型条件，则返回 true；否则返回 false。
     */
    public override func accept(stanza: Stanza): Bool {
        let jid: ?Jid = getJidToInspect(stanza)
        if (let Some(v) <- jid) {
            match (jidType) {
                case Some(AbstractJidTypeFilterJidType.entityFull) => return v.asEntityFullJidIfPossible().isSome()
                case Some(AbstractJidTypeFilterJidType.entityBare) => return v.asEntityBareJidIfPossible().isSome()
                case Some(AbstractJidTypeFilterJidType.domainFull) => return v.asDomainFullJidIfPossible().isSome()
                case Some(AbstractJidTypeFilterJidType.domainBare) | Some(AbstractJidTypeFilterJidType.any) => return true
                case _ => throw AssertionError()
            }
        } else {
            return false
        }
    }

    public open override func toString(): String {
        return if (let Some(v) <- jidType) {
            "AbstractPossibleJidTypeFilter: ${v}"
        } else {
            "AbstractPossibleJidTypeFilter: None"
        }
    }
}
