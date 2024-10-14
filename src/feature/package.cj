/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
/**
 * 一些数据结构层之上的工具类, 在feature归档.
 * 没有循环依赖的XEP模块应尽量单独成包
 * 依赖关系: packet <- feature <- 其他功能模块
 */
package xmpp4cj.feature

internal import log.*
internal import net.http.*
internal import net.tls.*
internal import std.collection.*
internal import std.io.*
internal import std.net.*
internal import std.sync.*
internal import std.time.*
internal import xmpp4cj.jid.*
internal import xmpp4cj.packet.*
internal import xmpp4cj.util.*
internal import xmpp4cj.xml.*
