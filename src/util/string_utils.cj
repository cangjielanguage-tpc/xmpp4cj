/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * 一个用于字符串对象的工具方法集合。
 */
public class StringUtils {
    public static let MD5: String = "MD5"
    public static let SHA1: String = "SHA-1"
    public static let QUOTE_ENCODE: String = "&quot;"
    public static let APOS_ENCODE: String = "&apos;"
    public static let AMP_ENCODE: String = "&amp;"
    public static let LT_ENCODE: String = "&lt;"
    public static let GT_ENCODE: String = "&gt;"
    public static let HEX_CHARS: Array<Byte> = "0123456789abcdef".toArray()
    /**
     * 24 upper case characters from the latin alphabet and numbers without '0' and 'O'.
     */
    public static let UNAMBIGUOUS_NUMBERS_AND_LETTERS_STRING: String = "123456789ABCDEFGHIJKLMNPQRSTUVWXYZ"
    /**
     * 24 upper case characters from the latin alphabet and numbers without '0' and 'O'.
     */
    private static let UNAMBIGUOUS_NUMBERS_AND_LETTERS: Array<Byte> = UNAMBIGUOUS_NUMBERS_AND_LETTERS_STRING.toArray()
    private static let RANDOM_STRING_CHUNK_SIZE: Int64 = 4

    /**
     * 对<code>input</code>进行 XML 转义。
     *
     * @param input 要转义的输入。
     * @return <code>input</code>的 XML 转义变体。
     */
    public static func escapeForXml(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.safe)
    }

    /**
     * 对<code>input</code>进行 XML 转义。
     *
     * @param input 要转义的输入。
     * @return <code>input</code>的 XML 转义变体。
     */
    public static func escapeForXmlAttribute(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.forAttribute)
    }

    /**
     * 对<code>input</code>进行 XML 转义。
     * <p>
     * 这是 {@link #escapeForXmlAttribute(CharSequence)} 的优化变体，用于 XML 属性用'''（Apos）引用的情况。
     * </p>
     *
     * @param input 要转义的输入。
     * @return <code>input</code>的 XML 转义变体。
     */
    public static func escapeForXmlAttributeApos(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.forAttributeApos)
    }

    /**
     * 对<code>input</code>进行 XML 转义。
     *
     * @param input 要转义的输入。
     * @return <code>input</code>的 XML 转义变体。
     */
    public static func escapeForXmlText(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.forText)
    }
    /**
     * 转义 CharSequence 中的所有必要字符，以便它可以在 XML 文档中使用。
     *
     * @param input 要转义的 CharSequence。
     * @return 带有适当转义字符的字符串。
     */
    private static func escapeForXml(input: String, xmlEscapeMode: StringUtilsXmlEscapeMode): String {
        let inputer = input.toRuneArray()
        let len: Int64 = inputer.size
        let out: StringBuilder = StringBuilder(Int64(floor(Float64(len) * 1.3)) + 1)
        var toAppend: ?String
        var last: Int64 = 0
        var i: Int64 = 0
        while (i < len) {
            toAppend = None
            let ch = inputer[i]
            match (xmlEscapeMode) {
                case safe => match (ch) {
                    case r'<' => toAppend = LT_ENCODE
                    case r'>' => toAppend = GT_ENCODE
                    case r'&' => toAppend = AMP_ENCODE
                    case r'"' => toAppend = QUOTE_ENCODE
                    case r'\'' => toAppend = APOS_ENCODE
                    case _ => ()
                }
                case forAttribute => match (ch) { // No need to escape '>' for attributes.
                    case r'<' => toAppend = LT_ENCODE
                    case r'&' => toAppend = AMP_ENCODE
                    case r'"' => toAppend = QUOTE_ENCODE
                    case r'\'' => toAppend = APOS_ENCODE
                    case _ => ()
                }
                case forAttributeApos => match (ch) { // No need to escape '>' and '"' for attributes using '\'' as quote.
                    case r'<' => toAppend = LT_ENCODE
                    case r'&' => toAppend = AMP_ENCODE
                    case r'\'' => toAppend = APOS_ENCODE
                    case _ => ()
                }
                case forText => match (ch) { // No need to escape '"', '\'', and '>' for text.
                    case r'<' => toAppend = LT_ENCODE
                    case r'&' => toAppend = AMP_ENCODE
                    case _ => ()
                }
            }
            if (let Some(toAppend) <- toAppend) {
                if (i > last) {
                    out.append(inputer[last..i])
                }
                out.append(toAppend)
                i++
                last = i
            } else {
                i++
            }
        }
        if (last == 0) {
            return input
        }
        if (i > last) {
            out.append(inputer[last..i])
        }
        return out.toString()
    }

    /**
     * 将字节数组编码为十六进制的字符串表示形式。
     *
     * @param bytes 要转换为十六进制字符串的字节数组。
     * @return 生成的十六进制字符串。
     */
    public static func encodeHex(bytes: Array<Byte>): String {
        return toHexString(bytes)
    }

    public static func toUtf8Bytes(string: String): Array<Byte> {
        return string.toArray()
    }

    /**
     * 返回指定长度的由数字和字母（大小写）组成的随机字符串。
     * 该方法使用 Cangjie 内置的 Random 类。
     * 这意味着输出只是伪随机的，即每个数字都是数学生成的，因此不是真正的随机。<p>
     *
     * 指定的长度必须至少为一。如果不是，该方法将返回 None。
     *
     * @param length 要返回的随机字符串的所需长度。
     * @return 指定长度的数字和字母组成的随机字符串。
     */
    public static func insecureRandomString(length: Int64): String {
        return randomString(length, RandomUtil.RANDOM)
    }

    public static func secureOnlineAttackSafeRandomString(): String {
        // 34^10 = 2.06e15 possible combinations. Which is enough to protect against online brute force attacks.
        // See also grc/com/haystack.htm
        let REQUIRED_LENGTH: Int64 = 10

        return randomString(RandomUtil.SECURE_RANDOM, UNAMBIGUOUS_NUMBERS_AND_LETTERS, REQUIRED_LENGTH)
    }

    public static func secureUniqueRandomString(): String {
        // 34^13 = 8.11e19 possible combinations, which is > 2^64.
        let REQUIRED_LENGTH: Int64 = 13

        return randomString(RandomUtil.SECURE_RANDOM, UNAMBIGUOUS_NUMBERS_AND_LETTERS, REQUIRED_LENGTH)
    }

    /**
     * 生成一个人类可读的安全随机字符串。结果字符串由 24 个拉丁字母中的大写字符和数字组成，不包括'0'和'O'，分成 4 个字符的块，例如
     * "TWNK-KD5Y-MT3T-E1GS-DRDB-KVTW"。字符由密码学安全的伪随机数生成器（CSPRNG）随机选择。
     * <p>
     * 该字符串可以用作秘密的备份“代码”，实际上与 XEP-0373 中指定的备份代码以及
     * <a href="github.com/open-keychain/open-keychain/wiki/Backups">OpenKeychain 的备份格式 v2</a>中使用的代码相同。
     * </p>
     *
     * @see xep-0373/#backup-encryption XEP-0373 §5.4 加密密钥备份
     * @return 一个人类可读的安全随机字符串。
     */
    public static func secureOfflineAttackSafeRandomString(): String {
        // 34^24 = 2^122.10 possible combinations. Which is enough to protect against offline brute force attacks.
        // See also grc/com/haystack.htm
        let REQUIRED_LENGTH: Int64 = 24

        return randomString(RandomUtil.SECURE_RANDOM, UNAMBIGUOUS_NUMBERS_AND_LETTERS, REQUIRED_LENGTH)
    }

    private static func randomString(random: Random, alphabet: Array<Byte>, numRandomChars: Int64): String {
        // The buffer most hold the size of the requested number of random chars and the chunk separators ('-').
        let bufferSize: Int64 = numRandomChars + ((numRandomChars - 1) / RANDOM_STRING_CHUNK_SIZE)
        let charBuffer: ArrayList<Byte> = ArrayList<Byte>(bufferSize)

        randomString(charBuffer, random, alphabet, numRandomChars)

        return unsafe { String.fromUtf8Unchecked(charBuffer.getRawArray()[..charBuffer.size]) }
    }

    private static func randomString(
        appendable: ArrayList<Byte>,
        random: Random,
        alphabet: Array<Byte>,
        numRandomChars: Int64
    ): Unit {
        for (randomCharNum in 1..numRandomChars) {
            let randomIndex: Int64 = random.nextInt64(alphabet.size)
            let randomChar: Byte = alphabet[randomIndex]
            appendable.append(randomChar)
            if (randomCharNum % RANDOM_STRING_CHUNK_SIZE == 0 && randomCharNum < numRandomChars) {
                appendable.append(b'-')
            }
        }
    }

    public static func randomString(length: Int64): String {
        return randomString(length, RandomUtil.SECURE_RANDOM)
    }

    public static func randomString(length: Int64, random: Random): String {
        if (length == 0) {
            return ""
        }
        let randomChars: Array<Byte> = Array<Byte>(length, repeat: 0)
        for (i in 0..length) {
            let index: Int64 = random.nextInt64(UNAMBIGUOUS_NUMBERS_AND_LETTERS.size)
            randomChars[i] = UNAMBIGUOUS_NUMBERS_AND_LETTERS[index]
        }
        return unsafe { String.fromUtf8Unchecked(randomChars) }
    }

    /**
     * 如果字符序列不是 None 且不为空，则返回 true，否则返回 false。
     * 示例：
     *    isNotEmpty(None) - false
     *    isNotEmpty("") - false
     *    isNotEmpty(" ") - true
     *    isNotEmpty("empty") - true
     *
     * @param cs 被检查的字符序列
     * @return 如果字符串不是 None 且不为空，则为 true，否则为 false
     */
    public static func isNotEmpty<T>(cs: ?T): Bool where T <: ToString {
        return !isNullOrEmpty(cs)
    }

    /**
     * 如果给定的字符序列是 None 或为空，则返回 true。
     *
     * @param cs
     * @return 如果给定的字符序列是 None 或为空，则为 true
     */
    public static func isNullOrEmpty<T>(cs: ?T): Bool where T <: ToString {
        return cs.isNone() || isEmpty(cs.getOrThrow())
    }

    /**
     * 如果所有给定的字符序列都不为空，则返回 true。
     *
     * @param css 要测试的字符序列。
     * @return 如果所有给定的字符序列都不为空，则为 true。
     */
    public static func isNotEmpty(css: Array<CharSequence>): Bool {
        for (cs in css) {
            if (StringUtils.isNullOrEmpty(cs)) {
                return false
            }
        }
        return true
    }

    /**
     * 如果所有给定的字符序列都是 None 或为空，则返回 true。
     *
     * @param css 要测试的字符序列。
     * @return 如果所有给定的字符序列都是 None 或为空，则为 true。
     */
    public static func isNullOrEmpty(css: Array<CharSequence>): Bool {
        for (cs in css) {
            if (StringUtils.isNotEmpty(cs)) {
                return false
            }
        }
        return true
    }

    public static func isNullOrNotEmpty(cs: CharSequence): Bool {
        return !cs.toString().isEmpty()
    }

    /**
     * 如果给定的字符序列为空，则返回 true。
     *
     * @param cs
     * @return 如果给定的字符序列为空，则为 true
     */
    public static func isEmpty(cs: ToString): Bool {
        return cs.toString().size == 0
    }

    /**
     * 将一个对象集合转换为以空格分隔的字符串。
     *
     * @param collection 要转换的集合。
     * @return 包含集合中所有元素的字符串。
     */
    public static func collectionToString<T>(collection: Collection<T>): String where T <: ToString {
        return toStringBuilder(collection, " ").toString()
    }

    /**
     * 将一个对象集合转换为以指定分隔符分隔的字符串。
     *
     * @param collection 要转换的集合。
     * @param delimiter 用于分隔字符串的分隔符。
     * @return 包含集合中所有元素的 StringBuilder。
     */
    public static func toStringBuilder<T>(collection: Collection<T>, delimiter: String): StringBuilder where T <: ToString {
        let sb: StringBuilder = StringBuilder(collection.size * 20)
        appendTo(collection, delimiter, sb)
        return sb
    }

    public static func appendTo<T>(collection: Iterable<T>, sb: StringBuilder): Unit where T <: ToString {
        appendTo(collection, ", ", sb)
    }

    public static func appendTo<T>(collection: Iterable<T>, sb: StringBuilder, appendFunction: (T) -> Unit): Unit where T <: ToString {
        appendTo(collection, ", ", sb, appendFunction)
    }

    public static func appendTo<T>(collection: Iterable<T>, delimiter: String, sb: StringBuilder): Unit where T <: ToString {
        appendTo(collection, delimiter, sb, {obj => sb.append(obj)})
    }

    public static func appendTo<T>(
        collection: Iterable<T>,
        delimiter: String,
        sb: StringBuilder,
        appendFunction: (T) -> Unit
    ): Unit where T <: ToString {
        let it = collection.iterator()
        if (let Some(v) <- it.next()) {
            appendFunction(v)
        }
        while (let Some(cs) <- it.next()) {
            sb.append(delimiter)
            appendFunction(cs)
        }
    }

    public static func returnIfNotEmptyTrimmed(string: ?String): ?String {
        string?.trimAscii()
    }

    public static func nullSafeCharSequenceEquals(csOne: CharSequence, csTwo: CharSequence): Bool {
        return nullSafeCharSequenceComparator(csOne, csTwo) == Ordering.EQ
    }

    public static func nullSafeCharSequenceComparator(csOne: ?CharSequence, csTwo: ?CharSequence): Ordering {
        "${csOne}".compare("${csTwo}")
    }

    /**
     * 要求一个 {@link CharSequence} 既不是 None，也不是空。
     *
     * @param cs CharSequence
     * @param message 错误消息
     * @param <CS> CharSequence 类型
     * @return cs
     */
    public static func requireNotNullNorEmpty<CS>(cs: ?CS, message: String): CS where CS <: CharSequence {
        match (cs) {
            case Some(v) where v.toString().size > 0 => v
            case _ => throw IllegalArgumentException(message)
        }
    }

    public static func requireNullOrNotEmpty<CS>(cs: ?CS, message: String): ?CS where CS <: CharSequence {
        match (cs) {
            case Some(v) where v.toString().size > 0 => v
            case None => cs
            case _ => throw IllegalArgumentException(message)
        }
    }

    /**
     * 如果给定的字符序列不是 None，则返回其字符串表示。
     *
     * @param cs 字符序列或 None。
     * @return <code>cs</code> 的字符串表示或 None。
     */
    public static func maybeToString(cs: CharSequence): String {
        return cs.toString()
    }

    /**
     * Defined by XML 1.0 § 2.3 as:
     *  S      ::=      (#x20 | #x9 | #xD | #xA)+
     *
     * @see org/w3/TR/xml/#sec-white-space XML 1.0 § 2.3
     */
    private static let XML_WHITESPACE: Regex = Regex("[\t\n\r ]")

    public static func deleteXmlWhitespace(string: String): String {
        return XML_WHITESPACE.matcher(string).replaceAll("")
    }

    public static func appendHeading(appendable: Appendable, heading: String): Appendable {
        return appendHeading(appendable, heading, r'-')
    }

    public static func appendHeading(appendable: Appendable, heading: String, underlineChar: Rune): Appendable {
        appendable.append(heading).append(r'\n')
        for (_ in heading.toRuneArray()) {
            appendable.append(underlineChar)
        }
        return appendable.append(r'\n')
    }

    public static let PORTABLE_NEWLINE_REGEX: String = "\\r?\\n"

    public static func splitLinesPortable(input: String): ArrayList<String> {
        let lines: Array<String> = input.split(PORTABLE_NEWLINE_REGEX)
        return ArrayList<String>(lines)
    }

    public static func toStrings(charSequences: Collection<String>): ArrayList<String> {
        let res: ArrayList<String> = ArrayList<String>(charSequences.size)
        for (cs in charSequences) {
            res.append(cs)
        }
        return res
    }
}

enum StringUtilsXmlEscapeMode {
    safe
    | forAttribute
    | forAttributeApos
    | forText
}

public func anyToString(any: Any): String {
    var str = (any as ToString)?.toString() ?? "None"
    while (str.startsWith("Some(")) {
        str = str[5..str.size - 1]
    }
    str
}
