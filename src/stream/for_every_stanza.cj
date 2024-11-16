/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class ForEveryStanza <: StanzaFilter {
    public static let INSTANCE = ForEveryStanza()

    public override func accept(packet: Stanza): Bool {
        return true
    }

    public override func toString(): String {
        "ForEveryStanza"
    }
}
