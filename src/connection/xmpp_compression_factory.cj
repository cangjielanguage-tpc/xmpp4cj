/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * public abstract class XmppCompressionFactory <: Comparable<XmppCompressionFactory>
 *
 */
public abstract class XmppCompressionFactory <: Comparable<XmppCompressionFactory> {
    private let method: String

    private let priority: Int

    protected init(method: String, priority: Int) {
        this.method = method
        this.priority = priority
    }

    public func getCompressionMethod(): String {
        return method
    }

    public func getPriority(): Int {
        return priority
    }

    public override func compare(other: XmppCompressionFactory): Ordering {
        return getPriority().compare(other.getPriority())
    }

    public open func fabricate(configuration: ConnectionConfiguration): XmppInputOutputFilter
}
