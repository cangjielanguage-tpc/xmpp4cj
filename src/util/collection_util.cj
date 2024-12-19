/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/** 
 * 列表工具类
 */
public class CollectionUtil {
    /**
     * 列表不为空。
     *
     * @param collection 列表。
     * @param collectionName 为空抛异常的提示信息。
     * @return 列表。
     * @throws IllegalArgumentException collection没数据的时候抛IllegalArgumentException异常。
     */
    public static func requireNotEmpty<T>(collection: Collection<T>, collectionName: String): Collection<T> {
        if (collection.isEmpty()) {
            throw IllegalArgumentException("${collectionName} must not be empty.")
        }
        return collection
    }

    /**
     * 清空collection数据，返回collection长度的空列表。
     *
     * @param collection 列表。
     * @param predicate 接口。
     * @return collection长度的空列表。
     */
    public static func removeUntil<T, C>(collection: C, predicate: (T) -> Bool): ArrayList<T> where C <: ArrayList<T> {
        let removedElements = ArrayList<T>(collection.size)
        let i = 0
        while (i < collection.size) {
            let t = collection[i]
            if (predicate(t)) {
                break
            }
        }
        collection.remove(0..i)
        return removedElements
    }

    /**
     * 通过Collection对象创建一个列表对象。
     *
     * @param collection Collection对象。
     * @return 可能为空的列表对象。
     */
    public static func newListWith<T>(collection: ?Collection<T>): ?ArrayList<T> {
        return ArrayList<T>(collection ?? return None)
    }

    /**
     * 通过Collection对象创建一个列表对象。
     *
     * @param collection Collection对象。
     * @return 列表对象。
     */
    public static func cloneAndSeal<T>(collection: ?Collection<T>): ArrayList<T> {
        if (collection.isNone()) {
            return ArrayList<T>()
        }
        let clone = newListWith(collection)
        return clone.getOrThrow()
    }

    /**
     * 克隆一个Map对象。
     *
     * @param collection Collection对象。
     * @return 新的Map对象。
     */
    public static func cloneAndSeal<K, V>(map: Map<K, V>): Map<K, V> where K <: Equatable<K> & Hashable {
        let clone: Map<K, V> = HashMap<K, V>(map)
        return Collections.unmodifiableMap(clone)
    }

    /**
     * 通过Collection对象创建一个Set对象。
     *
     * @param collection Collection对象。
     * @return Set对象。
     */
    public static func newSetWith<T>(collection: ?Collection<T>): ?Set<T> where T <: Equatable<T> & Hashable {
        return HashSet<T>(collection ?? return None)
    }

    /**
     * 通过element创建一个空的列表对象或者只有一条element数据的列表对象。
     *
     * @param element 泛型。
     * @return 列表。
     */
    public static func emptyOrSingletonListFrom<T>(element: ?T): ArrayList<T> {
        return ArrayList<T>([element ?? return ArrayList<T>()])
    }
}
