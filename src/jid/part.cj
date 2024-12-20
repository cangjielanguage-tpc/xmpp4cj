/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.jid

/**
 * public abstract class Part <: ToString & Hashable & Equatable<Part>
 *
 * JID资源实体。
 */
public abstract class Part <: ToString & Hashable & Equatable<Part> {
    private let part: String

    /**
     * 构造方法。
     *
     * @param part String数据。
     */
    protected Part(part: String) {
        this.part = part
    }

    public override func toString(): String {
        return part
    }

    public operator override func ==(other: Part): Bool {
        return part.toString() == other.toString()
    }

    public operator override func !=(other: Part): Bool {
        return part.toString() != other.toString()
    }

    @OverflowWrapping
    public override func hashCode(): Int {
        return part.hashCode()
    }

    /**
     * 判断传入内容的长度。
     *
     * @param string 需要校验的内容。
     * @throw XmppStringprepException 长度大于1023或者为空的时候抛异常。
     */
    protected static func assertNotLongerThan1023BytesOrEmpty(string: String): Unit {
        let bytes = string

        // 这里最好抛出XmppStringprepException而不是IllegalArgumentException，因为用户不期望IAE，这也让用户更容易处理错误。
        if (bytes.size > 1023) {
            throw XmppStringprepException(string, "Given string is longer then 1023 bytes")
        } else if (bytes.size == 0) {
            throw XmppStringprepException(string, "Argument can't be the empty string")
        }
    }
}

/**
 * XMPP 地址（JID）的“本地部分”。本地部分是 XMPP 地址中第一个“@”符号之前的部分，通常在 XMPP 服务中标识用户（或 XMPP 实体）。它也常被称为“用户名”，但请注意，用于登录的实际用户名可能与用户 JID 的最终本地部分不同。
 * <p>
 * 你可以使用 {@link #from(String)} 从字符串创建这个类的实例。
 * </p>
 *
 * @see RFC 6122 § 2.3. 本地部分
 */
public class Localpart <: Part {
    private var unescapedCache: ?String = None

    private init(localpart: String) {
        super(localpart)
    }

    /**
     * 返回这个本地部分的<b>未转义</b>字符串表示形式。
     * <p>
     * 由于所需的字符串准备（stringprep）配置文件不允许在 JID 的本地部分中使用某些 Unicode 码点，因此在实际的 JID 中使用时这些码点需要进行转义。JID 的未转义表示形式仅用于向人类用户展示或用于与非 XMPP 系统进行交互。
     * </p>
     *
     * @return 这个 JID 的未转义字符串表示形式。
     * @see xmpp.jid.Jid#asUnescapedString()
     */
    public func asUnescapedString(): String {
        if (unescapedCache.isSome()) {
            return unescapedCache()
        }
        unescapedCache = XmppStringUtils.unescapeLocalpart(toString())
        return unescapedCache()
    }

    /**
     * 类似于 {@link #from(String)}，但如果输入不是有效的本地部分，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为本地部分（Localpart）的字符序列。
     * @return 如果没有异常发生，则返回本地部分。
     * @throws IllegalArgumentException 如果给定的输入不是有效的本地部分。
     * @see #from(String)
     */
    public static func fromOrThrowUnchecked(cs: String): Localpart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 类似于 {@link #fromUnescaped(String)}，但如果输入不是有效的本地部分，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为本地部分（Localpart）的字符序列。
     * @return 如果没有异常发生，则返回本地部分。
     * @see #from(String)
     */
    public static func fromUnescapedOrThrowUnchecked(cs: String): Localpart {
        try {
            return fromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的字符序列获取一个本地部分（Localpart），如果输入不是有效的本地部分，则返回 None。
     *
     * @param cs 输入的字符序列。
     * @return 一个本地部分或 None。
     */
    public static func formUnescapedOrNull(cs: String): ?Localpart {
        try {
            return fromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从未转义的字符串获取一个本地部分（Localpart）。
     *
     * @param unescapedLocalpart 一个未转义的表示本地部分的字符串。
     * @return 一个本地部分。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func fromUnescaped(unescapedLocalpart: String): Localpart {
        let escapedLocalpartString: ?String = XmppStringUtils.escapeLocalpart(unescapedLocalpart)
        return froms(escapedLocalpartString)
    }

    /**
     * 从给定的字符序列获取一个本地部分（Localpart），如果输入不是有效的本地部分，则返回 None。
     *
     * @param cs 输入的字符序列。
     * @return 一个本地部分或 None。
     */
    public static func fromOrNull(cs: String): ?Localpart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 获取表示输入字符串的本地部分。
     *
     * @param localpart 输入字符串。
     * @return 本地部分。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(localpart: ?String): Localpart {
        return froms(localpart, XmppContext.getDefaultContext())
    }

    /**
     * 获取表示输入字符串的本地部分。
     *
     * @param localpart 输入字符串。
     * @param context XMPP 上下文。
     * @return 本地部分。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(localpart: ?String, context: XmppContext): Localpart {
        let localpartStr = XmppStringPrepUtil.localprep(localpart, context)
        // 首先准备String，然后确保*结果的限制*
        assertNotLongerThan1023BytesOrEmpty(localpartStr)
        return Localpart(localpartStr)
    }
}

/**
 * XMPP 地址（JID）的“资源部分”。
 * <p>
 * 你可以使用 {@link #from(String)} 从字符串创建这个类的实例。
 * </p>
 *
 * @see RFC 6122 § 2.4. 资源部分
 */
public class Resourcepart <: Part {
    /**
     * 空资源部分。
     * <p>
     * 这个空资源部分是由空字符串表示的部分。在你有一个不允许为 None 值的资源部分集合，但又要处理“没有资源”的情况时，这很有用。
     * </p>
     */
    public static let EMPTY: Resourcepart = Resourcepart("")

    private Resourcepart(resource: String) {
        super(resource)
    }

    /**
     * 从给定的字符序列获取一个资源部分（Resourcepart），如果输入不是有效的资源部分，则返回 None。
     *
     * @param cs 输入的字符序列。
     * @return 一个资源部分或 None。
     */
    public static func fromOrNull(cs: String): ?Resourcepart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 类似于 {@link #from(String)}，但如果输入不是有效的资源部分，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为资源部分（Resourcepart）的字符序列。
     * @return 如果没有异常发生，则返回资源部分。
     * @throws IllegalArgumentException 如果给定的输入不是有效的资源部分。
     * @see #from(String)
     */
    public static func fromOrThrowUnchecked(cs: String): Resourcepart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 获取表示输入字符串的资源部分。
     *
     * @param resource 输入字符串。
     * @return 资源部分。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(resource: ?String): Resourcepart {
        return froms(resource, XmppContext.getDefaultContext())
    }

    /**
     * 获取表示输入字符串的资源部分。
     *
     * @param resource 输入字符串。
     * @param context XMPP 上下文。
     * @return 资源部分。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(resource: ?String, context: XmppContext): Resourcepart {
        let str = XmppStringPrepUtil.resourceprep(resource, context)
        // 首先准备String，然后确保*结果的限制*
        assertNotLongerThan1023BytesOrEmpty(str)
        return Resourcepart(str)
    }
}

/**
 * XMPP 地址（JID）的“域部分”。
 * <p>
 * 你可以使用 {@link #from(String)} 从字符串创建这个类的实例。
 * </p>
 *
 * @see RFC 6122 § 2.2. 域部分
 */
public class Domainpart <: Part {
    private Domainpart(domain: String) {
        super(domain)
    }

    /**
     * 从给定的字符序列获取一个域部分（Domainpart），如果输入不是有效的域部分，则返回 None。
     *
     * @param cs 输入的字符序列。
     * @return 一个域部分或 None。
     */
    public static func fromOrNull(cs: String): ?Domainpart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 类似于 {@link #from(String)}，但如果输入不是有效的域部分，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为域部分（Domainpart）的字符序列。
     * @return 如果没有异常发生，则返回域部分。
     * @throws IllegalArgumentException 如果给定的输入不是有效的域部分。
     * @see #from(String)
     */
    public static func fromOrThrowUnchecked(cs: String): Domainpart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 获取表示输入字符串的域部分。
     *
     * @param domain 输入字符串。
     * @return 域部分。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(domain: String): Domainpart {
        return froms(domain, XmppContext.getDefaultContext())
    }

    /**
     * 获取表示输入字符串的域部分。
     *
     * @param domainStr 输入字符串。
     * @param context XMPP 上下文。
     * @return 域部分。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(domainStr: String, context: XmppContext): Domainpart {
        //RFC 6122§2.2“如果域部分包含被视为标签的最后一个字符
        //用[IDNA2003]或[DNS]分隔（点），此字符必须被删除…”
        var domain = domainStr
        if (domain.size > 0 && domain[domain.size - 1] == b'.') {
            domain = domain[..domain.size]
        }
        domain = XmppStringPrepUtil.domainprep(domain, context)
        // 首先准备String，然后确保*结果的限制*
        assertNotLongerThan1023BytesOrEmpty(domain)
        return Domainpart(domain)
    }
}
