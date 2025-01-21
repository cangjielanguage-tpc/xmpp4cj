/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class ShortcutPredicates <: StanzaFilter {
    /* 
     * 假设所有的StanzaFilter无副作用
     * 当前 {@link #accept} 中任一filter返回true即返回true
     * 那么predicates的顺序无关
     */
    private let predicates: Set<StanzaFilter> = HashSet()

    public init(predicates: Collection<StanzaFilter>) {
        this.predicates.add(all: predicates)
    }

    public func addPredicate(predicate: StanzaFilter): Bool {
        return predicates.add(predicate)
    }

    public func removePredicate(prediacte: StanzaFilter): Bool {
        return predicates.remove(prediacte)
    }

    public override func accept(packet: Stanza): Bool {
        for (predicate in predicates) {
            if (predicate.accept(packet)) {
                return true
            }
        }
        return false
    }

    public override func toString(): String {
        return "ShortcutPredicates"
    }
}
