/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public open class LazyStringBuilder <: CharSequence & Appendable {
    private let list: ArrayList<CharSequence>
    private var cache: ?String = None
    private var cachedLength: Int64 = -1

    private func invalidateCache() {
        cache = None
        cachedLength = -1
    }

    public init() {
        list = ArrayList<CharSequence>(20)
    }

    public func append(lsb: LazyStringBuilder): LazyStringBuilder {
        list.appendAll(lsb.list)
        invalidateCache()
        return this
    }

    public override func append(csq: CharSequence): LazyStringBuilder {
        list.append(csq.toString())
        invalidateCache()
        return this
    }

    /*
    public override func append(csq: CharSequence, start: Int64, end: Int64): LazyStringBuilder {
        let str: String = csq.toString()[start..end]
        list.append(str)
        invalidateCache()
        return this
    }

    public override func append(c: Rune): LazyStringBuilder {
        list.append(c.toString())
        invalidateCache()
        return this
    }

    public func subSequence(start: Int64, end: Int64): CharSequence {
        return toString()[start..end]
    }
     */
    public override func toString(): String {
        return if (let Some(v) <- cache) {
            v
        } else {
            let sb: StringBuilder = StringBuilder()
            for (csq in list) {
                sb.append(csq)
            }
            cache = sb.toString()
            return sb.toString()
        }
    }

    public prop size: Int64 {
        get() {
            if (let Some(cache) <- cache) {
                return cache.size
            }
            var length = 0
            for (csq in list) {
                length += csq.toString().size
            }
            return length
        }
    }

    /**
     * Get the List of CharSequences representation of this instance. The list is unmodifiable. If
     * the resulting String was already cached, a list with a single String entry will be returned.
     *
     * @return a List of CharSequences representing this instance.
     */
    public func getAsList(): ArrayList<CharSequence> {
        return if (let Some(v) <- cache) {
            ArrayList<CharSequence>(v)
        } else {
            let arr: ArrayList<CharSequence> = ArrayList<CharSequence>()
            for (csq in list) {
                arr.append(csq.toString())
            }
            arr
        }
    }
}
