/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class StreamClose <: Nonza {
    public static let INSTANCE = StreamClose()

    private init() {}

    public override func toXML(_: ?XmlEnvironment): ToString {
        return "</${getElementName()}>"
    }

    public override func getNamespace(): String {
        // Closing XML tags do never explicitly state their namespace.
        return "(none)"
    }

    public override func getElementName(): String {
        return StreamOpen.ELEMENT
    }
}
