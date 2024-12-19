/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * 可前进后退的迭代器
 */
public class ListIterator<T> <: Iterator<T> {
    public let data: Array<T>
    var nextIndex = 0
    /*
     * @param iter 源迭代器
     * @param iterIndex 开始位置
     */
    public ListIterator(let iter: Iterator<T>, let iterIndex: Int) {
        this.data = iter |> collectArray
        this.nextIndex = iterIndex
    }
    /*
     * @param iter 源迭代器
     */
    public init(iter: Iterator<T>) {
        this.iter = iter
        this.iterIndex = 0
        this.data = iter |> collectArray
    }
    public func hasNext(): Bool {
        nextIndex < data.size
    }
    public override func next(): ?T {
        if (hasNext()) {
            let v = data[nextIndex]
            nextIndex++
            v
        } else {
            None
        }
    }
    public func hasPrevious(): Bool {
        nextIndex - 1 >= 0
    }
    public func previous(): ?T {
        if (hasPrevious()) {
            let v = data[nextIndex - 1]
            nextIndex--
            v
        } else {
            None
        }
    }
}
