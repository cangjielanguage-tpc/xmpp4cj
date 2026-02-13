/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Allows {@link xmpp4cj.StanzaCollector} and {@link xmpp4cj.StanzaListener} instances to filter for stanzas with particular attributes.
 * Filter based on the type of an XMPP address.
 */
package cangjie_tpc::xmpp4cj.filter

internal import std.collection.*
internal import std.io.*
internal import stdx.log.{getGlobalLogger, Logger}
internal import cangjie_tpc::xmpp4cj.packet.*
internal import cangjie_tpc::xmpp4cj.util.*
internal import cangjie_tpc::xmpp4cj.xml.*
internal import cangjie_tpc::xmpp4cj.jid.*
