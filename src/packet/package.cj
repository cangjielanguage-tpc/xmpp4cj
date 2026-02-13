/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * XML stanzas and extension elements that are part of the XMPP protocol.
 */
package cangjie_tpc::xmpp4cj.packet

internal import stdx.crypto.crypto.*
internal import stdx.encoding.hex.*
internal import stdx.encoding.url.*
internal import stdx.log.*
internal import stdx.logger.*
internal import std.collection.*
internal import std.convert.*
internal import std.io.*
internal import std.net.*
internal import std.random.*
internal import std.sync.*
internal import std.time.*
internal import cangjie_tpc::xmpp4cj.jid.*
internal import cangjie_tpc::xmpp4cj.util.*
internal import cangjie_tpc::xmpp4cj.xml.*

func castOrThrow<T, R>(t: T): R {
    match (t) {
        case v: R => v
        case v: Option<R> => v.getOrThrow()
        case _ => throw Exception("Type cast fail.")
    }
}

let EMPTY_EXTENSION_ELEMENT_COLLECTION: Collection<ExtensionElement> = []
let EMPTY_STANDARD_EXTENSION_ELEMENT_COLLECTION: Collection<StandardExtensionElement> = []
