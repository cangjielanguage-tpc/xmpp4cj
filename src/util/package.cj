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

public interface ArrayListExt<T> {
    /*
     * 删除第一个匹配的值
     * 使用 @link{EqualsUtil#equals} 尽力匹配
     */
    func remove(v: T): Bool
}

extend<T> ArrayList<T> <: ArrayListExt<T> {
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

public class Objects {
    public static func requireNonNull<T>(obj: ?T): T {
        requireNonNull(obj, None)
    }
    public static func requireNonNull<T>(obj: ?T, message: ?String): T {
        obj ?? throw IllegalArgumentException(message ?? "Can not provide None argument")
    }
}
