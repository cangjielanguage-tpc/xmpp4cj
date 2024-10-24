/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/** 
 * 提供可迭代的BlockingQueue。
 */
public class CollectionBlockingQueue<E> <: Collection<E> {
    private let lock: ReentrantReadWriteMutex = ReentrantReadWriteMutex() // 所有方法都应该是synchronized

    private var queue: ArrayBlockingQueue<E>

    /**
     * 构造一个初始容量为capacity的新ArrayBlockingQueue。
     */
    public init(capacity: Int) {
        queue = ArrayBlockingQueue<E>(capacity)
    }

    /**
     * 构造
     */
    public init(arr: ArrayBlockingQueue<E>) {
        queue = arr
    }

    /**
     * 列表长度。
     */
    public override prop size: Int64 {
        get() {
            synchronized(lock.readMutex) {
                queue.size
            }
        }
    }

    /**
     * 内容是否为空。
     *
     * @return 空返回true，不为空返回false。
     */
    public override func isEmpty(): Bool {
        synchronized(lock.readMutex) {
            queue.size == 0
        }
    }

    /**
     * 返回列表的迭代器。
     *
     * @return 迭代器。
     */
    public override func iterator(): Iterator<E> {
        synchronized(lock.writeMutex) {
            let old = queue
            let arr: ArrayList<E> = ArrayList<E>(old.capacity)
            queue = ArrayBlockingQueue<E>(old.capacity)
            while (let Some(v) <- old.tryDequeue()) {
                arr.append(v)
                queue.enqueue(v)
            }
            arr.iterator()
        }
    }
}
