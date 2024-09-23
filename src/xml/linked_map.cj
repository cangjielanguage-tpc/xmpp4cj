/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xml

/*
 * 内部使用 不完全实现
 */
class LinkedHashMap<K, V> where K <: Hashable & Equatable<K> {
    private let map: HashMap<K, V> = HashMap<K, V>()
    private let kvs: ArrayList<(K, V)> = ArrayList<(K, V)>()
    func put(k: K, v: V): Unit {
        if (let Some(old) <- map.put(k, v)) {
            for (i in 0..kvs.size where kvs[i][0] == k) {
                kvs[i] = (k, v)
            }
        } else {
            kvs.append((k, v))
        }
    }
    operator func [](key: K): V {
        map[key]
    }
    func get(key: K): ?V {
        map.get(key)
    }
    operator func [](index: Int64): (K, V) {
        kvs[index]
    }
    func clear() {
        map.clear()
        kvs.clear()
    }
    prop size: Int64 {
        get() {
            kvs.size
        }
    }
}
