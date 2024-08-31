package xmpp4cj.xml

class LinkedHashMap<K, V> where K <: Hashable & Equatable<K> {
    private let map: HashMap<K, V> = HashMap<K, V>()
    private let kvs: ArrayList<(K, V)> = ArrayList<(K, V)>()
    func put(k: K, v: V): Unit {
        map.put(k, v)
        kvs.append((k, v))
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
