/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class EqualsUtil {
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

    public static func equals<T>(a: T, b: T): Bool {
        match ((a, b)) {
            case (a: Equatable<T>, _: Equatable<T>) => a == b
            case (a: Object, b: Object) => refEq(a, b)
            case _ => throw UnsupportedException("${a as ToString} ${b as ToString}")
        }
    }
}

public type EqualsComperator<T> = (equalsBuilder: EqualsBuilder, other: T) -> Unit

public class EqualsBuilder {
    var isEquals = true

    public func append(left: ?String, right: ?String): EqualsBuilder {
        if (!isEquals) {
            return this
        }
        isEquals = left == right
        return this
    }
}
