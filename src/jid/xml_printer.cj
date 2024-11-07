/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.jid

/**  
 * 抽象类，表示 XML 打印机的接口
 */
public abstract class XmlPrinter {
    /**  
     * 当一个块开始时调用
     */
    public func onChunkStart(): Unit

    /**  
     * 当一个块结束时调用
     */
    public func onChunkEnd(): Unit

    /**  
     * 当下一个字符到达时调用
     *
     * @param c               当前字符
     * @param depth           当前深度
     * @param initialState    初始状态
     * @param currentState    当前状态
     */
    public func onNextChar(c: Rune, depth: Int64, initialState: XmlSplitterState, currentState: XmlSplitterState): Unit

    /**  
     * 当完成一个元素时调用
     */
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
     * 构建一个新的XML漂亮打印机。
     *
     * @param part 回调一个零件回调。
     */
    public init(partCallback: PrettyPrintedXmlPartCallback) {
        this(builder().setPartCallback(partCallback))
    }

    /**
     * 构建一个新的XML漂亮打印机。
     *
     * @param prettyWriter 是打印精美的XML流的编写器。
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

    /**  
     * 当一个新的 XML 片段开始时被调用。
     * <p>
     * 用户需要在实现中定义如何处理片段开始的逻辑。
     * </p>
     */
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

    /**  
     * 当一个 XML 片段结束时被调用。
     * <p>
     * 用户需要在实现中定义如何处理片段结束的逻辑。
     * </p>
     */
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

    /**  
     * 当处理下一个字符时被调用。
     *
     * @param c 当前字符
     * @param depth 当前 XML 深度
     * @param initialState XML 解析的初始状态
     * @param currentState 当前状态
     * @throws IOException 如果在处理字符时发生输入输出异常
     */
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
                case XmlSplitterState.IN_ATTRIBUTE_NAME =>
                    if (attributeIndent > 0) {
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

    /**  
     * 当完成一个完整的 XML 元素时被调用。
     * <p>
     * 用户需要在实现中定义如何处理完整元素的逻辑。
     * </p>
     */
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

/**  
 * PrettyPrintedXmlChunkWithCurrentPartCallback 接口用于定义一个回调，
 * 该回调在接收到美观格式打印的 XML 片段时被调用。
 */
public interface PrettyPrintedXmlChunkWithCurrentPartCallback {
    /**  
     * 当接收到一个美观格式打印的 XML 片段时调用此方法。
     *
     * @param chunk 包含 XML 片段的字符串构建器
     */
    func onPrettyPrintedXmlChunk(chunk: StringBuilder): Unit
}

/**  
 * PrettyPrintedXmlPartCallback 接口用于定义一个回调，
 * 该回调在接收到美观格式打印的 XML 部分时被调用。
 */
public open class PrettyPrintedXmlPartCallback {
    public PrettyPrintedXmlPartCallback(let callback: (StringBuilder) -> Unit) {}
    /**  
     * 当接收到一个美观格式打印的 XML 部分时调用此方法。
     *
     * @param part 包含 XML 部分的字符串构建器
     */
    public open func onPrettyPrintedXmlPart(part: StringBuilder): Unit {
        callback(part)
    }
}

/**  
 * PrettyPrintedXmlChunkSink 接口用于定义一个接收器，
 * 该接收器接受以美观格式打印的 XML 片段。
 */
public open class PrettyPrintedXmlChunkSink {
    public PrettyPrintedXmlChunkSink(let callback: (StringBuilder) -> Unit) {}
    /**  
     * 接收一个字符串构建器，其中包含要处理的 XML 字符串。
     *
     * @param stringBuilder 包含 XML 片段的字符串构建器
     */
    public open func sink(stringBuilder: StringBuilder): Unit {
        callback(stringBuilder)
    }
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
