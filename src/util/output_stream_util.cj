/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

public class OutputStreamUtil {
    public static func writeByteSafe(outputStream: OutputStream, i: Int64, message: String): Unit {
        if (i < 0 || i > 0xff) {
            throw IOException("#{message}. The value ${i} is not within the allowed range for bytes")
        }
        outputStream.write(UInt8(i))
    }
}
