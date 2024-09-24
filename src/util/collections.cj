/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public class Collections {
    public static let EMPTY_STRING_MAP: Map<String, String> = EmptyMap<String, String>(HashMap<String, String>())

    public static let EMPTY_STRING_COLLECTION: Collection<String> = []

    public static func unmodifiableMap<K, V>(source: Map<K, V>): Map<K, V> where K <: Equatable<K> & Hashable {
        UnmodifiableMap(HashMap<K, V>(source))
    }

    public static func unmodifiableList<T>(source: Collection<T>): Collection<T> {
        source
    }
}

class UnmodifiableMap<K, V> <: Map<K, V> where K <: Equatable<K> {
    UnmodifiableMap(let innermap: Map<K, V>) {}

    public override func get(key: K): ?V {
        innermap.get(key)
    }
    public override func contains(key: K): Bool {
        innermap.contains(key)
    }
    public override func containsAll(keys: Collection<K>): Bool {
        innermap.containsAll(keys)
    }
    public override func put(_: K, _: V): ?V {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func putAll(_: Collection<(K, V)>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func remove(_: K): Option<V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func removeAll(_: Collection<K>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func removeIf(_: (K, V) -> Bool): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func clear(): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func clone(): Map<K, V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public operator override func [](key: K): V {
        innermap[key]
    }
    public operator override func [](_: K, value!: V): Unit {
        value is ToString
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func keys(): EquatableCollection<K> {
        innermap.keys()
    }
    public override func values(): Collection<V> {
        innermap.values()
    }
    public override prop size: Int64 {
        get() {
            innermap.size
        }
    }
    public override func isEmpty(): Bool {
        innermap.size == 0
    }
    public override func iterator(): Iterator<(K, V)> {
        innermap.iterator()
    }
}

class EmptyMap<K, V> <: Map<K, V> where K <: Equatable<K> {
    EmptyMap(let empty: Map<K, V>) {}
    public override func get(_: K): ?V {
        None
    }
    public override func contains(_: K): Bool {
        false
    }
    public override func containsAll(_: Collection<K>): Bool {
        false
    }
    public override func put(_: K, _: V): ?V {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func putAll(_: Collection<(K, V)>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func remove(_: K): Option<V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func removeAll(_: Collection<K>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func removeIf(_: (K, V) -> Bool): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func clear(): Unit {}
    public override func clone(): Map<K, V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public operator override func [](_: K): V {
        throw UnsupportedException("UnsupportedOperation")
    }
    public operator override func [](_: K, value!: V): Unit {
        value is ToString
        throw UnsupportedException("UnsupportedOperation")
    }
    public override func keys(): EquatableCollection<K> {
        empty.keys()
    }
    public override func values(): Collection<V> {
        empty.values()
    }
    public override prop size: Int64 {
        get() {
            0
        }
    }
    public override func isEmpty(): Bool {
        true
    }
    public override func iterator(): Iterator<(K, V)> {
        empty.iterator()
    }
}
