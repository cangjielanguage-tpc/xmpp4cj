/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.compression

/**  
 * 该类提供XMPP的"zlib"压缩功能
 */
public class ZlibInputOutputStream <: XMPPInputOutputStream {
    /**  
     * 初始化 ZlibInputOutputStream
     */
    public init() {
        super("zlib")
    }

    /**  
     * 检查此压缩格式是否被支持。
     *
     * @return 如果支持则返回true，否则返回false。
     */
    public override func isSupported(): Bool {
        true
    }

    /**  
     * 获取解压缩的输入流。
     *
     * @param inputStream 原始输入流
     * @return 解压缩后的输入流
     */
    public override func getInputStream(inputStream: InputStream): InputStream {
        DeCompressInWrapper(inputStream)
    }

    /**
     * 获取压缩的输出流。
     *
     * @param outputStream 原始输出流
     * @return 压缩后的输出流
     */
    public override func getOutputStream(outputStream: OutputStream): OutputStream {
        CompressOutWrapper(outputStream)
    }
}

class CompressOutWrapper <: OutputStream {
    private let buf = ByteBuffer()
    let deflater = Deflate()
    /*
     * 使用 FULL_FLUSH 策略 简化流程
     * Z_SYNC_FLUSH : 根据内部状态flush 但buffer区可能有残留 可提高压缩率
     * Z_FULL_FLUSH : 所有内部状态和数据都进行彻底的flush 可保证完整的数据边界 流程简单
     */
    let flush_flag: UInt32 = Z_FULL_FLUSH
    CompressOutWrapper(let out: OutputStream) {
        deflater.deflateInit() // 默认包装格式zlib 默认压缩级别6
    }
    public override func write(buffer: Array<UInt8>): Unit {
        buf.write(buffer)
    }
    public override func flush(): Unit {
        let inbuf = readToEnd(buf)
        let outlen: Int64 = deflater.deflateBound(inbuf.size)
        let outbuf: Array<UInt8> = Array<UInt8>(outlen, repeat: 0)
        deflater.setInBuf(inbuf)
        deflater.setOutBuf(outbuf)
        deflater.deflate(flush_flag)
        let outdata = outbuf[0..deflater.getOutDataLength()]
        out.write(outdata)
        out.flush()
    }
}

class DeCompressInWrapper <: InputStream {
    let buf = ByteBuffer()
    let inflate: Inflate = Inflate()
    DeCompressInWrapper(let ins: InputStream) {
        inflate.inflateInit(wrap: ZLIB_TYPE)
    }
    public override func read(buffer: Array<UInt8>): Int {
        while (let Some(len) <- Some(ins.read(buffer))) {
            buf.write(buffer[..len])
            if (len < buffer.size) {
                break
            }
        }
        inflate.setInBuf(buf.bytes())
        inflate.setOutBuf(buffer)
        inflate.inflate(Z_FULL_FLUSH)
        buf.clear()
        inflate.getOutDataLength()
    }
}
