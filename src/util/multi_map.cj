/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * A lightweight implementation of a MultiMap, that is a Map that is able to hold multiple values for every key.
 * <p>
 * This MultiMap uses a {@link LinkedHashMap} together with a {@link ArrayList} in order to keep the order of its entries.
 * </p>
 *
 * @param <K> the type of the keys the map uses.
 * @param <V> the type of the values the map uses.
 */
public class MultiMap<K, V> where K <: Hashable & Equatable<K> {
    /**
     * The constant value {@value}.
     */
    public static let DEFAULT_MAP_SIZE = 6
    private static let ENTRY_LIST_SIZE = 3

    private let map: Map<K, ArrayList<V>>
    public let lock: Monitor = Monitor()

    /**
     * Constructs a new MultiMap with a initial capacity of {@link #DEFAULT_MAP_SIZE}.
     */
    public init() {
        this(DEFAULT_MAP_SIZE)
    }

    /**
     * Constructs a new MultiMap.
     *
     * @param size the initial capacity.
     */
    public init(size: Int) {
        this(HashMap<K, ArrayList<V>>(size))
    }

    private init(map: Map<K, ArrayList<V>>) {
        this.map = map
    }

    public prop size: Int {
        get() {
            var size = 0
            for (list in map.values()) {
                size += list.size
            }
            return size
        }
    }

    public func isEmpty(): Bool {
        return map.isEmpty()
    }

    public func containsKey(key: K): Bool {
        return map.contains(key)
    }

    /**
     * Get the first value for the given key, or <code>None</code> if there are no entries.
     *
     * @param key
     * @return the first value or None.
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
     * Get all values for the given key. Returns the empty set if there are none.
     * <p>
     * Changes to the returned set will update the underlying MultiMap if the return set is not empty.
     * </p>
     *
     * @param key
     * @return all values for the given key.
     */
    public func getAll(key: K): ArrayList<V> {
        return if (let Some(res) <- map.get(key)) {
            res
        } else {
            ArrayList<V>()
        }
    }

    public func put(key: K, value: V): Bool {
        return putInternal(key, {list => list.append(value)})
    }

    public func putFirst(key: K, value: V): Bool {
        return putInternal(key, {list => list.prepend(value)})
    }

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
     * Removes all mappings for the given key and returns the first value if there where mappings or <code>None</code> if not.
     *
     * @param key
     * @return the first value of the given key or None.
     */
    public func remove(key: K): ?V {
        return if (let Some(res) <- map.remove(key)) {
            res[0]
        } else {
            None
        }
    }

    /**
     * Remove the mapping of the given key to the value.
     * <p>
     * Returns <code>true</code> if the mapping was removed and <code>false</code> if the mapping did not exist.
     * </p>
     *
     * @param key
     * @param value
     * @return true if the mapping was removed, false otherwise.
     */
    public func removeOne(key: K, value: V): Bool {
        if (let Some(list) <- map.get(key)) {
            let res: Bool = list.remove(value)
            if (list.size == 0) {
                // Remove the key also if the value set is now empty
                map.remove(key)
            }
            return res
        } else {
            return false
        }
    }

    /**
     * Remove the given number of values for a given key. May return less values then requested.
     *
     * @param key the key to remove from.
     * @param num the number of values to remove.
     * @return a list of the removed values.
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

    public func putAll(map: Map<K, V>): Unit {
        for ((k, v) in map) {
            put(k, v)
        }
    }

    public func clear(): Unit {
        map.clear()
    }

    public func keySet(): Set<K> {
        return HashSet<K>(map.keys())
    }

    /**
     * Returns a new list containing all values of this multi map.
     *
     * @return a new list with all values.
     */
    public func values(): ArrayList<V> {
        let values = ArrayList<V>(size)
        for (list in map.values()) {
            values.appendAll(list)
        }
        return values
    }

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
