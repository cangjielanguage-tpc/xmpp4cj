/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * 懒加载的StringBuilder
 */
public open class LazyStringBuilder <: CharSequence & Appendable {
    private let list: ArrayList<CharSequence>
    private var cache: ?String = None
    private var cachedLength: Int64 = -1

    private func invalidateCache() {
        cache = None
        cachedLength = -1
    }

    /**
     * 对象初始化。
     */
    public init() {
        list = ArrayList<CharSequence>(20)
    }

    /**
     * 添加LazyStringBuilder数据。
     *
     * @param lsb LazyStringBuilder数据。
     * @return 当前对象。
     */
    public func append(lsb: LazyStringBuilder): LazyStringBuilder {
        list.appendAll(lsb.list)
        invalidateCache()
        return this
    }

    /**
     * 添加CharSequence数据。
     *
     * @param csq CharSequence数据。
     * @return 当前对象。
     */
    public override func append(csq: CharSequence): LazyStringBuilder {
        list.append(csq.toString())
        invalidateCache()
        return this
    }

    // public override func append(csq: CharSequence, start: Int64, end: Int64): LazyStringBuilder {
    //     let str: String = csq.toString()[start..end]
    //     list.append(str)
    //     invalidateCache()
    //     return this
    // }

    // public override func append(c: Rune): LazyStringBuilder {
    //     list.append(c.toString())
    //     invalidateCache()
    //     return this
    // }

    // public func subSequence(start: Int64, end: Int64): CharSequence {
    //     return toString()[start..end]
    // }

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

    /**
     * 数据长度。
     */
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
     * 获取此实例的CharSequence表示形式列表。这份名单是不可修改的。如果
     * 生成的String已被缓存，将返回一个包含单个String条目的列表。
     *
     * @return 代表此实例的CharSequence列表。
     */
    public func getAsList(): ArrayList<CharSequence> {
        return if (let Some(v) <- cache) {
            ArrayList<CharSequence>(v)
        } else {
            let arr: ArrayList<CharSequence> = ArrayList<CharSequence>(list.size)
            for (csq in list) {
                arr.append(csq.toString())
            }
            arr
        }
    }
}
