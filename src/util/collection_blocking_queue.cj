/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/* 提供可迭代的BlockingQueue */
public class CollectionBlockingQueue<E> <: Collection<E> {
    private let lock: Monitor = Monitor() // 所有方法都应该是synchronized
    private var queue: ArrayBlockingQueue<E>
    public init(capacity: Int) {
        queue = ArrayBlockingQueue<E>(capacity)
    }

    public override prop size: Int64 {
        get() {
            synchronized(lock) {
                queue.size
            }
        }
    }

    public override func isEmpty(): Bool {
        synchronized(lock) {
            queue.size == 0
        }
    }

    public override func iterator(): Iterator<E> {
        synchronized(lock) {
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
