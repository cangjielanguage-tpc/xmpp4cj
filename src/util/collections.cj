/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * 定义一个公共类 Collections，提供常用的集合操作和常量
 */
public class Collections {
    /**
     * 定义一个不可变的空字符串映射，使用空的 HashMap 初始化。
     */
    public static let EMPTY_STRING_MAP: Map<String, String> = EmptyMap<String, String>(HashMap<String, String>())

    /**
     * 定义一个不可变的空字符串集合。
     */
    public static let EMPTY_STRING_COLLECTION: Collection<String> = []

    /**
     * 通过source创建一个不可改变的Map对象。
     *
     * @param source Map对象。
     * @return 不可改变的Map对象。
     */
    public static func unmodifiableMap<K, V>(source: Map<K, V>): Map<K, V> where K <: Equatable<K> & Hashable {
        UnmodifiableMap(HashMap<K, V>(source))
    }

    /**
     * 通过source创建一个不可改变的Collection对象。
     *
     * @param source Collection对象。
     * @return 不可改变的Collection对象。
     */
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
