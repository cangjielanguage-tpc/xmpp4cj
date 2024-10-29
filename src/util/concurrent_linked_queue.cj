/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/* 
 * 线程安全的LinkedList
 */
public class ConcurrentLinkedQueue<T> <: Collection<T> {
    private let lock: ReentrantReadWriteMutex = ReentrantReadWriteMutex()
    private let list = LinkedList<T>()

    /**
     * 获取列表长度。
     */
    public prop size: Int64 {
        get() {
            synchronized(lock.readMutex) {
                list.size
            }
        }
    }

    /**
     * 向列表中添加数据。
     *
     * @param t 数据。
     */
    public func append(t: T): Unit {
        synchronized(lock.writeMutex) {
            list.append(t)
        }
    }

    public func prepend(t: T): Unit {
        synchronized(lock.writeMutex) {
            list.prepend(t)
        }
    }

    /**
     * 删除为t的数据。
     *
     * @param t 要删除的数据。
     * @return true 删除成功，false 未找到。
     */
    public func remove(t: T): Bool {
        synchronized(lock.writeMutex) {
            let res = [false]
            list.removeIf {
                item =>
                let eq = EqualsUtil.equals(item, t)
                if (eq) {
                    res[0] = true
                }
                eq
            }
            return res[0]
        }
    }

    /**
     * 删除下标为index的数据。
     *
     * @param index 下标。
     * @return index旧数据
     */
    public func remove(index: Int): ?T {
        synchronized(lock.writeMutex) {
            var node = list.nodeAt(index)
            if (let Some(n) <- node) {
                list.remove(n)
                return n.value
            }
            return None
        }
    }

    /**
     * 清空列表。
     */
    public func clear(): Unit {
        synchronized(lock.writeMutex) {
            list.clear()
        }
    }

    /**
     * 判断列表是否为空。
     *
     * @return true表示列表为空，false表示列表不为空。
     */
    public override func isEmpty(): Bool {
        synchronized(lock.readMutex) {
            list.isEmpty()
        }
    }

    /**
     * 返回列表迭代器。
     *
     * @return 迭代器。
     */
    public override func iterator(): Iterator<T> {
        synchronized(lock.writeMutex) {
            list.iterator()
        }
    }
}
