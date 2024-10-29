/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * 对比工具类
 */
public class EqualsUtil {
    /**
     * 两个对象进行对比。
     *
     * @param thisObj 第一个对象。
     * @param other 第二个对象。
     * @param equalsComperator 接口。
     * @return 是否相等。true表示相等，false表示不相等。
     */
    public static func equals<T>(thisObj: T, other: T, equalsComperator: EqualsComperator<T>): Bool {
        match ((thisObj, other)) {
            case (a: Object, b: Object) where refEq(a, b) => return true
            case _ => ()
        }
        match ((thisObj, other)) {
            case (a: Hashable, b: Hashable) where a.hashCode() != b.hashCode() => return false
            case _ => ()
        }
        let equalsBuilder = EqualsBuilder()
        equalsComperator(equalsBuilder, other)
        return equalsBuilder.isEquals
    }

    /**
     * 两个对象进行对比。
     *
     * @param a 第一个对象。
     * @param b 第二个对象。
     * @return 是否相等。true表示相等，false表示不相等。
     * @throws UnsupportedException a b 类型不正确的时候抛UnsupportedException异常。
     */
    public static func equals<T>(a: T, b: T): Bool {
        match ((a, b)) {
            case (a: Equatable<T>, _: Equatable<T>) => a == b
            case (a: Object, b: Object) => refEq(a, b)
            case _ => throw UnsupportedException("${a as ToString} ${b as ToString}")
        }
    }
}

public type EqualsComperator<T> = (equalsBuilder: EqualsBuilder, other: T) -> Unit

/**
 * 对比工具类
 */
public class EqualsBuilder {
    var isEquals = true

    /**
     * 判断两条数据是否相等，并且返回EqualsBuilder对象。
     *
     * @param left 第一条数据。
     * @param right 第二条数据。
     * @return EqualsBuilder对象。
     */
    public func append(left: ?String, right: ?String): EqualsBuilder {
        if (!isEquals) {
            return this
        }
        isEquals = left == right
        return this
    }
}
