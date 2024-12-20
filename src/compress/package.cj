/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
/**
 * XMPP流压缩的类和接口（XEP-138）。
 * XMPP流压缩用三角架和扩展元件（XEP-138）。
 * XMPP流压缩提供程序（XEP-138）。
 */
package xmpp4cj.compress

internal import log.*
internal import std.collection.ArrayList
internal import xmpp4cj.packet.*
internal import xmpp4cj.provider.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.util.*

/**
 * 解析服务器报告的压缩功能。
 *
 * @param parser XML解析器，位于压缩节的开头。
 * @return CompressionFeature流元素
 * @throws IOException 如果发生I/O错误，会抛出IOException。
 * @throws XmlPullParserException 如果在解析节时发生异常，会抛出XmlPullParserException。
 */
public func parseCompressionFeature(parser: XmlPullParser): CompressFeature {
    assert(parser.getEventType() == XmlPullParserEvent.START_ELEMENT)
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
    assert(parser.getEventType() == XmlPullParserEvent.END_ELEMENT)
    assert(parser.getDepth() == initialDepth)
    return CompressFeature(methods)
}
