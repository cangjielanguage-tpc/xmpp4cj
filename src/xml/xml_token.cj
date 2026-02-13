/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.xml

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
const TO_STRING_MAX_LEN = 17

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
