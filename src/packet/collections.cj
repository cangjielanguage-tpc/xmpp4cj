/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

class UnmodifiableMap<K, V> <: Map<K, V> where K <: Equatable<K> {
    UnmodifiableMap(let innermap: Map<K, V>) {}

    public func get(key: K): ?V {
        innermap.get(key)
    }
    public func contains(key: K): Bool {
        innermap.contains(key)
    }
    public func containsAll(keys: Collection<K>): Bool {
        innermap.containsAll(keys)
    }
    public func put(_: K, _: V): ?V {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func putAll(_: Collection<(K, V)>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func remove(_: K): Option<V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func removeAll(_: Collection<K>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func removeIf(_: (K, V) -> Bool): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func clear(): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func clone(): Map<K, V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public operator func [](key: K): V {
        innermap[key]
    }
    public operator func [](_: K, value!: V): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func keys(): EquatableCollection<K> {
        innermap.keys()
    }
    public func values(): Collection<V> {
        innermap.values()
    }
    public prop size: Int64 {
        get() {
            innermap.size
        }
    }
    public func isEmpty(): Bool {
        innermap.size == 0
    }
    public func iterator(): Iterator<(K, V)> {
        innermap.iterator()
    }
}

class EmptyMap<K, V> <: Map<K, V> where K <: Equatable<K> {
    EmptyMap(let empty: Map<K, V>) {}
    public func get(_: K): ?V {
        None
    }
    public func contains(_: K): Bool {
        false
    }
    public func containsAll(_: Collection<K>): Bool {
        false
    }
    public func put(_: K, _: V): ?V {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func putAll(_: Collection<(K, V)>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func remove(_: K): Option<V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func removeAll(_: Collection<K>): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func removeIf(_: (K, V) -> Bool): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func clear(): Unit {}
    public func clone(): Map<K, V> {
        throw UnsupportedException("UnsupportedOperation")
    }
    public operator func [](_: K): V {
        throw UnsupportedException("UnsupportedOperation")
    }
    public operator func [](_: K, value!: V): Unit {
        throw UnsupportedException("UnsupportedOperation")
    }
    public func keys(): EquatableCollection<K> {
        empty.keys()
    }
    public func values(): Collection<V> {
        empty.values()
    }
    public prop size: Int64 {
        get() {
            0
        }
    }
    public func isEmpty(): Bool {
        true
    }
    public func iterator(): Iterator<(K, V)> {
        empty.iterator()
    }
}

class Collections {
    private static let empty = HashMap<String, String>()
    static let EMPTY_STRING_MAP: Map<String, String> = EmptyMap(empty)

    static let EMPTY_STRING_COLLECTION: Collection<String> = []
    static let EMPTY_EXTENSION_ELEMENT_COLLECTION: Collection<ExtensionElement> = []
    static let EMPTY_STANDARD_EXTENSION_ELEMENT_COLLECTION: Collection<StandardExtensionElement> = []
}
