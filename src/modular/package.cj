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
package cangjie_tpc::xmpp4cj.modular

internal import stdx.log.*
internal import stdx.net.tls.common.*
internal import std.collection.*
internal import std.convert.*
internal import std.sync.*
internal import std.time.{DateTime}
internal import cangjie_tpc::xmpp4cj.connection.*
internal import cangjie_tpc::xmpp4cj.feature.*
internal import cangjie_tpc::xmpp4cj.filter.*
internal import cangjie_tpc::xmpp4cj.jid.*
internal import cangjie_tpc::xmpp4cj.packet.*
internal import cangjie_tpc::xmpp4cj.provider.*
internal import cangjie_tpc::xmpp4cj.util.*
internal import cangjie_tpc::xmpp4cj.xml.*
internal import cangjie_tpc::xmpp4cj.compress.*
