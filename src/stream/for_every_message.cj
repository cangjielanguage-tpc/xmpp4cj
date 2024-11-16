/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class ForEveryMessage <: StanzaFilter {
    public static let INSTANCE = ForEveryMessage()

    public override func accept(packet: Stanza): Bool {
        if (packet is Message) {
            return true
        }
        return false
    }
    public override func toString(): String {
        "ForEveryMessage"
    }
}
