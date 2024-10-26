/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public open class ExtendedAppendable <: Appendable {
    private let appendable: Appendable

    public init(appendable: Appendable) {
        this.appendable = appendable
    }

    public open override func append(csq: ToString): ExtendedAppendable {
        appendable.append(csq)
        return this
    }
}
