/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

class TcpmodXmppElementCallback <: XmppElementCallback & ToString {
    var tcpmod: XmppTcpTransportModule = unsafe { zeroValue<XmppTcpTransportModule>() } // 占位
    private let hash = RandomUtil.nextSecureRandomInt()
    public override func toString(): String {
        "XmppTcpTransportModule_XmppElementCallback@${hash}"
    }

    init() {}
    init(tcpmod: XmppTcpTransportModule) {
        this.tcpmod = tcpmod
    }

    private var streamOpen: String = '\0'
    private var streamClose: String = '\0'

    public override func onCompleteElement(completeElement: String): Unit {
        assert(streamOpen != '\0')
        assert(streamClose != '\0')

        tcpmod.connectionInternal.withXmppDebugger({debugger => debugger.onIncomingElementCompleted()})
        let wrappedCompleteElement: String = streamOpen + completeElement + streamClose
        tcpmod.connectionInternal.parseAndProcessElement(wrappedCompleteElement)
    }

    public override func streamOpened(prefix: String, attributes: Map<String, String>): Unit {
        if (XmppTcpTransportModule.LOGGER.isLoggable(XmppTcpTransportModule.STREAM_OPEN_CLOSE_DEBUG_LOG_LEVEL)) {
            XmppTcpTransportModule
                .LOGGER
                .log(
                    XmppTcpTransportModule.STREAM_OPEN_CLOSE_DEBUG_LOG_LEVEL,
                    "Stream of ${this} opened. prefix=${prefix} attributes=${attributes|>map{kv=>"${kv[0]}=${kv[1]}"}|>collectString<String>(delimiter: " ")}"
                )
        }

        let prefixXmlns: String = "xmlns:" + prefix
        let streamClose = StringBuilder(32)
        let streamOpen = StringBuilder(64)

        streamOpen.append(r'<')
        streamClose.append("</")
        if (StringUtils.isNotEmpty(prefix)) {
            streamOpen.append(prefix)
            streamOpen.append(r':')
            streamClose.append(prefix)
            streamClose.append(r':')
        }
        streamOpen.append("stream")
        streamClose.append("stream>")
        for ((attributeName, attributeValue) in attributes) {
            match (attributeName) {
                case "to" | "from" | "id" | "version" => ()
                case "xml:lang" =>
                    streamOpen.append(" xml:lang='")
                    streamOpen.append(attributeValue)
                    streamOpen.append(r'\'')
                case "xmlns" =>
                    streamOpen.append(" xmlns='")
                    streamOpen.append(attributeValue)
                    streamOpen.append(r'\'')
                case _ =>
                    if (attributeName == prefixXmlns) {
                        streamOpen.append(r' ')
                        streamOpen.append(prefixXmlns)
                        streamOpen.append("='")
                        streamOpen.append(attributeValue)
                        streamOpen.append(r'\'')
                    } else {
                        XmppTcpTransportModule.LOGGER.info("Unknown <stream/> attribute: ${attributeName}")
                    }
            }
        }
        streamOpen.append(r'>')

        this.streamOpen = streamOpen.toString()
        this.streamClose = streamClose.toString()

        let streamOpenParser: XmlPullParser
        try {
            streamOpenParser = PacketParserUtils.getParserFor(this.streamOpen)
        } catch (e: Exception) {
            DEBUGER.log(LogLevel.TRACE, "TcpmodXmppElementCallback#streamOpened", e)
            throw AssertionError(e)
        }
        tcpmod.connectionInternal.onStreamOpen(streamOpenParser)
    }

    public override func streamClosed(): Unit {
        if (XmppTcpTransportModule.LOGGER.isLoggable(XmppTcpTransportModule.STREAM_OPEN_CLOSE_DEBUG_LOG_LEVEL)) {
            XmppTcpTransportModule
                .LOGGER
                .log(XmppTcpTransportModule.STREAM_OPEN_CLOSE_DEBUG_LOG_LEVEL, "Stream of ${this} closed")
        }
        tcpmod.connectionInternal.onStreamClosed()
    }
}
