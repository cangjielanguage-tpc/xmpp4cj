/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 流关闭类
 */
public class StreamClose <: Nonza {
    /**
     * 单例实例
     */
    public static let INSTANCE = StreamClose()

    /**
     * 默认构造方法
     */
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
