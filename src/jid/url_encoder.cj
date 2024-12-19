/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.jid

/**
 * URL编码。
 */
class URLEncoder {
    /**
     * URL编码。
     *
     * @param s 需要编码的文本
     * @return 编码之后的文本内容。
     */
    public static func encode(s: String): String {
        let arrByte: Array<Byte> = s.toArray()
        var out: ArrayList<Byte> = ArrayList<Byte>()
        for (c in arrByte) {
            if (c == b' ') {
                out.append(b'+')
            } else if ((c >= b'A' && c <= b'Z') || (c >= b'a' && c <= b'z') || (c >= b'0' && c <= b'9') || c == b'-' ||
                c == b'_' || c == b'.' || c == b'*') {
                out.append(c)
            } else {
                out.append(b'%')
                out.append(dec2HexBytes(c)[0])
                out.append(dec2HexBytes(c)[1])
            }
        }
        unsafe { String.fromUtf8Unchecked(out.getRawArray()[..out.size]) }
    }

    private static func dec2HexBytes(b: Byte): (Byte, Byte) {
        let a1: Byte = b / 16
        let a2: Byte = b % 16
        (dec2Hex(a1), dec2Hex(a2))
    }

    private static func dec2Hex(b: Byte): Byte {
        return match (b) {
            case 0 => b'0'
            case 1 => b'1'
            case 2 => b'2'
            case 3 => b'3'
            case 4 => b'4'
            case 5 => b'5'
            case 6 => b'6'
            case 7 => b'7'
            case 8 => b'8'
            case 9 => b'9'
            case 10 => b'A'
            case 11 => b'B'
            case 12 => b'C'
            case 13 => b'D'
            case 14 => b'E'
            case 15 => b'F'
            case _ => throw IllegalArgumentException()
        }
    }
}
