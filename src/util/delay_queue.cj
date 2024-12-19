/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * 可延迟的对象
 */
public interface Delayed {
    /**
     * 获取延迟时间, 表示当前还需多少延迟, 即此返回值非固定, 每次获取时应刷新
     *
     * @return 延迟时间
     */
    func getDelay(): Duration
}

/**
 * 使用延迟时间排序的线程安全阻塞队列.
 * 延迟后时间越早, 优先级越高.
 * 获取时 若当前无到期元素: 阻塞直到有到期的元素
 *      否则优先级高的先出列
 */
public class DelayQueue<T> where T <: Delayed & Comparable<T> & Object {
    let list = LinkedList<T>()

    let lock: Monitor = Monitor()

    /**
     * 添加一个元素。
     *
     * @param t 添加的元素。
     */
    public func append(t: T): Unit {
        synchronized(lock) {
            var node = list.firstNode()
            while (let Some(n) <- node) {
                node = n.next
                if (t.getDelay() < n.value.getDelay()) {
                    list.insertBefore(n, t)
                    return
                }
            }
            list.append(t)
        }
    }

    /**
     * 删除一个元素。
     *
     * @param t 删除的元素。
     * @return true 成功删除了一个元素 false 无变化
     */
    public func remove(t: T): Bool {
        synchronized(lock) {
            var node = list.firstNode()
            while (let Some(n) <- node) {
                node = n.next
                if (refEq(n.value, t)) {
                    list.remove(n)
                    return true
                }
            }
            return false
        }
    }

    /**
     * 获取头元素，不移除数据。
     *
     * @return 头元素
     */
    public func peek(): Option<T> {
        synchronized(lock) {
            list.first
        }
    }

    /**
     * 获取到期头元素
     * 若无头元素 返回None
     * 若头元素未到期 返回None
     *
     * @return 到期头元素
     */
    public func poll(): Option<T> {
        synchronized(lock) {
            let node = list.first ?? return None
            if (node.getDelay() > Duration.Zero) {
                return None
            }
            return list.popFirst()
        }
    }

    /**
     * 获取头元素
     * 若无头元素 返回None
     * 若头元素未到期 则阻塞直到头元素到期 然后返回头元素
     *
     * @return 头元素
     */
    public func take(): Option<T> {
        synchronized(lock) {
            let node = list.first ?? return None
            let delay = node.getDelay()
            if (delay > Duration.Zero) {
                sleep(delay)
            }
            return list.popFirst()
        }
    }
}
