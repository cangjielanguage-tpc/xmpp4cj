/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

/**
 * A XML splitter capable of splitting XML into top-level elements.
 * <p>
 * Note that this class does not yet support the feature set of XML. Only the
 * required features for XMPP are supported. XML comments and processing
 * instructions are not supported.
 * </p>
 * StringWriter & Resource
 */
public open class XmlSplitter <: Resource {
    private let declarationCallback: ?DeclarationCallback

    private let processingInstructionCallback: ?ProcessingInstructionCallback

    private let xmlPrinter: ?XmlPrinter

    protected let completeElementCallback: ?CompleteElementCallback

    private let splittedPartBuffer: StringBuilder

    private let tokenBuffer = StringBuilder()

    private let attributes: Map<String, String> = HashMap<String, String>()

    private var depth: Int64 = 0

    private var qName: String = ""

    private var attributeName: String = ""

    private var state: XmlSplitterState = XmlSplitterState.START

    private var attributeValueQuotes: XmlSplitter_AttributeValueQuotes = XmlSplitter_AttributeValueQuotes.non

    public init(bufferSize: Int64, completeElementCallback: ?CompleteElementCallback,
        declarationCallback: ?DeclarationCallback, processingInstructionCallback: ?ProcessingInstructionCallback) {
        this(bufferSize, completeElementCallback, declarationCallback, processingInstructionCallback, None)
    }

    public init(bufferSize: Int64, completeElementCallback: ?CompleteElementCallback, xmlPrinter: ?XmlPrinter) {
        this(bufferSize, completeElementCallback, None, None, xmlPrinter)
    }

    public init(bufferSize: Int64, completeElementCallback: ?CompleteElementCallback) {
        this(bufferSize, completeElementCallback, None, None)
    }

    public init(bufferSize: Int64, completeElementCallback: ?CompleteElementCallback,
        declarationCallback: ?DeclarationCallback, processingInstructionCallback: ?ProcessingInstructionCallback,
        xmlPrinter: ?XmlPrinter) {
        var tempbufferSize = bufferSize
        if (tempbufferSize < 0) {
            tempbufferSize = 128
        }
        this.splittedPartBuffer = StringBuilder()
        this.completeElementCallback = completeElementCallback
        this.declarationCallback = declarationCallback
        this.processingInstructionCallback = processingInstructionCallback
        this.xmlPrinter = xmlPrinter
    }

    public func write(cbuf: Array<Rune>): Unit {
        xmlPrinter?.onChunkStart()
        for (c in cbuf) {
            processChar(c)
        }
        xmlPrinter?.onChunkEnd()
    }

    public func getCurrentSplittedPartSize(): Int64 {
        return splittedPartBuffer.size
    }

    protected open func onNextChar(): Unit {}

    protected open func onStartTag(_: String, _: String, _: Map<String, String>): Unit {}

    protected open func onEndTag(_: String): Unit {}

    protected func newSplittedPart(): Unit {
        depth = 0
        splittedPartBuffer.reset()
        if (state == XmlSplitterState.START) {
            throw Exception("Invalid state: ${state}")
        }
        state = XmlSplitterState.START
    }

    private func processChar(c: Rune): Unit {
        onNextChar()
        splittedPartBuffer.append(c)
        var endTagFinished = false
        let initialState = state
        match (state) {
            case XmlSplitterState.TAG_RIGHT_ANGLE_BRACKET =>
                state = XmlSplitterState.START
                match (c) {
                    case r'<' => state = XmlSplitterState.TAG_LEFT_ANGLE_BRACKET
                    case _ => ()
                }
            case XmlSplitterState.START => match (c) {
                case r'<' => state = XmlSplitterState.TAG_LEFT_ANGLE_BRACKET
                case _ => ()
            }
            case XmlSplitterState.TAG_LEFT_ANGLE_BRACKET => match (c) {
                case r'/' => state = XmlSplitterState.END_TAG_SOLIDUS
                case r'?' => state = XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION
                case r'!' => state = XmlSplitterState.AFTER_COMMENT_BANG
                case _ =>
                    tokenBuffer.append(c)
                    state = XmlSplitterState.IN_TAG_NAME
            }
            case XmlSplitterState.END_TAG_SOLIDUS =>
                state = XmlSplitterState.IN_END_TAG
                tokenBuffer.append(c)
            case XmlSplitterState.IN_TAG_NAME => match (c) {
                case r' ' | r'\n' | r'\r' | r'\t' =>
                    qName = getToken()
                    state = XmlSplitterState.AFTER_START_NAME
                case r'/' =>
                    qName = getToken()
                    onStartTagFinished()
                    state = XmlSplitterState.IN_EMPTY_TAG
                case r'>' =>
                    qName = getToken()
                    onStartTagFinished()
                    state = XmlSplitterState.TAG_RIGHT_ANGLE_BRACKET
                case _ => tokenBuffer.append(c)
            }
            case XmlSplitterState.IN_END_TAG => match (c) {
                case r'>' =>
                    endTagFinished = true
                    state = XmlSplitterState.TAG_RIGHT_ANGLE_BRACKET
                case _ => tokenBuffer.append(c)
            }
            case XmlSplitterState.AFTER_START_NAME => match (c) {
                case r'/' =>
                    onStartTagFinished()
                    state = XmlSplitterState.IN_EMPTY_TAG
                case r'>' =>
                    onStartTagFinished()
                    state = XmlSplitterState.TAG_RIGHT_ANGLE_BRACKET
                case r' ' | r'\n' | r'\r' | r'\t' => ()
                case _ =>
                    tokenBuffer.append(c)
                    state = XmlSplitterState.IN_ATTRIBUTE_NAME
            }
            case XmlSplitterState.IN_ATTRIBUTE_NAME => match (c) {
                case r'=' =>
                    attributeName = getToken()
                    state = XmlSplitterState.AFTER_ATTRIBUTE_EQUALS
                case _ => tokenBuffer.append(c)
            }
            case XmlSplitterState.AFTER_ATTRIBUTE_EQUALS => match (c) {
                case r'\'' =>
                    attributeValueQuotes = XmlSplitter_AttributeValueQuotes.apos
                    state = XmlSplitterState.IN_ATTRIBUTE_VALUE
                case r'"' =>
                    attributeValueQuotes = XmlSplitter_AttributeValueQuotes.quot
                    state = XmlSplitterState.IN_ATTRIBUTE_VALUE
                case _ => throw InvalidAttributeDeclarationException.create(c, splittedPartBuffer.toString())
            }
            case XmlSplitterState.IN_ATTRIBUTE_VALUE => if (c == attributeValueQuotes.c) {
                attributes.put(attributeName, getToken())
                state = XmlSplitterState.AFTER_START_NAME
            } else {
                tokenBuffer.append(c)
            }
            case XmlSplitterState.IN_EMPTY_TAG => match (c) {
                case r'>' =>
                    endTagFinished = true
                    state = XmlSplitterState.TAG_RIGHT_ANGLE_BRACKET
                case _ => throw InvalidEmptyTagException.create(c, splittedPartBuffer.toString())
            }
            case XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION => match (c) {
                case r'\'' =>
                    attributeValueQuotes = XmlSplitter_AttributeValueQuotes.apos
                    state = XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE
                case r'"' =>
                    attributeValueQuotes = XmlSplitter_AttributeValueQuotes.quot
                    state = XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE
                case r'?' => state = XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION_QUESTION_MARK
                case _ => ()
            }
            case XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE => if (c ==
                attributeValueQuotes.c) {
                state = XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION
            }
            case XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION_QUESTION_MARK => if (c == r'>') {
                let processingInstructionOrDeclaration: String = splittedPartBuffer.toString()
                onProcessingInstructionOrDeclaration(processingInstructionOrDeclaration)
                newSplittedPart()
            } else {
                state = XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION
            }
            case AFTER_COMMENT_BANG | AFTER_COMMENT_DASH1 | AFTER_COMMENT_DASH2 | AFTER_COMMENT | AFTER_COMMENT_CLOSING_DASH1 | AFTER_COMMENT_CLOSING_DASH2 => throw Exception(
                "XML comments are not supported by XmlSplitter (yet). They are also not allowed in XMPP streams (cf. RFC 6120 \u{00a7} 11.1)."
            )
        }
        xmlPrinter?.onNextChar(c, depth, initialState, state)
        if (endTagFinished) {
            onEndTagFinished()
        }
    }

    private func onStartTagFinished(): Unit {
        depth++
        let prefix = extractPrefix(qName)
        let localpart = extractLocalpart(qName)
        onStartTag(prefix, localpart, attributes)
        attributes.clear()
    }

    private func onEndTagFinished(): Unit {
        var endTagName = getToken()
        if (Int64(endTagName.size) == 0) {
            endTagName = qName
        }
        depth--
        if (depth == 0) {
            let completeElement: String = splittedPartBuffer.toString()
            splittedPartBuffer.reset()
            completeElementCallback?.onCompleteElement(completeElement)
            xmlPrinter?.onCompleteElement()
        }
        onEndTag(endTagName)
        if (state == XmlSplitterState.START) {
            throw Exception("Invalid state: ${state}")
        }
        state = XmlSplitterState.START
    }

    private func getToken(): String {
        let token: String = tokenBuffer.toString()
        tokenBuffer.reset()
        return token
    }

    private func onProcessingInstructionOrDeclaration(processingInstructionOrDeclaration: String): Unit {
        if (processingInstructionOrDeclaration.startsWith("<xml ")) {
            declarationCallback?.onDeclaration(processingInstructionOrDeclaration)
        } else {
            processingInstructionCallback?.onProcessingInstruction(processingInstructionOrDeclaration)
        }
    }

    private static func extractPrefix(qName: String): String {
        let index = qName.indexOf(":")
        return if (let Some(i) <- index) {
            qName[..i]
        } else {
            qName
        }
    }

    private static func extractLocalpart(qName: String): String {
        let index = qName.indexOf(":")
        return if (let Some(i) <- index) {
            qName[(i + 1)..]
        } else {
            qName
        }
    }

    public open override func isClosed(): Bool {
        false
    }
    public open override func close(): Unit {}
}

public enum XmlSplitterState <: Equatable<XmlSplitterState> & ToString {
    | START
    | TAG_LEFT_ANGLE_BRACKET
    | TAG_RIGHT_ANGLE_BRACKET
    | END_TAG_SOLIDUS
    | IN_TAG_NAME
    | IN_END_TAG
    | AFTER_START_NAME
    | IN_EMPTY_TAG
    | IN_ATTRIBUTE_NAME
    | AFTER_ATTRIBUTE_EQUALS
    | IN_ATTRIBUTE_VALUE
    | AFTER_COMMENT_BANG
    | AFTER_COMMENT_DASH1
    | AFTER_COMMENT_DASH2
    | AFTER_COMMENT
    | AFTER_COMMENT_CLOSING_DASH1
    | AFTER_COMMENT_CLOSING_DASH2
    | IN_PROCESSING_INSTRUCTION_OR_DECLARATION
    | IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE
    | IN_PROCESSING_INSTRUCTION_OR_DECLARATION_QUESTION_MARK

    public operator func ==(that: XmlSplitterState) {
        this.toString() == that.toString()
    }
    public operator func !=(that: XmlSplitterState) {
        return !(this == that)
    }
    public override func toString(): String {
        match (this) {
            case START => "START"
            case TAG_LEFT_ANGLE_BRACKET => "TAG_LEFT_ANGLE_BRACKET"
            case TAG_RIGHT_ANGLE_BRACKET => "TAG_RIGHT_ANGLE_BRACKET"
            case END_TAG_SOLIDUS => "END_TAG_SOLIDUS"
            case IN_TAG_NAME => "IN_TAG_NAME"
            case IN_END_TAG => "IN_END_TAG"
            case AFTER_START_NAME => "AFTER_START_NAME"
            case IN_EMPTY_TAG => "IN_EMPTY_TAG"
            case IN_ATTRIBUTE_NAME => "IN_ATTRIBUTE_NAME"
            case AFTER_ATTRIBUTE_EQUALS => "AFTER_ATTRIBUTE_EQUALS"
            case IN_ATTRIBUTE_VALUE => "IN_ATTRIBUTE_VALUE"
            case AFTER_COMMENT_BANG => "AFTER_COMMENT_BANG"
            case AFTER_COMMENT_DASH1 => "AFTER_COMMENT_DASH1"
            case AFTER_COMMENT_DASH2 => "AFTER_COMMENT_DASH2"
            case AFTER_COMMENT => "AFTER_COMMENT"
            case AFTER_COMMENT_CLOSING_DASH1 => "AFTER_COMMENT_CLOSING_DASH1"
            case AFTER_COMMENT_CLOSING_DASH2 => "AFTER_COMMENT_CLOSING_DASH2"
            case IN_PROCESSING_INSTRUCTION_OR_DECLARATION => "IN_PROCESSING_INSTRUCTION_OR_DECLARATION"
            case IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE => "IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE"
            case IN_PROCESSING_INSTRUCTION_OR_DECLARATION_QUESTION_MARK => "IN_PROCESSING_INSTRUCTION_OR_DECLARATION_QUESTION_MARK"
        }
    }
}

enum XmlSplitter_AttributeValueQuotes {
    | apos
    | quot
    | non

    prop c: Rune {
        get() {
            match (this) {
                case apos => r'\''
                case quot => r'"'
                case non => r'\0'
            }
        }
    }
}

/**
 * A XML splitter for XMPP. Unlike {@link XmlSplitter}, this splitter is aware
 * of the special semantics of XMPP's {@code <stream:stream>} element.
 */
public class XmppXmlSplitter <: XmlSplitter {
    private let xmppElementCallback: ?XmppElementCallback

    private let maxElementSize: Int64

    private var streamPrefix: String = ""

    public init(xmppElementCallback: ?XmppElementCallback) {
        this(10000, xmppElementCallback)
    }

    public init(xmppElementCallback: ?XmppElementCallback, declarationCallback: ?DeclarationCallback,
        processingInstructionCallback: ?ProcessingInstructionCallback) {
        this(10000, xmppElementCallback, declarationCallback, processingInstructionCallback)
    }

    public init(maxElementSize: Int64, xmppElementCallback: ?XmppElementCallback) {
        this(maxElementSize, xmppElementCallback, None, None)
    }

    public init(maxElementSize: Int64, xmppElementCallback: ?XmppElementCallback,
        declarationCallback: ?DeclarationCallback, processingInstructionCallback: ?ProcessingInstructionCallback) {
        this(maxElementSize, xmppElementCallback, declarationCallback, processingInstructionCallback, None)
    }

    public init(xmlPrinter: ?XmlPrinter) {
        this(-1, None, xmlPrinter)
    }

    public init(maxElementSize: Int64, xmppElementCallback: ?XmppElementCallback, xmlPrinter: ?XmlPrinter) {
        this(maxElementSize, xmppElementCallback, None, None, xmlPrinter)
    }

    public init(
        maxElementSize: Int64,
        xmppElementCallback: ?XmppElementCallback,
        declarationCallback: ?DeclarationCallback,
        processingInstructionCallback: ?ProcessingInstructionCallback,
        xmlPrinter: ?XmlPrinter
    ) {
        super(
            maxElementSize,
            if (let Some(v: CompleteElementCallback) <- xmppElementCallback) {
                v
            } else {
                None
            },
            declarationCallback,
            processingInstructionCallback,
            xmlPrinter
        )
        this.maxElementSize = maxElementSize
        this.xmppElementCallback = xmppElementCallback
    }

    protected override func onNextChar(): Unit {
        if (maxElementSize > 0 && getCurrentSplittedPartSize() >= maxElementSize) {
            throw IOException("Max element size exceeded")
        }
    }

    protected override func onStartTag(prefix: String, localpart: String, attributes: Map<String, String>): Unit {
        if ("stream" != localpart) {
            return
        }
        if (attributes.get("xmlns:${prefix}") == ETHERX_JABBER_STREAMS_NAMESPACE) {
            streamPrefix = prefix
            newSplittedPart()
            xmppElementCallback?.streamOpened(prefix, HashMap(attributes))
        }
    }

    protected override func onEndTag(qName: String): Unit {
        if (streamPrefix.isEmpty() || !qName.startsWith(streamPrefix)) {
            return
        }
        if ("${streamPrefix}:stream" == qName && xmppElementCallback.isSome()) {
            xmppElementCallback?.streamClosed()
        }
    }
}

/**
 * Extended version of {@link XmppXmlSplitter} allowing input to be bytes or
 * {@link ByteArrayStream} representing a UTF-8 encoded XML string for XMPP. Just as
 * they come from a network socket.
 * <p>
 * This class respects the byte order mark (BOM )requirement of RFC 6120 11.6
 * and treats the BOM as zero width no-break space, and not as byte order mark.
 * </p>
 */
public class Utf8ByteXmppXmlSplitter <: OutputStream {
    private let xmppXmlSplitter: XmppXmlSplitter

    public init(xmppElementCallback: XmppElementCallback) {
        this(XmppXmlSplitter(xmppElementCallback))
    }

    public init(xmppXmlSplitter: XmppXmlSplitter) {
        this.xmppXmlSplitter = xmppXmlSplitter
    }

    private let buffer = ByteArrayStream()
    private let reader: StringReader<ByteArrayStream> = StringReader<ByteArrayStream>(buffer)

    /**
     * Write a single byte. The byte must be part of a UTF-8 String.
     *
     * @param b the byte to write.
     * @throws IOException if an error occurs.
     */
    public override func write(bytes: Array<Byte>): Unit {
        buffer.write(bytes)
        flush()
    }

    /**
     * Write the given collection of byte buffers.
     *
     * @param byteBuffers the collection of byte buffers.
     * @throws IOException if an error occurs.
     */
    public func write(byteBuffers: Array<ByteArrayStream>): Unit {
        for (byteBuffer in byteBuffers) {
            byteBuffer.copyTo(buffer)
        }
        flush()
    }

    private let tmp: Array<Rune> = [r'\0']
    public override func flush(): Unit {
        for (r in reader.runes()) {
            tmp[0] = r
            xmppXmlSplitter.write(tmp)
        }
    }
}
