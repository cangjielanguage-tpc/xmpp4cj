/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

/**
 * ZlibXMPP 压缩工厂类，用于创建 Zlib 压缩的 XMPP 输入输出过滤器。
 * 该类实现了 XmppCompressionFactory，并提供了对 Zlib 压缩的支持。
 */
public class ZlibXmppCompressionFactory <: XmppCompressionFactory {
    /**
     * 单例实例。
     */
    public static let INSTANCE = ZlibXmppCompressionFactory()

    /**
     * 私有构造函数，初始化工厂，设置压缩类型和级别 。
     */
    private init() {
        super("zlib", 100)
    }

    /**
     * 创建并返回一个新的 Zlib 输入输出过滤器。
     *
     * @param config 连接配置
     * @return 返回一个 ZlibXmppInputOutputFilter 实例
     */
    public override func fabricate(config: ConnectionConfiguration): XmppInputOutputFilter {
        return ZlibXmppInputOutputFilter()
    }
}

class ZlibXmppInputOutputFilter <: XmppInputOutputFilter {
    private static let MINIMUM_OUTPUT_BUFFER_INITIAL_SIZE = 4
    private static let MINIMUM_OUTPUT_BUFFER_INCREASE = 480

    private let compressorBuffer: ByteBuffer = ByteBuffer()
    private let compressor: OutputStream

    private let decompressorBuffer = ByteBuffer()
    private let decompressor: InputStream

    private var outputBuffer: ?ByteBuffer = None

    var compressorInBytes: Int = 0
    var compressorOutBytes: Int = 0

    var decompressorInBytes: Int = 0
    var decompressorOutBytes: Int = 0

    var maxOutputOutput = -1
    var maxInputOutput = -1

    var maxBytesWrittenAfterFullFlush = -1

    init() {
        let zlib = ZlibInputOutputStream()
        compressor = zlib.getOutputStream(compressorBuffer)
        decompressor = zlib.getInputStream(decompressorBuffer)
    }

    public override func output(outputData: ?ByteBuffer, isFinalDataOfElement: Bool, destinationAddressChanged: Bool,
        moreDataAvailable: Bool): XmppInputOutputFilterOutputResult {
        if (destinationAddressChanged && XMPPInputOutputStream.getFlushMethod() == XMPPInputOutputStreamFlushMethod
            .FULL_FLUSH) {
            outputBuffer = ByteBuffer(256)
            let bytesWritten = deflate(true)
            maxBytesWrittenAfterFullFlush = max(bytesWritten, maxBytesWrittenAfterFullFlush)
            compressorOutBytes += bytesWritten
        }
        if (outputData.isNone() && outputBuffer.isNone()) {
            return XmppInputOutputFilterOutputResult.NO_OUTPUT
        }
        let outputData0 = outputData.getOrThrow()
        let bytesRemaining = outputData0.remainLength
        if (outputBuffer.isNone()) {
            let outputBufferSize = if (bytesRemaining < MINIMUM_OUTPUT_BUFFER_INITIAL_SIZE) {
                MINIMUM_OUTPUT_BUFFER_INITIAL_SIZE
            } else {
                bytesRemaining
            }
            outputBuffer = ByteBuffer(outputBufferSize)
        }

        // assert(compressor.needsInput()) // 无法获知compressor内部状态,忽略

        let compressorInputBufferLength = outputData0.remainLength
        let compressorInputBuffer: Array<UInt8> = outputData0.bytes()

        compressorInBytes += compressorInputBufferLength
        compressor.write(compressorInputBuffer)

        let bytesWritten = deflate(moreDataAvailable == false)

        maxOutputOutput = max(outputBuffer.getOrThrow().length, maxOutputOutput)
        compressorOutBytes += bytesWritten

        let outputResult = XmppInputOutputFilterOutputResult(outputBuffer.getOrThrow())
        outputBuffer = None
        return outputResult
    }

    private func deflate(needFlush: Bool): Int {
        let outputBuffer = this.outputBuffer.getOrThrow()
        if (needFlush) {
            compressor.flush()
            let totalBytesWritten = compressorBuffer.remainLength
            copy(compressorBuffer, to: outputBuffer)
            return totalBytesWritten
        } else {
            return 0
        }
    }

    public override func input(inputData: ByteBuffer): ?ByteBuffer {
        let bytesRemaining = inputData.remainLength
        let inputBytes: Array<UInt8> = inputData.bytes()
        let length: Int = bytesRemaining

        decompressorInBytes += length
        decompressorBuffer.write(inputBytes)

        decompressorOutBytes += decompressorBuffer.remainLength

        let outputBuffer = ByteBuffer(length * 2)
        copy(decompressor, to: outputBuffer)

        if (outputBuffer.remainLength == 0) {
            // 如果decompressor没有解压输出 
            return None
        }

        maxInputOutput = max(outputBuffer.length, maxInputOutput)
        return outputBuffer
    }

    public override func getStats(): ZlibXmppCompressionFactoryStats {
        return ZlibXmppCompressionFactoryStats(this)
    }

    public override func getFilterName(): String {
        return "Compression (zlib)"
    }
}

/**
 * 该类表示压缩和解压缩过滤器的统计信息。
 */
public class ZlibXmppCompressionFactoryStats <: ToString & Equatable<ZlibXmppCompressionFactoryStats> {
    /**
     *  输入到压缩器的字节数。
     */
    public let compressorInBytes: Int

    /**
     * 从压缩器输出的字节数 。
     */
    public let compressorOutBytes: Int

    /**
     * 压缩比，即输出字节数与输入字节数的比率。
     */
    public let compressionRatio: Float64

    /**
     * 输入到解压缩器的字节数。
     */
    public let decompressorInBytes: Int

    /**
     * 从解压缩器输出的字节数。
     */
    public let decompressorOutBytes: Int

    /**
     * 解压缩比，即输入字节数与输出字节数的比率。
     */
    public let decompressionRatio: Float64

    /**
     * 过滤器的最大输出大小。
     */
    public let maxOutputOutput: Int

    /**
     * 过滤器处理的最大输入大小。
     */
    public let maxInputOutput: Int

    /**
     * 完全刷新后写入的最大字节数。
     */
    public let maxBytesWrittenAfterFullFlush: Int

    /**
     * 私有构造函数，用于从给定的过滤器初始化统计信息。
     *
     * @param filter 要从中获取统计信息的 ZlibXmppInputOutputFilter
     */
    init(filter: ZlibXmppInputOutputFilter) {
        compressorOutBytes = filter.compressorOutBytes
        compressorInBytes = filter.compressorInBytes
        compressionRatio = Float64(compressorOutBytes) / Float64(compressorInBytes)
        decompressorOutBytes = filter.decompressorOutBytes
        decompressorInBytes = filter.decompressorInBytes
        decompressionRatio = Float64(decompressorInBytes) / Float64(decompressorOutBytes)
        maxOutputOutput = filter.maxOutputOutput
        maxInputOutput = filter.maxInputOutput
        maxBytesWrittenAfterFullFlush = filter.maxBytesWrittenAfterFullFlush
    }

    /**
     * 缓存的字符串表示，供高效重用。
     */
    private var toStringCache: ?String = None

    /**
     * 返回压缩和解压缩统计信息的字符串表示。
     *
     * @return 概述统计信息的字符串。
     */
    public override func toString(): String {
        if (let Some(v) <- toStringCache) {
            return v
        }
        let str = """
compressor-in-bytes: ${compressorInBytes}
compressor-out-bytes: ${compressorOutBytes}
compression-ratio: ${compressionRatio}
decompressor-in-bytes: ${decompressorInBytes}
decompressor-out-bytes: ${decompressorOutBytes}
decompression-ratio: ${decompressionRatio}
max-output-output: ${maxOutputOutput}
max-input-output: ${maxInputOutput}
max-bytes-written-after-full-flush: ${maxBytesWrittenAfterFullFlush}
"""
        toStringCache = str
        return str
    }

    public operator func ==(that: ZlibXmppCompressionFactoryStats): Bool {
        return refEq(this, that)
    }
}

func max(a: Int, b: Int): Int {
    if (a > b) {
        a
    } else {
        b
    }
}
