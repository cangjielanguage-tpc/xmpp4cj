/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public class LinkedHashMap<K, V> <: Map<K, V> where K <: Hashable & Equatable<K> {
    private let map: HashMap<K, V> = HashMap<K, V>()
    private let arr: ArrayList<(K, V)> = ArrayList<(K, V)>()

    public operator func [](index: Int64): (K, V) {
        arr[index]
    }
    func set(key: K, value: V): Unit {
        for (i in 0..arr.size where arr[i][0] == key) {
            arr[i] = (key, value)
        }
    }
    public override func get(key: K): ?V {
        map.get(key)
    }
    public override func contains(key: K): Bool {
        map.contains(key)
    }
    public override func containsAll(keys: Collection<K>): Bool {
        map.containsAll(keys)
    }
    public override func put(key: K, value: V): ?V {
        if (let Some(old) <- map.put(key, value)) {
            set(key, value)
            old
        } else {
            arr.append((key, value))
            None
        }
    }
    public override func putAll(kvs: Collection<(K, V)>): Unit {
        for (kv in kvs) {
            put(kv[0], kv[1])
        }
    }
    public override func remove(key: K): Option<V> {
        if (let Some(old) <- map.remove(key)) {
            arr.removeIf {kv => kv[0] == key}
            old
        } else {
            None
        }
    }
    public override func removeAll(keys: Collection<K>): Unit {
        for (key in keys) {
            remove(key)
        }
    }
    public override func removeIf(matcher: (K, V) -> Bool): Unit {
        arr.removeIf {kv => matcher(kv[0], kv[1])}
        map.removeIf(matcher)
    }
    public override func clear() {
        arr.clear()
        map.clear()
    }
    public override func clone(): Map<K, V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public operator override func [](key: K): V {
        map[key]
    }
    public operator override func [](key: K, value!: V): Unit {
        map[key] = value
        set(key, value)
    }
    public override func keys(): EquatableCollection<K> {
        HashMap<K, V>(arr).keys()
    }
    public override func values(): Collection<V> {
        HashMap<K, V>(arr).values()
    }
    public override prop size: Int64 {
        get() {
            arr.size
        }
    }
    public override func isEmpty(): Bool {
        arr.isEmpty()
    }
    public override func iterator(): Iterator<(K, V)> {
        arr.iterator()
    }
}
