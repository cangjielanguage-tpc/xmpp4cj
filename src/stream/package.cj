/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Xmpp's implementation of XEP-0198: Stream Management.
 * Plain stream elements for XEP-0198: Stream Management.
 * Predicates for requesting Stream Management acknowledgements.
 * Providers for XEP-0198: Stream Management.
 */
package xmpp4cj.stream

internal import std.collection.*
internal import std.collection.concurrent.*
internal import std.sync.*
internal import xmpp4cj.compression.*
internal import xmpp4cj.feature.*
internal import xmpp4cj.filter.*
internal import xmpp4cj.modular.*
internal import xmpp4cj.packet.*
internal import xmpp4cj.provider.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.util.*

type ClassTypeInfo = ClassId
