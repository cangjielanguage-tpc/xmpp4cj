/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.jid

/**
 * URL解码。
 */
class URLDecoder {
    /**
     * URL解码。
     *
     * @param s 需要解码的文本
     * @return 解码之后的文本内容。
     */
    public static func urlDecoderDecode(s: String): String {
        try {
            let arrByte: Array<Byte> = s.toArray()
            var out: ArrayList<Byte> = ArrayList<Byte>(arrByte.size)
            var i: Int64 = 0
            while (i < arrByte.size) {
                let c: Byte = arrByte[i]
                if (c == b'+') {
                    out.append(b' ')
                    i++
                } else if (c == b'%') {
                    let c1: Byte = arrByte[i + 1]
                    let c2: Byte = arrByte[i + 2]
                    let b: Byte = hex2Dec(c1) * 16 + hex2Dec(c2)
                    out.append(b)
                    i = i + 3
                } else {
                    out.append(c)
                    i++
                }
            }
            unsafe { String.fromUtf8Unchecked(out.getRawArray()[..out.size]) }
        } catch (e: IllegalArgumentException) {
            throw e
        } catch (e: Exception) {
            throw IllegalArgumentException(e.toString())
        }
    }

    private static func hex2Dec(b: Byte): Byte {
        return match (b) {
            case b'0' => 0
            case b'1' => 1
            case b'2' => 2
            case b'3' => 3
            case b'4' => 4
            case b'5' => 5
            case b'6' => 6
            case b'7' => 7
            case b'8' => 8
            case b'9' => 9
            case b'a' | b'A' => 10
            case b'b' | b'B' => 11
            case b'c' | b'C' => 12
            case b'd' | b'D' => 13
            case b'e' | b'E' => 14
            case b'f' | b'F' => 15
            case _ => throw IllegalArgumentException()
        }
    }
}
