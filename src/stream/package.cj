/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Xmpp's implementation of XEP-0198: Stream Management.
 * Plain stream elements for XEP-0198: Stream Management.
 * Predicates for requesting Stream Management acknowledgements.
 * Providers for XEP-0198: Stream Management.
 */
package cangjie_tpc::xmpp4cj.stream

internal import std.collection.*
internal import std.collection.concurrent.*
internal import std.sync.*
internal import cangjie_tpc::xmpp4cj.compression.*
internal import cangjie_tpc::xmpp4cj.feature.*
internal import cangjie_tpc::xmpp4cj.filter.*
internal import cangjie_tpc::xmpp4cj.modular.*
internal import cangjie_tpc::xmpp4cj.packet.*
internal import cangjie_tpc::xmpp4cj.provider.*
internal import cangjie_tpc::xmpp4cj.xml.*
internal import cangjie_tpc::xmpp4cj.util.*

type ClassTypeInfo = ClassId
