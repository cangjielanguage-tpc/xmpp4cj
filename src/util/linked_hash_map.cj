/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * 定义一个 LinkedHashMap 类，它实现了 Map 接口，支持按插入顺序保持键值对。
 *
 * @param <K> 映射使用的键的类型。
 * @param <V> 映射使用的值的类型。
 */
public class LinkedHashMap<K, V> <: Map<K, V> where K <: Hashable & Equatable<K> {
    private let map: HashMap<K, V> = HashMap<K, V>()

    private let arr: ArrayList<(K, V)> = ArrayList<(K, V)>()

    /**
     * 通过index获取当前位置的键值对。
     *
     * @param index 位置。
     * @return 键值对。
     */
    public operator func [](index: Int64): (K, V) {
        arr[index]
    }

    func set(key: K, value: V): Unit {
        for (i in 0..arr.size where arr[i][0] == key) {
            arr[i] = (key, value)
        }
    }

    /**
     * 通过key获取value。
     *
     * @param key 键。
     * @return 值。
     */
    public override func get(key: K): ?V {
        map.get(key)
    }

    /**
     * 是否包含key。
     *
     * @param key LazyStringBuilder数据。
     * @return true表示包含key，false表示不包含。
     */
    public override func contains(key: K): Bool {
        map.contains(key)
    }

    /**
     * 是否包含key列表。
     *
     * @param keys key列表。
     * @return true表示包含key，false表示不包含。
     */
    public override func containsAll(keys: Collection<K>): Bool {
        map.containsAll(keys)
    }

    /**
     * 添加键值对。
     *
     * @param key 键。
     * @param value 值。
     * @return 替换值的话返回是之前的值，添加新的数据返回None。
     */
    public override func put(key: K, value: V): ?V {
        if (let Some(old) <- map.put(key, value)) {
            set(key, value)
            old
        } else {
            arr.append((key, value))
            None
        }
    }

    /**
     * 添加键值对列表。
     *
     * @param kvs 键值对列表。
     */
    public override func putAll(kvs: Collection<(K, V)>): Unit {
        for (kv in kvs) {
            put(kv[0], kv[1])
        }
    }

    /**
     * 删除为key的值。
     *
     * @param key 键。
     * @return 删除成功返回之前的值，没有删除返回时None。
     */
    public override func remove(key: K): Option<V> {
        if (let Some(old) <- map.remove(key)) {
            arr.removeIf {kv => kv[0] == key}
            old
        } else {
            None
        }
    }

    /**
     * 删除key列表。
     *
     * @param keys key列表。
     */
    public override func removeAll(keys: Collection<K>): Unit {
        for (key in keys) {
            remove(key)
        }
    }

    /**
     * 删除满足给定 lambda 表达式或函数的所有元素。
     *
     * @param matcher 要删除的元素。
     */
    public override func removeIf(matcher: (K, V) -> Bool): Unit {
        arr.removeIf {kv => matcher(kv[0], kv[1])}
        map.removeIf(matcher)
    }

    /**
     * 清除数据
     */
    public override func clear() {
        arr.clear()
        map.clear()
    }

    /**
     * 克隆一个Map对象。
     *
     * @return Map对象。
     */
    public override func clone(): Map<K, V> {
        throw UnsupportedException("UnsupportedOperation")
    }

    /**
     * 通过key获取value。
     *
     * @param key 键。
     * @return 值。
     */
    public operator override func [](key: K): V {
        map[key]
    }

    /**
     * 添加LazyStringBuilder数据。
     *
     * @param lsb LazyStringBuilder数据。
     * @return 当前对象。
     */
    public operator override func [](key: K, value!: V): Unit {
        map[key] = value
        set(key, value)
    }

    /**
     * 获取key列表。
     *
     * @return key列表。
     */
    public override func keys(): EquatableCollection<K> {
        HashMap<K, V>(arr).keys()
    }

    /**
     * 获取value列表。
     *
     * @return value列表。
     */
    public override func values(): Collection<V> {
        HashMap<K, V>(arr).values()
    }

    /**
     * 数据长度
     */
    public override prop size: Int64 {
        get() {
            arr.size
        }
    }

    /**
     * 判断是否为空。
     *
     * @return true表示为空，false表示不为空。
     */
    public override func isEmpty(): Bool {
        arr.isEmpty()
    }

    /**
     * 返回<K,V>类型的迭代器。
     *
     * @return <K,V>类型的迭代器。
     */
    public override func iterator(): Iterator<(K, V)> {
        arr.iterator()
    }
}
