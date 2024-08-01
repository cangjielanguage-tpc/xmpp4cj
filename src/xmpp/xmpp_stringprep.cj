/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

/**
 * Interface for commonly used Stringprep operations used in XMPP.
 * <p>
 * The relevant RFCs are:
 * <ul>
 * <li>RFC 6122</li>
 * <li>draft-ietf-xmpp-6122bis-14</li>
 * </ul>
 *
 */
public interface XmppStringprep <: Hashable & Equatable<XmppStringprep> {

    /**
     * Performs String preparation on the localpart String of a JID. In RFC 6122 terms this means applying the
     * <i>nodeprep</i> profile of Stringprep.
     *
     * @param string the String to transform.
     * @return the prepared String.
     * @throws XmppStringprepException if there is an error.
     */
    func localprep(string: String): String

    /**
     * Performs String preparation on the domainpart String of a JID. In RFC 61ss terms, this means applying the
     * <i>nameprep</i> profile of Stringprep.
     *
     * @param string the String to transform.
     * @return the prepared String.
     * @throws XmppStringprepException if there is an error.
     */
    func domainprep(string: String): String

    /**
     * Performs String preparation on the resourcepart String of a JID. In RFC 6122 terms this means applying the <i>resourceprep</i> profile of Stringprep.
     * @param string the String to transform.
     * @return the prepared String.
     * @throws XmppStringprepException if there is an error.
     */
    func resourceprep(string: String): String
}

public class SimpleXmppStringprep <: XmppStringprep {
    private static var instance: ?SimpleXmppStringprep = None

    public static let NAME: String = "simple"

    /**
     * Setup Simple XMPP Stringprep as implementation to use.
     */
    public static func setup(): Unit {
        XmppContext.setDefaultXmppStringprep(getInstance())
    }

    static let SimpleXmppStringprepSetup = {
        => SimpleXmppStringprep.setup()
    }()

    /**
     * Get the Simple XMPP Stringprep singleton.
     *
     * @return the simple XMPP Stringprep singleton.
     */
    public static func getInstance(): SimpleXmppStringprep {
        return if (let Some(v) <- instance) {
            v
        } else {
            let v = SimpleXmppStringprep()
            instance = v
            v
        }
    }

    private SimpleXmppStringprep() {}

    /**
     * From RFC 7622 § 3.3.1
     */
    private static let LOCALPART_FURTHER_EXCLUDED_CHARACTERS: Array<Byte> = [
        b'"', // U+0022 (QUOTATION MARK) , i.e., "
        b'&', // U+0026 (AMPERSAND), i.e., &
        b'\'', // U+0027 (APOSTROPHE), i.e., '
        b'/', // U+002F (SOLIDUS), i.e., /
        b':', // U+003A (COLON), i.e., :
        b'<', // U+003C (LESS-THAN SIGN), i.e., <
        b'>', // U+003E (GREATER-THAN SIGN), i.e., >
        b'@' // U+0040 (COMMERCIAL AT), i.e., @
    ]

    private static let USERNAME_CASE_MAPPED_EXCLUDED_CHARACTERS: Array<Byte> = [b' ' // U+0020 (SPACE) - forbidden by PRECIS IdentifierClass.
    ]

    // Combine LOCALPART_FURTHER_EXCLUDED_CHARACTERS and USERNAME_CASE_MAPPED_EXCLUDED_CHARACTERS into LOCALPART_EXCLUDED_CHARACTERS.
    private static let LOCALPART_EXCLUDED_CHARACTERS: Array<Byte>

    static init() {
        LOCALPART_EXCLUDED_CHARACTERS = LOCALPART_FURTHER_EXCLUDED_CHARACTERS |> concat<Byte>(
            USERNAME_CASE_MAPPED_EXCLUDED_CHARACTERS) |> collectArray
        stableSort(LOCALPART_EXCLUDED_CHARACTERS)
    }

    public override func localprep(string: String): String {
        let str = simpleStringprep(string)

        ensurePartDoesNotContain(XmppAddressParttype.localpart, string, LOCALPART_EXCLUDED_CHARACTERS)
        ensureValid(XmppAddressParttype.localpart, string)

        return str
    }

    private static func ensurePartDoesNotContain(parttype: XmppAddressParttype, input: String,
        excludedChars: Array<Byte>): Unit {
        // assert isSorted(excludedChars))

        for (c in input) {
            let forbiddenCharPos = binarySearch(excludedChars, c)
            if (forbiddenCharPos >= 0) {
                throw XmppStringprepException(input,
                    "${parttype.getCapitalizedName()} must not contain '${excludedChars[forbiddenCharPos]}'")
            }
        }
    }

    /**
     * Ensure that the input string does not contain any of the further excluded characters of XMPP localparts.
     *
     * @param localpart the input string.
     * @throws XmppStringprepException if one of the further excluded characters is found.
     * @see RFC 7622 § 3.3.1
     */
    public static func ensureLocalpartDoesNotIncludeFurtherExcludedCharacters(localpart: String): Unit {
        ensurePartDoesNotContain(XmppAddressParttype.localpart, localpart, LOCALPART_FURTHER_EXCLUDED_CHARACTERS)
    }

    public override func domainprep(string: String): String {
        let str = simpleStringprep(string)
        ensureValid(XmppAddressParttype.localpart, string)
        return str
    }

    public override func resourceprep(string: String): String {
        // rfc6122-bis specifies that resourceprep uses saslprep-bis OpaqueString Profile which says that
        // "Uppercase and titlecase characters MUST NOT be mapped to their lowercase equivalents."

        ensureValid(XmppAddressParttype.resourcepart, string)

        return string
    }

    private static func simpleStringprep(string: String): String {
        let res = string.toLower()
        return res
    }

    private static func ensureValid(parttype: XmppAddressParttype, input: String): Unit {
        for (i in 0..input.size) {
            let c = input[i]
            let disallowedAsciiChar = isDisallowedAsciiChar(c)
            if (disallowedAsciiChar) {
                throw XmppStringprepException(input,
                    "${parttype.getCapitalizedName()} does contain disallowed ASCII character at pos ${i}")
            }
        }
    }

    /**
     * XML 1.0 disallows certain characters. Below 0x20 (SPACE) only 0x09 (\t), 0x0A (\n), and 0x0D (\r) are allowed.
     * See XML 1.0 § 2.2 which has the following production rule:
     *  Rune       ::=       #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
     *
     * @param c the character is check.
     * @return true if the character is disallowed by XML.
     */
    private static func isDisallowedAsciiChar(c: Byte): Bool {
        if (c >= 0x20) {
            return false
        }

        return match (c) {
            case 0x09 | 0x0A | 0X0D => false
            case _ => true
        }
    }

    private let hash = DateTime.now().hashCode()
    public func hashCode(): Int {
        hash
    }
    public operator func ==(other: XmppStringprep): Bool {
        match (other) {
            case v: SimpleXmppStringprep => refEq(this, v)
            case _ => false
        }
    }
    public operator func !=(other: XmppStringprep): Bool {
        !(this == other)
    }
}

/**
 * XMPP Stringprep exceptions signal an error when performing a particular Stringprep profile on a String.
 */
public open class XmppStringprepException <: Exception {
    private let causingString: String
    private var causingException: ?Exception = None

    /**
     * Construct a XMPP Stringprep exception with the given causing String and exception.
     *
     * @param causingString the String causing the exception.
     * @param exception the exception.
     */
    public init(causingString: String, exception: Exception) {
        super("XmppStringprepException caused by '${causingString}': ${exception}")
        this.causingException = exception
        this.causingString = causingString
    }

    /**
     * Construct a XMPP Stringprep exception with the given causing String and exception message.
     *
     * @param causingString the String causing the exception.
     * @param message the message of the exception.
     */
    public init(causingString: String, message: String) {
        super(message)
        this.causingString = causingString
    }

    /**
     * Get the String causing the XMPP Stringprep exception.
     *
     * @return the causing String.
     */
    public func getCausingString(): String {
        return causingString
    }
}

/**
 * The input string does not contain a domainpart.
 */
public class MissingDomainpart <: XmppStringprepException {
    private MissingDomainpart(causingString: String) {
        super(causingString, "The provided string does not have a domainpart")
    }

    /**
     * Create a "missing domainpart" exception from the give parts.
     *
     * @param localpart the localpart.
     * @param resourcepart the resourcepart.
     * @return a "missing domanipart" exception.
     */
    public static func froms(localpart: ?String, resourcepart: ?String): MissingDomainpart {
        let causingString: StringBuilder = StringBuilder()
        if (let Some(v) <- localpart) {
            causingString.append(v)
            causingString.append('@')
        }
        if (let Some(v) <- resourcepart) {
            causingString.append('/')
            causingString.append(v)
        }
        return MissingDomainpart(causingString.toString())
    }
}

public class XmppStringPrepUtil {
    static init() {
        // Ensure that there is always at least the simple XMPP stringprep implementation active
        SimpleXmppStringprep.setup()
    }

    private static let NODEPREP_CACHE: Cache<String, String> = LruCache<String, String>(100)
    private static let DOMAINPREP_CACHE: Cache<String, String> = LruCache<String, String>(100)
    private static let RESOURCEPREP_CACHE: Cache<String, String> = LruCache<String, String>(100)

    /**
     * Perform localprep on the input String.
     *
     * @param string the input String.
     * @return the localpreped String.
     * @throws XmppStringprepException if the input String can not be transformed.
     */
    public static func localprep(string: String): String {
        return localprep(string, XmppContext.getDefaultContext())
    }

    /**
     * Perform localprep on the input String.
     *
     * @param string the input String.
     * @param context the XMPP JID context.
     * @return the localpreped String.
     * @throws XmppStringprepException if the input String can not be transformed.
     */
    public static func localprep(strings: ?String, context: XmppContext): String {
        throwIfNullOrEmpty(strings, XmppAddressParttype.localpart)
        let string = strings()
        if (context.isCachingEnabled()) {
            if (let Some(res) <- NODEPREP_CACHE.lookup(string)) {
                return res
            }
        }

        let res = context.xmppStringprep.localprep(string)

        if (context.isCachingEnabled()) {
            NODEPREP_CACHE.put(string, res)
        }
        return res
    }

    /**
     * Perform domainprep on the input String.
     *
     * @param string the input String.
     * @return the domainprep String.
     * @throws XmppStringprepException if the input String can not be transformed.
     */
    public static func domainprep(string: String): String {
        return domainprep(string, XmppContext.getDefaultContext())
    }

    /**
     * Perform domainprep on the input String.
     *
     * @param string the input String.
     * @param context the XMPP JID context.
     * @return the domainprep String.
     * @throws XmppStringprepException if the input String can not be transformed.
     */
    public static func domainprep(strings: ?String, context: XmppContext): String {
        throwIfNullOrEmpty(strings, XmppAddressParttype.domainpart)
        let string = strings()
        if (context.isCachingEnabled()) {
            if (let Some(res) <- DOMAINPREP_CACHE.lookup(string)) {
                return res
            }
        }

        let res = context.xmppStringprep.domainprep(string)

        if (context.isCachingEnabled()) {
            DOMAINPREP_CACHE.put(string, res)
        }
        return res
    }

    /**
     * Perform resourceprep on the input String.
     *
     * @param string the input String.
     * @return the resourceprep String.
     * @throws XmppStringprepException if the input String can not be transformed.
     */
    public static func resourceprep(string: String): String {
        return resourceprep(string, XmppContext.getDefaultContext())
    }

    /**
     * Perform resourceprep on the input String.
     *
     * @param string the input String.
     * @param context the XMPP JID context.
     * @return the resourceprep String.
     * @throws XmppStringprepException if the input String can not be transformed.
     */
    public static func resourceprep(strings: ?String, context: XmppContext): String {
        throwIfNullOrEmpty(strings, XmppAddressParttype.resourcepart)
        let string = strings()
        if (context.isCachingEnabled()) {
            if (let Some(res) <- RESOURCEPREP_CACHE.lookup(string)) {
                return res
            }
        }

        let res = context.xmppStringprep.resourceprep(string)

        if (context.isCachingEnabled()) {
            RESOURCEPREP_CACHE.put(string, res)
        }
        return res
    }

    /**
     * Set the maximum cache sizes.
     *
     * @param size the maximum cache size.
     */
    public static func setMaxCacheSizes(size: Int): Unit {
        NODEPREP_CACHE.setMaxCacheSize(size)
        DOMAINPREP_CACHE.setMaxCacheSize(size)
        RESOURCEPREP_CACHE.setMaxCacheSize(size)
    }

    /**
     * Throws a XMPP Stringprep exception if string is the empty string.
     *
     * @param string the string to check
     * @throws XmppStringprepException exception telling that the argument was the empty string
     */
    static func throwIfNullOrEmpty(string: ?String, types: XmppAddressParttype): Unit {
        if (string.isNone()) {
            throw XmppStringprepException("None", "${types.getCapitalizedName()} can't be null")
        }
        if (string?.isEmpty() ?? true) {
            throw XmppStringprepException("", "${types.getCapitalizedName()} can't be the empty string")
        }
    }
}
