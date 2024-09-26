/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
/**
 * Classes and interfaces for XMPP stream compression (XEP-138).
 * Stanzas and extension elements for XMPP stream compression (XEP-138).
 * Providers for XMPP stream compression (XEP-138).
 */
package xmpp4cj.compress

internal import log.*
internal import std.collection.ArrayList
internal import xmpp4cj.packet.*
internal import xmpp4cj.provider.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.util.*

/**
 * Parse the Compression Feature reported from the server.
 *
 * @param parser the XML parser, positioned at the start of the compression stanza.
 * @return The CompressionFeature stream element
 * @throws IOException if an I/O error occurred.
 * @throws XmlPullParserException if an exception occurs while parsing the stanza.
 */
public func parseCompressionFeature(parser: XmlPullParser): CompressFeature {
    if (parser.getEventType() != XmlPullParserEvent.START_ELEMENT) {
        throw Exception("AssertionError")
    }
    var name: String
    let initialDepth = parser.getDepth()
    let methods = ArrayList<String>()

    while (true) {
        let eventType = parser.next()
        match (eventType) {
            case XmlPullParserEvent.START_ELEMENT =>
                name = parser.getName()
                if (name == "method") {
                    methods.append(parser.nextText())
                }
            case XmlPullParserEvent.END_ELEMENT =>
                name = parser.getName()
                if (name == CompressFeature.ELEMENT) {
                    if (parser.getDepth() == initialDepth) {
                        break
                    }
                }
            case _ => ()
        }
    }
    if (parser.getEventType() != XmlPullParserEvent.END_ELEMENT) {
        throw Exception("AssertionError")
    }
    if (parser.getDepth() != initialDepth) {
        throw Exception("AssertionError")
    }
    return CompressFeature(methods)
}
