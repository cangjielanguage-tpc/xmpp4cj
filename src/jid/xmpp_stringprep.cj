/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

/**
 * XMPP 中常用的 Stringprep 操作的接口。
 * <p>
 * 相关的 RFC 文档有：
 * <ul>
 * <li>RFC 6122</li>
 * <li>draft-ietf-xmpp-6122bis-14</li>
 * </ul>
 */
public interface XmppStringprep <: Hashable & Equatable<XmppStringprep> {
    /**
     * 对 JID 的本地部分字符串执行字符串准备操作。在 RFC 6122 中，这意味着应用 Stringprep 的<i>nodeprep</i>配置文件。
     *
     * @param string 要转换的字符串。
     * @return 准备后的字符串。
     * @throws XmppStringprepException 如果出现错误。
     */
    func localprep(string: String): String

    /**
     * 对 JID 的域部分字符串执行字符串准备操作。在 RFC 6122 中，这意味着应用 Stringprep 的<i>nameprep</i>配置文件。
     *
     * @param string 要转换的字符串。
     * @return 准备后的字符串。
     * @throws XmppStringprepException 如果出现错误。
     */
    func domainprep(string: String): String

    /**
     * 对 JID 的资源部分字符串执行字符串准备操作。在 RFC 6122 中，这意味着应用 Stringprep 的<i>resourceprep</i>配置文件。
     * @param string 要转换的字符串。
     * @return 准备后的字符串。
     * @throws XmppStringprepException 如果出现错误。
     */
    func resourceprep(string: String): String
}

public class SimpleXmppStringprep <: XmppStringprep {
    private static var instance: ?SimpleXmppStringprep = None

    /**
     * simple常量。
     */
    public static let NAME: String = "simple"

    /**
     * 设置简单 XMPP Stringprep 为要使用的实现。
     */
    public static func setup(): Unit {
        XmppContext.setDefaultXmppStringprep(getInstance())
    }

    static let SimpleXmppStringprepSetup = {
        => SimpleXmppStringprep.setup()
    }()

    /**
     * 获取简单 XMPP Stringprep 的单例。
     *
     * @return 简单 XMPP Stringprep 的单例。
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
        for (c in input) {
            let forbiddenCharPos = binarySearch(excludedChars, c)
            if (forbiddenCharPos >= 0) {
                throw XmppStringprepException(
                    input,
                    "${parttype.getCapitalizedName()} must not contain '${String.fromUtf8(excludedChars[forbiddenCharPos])}'"
                )
            }
        }
    }

    /**
     * 确保输入字符串不包含 XMPP 本地部分的任何进一步被排除的字符。
     *
     * @param localpart 输入字符串。
     * @throws XmppStringprepException 如果发现进一步被排除的字符之一。
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
        let res = string.toAsciiLower()
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
     * XML 1.0 禁止某些字符。在 0x20（空格）以下，仅允许 0x09（\t）、0x0A（\n）和 0x0D（\r）。
     * 请参阅 XML 1.0 § 2.2，其中有以下产生式规则：
     *  Rune       ::=       #x9 | #xA | #xD | [#x20-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
     *
     * @param c 要检查的字符。
     * @return 如果该字符被 XML 禁止，则为 true。
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

    public override func hashCode(): Int {
        hash
    }

    public operator func ==(other: XmppStringprep): Bool {
        match (other) {
            case v: SimpleXmppStringprep => refEq(this, v)
            case _ => false
        }
    }
}

/**
 * XMPP Stringprep 异常在对字符串执行特定的 Stringprep 配置文件时表示错误。
 */
public open class XmppStringprepException <: Exception {
    private let causingString: String

    private var causingException: ?Exception = None

    /**
     * 使用给定的导致异常的字符串和异常构造一个 XMPP Stringprep 异常。
     *
     * @param causingString 导致异常的字符串。
     * @param exception 异常。
     */
    public init(causingString: String, exception: Exception) {
        super("XmppStringprepException caused by '${causingString}': ${exception}")
        this.causingException = exception
        this.causingString = causingString
    }

    /**
     * 使用给定的导致异常的字符串和异常消息构造一个 XMPP Stringprep 异常。
     *
     * @param causingString 导致异常的字符串。
     * @param message 异常消息。
     */
    public init(causingString: String, message: String) {
        super(message)
        this.causingString = causingString
    }

    /**
     * 获取导致 XMPP Stringprep 异常的字符串。
     *
     * @return 导致异常的字符串。
     */
    public func getCausingString(): String {
        return causingString
    }

    /**  
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "XmppStringprepException"
    }
}

/**
 * 输入字符串不包含域部分。
 */
public class MissingDomainpart <: XmppStringprepException {
    private MissingDomainpart(causingString: String) {
        super(causingString, "The provided string does not have a domainpart")
    }

    /**
     * 从给定的部分创建一个“缺少域部分”异常。
     *
     * @param localpart 本地部分。
     * @param resourcepart 资源部分。
     * @return 一个“缺少域部分”异常。
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

    /**  
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "MissingDomainpart"
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
     * 对输入字符串执行 localprep。
     *
     * @param string 输入字符串。
     * @return 经过 localprep 的字符串。
     * @throws XmppStringprepException 如果输入字符串无法转换。
     */
    public static func localprep(string: String): String {
        return localprep(string, XmppContext.getDefaultContext())
    }

    /**
     * 对输入字符串执行 localprep。
     *
     * @param string 输入字符串。
     * @param context XMPP JID 上下文。
     * @return 经过 localprep 的字符串。
     * @throws XmppStringprepException 如果输入字符串无法转换。
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
     * 对输入字符串执行 domainprep。
     *
     * @param string 输入字符串。
     * @return 经过 domainprep 的字符串。
     * @throws XmppStringprepException 如果输入字符串无法转换。
     */
    public static func domainprep(string: String): String {
        return domainprep(string, XmppContext.getDefaultContext())
    }

    /**
     * 对输入字符串执行 domainprep。
     *
     * @param string 输入字符串。
     * @param context XMPP JID 上下文。
     * @return 经过 domainprep 的字符串。
     * @throws XmppStringprepException 如果输入字符串无法转换。
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
     * 对输入字符串执行 resourceprep。
     *
     * @param string 输入字符串。
     * @return 经过 resourceprep 的字符串。
     * @throws XmppStringprepException 如果输入字符串无法转换。
     */
    public static func resourceprep(string: String): String {
        return resourceprep(string, XmppContext.getDefaultContext())
    }

    /**
     * 对输入字符串执行 resourceprep。
     *
     * @param string 输入字符串。
     * @param context XMPP JID 上下文。
     * @return 经过 resourceprep 的字符串。
     * @throws XmppStringprepException 如果输入字符串无法转换。
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
     * 设置最大缓存大小。
     *
     * @param size 最大缓存大小。
     */
    public static func setMaxCacheSizes(size: Int): Unit {
        NODEPREP_CACHE.setMaxCacheSize(size)
        DOMAINPREP_CACHE.setMaxCacheSize(size)
        RESOURCEPREP_CACHE.setMaxCacheSize(size)
    }

    /**
     * 如果字符串为空字符串，则抛出 XMPP Stringprep 异常。
     *
     * @param string 要检查的字符串
     * @throws XmppStringprepException 异常表示参数为空字符串
     */
    static func throwIfNullOrEmpty(string: ?String, types: XmppAddressParttype): Unit {
        if (string.isNone()) {
            throw XmppStringprepException("None", "${types.toString()} can't be None")
        }
        if (string?.isEmpty() ?? true) {
            throw XmppStringprepException("", "${types.toString()} can't be the empty string")
        }
    }
}
