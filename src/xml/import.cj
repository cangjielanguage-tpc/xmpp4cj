/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xml

internal import std.collection.{ArrayList, HashMap}
internal import std.io.{InputStream, OutputStream}
internal import encoding.xml.*

// BA: ByteArray
// S: Space
// PRE: Prefix
// SUF: Suffix
let BA_XML_S = "xml ".toArray()
let BA_DOCTYPE = "DOCTYPE".toArray()
let BA_CDATA_PRE = "[CDATA[".toArray()
let BA_CDATA_SUF = "]]>".toArray()
let BA_DASH_DASH = "--".toArray()
let BA_EMPTY_TAG_END = "/>".toArray()
let BA_XMLNS = "xmlns".toArray()
