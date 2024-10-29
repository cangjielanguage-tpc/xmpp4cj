/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**  
 * 抽象类，用于实现基于 JID 类型的过滤器。
 * 该类实现 StanzaFilter 接口，供具体的 JID 类型过滤器继承使用。
 */
public abstract class AbstractJidTypeFilter <: StanzaFilter & ToString {
    /**
     * 存储待匹配的 JID 类型
     */
    protected let jidType: ?AbstractJidTypeFilterJidType

    /**  
     * 构造函数，用于初始化 JID 类型过滤器。
     *
     * @param jidType 需要匹配的 JID 类型。
     */
    protected init(jidType: AbstractJidTypeFilterJidType) {
        this.jidType = jidType
    }

    /**  
     * 抽象方法，用于从 Stanza 中获取待检查的 JID。
     * 子类需要实现该方法以指定如何获取 JID。
     *
     * @param stanza 要检查的 Stanza 对象。
     * @return 从 Stanza 中获取的 JID 对象。
     */
    protected func getJidToInspect(stanza: Stanza): ?Jid

    public open override func toString(): String {
        return if (let Some(v) <- jidType) {
            "AbstractJidTypeFilter: ${v}"
        } else {
            "AbstractJidTypeFilter: None"
        }
    }
}

/**  
 * 枚举类型，定义了可能的 JID 类型。
 */
public enum AbstractJidTypeFilterJidType <: ToString & Equatable<AbstractJidTypeFilterJidType> {
    /**
     * 完整实体 JID
     */
    | entityFull
    /**
     * 裸露实体 JID
     */
    | entityBare
    /**
     * 完整域名 JID
     */
    | domainFull
    /**
     * 裸露域名 JID
     */
    | domainBare
    /**
     * 任何类型的 JID
     */
    | any

    public operator override func ==(that: AbstractJidTypeFilterJidType): Bool {
        match ((this, that)) {
            case (entityFull, entityFull) => true
            case (entityBare, entityBare) => true
            case (domainFull, domainFull) => true
            case (domainBare, domainBare) => true
            case (any, any) => true
            case _ => false
        }
    }

    public override func toString(): String {
        match (this) {
            case entityFull => "entityFull"
            case entityBare => "entityBare"
            case domainFull => "domainFull"
            case domainBare => "domainBare"
            case any => "any"
        }
    }
}
