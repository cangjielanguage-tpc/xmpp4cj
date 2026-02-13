/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.modular

/**
 * public abstract class AbstractStats <: ToString
 *
 */
public abstract class AbstractStats <: ToString {
    public func appendStatsTo(appendable: StringBuilder): Unit

    private var toStringCache: ?String = None

    public override func toString(): String {
        if (let Some(v) <- toStringCache) {
            return v
        }
        let sb = StringBuilder()
        appendStatsTo(sb)
        let str = sb.toString()
        toStringCache = str
        return str
    }
}
