/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * 线程安全的Set 使用EqualsUtil.equals判等
 */
public class ConcurrentSet<T> <: Collection<T> {
    let list = LinkedList<T>()

    public let lock: Monitor = Monitor()

    /**
     * set长度。
     */
    public prop size: Int64 {
        get() {
            synchronized(lock) {
                list.size
            }
        }
    }

    /**
     * 判断set时候为空。
     *
     * @return true表示为空，false表示不为空。
     */
    public override func isEmpty(): Bool {
        synchronized(lock) {
            list.isEmpty()
        }
    }

    /**
     * 返回set的迭代器。
     *
     * @return 迭代器。
     */
    public override func iterator(): Iterator<T> {
        synchronized(lock) {
            list.iterator()
        }
    }

    /**
     * 清除set数据。
     */
    public func clear(): Unit {
        synchronized(lock) {
            list.clear()
        }
    }

    // public override func clone(): ConcurrentSet<T> {
    //     throw UnsupportedException()
    // }

    // public override func contains(_: T): Bool {
    //     throw UnsupportedException()
    // }

    // public override func containsAll(_: Collection<T>): Bool {
    //     throw UnsupportedException()
    // }

    /**
     * 像set中插入数据。
     *
     * @param t 插入的数据。
     * @return true表示插入成功，false表示插入失败。
     */
    public func put(t: T): Bool {
        synchronized(lock) {
            var node: ?LinkedListNode<T> = list.firstNode
            while (let Some(n) <- node) {
                node = n.next
                if (EqualsUtil.equals(n.value, t)) {
                    return false
                }
            }
            list.addLast(t)
            return true
        }
    }

    // public override func putAll(_: Collection<T>): Unit {
    //     throw UnsupportedException()
    // }

    /**
     * 删除t的数据。
     *
     * @param t 要删除的数据。
     * @return true表示删除成功，false表示删除失败。
     */
    public func remove(t: T): Bool {
        synchronized(lock) {
            let flag = [false]
            list.removeIf {
                v =>
                let got = EqualsUtil.equals(v, t)
                if (got) {
                    flag[0] = true
                }
                got
            }
            return flag[0]
        }
    }

    // public override func removeAll(_: Collection<T>): Unit {
    //     throw UnsupportedException()
    // }

    // public func removeIf(f: (T) -> Bool): Unit {
    //     throw UnsupportedException()
    // }

    // public override func retainAll(_: Set<T>): Unit {
    //     throw UnsupportedException()
    // }

    // public override func subsetOf(_: Set<T>): Bool {
    //     throw UnsupportedException()
    // }
}
