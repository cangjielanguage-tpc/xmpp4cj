package xmpp4cj.util

import stdx.crypto.digest.SHA1

/**
 * SHA1工具类
 */
public class SHA1Util {
    /**
     * 用于 hash 方法的 MessageDigest 实例
     */
    private static let SHA1_DIGEST: SHA1 = SHA1()

    /**
     * 锁
     */
    private static let lock = Mutex()

    /**
     * 计算给定字节数组的 SHA1 哈希值
     *
     * @param bytes 输入的字节数组
     * @return 计算得到的 SHA1 哈希值
     */
    public static func bytes(bytes: Array<UInt8>): Array<UInt8> {
        synchronized(lock) {
            SHA1_DIGEST.write(bytes)
            let arr = SHA1_DIGEST.finish()
            SHA1_DIGEST.reset()
            return arr
        }
    }

    /**
     * 计算给定字符串的 SHA1 哈希值
     *
     * @param string 输入的字符串
     * @return 计算得到的 SHA1 哈希值
     */
    public static func bytes(string: String): Array<UInt8> {
        return bytes(StringUtils.toUtf8Bytes(string))
    }

    /**
     * 将字节数组转换为十六进制字符串
     *
     * @param bytes 输入的字节数组
     * @return 十六进制表示的字符串
     */
    public static func hex(bytes: Array<UInt8>): String {
        return StringUtils.encodeHex(SHA1Util.bytes(bytes))
    }

    /**
     * 将字符串转换为十六进制字符串
     *
     * @param string 输入的字符串
     * @return 十六进制表示的字符串
     */
    public static func hex(string: String): String {
        return hex(StringUtils.toUtf8Bytes(string))
    }
}
