/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Allows {@link xmpp4cj.StanzaCollector} and {@link xmpp4cj.StanzaListener} instances to filter for stanzas with particular attributes.
 * Filter based on the type of an XMPP address.
 */
package xmpp4cj.filter

internal import std.collection.*
internal import std.io.*
internal import stdx.log.{getGlobalLogger, Logger}
internal import xmpp4cj.packet.*
internal import xmpp4cj.util.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.jid.*
