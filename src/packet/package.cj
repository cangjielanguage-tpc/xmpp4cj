/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
/**
 * XML stanzas and extension elements that are part of the XMPP protocol.
 */
package xmpp4cj.packet

internal import crypto.crypto.*
internal import encoding.hex.*
internal import encoding.url.*
internal import log.*
internal import logger.*
internal import std.collection.*
internal import std.convert.*
internal import std.io.*
internal import std.net.*
internal import std.random.*
internal import std.sync.*
internal import std.time.*
internal import xmpp4cj.jid.*
internal import xmpp4cj.util.*
internal import xmpp4cj.xml.*

func castOrThrow<T, R>(t: T): R {
    match (t) {
        case v: R => v
        case v: Option<R> => v.getOrThrow()
        case _ => throw Exception("Type cast fail.")
    }
}

let EMPTY_EXTENSION_ELEMENT_COLLECTION: Collection<ExtensionElement> = []
let EMPTY_STANDARD_EXTENSION_ELEMENT_COLLECTION: Collection<StandardExtensionElement> = []
