/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Provides pluggable parsing of incoming IQ's and extensions elements.
 */
package cangjie_tpc::xmpp4cj.provider

internal import stdx.log.*
internal import std.collection.*
internal import std.collection.concurrent.ConcurrentHashMap
internal import std.convert.*
internal import std.io.*
internal import std.unicode.*
internal import cangjie_tpc::xmpp4cj.jid.*
internal import cangjie_tpc::xmpp4cj.packet.*
internal import cangjie_tpc::xmpp4cj.util.*
internal import cangjie_tpc::xmpp4cj.xml.*

extend<K, V> ConcurrentHashMap<K, V> where K <: Hashable & Equatable<K> {
    /**
     * 返回一个迭代器，用于遍历 ConcurrentHashMap 中的所有值。
     *
     * @return 值的迭代器
     */
    func values(): Iterator<V> {
        this |> map<(K, V), V> {kv => kv[1]}
    }
}

func castOrThrow<T, R>(t: T): R {
    match (t) {
        case v: R => v
        case v: Option<R> => v.getOrThrow()
        case _ => throw Exception("Type cast fail.")
    }
}
