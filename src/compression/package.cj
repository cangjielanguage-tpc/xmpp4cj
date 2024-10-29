/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * Xmpp classes for compression.
 * Xmpp classes for compression (XEP-0138) using zlib (RFC 1950).
 */
package xmpp4cj.compression

internal import compress.zlib.*
internal import std.collection.*
internal import std.io.*
internal import std.sort.*
internal import std.sync.*
internal import xmpp4cj.compress.*
internal import xmpp4cj.feature.*
internal import xmpp4cj.filter.*
// internal import xmpp4cj.modular.*
