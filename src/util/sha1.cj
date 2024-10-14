/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public class SHA1Util {
    /**
     *  Used by the hash method.
     */
    private static let SHA1_DIGEST: SHA1 = SHA1()
    private static let lock = Monitor()

    public static func bytes(bytes: Array<UInt8>): Array<UInt8> {
        synchronized(lock) {
            SHA1_DIGEST.write(bytes)
            let arr = SHA1_DIGEST.finish()
            SHA1_DIGEST.reset()
            return arr
        }
    }

    public static func bytes(string: String): Array<UInt8> {
        return bytes(StringUtils.toUtf8Bytes(string))
    }

    public static func hex(bytes: Array<UInt8>): String {
        return StringUtils.encodeHex(SHA1Util.bytes(bytes))
    }

    public static func hex(string: String): String {
        return hex(StringUtils.toUtf8Bytes(string))
    }
}
