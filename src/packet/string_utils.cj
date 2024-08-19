/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * A collection of utility methods for String objects.
 */
public class StringUtils {
    public static let MD5: String = "MD5"
    public static let SHA1: String = "SHA-1"
    public static let QUOTE_ENCODE: String = "&quot"
    public static let APOS_ENCODE: String = "&apos"
    public static let AMP_ENCODE: String = "&amp"
    public static let LT_ENCODE: String = "&lt"
    public static let GT_ENCODE: String = "&gt"
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
     * Escape <code>input</code> for XML.
     *
     * @param input the input to escape.
     * @return the XML escaped variant of <code>input</code>.
     */
    public static func escapeForXml(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.safe)
    }

    /**
     * Escape <code>input</code> for XML.
     *
     * @param input the input to escape.
     * @return the XML escaped variant of <code>input</code>.
     * @since 4.2
     */
    public static func escapeForXmlAttribute(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.forAttribute)
    }

    /**
     * Escape <code>input</code> for XML.
     * <p>
     * This is an optimized variant of {@link #escapeForXmlAttribute(CharSequence)} for XML where the
     * XML attribute is quoted using ''' (Apos).
     * </p>
     *
     * @param input the input to escape.
     * @return the XML escaped variant of <code>input</code>.
     */
    public static func escapeForXmlAttributeApos(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.forAttributeApos)
    }

    /**
     * Escape <code>input</code> for XML.
     *
     * @param input the input to escape.
     * @return the XML escaped variant of <code>input</code>.
     */
    public static func escapeForXmlText(input: String): String {
        return escapeForXml(input, StringUtilsXmlEscapeMode.forText)
    }
    /**
     * Escapes all necessary characters in the CharSequence so that it can be used in an XML doc.
     *
     * @param input the CharSequence to escape.
     * @return the string with appropriate characters escaped.
     */
    private static func escapeForXml(inputStr: String, xmlEscapeMode: StringUtilsXmlEscapeMode): String {
        let input = inputStr.toRuneArray()
        let len: Int64 = input.size
        let out: StringBuilder = StringBuilder(Int64(Float64(len) * 1.3))
        var toAppend: ?String
        var last: Int64 = 0
        var i: Int64 = 0
        while (i < len) {
            toAppend = None
            let ch = input[i]
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
                    out.append(input[last..i])
                }
                out.append(toAppend)
                i++
                last = i
            } else {
                i++
            }
        }
        if (last == 0) {
            return inputStr
        }
        if (i > last) {
            out.append(input[last..i])
        }
        return out.toString()
    }

    /**
     * Encodes an array of bytes as String representation of hexadecimal.
     *
     * @param bytes an array of bytes to convert to a hex string.
     * @return generated hex string.
     */
    public static func encodeHex(bytes: Array<Byte>): String {
        return toHexString(bytes)
    }

    public static func toUtf8Bytes(string: String): Array<Byte> {
        return string.toArray()
    }

    /**
     * Returns a random String of numbers and letters (lower and upper case) of the specified length.
     * The method uses the Random class that is built-in to Cangjie.
     * This means that the output is only pseudo random, i.e., each number is
     * mathematically generated so is not truly random.<p>
     *
     * The specified length must be at least one. If not, the method will return
     * None.
     *
     * @param length the desired length of the random String to return.
     * @return a random String of numbers and letters of the specified length.
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
     * Generate a secure random string with is human readable. The resulting string consists of 24 upper case characters
     * from the Latin alphabet and numbers without '0' and 'O', grouped into 4-characters chunks, e.g.
     * "TWNK-KD5Y-MT3T-E1GS-DRDB-KVTW". The characters are randomly selected by a cryptographically secure pseudorandom
     * number generator (CSPRNG).
     * <p>
     * The string can be used a backup "code" for secrets,
     * and is in fact the same as the one backup code specified in XEP-0373 and the one used by the
     * <a href="github/com/open-keychain/open-keychain/wiki/Backups">Backup Format v2 of OpenKeychain</a>.
     * </p>
     *
     * @see xep-0373/#backup-encryption XEP-0373 §5.4 Encrypting the Secret Key Backup
     * @return a human readable secure random string.
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
        let randomChars: Array<Byte> = Array<Byte>(length, item: 0)
        for (i in 0..length) {
            let index: Int64 = random.nextInt64(UNAMBIGUOUS_NUMBERS_AND_LETTERS.size)
            randomChars[i] = UNAMBIGUOUS_NUMBERS_AND_LETTERS[index]
        }
        return unsafe { String.fromUtf8Unchecked(randomChars) }
    }

    /**
     * Returns true if CharSequence is not None and is not empty, false otherwise.
     * Examples:
     *    isNotEmpty(None) - false
     *    isNotEmpty("") - false
     *    isNotEmpty(" ") - true
     *    isNotEmpty("empty") - true
     *
     * @param cs checked CharSequence
     * @return true if string is not None and is not empty, false otherwise
     */
    public static func isNotEmpty<T>(cs: ?T): Bool where T <: ToString {
        return !isNullOrEmpty(cs)
    }

    /**
     * Returns true if the given CharSequence is None or empty.
     *
     * @param cs
     * @return true if the given CharSequence is None or empty
     */
    public static func isNullOrEmpty<T>(cs: ?T): Bool where T <: ToString {
        return cs.isNone() || isEmpty(cs.getOrThrow())
    }

    /**
     * Returns true if all given CharSequences are not empty.
     *
     * @param css the CharSequences to test.
     * @return true if all given CharSequences are not empty.
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
     * Returns true if all given CharSequences are either None or empty.
     *
     * @param css the CharSequences to test.
     * @return true if all given CharSequences are None or empty.
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
     * Returns true if the given CharSequence is empty.
     *
     * @param cs
     * @return true if the given CharSequence is empty
     */
    public static func isEmpty(cs: ToString): Bool {
        return cs.toString().size == 0
    }

    /**
     * Transform a collection of objects to a whitespace delimited String.
     *
     * @param collection the collection to transform.
     * @return a String with all the elements of the collection.
     */
    public static func collectionToString<T>(collection: Collection<T>): String where T <: ToString {
        return toStringBuilder(collection, " ").toString()
    }

    /**
     * Transform a collection of objects to a delimited String.
     *
     * @param collection the collection to transform.
     * @param delimiter the delimiter used to delimit the Strings.
     * @return a StringBuilder with all the elements of the collection.
     */
    public static func toStringBuilder<T>(collection: Collection<T>, delimiter: String): StringBuilder where T <: ToString {
        let sb: StringBuilder = StringBuilder(collection.size * 20)
        appendTo(collection, delimiter, sb)
        return sb
    }

    public static func appendTo<T>(collection: Collection<T>, sb: StringBuilder): Unit where T <: ToString {
        appendTo(collection, ", ", sb)
    }

    public static func appendTo<T>(collection: Collection<T>, sb: StringBuilder, appendFunction: (T) -> Unit): Unit where T <: ToString {
        appendTo(collection, ", ", sb, appendFunction)
    }

    public static func appendTo<T>(collection: Collection<T>, delimiter: String, sb: StringBuilder): Unit where T <: ToString {
        appendTo(collection, delimiter, sb, {obj => sb.append(obj)})
    }

    public static func appendTo<T>(
        collection: Collection<T>,
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

    public static func returnIfNotEmptyTrimmed(string: String): ?String {
        let trimmedString: String = string.trimAscii()
        if (trimmedString.size > 0) {
            return trimmedString
        } else {
            return None
        }
    }

    public static func nullSafeCharSequenceEquals(csOne: CharSequence, csTwo: CharSequence): Bool {
        return nullSafeCharSequenceComparator(csOne, csTwo) == Ordering.EQ
    }

    public static func nullSafeCharSequenceComparator(csOne: ?CharSequence, csTwo: ?CharSequence): Ordering {
        "${csOne}".compare("${csTwo}")
    }

    /**
     * Require a {@link CharSequence} to be neither None, nor empty.
     *
     * @param cs CharSequence
     * @param message error message
     * @param <CS> CharSequence type
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
     * Return the String representation of the given char sequence if it is not None.
     *
     * @param cs the char sequence or None.
     * @return the String representation of <code>cs</code> or None.
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
