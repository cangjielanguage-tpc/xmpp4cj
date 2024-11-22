/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/* 
 * 线程安全的LinkedList
 */
public class ConcurrentLinkedQueue<T> <: Collection<T> {
    private let lock: Monitor = Monitor()
    private let list = LinkedList<T>()

    /**
     * 获取列表长度。
     */
    public prop size: Int64 {
        get() {
            synchronized(lock) {
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
        synchronized(lock) {
            list.append(t)
        }
    }

    public func prepend(t: T): Unit {
        synchronized(lock) {
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
        synchronized(lock) {
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
        synchronized(lock) {
            var node = list.nodeAt(index)
            if (let Some(n) <- node) {
                let v = n.value
                list.remove(n)
                return v
            }
            return None
        }
    }

    /**
     * 清空列表。
     */
    public func clear(): Unit {
        synchronized(lock) {
            list.clear()
        }
    }

    /**
     * 判断列表是否为空。
     *
     * @return true表示列表为空，false表示列表不为空。
     */
    public override func isEmpty(): Bool {
        synchronized(lock) {
            list.isEmpty()
        }
    }

    /**
     * 返回列表迭代器。
     *
     * @return 迭代器。
     */
    public override func iterator(): Iterator<T> {
        synchronized(lock) {
            list.iterator()
        }
    }

    /**
     * 返回倒序迭代器
     *
     * @return 迭代器。
     */
    public func reverseIterator(): Iterator<T> {
        ReverseIterator(list.lastNode())
    }
}

class ReverseIterator<T> <: Iterator<T> {
    ReverseIterator(var begin: ?LinkedListNode<T>) {}
    public override func next(): ?T {
        let current = begin?.value
        begin = (begin?.prev).flatten()
        current
    }
}
