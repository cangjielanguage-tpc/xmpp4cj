/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * MultiMap的轻量级实现，即能够为每个键保存多个值的Map。
 * 此MultiMap使用{@link LinkedHashMap}和{@link ArrayList}来保持其条目的顺序。
 *
 * @param <K> 映射使用的键的类型。
 * @param <V> 映射使用的值的类型。
 */
public class MultiMap<K, V> where K <: Hashable & Equatable<K> {
    /**
     * 常数值。
     */
    public static let DEFAULT_MAP_SIZE = 6

    private static let ENTRY_LIST_SIZE = 3

    private let map: Map<K, ArrayList<V>>

    /**
     * 锁。
     */
    public let lock: Monitor = Monitor()

    /**
     * 构造一个初始容量为{@link#DEFAULT_MAP_SIZE}的新MultiMap。
     */
    public init() {
        this(DEFAULT_MAP_SIZE)
    }

    /**
     * 构造一个新的MultiMap。
     *
     * @param size 初始容量。
     */
    public init(size: Int) {
        this(HashMap<K, ArrayList<V>>(size))
    }

    /**
     * 构造一个新的MultiMap。
     *
     * @param map Map对象。
     */
    private init(map: Map<K, ArrayList<V>>) {
        this.map = map
    }

    /**
     * Map长度。
     */
    public prop size: Int {
        get() {
            var size = 0
            for (list in map.values()) {
                size += list.size
            }
            return size
        }
    }

    /**
     * 内容是否为空。
     *
     * @return 空返回true，不为空返回false。
     */
    public func isEmpty(): Bool {
        return map.isEmpty()
    }

    /**
     * 集合中是否包含key。
     *
     * @param key 键。
     * @return 包含返回true，不包含返回false。
     */
    public func containsKey(key: K): Bool {
        return map.contains(key)
    }

    /**
     * 获取给定键的第一个值，如果没有条目，则获取<code>None</code>。
     *
     * @param key 键。
     * @return 第一个值或None。
     */
    public func getFirst(key: K): ?V {
        let res = getAll(key)
        if (res.size == 0) {
            return None
        } else {
            return res[0]
        }
    }

    /**
     * 获取给定键的所有值。如果没有，则返回空集。
     * 如果返回集不为空，则对返回集的更改将更新基础MultiMap。
     *
     * @param key 键。
     * @return 给定键的所有值。
     */
    public func getAll(key: K): ArrayList<V> {
        return if (let Some(res) <- map.get(key)) {
            res
        } else {
            ArrayList<V>()
        }
    }

    /**
     * 插入键值对。
     *
     * @param ket 键。
     * @param value 值。
     * @return 是否插入成功。true标识插入成功，false标识插入失败。
     */
    public func put(key: K, value: V): Bool {
        return putInternal(key, {list => list.append(value)})
    }

    /**
     * 插入键值对，插入到数据顶部。
     *
     * @param ket 键。
     * @param value 值。
     * @return 是否插入成功。true标识插入成功，false标识插入失败。
     */
    public func putFirst(key: K, value: V): Bool {
        return putInternal(key, {list => list.prepend(value)})
    }

    /**
     * 插入键值对。
     *
     * @param ket 键。
     * @param value 值。
     * @return 是否插入成功。true标识插入成功，false标识插入失败。
     */
    private func putInternal(key: K, valueListConsumer: (ArrayList<V>) -> Unit): Bool {
        let keyExisted: Bool
        let list = if (let Some(list) <- map.get(key)) {
            keyExisted = true
            list
        } else {
            let list = ArrayList<V>(ENTRY_LIST_SIZE)
            map.put(key, list)
            keyExisted = false
            list
        }
        valueListConsumer(list)
        return keyExisted
    }

    /**
     * 删除给定键的所有映射，如果存在映射，则返回第一个值，否则返回<code>None</code>。
     *
     * @param  key 键。
     * @return 给定键的第一个值或None。
     */
    public func remove(key: K): ?V {
        return if (let Some(res) <- map.remove(key)) {
            res[0]
        } else {
            None
        }
    }

    /**
     * 删除给定键到值的映射。
     * 如果映射已删除，则返回<code>true</code>，如果映射不存在，则返回<code>false</code]。
     *
     * @param key 键。
     * @param value 值。
     * @return 如果映射被删除，则返回true，否则返回false。
     */
    public func removeOne(key: K, value: V): Bool {
        if (let Some(list) <- map.get(key)) {
            let res: Bool = list.removeValue(value)
            if (list.size == 0) {
                // 如果值集现在为空，也删除该键。
                map.remove(key)
            }
            return res
        } else {
            return false
        }
    }

    /**
     * 删除给定键的给定数量的值。可能返回的值比请求的值少。
     *
     * @param key 要删除的键。
     * @param num 表示要删除的值的数量。
     * @return 已删除值的列表。
     */
    public func remove(key: K, num: Int): ?ArrayList<V> {
        let values = if (let Some(values) <- map.get(key)) {
            values
        } else {
            return ArrayList<V>()
        }
        let resultSize = max(values.size, num)
        let result = ArrayList<V>(resultSize)
        var i = 0
        while (i < resultSize) {
            result.append(values[0])
            i++
        }
        if (values.isEmpty()) {
            map.remove(key)
        }
        return result
    }

    /**
     * 插入一整条Map数据。
     *
     * @param map Map。
     */
    public func putAll(map: Map<K, V>): Unit {
        for ((k, v) in map) {
            put(k, v)
        }
    }

    /**
     * 清除Map数据。
     */
    public func clear(): Unit {
        map.clear()
    }

    /**
     * 获取所有的key列表。
     *
     * @return key列表。
     */
    public func keySet(): Set<K> {
        return HashSet<K>(map.keys())
    }

    /**
     * 返回一个新列表，其中包含此多映射的所有值。
     *
     * @return 一个包含所有值的新列表。
     */
    public func values(): ArrayList<V> {
        let values = ArrayList<V>(size)
        for (list in map.values()) {
            values.appendAll(list)
        }
        return values
    }

    /**
     * 克隆一个新的Map对象。
     *
     * @return 新的Map对象。
     */
    public func clone(): MultiMap<K, V> {
        let newMap = HashMap<K, ArrayList<V>>(map.size)
        for ((k, list) in map) {
            let newList = ArrayList<V>(ENTRY_LIST_SIZE)
            newList.appendAll(list)
            newMap.put(k, newList)
        }
        return MultiMap<K, V>(newMap)
    }
}
