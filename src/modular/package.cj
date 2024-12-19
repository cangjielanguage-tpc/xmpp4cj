/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Xmpp模块化设计 使用有限状态机描述模块的依赖关系
 * 合并了c2s/fsm
 * Xmpp's (new) API for client-to-server (c2s) connections.
 * Xmpp's internal API for client-to-server (c2s) connections.
 * Xmpp's Finite State Machine to handle the login logic.
 */
package xmpp4cj.modular

internal import log.*
internal import net.tls.{TlsSession}
internal import std.collection.*
internal import std.format.{Formatter}
internal import std.sync.*
internal import std.time.{DateTime}
internal import xmpp4cj.connection.*
internal import xmpp4cj.feature.*
internal import xmpp4cj.filter.*
internal import xmpp4cj.jid.*
internal import xmpp4cj.packet.*
internal import xmpp4cj.provider.*
internal import xmpp4cj.util.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.compress.*
