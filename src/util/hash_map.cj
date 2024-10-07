/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/* 
 * 可以使用任意K的HashMap
 * - K.hashCode()优先级:
 *  1. K.hashCode()
 *  2. K.toString().hashCode()
 *  3. -1
 * - K的比较使用EqualsUtil.equals(K, K), 优先级:
 *  1. K==K
 *  2. refEq(K, K)
 * - 由于不限定K, 所以无法继承Map
 */
public class SimpleHashMap<K, V> <: Collection<(K, V)> {
    public let lock = Monitor()

    private let inner = HashMap<HashMapKey<K>, V>()

    // override
    /**
     * 通过k获取map的值。
     *
     * @param k 键。
     * @return map的值，没有为None。
     */
    public func get(k: K): ?V {
        inner.get(HashMapKey(k))
    }

    // override
    /**
     * 判断map中有没是k的键。
     *
     * @param k 键。
     * @return true表示包含，false表示不包含。
     */
    public func contains(k: K): Bool {
        inner.contains(HashMapKey(k))
    }

    // override
    /**
     * 判断map中是否包含列表。
     *
     * @param _ 列表。
     * @return true表示包含，false表示不包含。
     */
    public func containsAll(_: Collection<K>): Bool {
        throw UnsupportedException("UnsupportedOperation")
    }

    // override
    /**
     * 添加键值对。
     *
     * @param k 键。
     * @param v 值。
     * @return 值。
     */
    public func put(k: K, v: V): ?V {
        inner.put(HashMapKey(k), v)
    }

    // override
    /**
     * 添加键值对列表。
     *
     * @param kv 键值对列表。
     */
    public func putAll(kv: Collection<(K, V)>): Unit {
        for ((k, v) in kv) {
            inner.put(HashMapKey(k), v)
        }
    }

    // override
    /**
     * 删除键为k的数据。
     *
     * @param k 键。
     * @return 键为k对应的值。
     */
    public func remove(k: K): Option<V> {
        inner.remove(HashMapKey(k))
    }

    // override
    /**
     * 删除列表k。
     *
     * @param ks k的列表。
     */
    public func removeAll(ks: Collection<K>): Unit {
        for (k in ks) {
            inner.remove(HashMapKey(k))
        }
    }

    // override
    /**
     * 通过k获取map的值。
     *
     * @param k 键。
     * @return map的值，没有为None。
     */
    public func removeIf(kvf: (K, V) -> Bool): Unit {
        inner.removeIf {k, v => kvf(k.key, v)}
    }

    // override
    /**
     * 清空数据。
     */
    public func clear(): Unit {
        inner.clear()
    }

    // public override func clone(): Map<K, V> {
    //     throw UnsupportedException("UnsupportedOperation")
    // }

    // override
    /**
     * 通过k获取map的值。
     *
     * @param k 键。
     * @return map的值。
     */
    public operator func [](k: K): V {
        inner[HashMapKey(k)]
    }

    // override
    /**
     * 插入键为k值为value的值。
     *
     * @param k 键。
     * @param value 值。
     */
    public operator func [](k: K, value!: V): Unit {
        inner[HashMapKey(k)] = value
    }

    // override
    /**
     * 返回key列表的迭代器。
     *
     * @return 迭代器。
     */
    public func keys(): Iterable<K> {
        inner.keys() |> map {k => k.key}
    }

    // override
    /**
     * 返回value列表。
     *
     * @return value列表。
     */
    public func values(): Collection<V> {
        inner.values()
    }

    /**
     * map长度。
     */
    public override prop size: Int64 {
        get() {
            inner.size
        }
    }

    /**
     * 判断map是否为空。
     *
     * @return true表示为空，false表示不为空。
     */
    public override func isEmpty(): Bool {
        inner.isEmpty()
    }

    /**
     * 获取键值对的迭代器。
     *
     * @return 键值对的迭代器。
     */
    public override func iterator(): Iterator<(K, V)> {
        inner.iterator() |> map {kv => (kv[0].key, kv[1])}
    }
}

class HashMapKey<K> <: Hashable & Equatable<HashMapKey<K>> {
    HashMapKey(let key: K) {}

    public override func hashCode(): Int64 {
        match (key) {
            case v: Hashable => v.hashCode()
            case v: ToString => v.toString().hashCode()
            case _ => -1
        }
    }

    public operator func ==(other: HashMapKey<K>): Bool {
        EqualsUtil.equals(this.key, other.key)
    }
}
