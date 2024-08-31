/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package xmpp4cj.xml

/**
 * @see w3/org/TR/xml/#NT-NameStartChar
 */
let NameStartCharUnicodeRange = [
    (r'\u{C0}', r'\u{D6}'),
    (r'\u{D8}', r'\u{F6}'),
    (r'\u{F8}', r'\u{2FF}'),
    (r'\u{370}', r'\u{37D}'),
    (r'\u{37F}', r'\u{1FFF}'),
    (r'\u{200C}', r'\u{200D}'),
    (r'\u{2070}', r'\u{218F}'),
    (r'\u{2C00}', r'\u{2FEF}'),
    (r'\u{3001}', r'\u{D7FF}'),
    (r'\u{F900}', r'\u{FDCF}'),
    (r'\u{FDF0}', r'\u{FFFD}'),
    (r'\u{10000}', r'\u{E0000}')
]
let NameCharUnicodeRange = [
    (r'\u{B7}', r'\u{B7}'),
    (r'\u{300}', r'\u{36F}'),
    (r'\u{203F}', r'\u{2040}')
]
private const TO_STRING_MAX_LEN = 17

extend BytesInputStream <: ToString {
    func readName(): String {
        var (name, nameEnd) = doReadName()
        if (nameEnd) { // fast path
            return name
        }

        let sb = StringBuilder(name)
        while (!nameEnd) {
            (name, nameEnd) = doReadName()
            sb.append(name)
        }
        return sb.toString()
    }

    private func doReadName(): (String, Bool) {
        var (rune, runeSize) = peekRune(0)
        if (!isNameStartChar(rune)) {
            return ("", true)
        }

        var readLen = runeSize

        (rune, runeSize) = peekRune(readLen)
        while (readLen < this.size && isNameChar(rune)) {
            readLen += runeSize
            (rune, runeSize) = peekRune(readLen)
        }

        let readData = window.slice(0, readLen)
        window = window.slice(readLen, window.size - readLen)
        return (String.fromUtf8(readData), true)
    }

    /**
     * UTF-8:
     * 0xxx_xxxx
     * 110x_xxxx 10xx_xxxx
     * 1110_xxxx 10xx_xxxx 10xx_xxxx
     * 1111_0xxx 10xx_xxxx 10xx_xxxx 10xx_xxxx
     */
    func peekRune(idx: Int64): (Rune, Int64) {
        const trailingMask = 0b1011_1111u8
        const leadingMask2 = 0b0001_1111u8
        const leadingMask3 = 0b0000_1111u8
        const leadingMask4 = 0b0000_0111u8

        let b = this[idx]
        return match {
            case (b & 0x80) == 0x00 => (Rune(b), 1)
            case (b & 0xE0) == 0xC0 => (Rune(UInt32(leadingMask2 & b) << 8 | UInt32(this[idx + 1])), 2)
            case (b & 0xF0) == 0xE0 => (Rune(UInt32(leadingMask3 & b) << 16 | UInt32(this[idx + 1] & trailingMask) << 8 |
                    UInt32(this[idx + 2])), 3)
            case (b & 0xF8) == 0xF0 => (Rune(UInt32(leadingMask4 & b) << 24 | UInt32(this[idx + 1] & trailingMask) << 16 |
                    UInt32(this[idx + 2] & trailingMask) << 8 | UInt32(this[idx + 3])), 4)
            case _ => throw XmlException("Failed to read Rune, by leader byte `${b}` at: `${this}`.")
        }
    }

    public func toString(): String {
        return match (this.size > TO_STRING_MAX_LEN) {
            case true =>
                let sb = StringBuilder()
                var idx = 0
                for (_ in 0..TO_STRING_MAX_LEN) {
                    let (rune, size) = peekRune(idx)
                    match (rune) {
                        case r'\t' => sb.append("\\t")
                        case r'\r' => sb.append("\\r")
                        case r'\n' => sb.append("\\n")
                        case _ => sb.append(rune)
                    }
                    idx += size
                }
                return sb.toString() + "..."
            case false => String.fromUtf8(window)
        }
    }
}

func isNameStartChar(c: Rune): Bool {
    return match (c) {
        case ':' | '_' => true
        case _ => match {
            case (r'a' <= c) && (c <= r'z') => true
            case (r'A' <= c) && (c <= r'Z') => true
            case _ =>
                for ((min, max) in NameStartCharUnicodeRange where unicodeCheck(c, min, max)) {
                    return true
                }
                return false
        }
    }
}

func isNameChar(c: Rune): Bool {
    return match (c) {
        case ':' | '_' | '=' | '-' => true
        case _ => match {
            case (r'a' <= c) && (c <= r'z') => true
            case (r'A' <= c) && (c <= r'Z') => true
            case (r'0' <= c) && (c <= r'9') => true
            case _ =>
                for ((min, max) in NameCharUnicodeRange where unicodeCheck(c, min, max)) {
                    return true
                }
                for ((min, max) in NameStartCharUnicodeRange where unicodeCheck(c, min, max)) {
                    return true
                }
                return false
        }
    }
}

func unicodeCheck(rune: Rune, min: Rune, max: Rune): Bool {
    return (min <= rune) && (rune <= max)
}

func isWhitespace(b: Byte): Bool {
    return match (b) {
        case b' ' | b'\t' | b'\r' | b'\n' => true
        case _ => false
    }
}

let ESCAPE_MAPPING = HashMap<String, String>([("&lt;", "<"), ("&gt;", ">"), ("&amp;", "&"), ("&quot;", "\""),
    ("&apos;", "'")])
