/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.feature

/**
 * public abstract class XMPPInputOutputStream
 *
 * 抽象类，表示 XMPP 输入输出流。
 * 此类提供了压缩数据时所用的刷新方法，并定义了一些抽象方法，以便子类实现具体的输入输出流逻辑。
 */
public abstract class XMPPInputOutputStream {
    /**
     * 用于压缩数据时的刷新方法
     */
    protected static var flushMethod: XMPPInputOutputStreamFlushMethod = XMPPInputOutputStreamFlushMethod.SYNC_FLUSH

    /**
     * 设置压缩数据时使用的刷新方法。默认使用完全刷新，这可能无法达到最佳压缩比，
     * 但能提供更好的安全性以防御某些攻击。仅在完全理解其影响时使用同步刷新。
     *
     * @see <a href="https/blog/thijsalkema/de/blog/2014/08/07/https-attacks-and-xmpp-2-crime-and-breach/">针对使用压缩的 XMPP 的攻击</a>
     * @param flushMethod 要设置的刷新方法
     */
    public static func setFlushMethod(flushMethod: XMPPInputOutputStreamFlushMethod): Unit {
        XMPPInputOutputStream.flushMethod = Objects.requireNonNull(flushMethod)
    }

    /**
     * 获取当前使用的刷新方法。
     *
     * @return 当前的刷新方法
     */
    public static func getFlushMethod(): XMPPInputOutputStreamFlushMethod {
        return flushMethod
    }

    protected let compressionMethod: String // 记录压缩方法

    /**
     * 构造函数，初始化压缩方法。
     *
     * @param compressionMethod 压缩方法的名称
     */
    protected init(compressionMethod: String) {
        this.compressionMethod = compressionMethod
    }

    /**
     * 获取当前使用的压缩方法。
     *
     * @return 当前的压缩方法
     */
    public func getCompressionMethod(): String {
        return compressionMethod
    }

    /**
     * 判断当前输入输出流是否支持特定的功能。
     *
     * @return 如果支持，返回 true；否则返回 false
     */
    public func isSupported(): Bool

    /**
     * 获取处理输入流的具体实现。
     *
     * @param inputStream 要处理的输入流
     * @return 处理后的输入流
     * @throws IOException 如果处理输入流时发生 I/O 错误
     */
    public func getInputStream(inputStream: InputStream): InputStream

    /**
     * 获取处理输出流的具体实现。
     *
     * @param outputStream 要处理的输出流
     * @return 处理后的输出流
     * @throws IOException 如果处理输出流时发生 I/O 错误
     */
    public func getOutputStream(outputStream: OutputStream): OutputStream
}

/**
 * 表示刷新方法的枚举类型。
 * 该枚举定义了不同的刷新方式。
 */
public enum XMPPInputOutputStreamFlushMethod <: Equatable<XMPPInputOutputStreamFlushMethod> {
    /**
     * 完全刷新：强制所有数据立即被写入目标。
     */
    | FULL_FLUSH
    /**
     * 同步刷新：确保数据在刷新的同时保持一致性，但可能不是所有数据立即写入。
     */
    | SYNC_FLUSH

    public operator override func ==(that: XMPPInputOutputStreamFlushMethod): Bool {
        match ((this, that)) {
            case (FULL_FLUSH, FULL_FLUSH) => true
            case (SYNC_FLUSH, SYNC_FLUSH) => true
            case _ => false
        }
    }
}
