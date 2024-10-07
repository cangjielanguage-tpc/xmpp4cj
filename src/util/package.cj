/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
/**
 * Utility classes.
 */
package xmpp4cj.util

internal import crypto.crypto.*
internal import encoding.hex.*
internal import std.collection.*
internal import std.collection.concurrent.*
internal import std.math.*
internal import std.random.*
internal import std.regex.*
internal import std.sync.*
internal import log.*

/*
 * ArrayList工具类
 */
public interface ArrayListExt<T> {
    /**
     * 删除第一个匹配的值。
     *
     * @param v 需要匹配的数据。
     * @return 是否删除成功。
     */
    func remove(v: T): Bool
}

/*
 * 扩展ArrayList
 */
extend<T> ArrayList<T> <: ArrayListExt<T> {
    /**
     * 删除第一个匹配的值。
     *
     * @param v 需要匹配的数据。
     * @return 是否删除成功。
     */
    public func remove(v: T): Bool {
        for (i in 0..this.size) {
            if (EqualsUtil.equals(this[i], v)) {
                this.remove(i)
                return true
            }
        }
        return false
    }
}

/*
 * Objects工具类
 */
public class Objects {
    /**
     * 将Option<T>对象处理成T。
     *
     * @param obj 需要处理的对象。
     * @return 对象处理成T的对象。
     * @throws IllegalArgumentException 如果为None时抛IllegalArgumentException异常。
     */
    public static func requireNonNull<T>(obj: ?T): T {
        requireNonNull(obj, None)
    }

    /**
     * 将Option<T>对象处理成T。
     *
     * @param obj 需要处理的对象。
     * @param message 为None时抛异常的信息。
     * @return 对象处理成T的对象。
     * @throws IllegalArgumentException 如果为None时抛IllegalArgumentException异常。
     */
    public static func requireNonNull<T>(obj: ?T, message: ?String): T {
        obj ?? throw IllegalArgumentException(message ?? "Can not provide None argument")
    }
}

/*
 * 判断是否为true。不为true抛异常。
 *
 * @param exp 判断true false的值。
 * @throws Exception 不为true的时候抛异常。
 */
public func assert(exp: Bool): Unit {
    if (!exp) {
        throw Exception("assert failed")
    }
}

/*
 * 继承Exception的异常类。
 */
public class AssertionError <: Exception {
    /**  
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "AssertionError"
    }
}
