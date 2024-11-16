/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class ForMatchingPredicateOrAfterXStanzas <: StanzaFilter {
    private let predicate: StanzaFilter

    private let afterXStanzas: AfterXStanzas

    public init(predicate: StanzaFilter, count: Int) {
        this.predicate = predicate
        this.afterXStanzas = AfterXStanzas(count)
    }

    public override func accept(packet: Stanza): Bool {
        if (predicate.accept(packet)) {
            afterXStanzas.resetCounter()
            return true
        }
        return afterXStanzas.accept(packet)
    }

    public override func toString(): String {
        "ForMatchingPredicateOrAfterXStanzas"
    }
}
