/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.compression

/**  
 * 该类提供XMPP的"zlib"压缩功能，使用compress.zlib进行实现。
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
        DecompressInputStream(inputStream, wrap: DeflateFormat)
    }

    /**  
     * 获取压缩的输出流。
     *
     * @param outputStream 原始输出流
     * @return 压缩后的输出流
     */
    public override func getOutputStream(outputStream: OutputStream): OutputStream {
        CompressOutputStream(outputStream, wrap: DeflateFormat)
    }
}
