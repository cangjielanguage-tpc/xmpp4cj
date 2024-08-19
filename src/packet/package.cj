/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

internal import crypto.crypto.*
internal import encoding.hex.*
internal import log.*
internal import std.collection.*
internal import std.collection.concurrent.{ConcurrentHashMap}
internal import std.convert.*
internal import std.io.*
internal import std.math.*
internal import std.math.numeric.*
internal import std.random.*
internal import std.regex.*
internal import std.sync.*
internal import std.time.*
internal import xmpp4cj.xmpp.*

extend<T> ArrayList<T> {
    func remove(v: T): Bool {
        for (i in 0..this.size) {
            if (EqualsUtil.equals(this[i], v)) {
                this.remove(i)
                return true
            }
        }
        return false
    }
}

extend<K, V> ConcurrentHashMap<K, V> where K <: Hashable & Equatable<K> {
    func values(): Iterator<V> {
        this |> map<(K, V), V> {kv => kv[1]}
    }
}

public class Objects {
    public static func requireNonNull<T>(obj: ?T, message: ?String): T {
        obj ?? throw IllegalArgumentException(message ?? "Can not provide None argument")
    }
}

func assert(exp: Bool): Unit {
    if (!exp) {
        throw Exception("assert failed")
    }
}
