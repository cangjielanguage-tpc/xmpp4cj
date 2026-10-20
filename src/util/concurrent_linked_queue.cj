package xmpp4cj.util

/**
 * 线程安全的LinkedList
 */
public class ConcurrentLinkedList<T> <: Collection<T> {
    private let lock: Mutex = Mutex()
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
            list.addLast(t)
        }
    }

    public func prepend(t: T): Unit {
        synchronized(lock) {
            list.addFirst(t)
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
     * 返回基于快照的弱一致迭代器：迭代期间其它线程的增删不会被本次迭代观察到，
     * 也不会因此抛出 ConcurrentModificationException（对齐 java.util.concurrent 的弱一致语义）。
     * 注意：不能直接返回底层 {@code list.iterator()}，它是 fail-fast 迭代器，
     * 在遍历过程中若列表被其它线程修改会抛 ConcurrentModificationException。
     *
     * @return 迭代器。
     */
    public override func iterator(): Iterator<T> {
        let snapshot = ArrayList<T>()
        synchronized(lock) {
            for (e in list) {
                snapshot.add(e)
            }
        }
        snapshot.iterator()
    }

    /**
     * 返回倒序迭代器
     *
     * @return 迭代器。
     */
    public func reverseIterator(): Iterator<T> {
        ReverseIterator(list.lastNode)
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
