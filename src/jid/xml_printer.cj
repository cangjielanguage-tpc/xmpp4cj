/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

public abstract class XmlPrinter {
    public func onChunkStart(): Unit

    public func onChunkEnd(): Unit

    public func onNextChar(c: Rune, depth: Int64, initialState: XmlSplitterState, currentState: XmlSplitterState): Unit

    public func onCompleteElement(): Unit
}

public class XmlPrettyPrinter <: XmlPrinter {
    private let indent: Int64

    private let attributeIndent: Int64

    private let tabWidth: Int64

    private let newChunkCallback: ?PrettyPrintedXmlChunkWithCurrentPartCallback

    private let newPartCallback: ?PrettyPrintedXmlPartCallback

    private let prettyWriter: ?PrettyPrintedXmlChunkSink

    private var currentPart: ?StringBuilder = None

    private var currentChunk: ?StringBuilder = None

    private var currentChunkWithCurrentPart: ?StringBuilder = None

    /**
     * Construct a new XML pretty printer.
     *
     * @param partCallback a part callback.
     */
    public init(partCallback: PrettyPrintedXmlPartCallback) {
        this(builder().setPartCallback(partCallback))
    }

    /**
     * Construct a new XML pretty printer.
     *
     * @param prettyWriter a writer for the pretty printed XML stream.
     */
    public init(prettyWriter: PrettyPrintedXmlChunkSink) {
        this(builder().setPrettyWriter(prettyWriter))
    }

    init(builder: XmlPrettyPrinterBuilder) {
        super()
        this.indent = builder.indent
        this.attributeIndent = builder.attributeIndent
        this.tabWidth = builder.tabWidth
        this.newChunkCallback = builder.newChunkCallback
        this.newPartCallback = builder.newPartCallback
        this.prettyWriter = builder.prettyWriter
    }

    public func onChunkStart(): Unit {
        if (newChunkCallback.isSome()) {
            currentChunkWithCurrentPart = StringBuilder()
            currentChunkWithCurrentPart?.append(currentPart)
            currentChunkWithCurrentPart?.append('[')
        }
        if (prettyWriter.isSome()) {
            currentChunk = StringBuilder(1024)
        }
    }

    public func onChunkEnd(): Unit {
        if (newChunkCallback.isSome()) {
            currentChunkWithCurrentPart?.append(']')
            newChunkCallback?.onPrettyPrintedXmlChunk(currentChunkWithCurrentPart())
            currentChunkWithCurrentPart = None
        }
        if (prettyWriter.isSome()) {
            prettyWriter?.sink(currentChunk())
            currentChunk = None
        }
    }

    public func onNextChar(c: Rune, depth: Int64, initialState: XmlSplitterState, currentState: XmlSplitterState): Unit {
        let stateChange = initialState != currentState
        let sb = StringBuilder()
        if (stateChange) {
            var deferredLeftAngle = false
            var indent = 0
            match (currentState) {
                case XmlSplitterState.TAG_LEFT_ANGLE_BRACKET => return
                case XmlSplitterState.END_TAG_SOLIDUS =>
                    indent = getElementIndent(depth - 1)
                    deferredLeftAngle = true
                case XmlSplitterState.IN_TAG_NAME =>
                    indent = getElementIndent(depth)
                    deferredLeftAngle = true
                case XmlSplitterState.IN_ATTRIBUTE_NAME => if (attributeIndent > 0) {
                    indent = getAttributeIndent(depth)
                }
                case XmlSplitterState.START => indent = getElementIndent(depth)
                case _ => ()
            }
            if (indent > 0 || deferredLeftAngle) {
                sb.append('\n')
            }
            appendIndent(sb, indent)
            if (deferredLeftAngle) {
                sb.append('<')
            }
        }
        sb.append(c)
        if (currentChunkWithCurrentPart.isSome()) {
            currentChunkWithCurrentPart?.append(sb)
        }
        if (newPartCallback.isSome()) {
            if (currentPart.isNone()) {
                currentPart = StringBuilder(1024)
            }
            currentPart?.append(sb)
        }
        if (prettyWriter.isSome()) {
            currentChunk?.append(sb)
        }
    }

    public func onCompleteElement(): Unit {
        if (newPartCallback.isNone()) {
            return
        }
        if (let Some(str) <- currentPart?.toString()) {
            if (str[0] == b'\n') {
                currentPart = StringBuilder(str[1..])
            }
        }
        newPartCallback?.onPrettyPrintedXmlPart(currentPart())
        currentPart = None
    }

    private func getElementIndent(depth: Int64): Int64 {
        return indent * depth
    }

    private func getAttributeIndent(depth: Int64): Int64 {
        return getElementIndent(depth) + attributeIndent
    }

    private func appendIndent(sb: StringBuilder, indent: Int64): Unit {
        var spaces = indent
        if (tabWidth > 0) {
            spaces = indent % tabWidth
            let tabs = indent / tabWidth
            for (_ in 0..tabs) {
                sb.append('\t')
            }
        }
        for (_ in 0..spaces) {
            sb.append(' ')
        }
    }

    /**
     * Create a new builder.
     *
     * @return a new builder.
     */
    public static func builder(): XmlPrettyPrinterBuilder {
        return XmlPrettyPrinterBuilder()
    }
}

public interface PrettyPrintedXmlChunkWithCurrentPartCallback {
    func onPrettyPrintedXmlChunk(chunk: StringBuilder): Unit
}

public interface PrettyPrintedXmlPartCallback {
    func onPrettyPrintedXmlPart(part: StringBuilder): Unit
}

public interface PrettyPrintedXmlChunkSink {
    func sink(stringBuilder: StringBuilder): Unit
}

public class XmlPrettyPrinterBuilder {
    var indent = 2

    var attributeIndent: Int64 = 0

    var tabWidth: Int64 = 0

    var newChunkCallback: ?PrettyPrintedXmlChunkWithCurrentPartCallback = None

    var newPartCallback: ?PrettyPrintedXmlPartCallback = None

    var prettyWriter: ?PrettyPrintedXmlChunkSink = None

    /**
     * 设置元素的缩进，以空白字符表示。
     *
     * @param indent 元素的缩进，以空白字符表示。
     * @return 对这个构建器的引用。
     */
    public func setIndent(indent: Int64): XmlPrettyPrinterBuilder {
        ensureNotNegative(indent)
        this.indent = indent
        return this
    }

    /**
     * 设置属性的缩进，以空白字符表示。使用较小的值可禁用属性缩进。
     *
     * @param attributeIndent 属性的缩进，以空白字符表示。
     * @return 对这个构建器的引用。
     */
    public func setAttributeIndent(attributeIndent: Int64): XmlPrettyPrinterBuilder {
        ensureNotNegative(attributeIndent)
        this.attributeIndent = attributeIndent
        return this
    }

    /**
     * 设置制表符宽度，以空白字符表示。使用较小的值可禁用使用制表符进行的漂亮打印。
     *
     * @param tabWidth 制表符宽度，以空白字符表示。
     * @return 对这个构建器的引用。
     */
    public func setTabWidth(tabWidth: Int64): XmlPrettyPrinterBuilder {
        ensureNotNegative(tabWidth)
        this.tabWidth = tabWidth
        return this
    }

    /**
     * 设置块回调。
     *
     * @param chunkCallback 块回调。
     * @return 对这个构建器的引用。
     */
    public func setChunkCallback(chunkCallback: PrettyPrintedXmlChunkWithCurrentPartCallback): XmlPrettyPrinterBuilder {
        this.newChunkCallback = chunkCallback
        return this
    }

    /**
     * 设置部分回调。
     *
     * @param partCallback 部分回调。
     * @return 对这个构建器的引用。
     */
    public func setPartCallback(partCallback: PrettyPrintedXmlPartCallback): XmlPrettyPrinterBuilder {
        this.newPartCallback = partCallback
        return this
    }

    /**
     * 为漂亮打印的 XML 流设置一个 {@link PrettyPrintedXmlChunkSink}。
     *
     * @param prettyWriter 用于漂亮打印的写入器。
     * @return 对这个构建器的引用。
     */
    public func setPrettyWriter(prettyWriter: PrettyPrintedXmlChunkSink): XmlPrettyPrinterBuilder {
        this.prettyWriter = prettyWriter
        return this
    }

    /**
     * 构建一个 XmlPrettyPrinter。
     *
     * @return 新构建的 XmlPrettyPrinter。
     */
    public func build(): XmlPrettyPrinter {
        return XmlPrettyPrinter(this)
    }

    private static func ensureNotNegative(i: Int64): Unit {
        if (i < 0) {
            throw IllegalArgumentException()
        }
    }
}
