/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

public abstract class XMPPInputOutputStream {
    protected static var flushMethod: XMPPInputOutputStreamFlushMethod = XMPPInputOutputStreamFlushMethod.SYNC_FLUSH

    /**
     * Set the used flushed method when compressing data. The default is full flush which may not
     * achieve the best compression ratio, but provides better security against certain attacks.
     * Only use sync flush if you fully understand the implications.
     *
     * @see <a href="https/blog/thijsalkema/de/blog/2014/08/07/https-attacks-and-xmpp-2-crime-and-breach/">Attacks against XMPP when using compression</a>
     * @param flushMethod TODO javadoc me please
     */
    public static func setFlushMethod(flushMethod: XMPPInputOutputStreamFlushMethod): Unit {
        XMPPInputOutputStream.flushMethod = Objects.requireNonNull(flushMethod)
    }

    public static func getFlushMethod(): XMPPInputOutputStreamFlushMethod {
        return flushMethod
    }

    protected let compressionMethod: String

    protected init(compressionMethod: String) {
        this.compressionMethod = compressionMethod
    }

    public func getCompressionMethod(): String {
        return compressionMethod
    }

    public func isSupported(): Bool

    public func getInputStream(inputStream: InputStream): InputStream

    public func getOutputStream(outputStream: OutputStream): OutputStream
}

public enum XMPPInputOutputStreamFlushMethod <: Equatable<XMPPInputOutputStreamFlushMethod> {
    | FULL_FLUSH
    | SYNC_FLUSH

    public operator override func ==(that: XMPPInputOutputStreamFlushMethod): Bool {
        match ((this, that)) {
            case (FULL_FLUSH, FULL_FLUSH) => true
            case (SYNC_FLUSH, SYNC_FLUSH) => true
            case _ => false
        }
    }
}
