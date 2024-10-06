/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

/**
 * 创建 JID（XMPP 地址）的 API，从字符串和字符序列中创建。
 * <p>
 * 如果输入是由用户生成的，例如从某种用户界面捕获的，应该使用 #fromUnescaped(String)。这允许用户输入未转义的 JID 值。你可以使用 JidUtil#isValidEntityBareJid(String) 来查询，例如在用户输入时，给定的字符串是否是一个有效的裸 JID。
 * </p>
 * <p>
 * JID 从 XMPP 源接收的输入创建时应该使用 #froms(String)。
 * </p>
 * <p>
 * JidCreate 使用缓存来高效地构造 JID，但不能保证相同的字符串总是产生相同的 Jid 实例。
 * </p>
 *
 * @see Jid
 */
public class JidCreate {
    private static let JID_CACHE: Cache<JidStringAndStringprep, Jid> = LruCache<JidStringAndStringprep, Jid>(100)

    private static let BAREJID_CACHE: Cache<JidStringAndStringprep, BareJid> = LruCache<JidStringAndStringprep, BareJid>(
        100)

    private static let ENTITYJID_CACHE: Cache<JidStringAndStringprep, EntityJid> = LruCache<JidStringAndStringprep, EntityJid>(
        100)

    private static let FULLJID_CACHE: Cache<JidStringAndStringprep, FullJid> = LruCache<JidStringAndStringprep, FullJid>(
        100)

    private static let ENTITY_BAREJID_CACHE: Cache<JidStringAndStringprep, EntityBareJid> = LruCache<JidStringAndStringprep, EntityBareJid>(
        100)

    private static let ENTITY_FULLJID_CACHE: Cache<JidStringAndStringprep, EntityFullJid> = LruCache<JidStringAndStringprep, EntityFullJid>(
        100)

    private static let DOMAINJID_CACHE: Cache<JidStringAndStringprep, DomainBareJid> = LruCache<JidStringAndStringprep, DomainBareJid>(
        100)

    private static let DOMAINRESOURCEJID_CACHE: Cache<JidStringAndStringprep, DomainFullJid> = LruCache<JidStringAndStringprep, DomainFullJid>(
        100)

    /**
     * 从给定的部分获取一个 Jid。
     * <p>
     * 只有域部分是必需的。
     * </p>
     *
     * @param localpart 可选的本地部分。
     * @param domainpart 必需的域部分。
     * @param resource 可选的资源部分。
     * @return 由给定部分组成的 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(localpart: ?String, domainpart: String, resource: ?String): Jid {
        return froms(localpart, domainpart, resource, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的部分获取一个 Jid。
     * <p>
     * 只有域部分是必需的。
     * </p>
     *
     * @param localpart 可选的本地部分。
     * @param domainpart 必需的域部分。
     * @param resource 可选的资源部分。
     * @param context XMPP 上下文。
     * @return 由给定部分组成的 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func froms(localpart: ?String, domainpart: String, resource: ?String, context: XmppContext): Jid { // Every JID must come with an domainpart.
        if (domainpart.isEmpty()) {
            throw MissingDomainpart.froms(localpart, resource);
        }
        let jid: String = XmppStringUtils.completeJidFrom(localpart, domainpart, resource)
        return froms(localpart, domainpart, resource, jid, context)
    }

    /**
     * 从给定的部分获取一个 Jid。
     *
     * @param localpart 可选的本地部分。
     * @param domainpart 必需的域部分。
     * @param resource 可选的资源部分。
     * @param jidString 已解析的原始字符串。
     * @param context XMPP 上下文。
     * @return 由给定部分组成的 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    private static func froms(localpart: ?String, domainpart: String, resource: ?String, jidString: String,
        context: XmppContext): Jid {
        // 每个JID都必须带有域名部分。
        if (domainpart.isEmpty()) {
            throw MissingDomainpart.froms(localpart, resource)
        }

        // 提供的jidString必须等于组装好的零件。
        if (jidString != XmppStringUtils.completeJidFrom(localpart, domainpart, resource)) {
            throw Exception("The provided jidString does not match the assembled parts")
        }

        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            let jidstr = JidStringAndStringprep(jidString, context)
            if (let Some(jid) <- JID_CACHE.lookup(jidstr)) {
                return jid
            }
            jidStringAndStringprep = jidstr
        }

        let jid: Jid = match ((localpart, resource)) {
            case (Some(l), Some(r)) => LocalDomainAndResourcepartJid(l, domainpart, r, context)
            case (Some(l), None) => LocalAndDomainpartJid(l, domainpart, context)
            case (None, None) => DomainpartJid(domainpart, context)
            case (None, Some(r)) => DomainAndResourcepartJid(domainpart, r, context)
        }

        if (let Some(v) <- jidStringAndStringprep) {
            JID_CACHE.put(v, jid)
        }
        return jid
    }

    /**
     * 类似于 #froms(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 Jid 的字符序列。
     * @return 如果没有异常发生，则返回 Jid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #froms(String)
     */
    public static func fromOrThrowUnchecked(cs: String): Jid {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.toString())
        }
    }

    /**
     * 从给定的字符串获取一个 Jid。
     *
     * @param jidString 输入字符串。
     * @return 由输入字符串表示的 Jid。
     * @throws XmppStringprepException 如果发生错误。
     * @see #froms(String)
     */
    public static func froms(jidString: String): Jid {
        return froms(jidString, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的字符串获取一个 Jid。
     *
     * @param jidString 输入字符串。
     * @param context XMPP 上下文。
     * @return 由输入字符串表示的 Jid。
     * @throws XmppStringprepException 如果发生错误。
     * @see #froms(String)
     */
    public static func froms(jidString: String, context: XmppContext): Jid {
        let localpart: ?String = XmppStringUtils.parseLocalpart(jidString)
        let domainpart: String = XmppStringUtils.parseDomain(jidString)
        let resource: ?String = XmppStringUtils.parseResource(jidString)
        try {
            return froms(localpart, domainpart, resource, jidString, context)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jidString, e)
        }
    }

    /**
     * 从给定的字符串获取一个 Jid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func fromOrNull(cs: String): ?Jid {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 类似于 #fromUnescaped(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 Jid 的字符序列。
     * @return 如果没有异常发生，则返回 Jid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #fromUnescaped(String)
     */
    public static func fromUnescapedOrThrowUnchecked(cs: String): Jid {
        try {
            return fromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.toString())
        }
    }

    /**
     * 从未转义的字符串获取一个 Jid。
     *
     * @param unescapedJidString 未转义的表示 JID 的字符串。
     * @return Jid。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func fromUnescaped(unescapedJidString: String): Jid {
        var localpart: ?String = XmppStringUtils.parseLocalpart(unescapedJidString)
        // Some as froms(String), but we escape the localpart
        localpart = XmppStringUtils.escapeLocalpart(localpart)

        let domainpart: String = XmppStringUtils.parseDomain(unescapedJidString)
        let resource: ?String = XmppStringUtils.parseResource(unescapedJidString)
        try {
            return froms(localpart, domainpart, resource)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(unescapedJidString, e)
        }
    }

    /**
     * 从给定的字符串获取一个 Jid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func fromUnescapedOrNull(cs: String): ?Jid {
        try {
            return fromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从 URL 编码的字符串获取一个 Jid。
     *
     * @param cs 表示 URL 编码的 JID 的字符串。
     * @return Jid。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func fromUrlEncoded(cs: String): Jid {
        let decoded: String = urlDecode(cs)
        return froms(decoded)
    }

    /**
     * 类似于 #bareFrom(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 BareJid 的字符序列。
     * @return 如果没有异常发生，则返回 BareJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #bareFrom(String)
     */
    public static func bareFromOrThrowUnchecked(cs: String): BareJid {
        try {
            return bareFrom(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的字符串获取一个 BareJid。
     *
     * @param jid 输入字符串。
     * @return 表示给定字符串的裸 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func bareFrom(jid: String): BareJid {
        return bareFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的字符串获取一个 BareJid。
     *
     * @param jid 输入字符串。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的裸 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func bareFrom(jid: String, context: XmppContext): BareJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(jid, context)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            if (let Some(bid) <- BAREJID_CACHE.lookup(jidstr)) {
                return bid
            }
        }

        let localpart: ?String = XmppStringUtils.parseLocalpart(jid)
        let domainpart: String = XmppStringUtils.parseDomain(jid)
        let bareJid: BareJid = try {
            if (localpart.isNone() || (localpart?.size ?? 0) == 0) {
                DomainpartJid(domainpart, context)
            } else {
                LocalAndDomainpartJid(localpart(), domainpart, context)
            }
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jid, e)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            BAREJID_CACHE.put(jidstr, bareJid)
        }
        return bareJid
    }

    /**
     * 从可选的本地部分和链接 DomainBareJid 构造一个 BareJid。
     *
     * @param localpart 可选的本地部分。
     * @param domainBareJid 域裸 JID。
     * @return 裸 JID。
     */
    public static func bareFrom(localpart: Localpart, domainBareJid: DomainBareJid): BareJid {
        return bareFrom(localpart, domainBareJid.getDomain())
    }

    /**
     * 从可选的本地部分和 Domainpart 构造一个 BareJid。
     *
     * @param localpart 可选的本地部分。
     * @param domain 域部分。
     * @return 由给定部分构造的裸 JID。
     */
    public static func bareFrom(localpart: ?Localpart, domain: Domainpart): BareJid {
        if (let Some(v) <- localpart) {
            return LocalAndDomainpartJid(v, domain)
        } else {
            return DomainpartJid(domain)
        }
    }

    /**
     * 从给定的字符串获取一个 BareJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func bareFromOrNull(cs: String): ?BareJid {
        try {
            return bareFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从 URL 编码的字符串获取一个 BareJid。
     *
     * @param cs 表示 URL 编码的裸 JID 的字符串。
     * @return 裸 JID。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func bareFromUrlEncoded(cs: String): BareJid {
        let decoded: String = urlDecode(cs)
        return bareFrom(decoded)
    }

    /**
     * 类似于 #fullFrom(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 FullJid 的字符序列。
     * @return 如果没有异常发生，则返回 FullJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #fullFrom(String)
     */
    public static func fullFromOrThrowUnchecked(cs: String): FullJid {
        try {
            return fullFrom(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的字符串获取一个 FullJid。
     *
     * @param jid JID 的字符串。
     * @return 表示输入字符串的完整 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func fullFrom(jid: String): FullJid {
        return fullFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的字符串获取一个 FullJid。
     *
     * @param jid JID 的字符串。
     * @param context XMPP 上下文。
     * @return 表示输入字符串的完整 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func fullFrom(jid: String, context: XmppContext): FullJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(jid, context)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            if (let Some(fullJid) <- FULLJID_CACHE.lookup(jidstr)) {
                return fullJid
            }
        }

        let localpart: ?String = XmppStringUtils.parseLocalpart(jid)
        let domainpart: String = XmppStringUtils.parseDomain(jid)
        let resource: ?String = XmppStringUtils.parseResource(jid)
        let fullJid: FullJid = try {
            fullFrom(localpart, domainpart, resource)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jid, e)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            FULLJID_CACHE.put(jidstr, fullJid)
        }

        return fullJid
    }

    /**
     * 从给定的部分构造一个 FullJid。
     *
     * @param localpart 可选的本地部分。
     * @param domainpart 域部分。
     * @param resource 资源部分。
     * @return 完整 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func fullFrom(localpart: ?String, domainpart: String, resource: ?String): FullJid {
        return fullFrom(localpart, domainpart, resource, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的部分构造一个 FullJid。
     *
     * @param localpart 可选的本地部分。
     * @param domainpart 域部分。
     * @param resource 资源部分。
     * @param context XMPP 上下文。
     * @return 完整 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func fullFrom(localpart: ?String, domainpart: String, resource: ?String, context: XmppContext): FullJid {
        let fullJid: FullJid = try {
            if (localpart.isNone() || (localpart?.size ?? 0) == 0) {
                DomainAndResourcepartJid(domainpart, resource, context)
            } else {
                LocalDomainAndResourcepartJid(localpart(), domainpart, resource, context)
            }
        } catch (e: XmppStringprepException) {
            let localpartStr = if (let Some(v) <- localpart) {
                v
            } else {
                "None"
            }
            let resourceStr = if (let Some(v) <- resource) {
                v
            } else {
                "None"
            }
            throw XmppStringprepException("${localpartStr}@${domainpart}/${resourceStr}", e)
        }
        return fullJid
    }

    /**
     * 从给定的部分构造一个 FullJid。
     *
     * @param localpart 可选的本地部分。
     * @param domainBareJid 域裸 JID。
     * @param resource 资源部分。
     * @return 完整 JID。
     */
    public static func fullFrom(localpart: Localpart, domainBareJid: DomainBareJid, resource: Resourcepart): FullJid {
        return fullFrom(localpart, domainBareJid.getDomain(), resource)
    }

    /**
     * 从给定的部分构造一个 FullJid。
     *
     * @param localpart 可选的本地部分。
     * @param domainpart 域部分。
     * @param resource 资源部分。
     * @return 完整 JID。
     */
    public static func fullFrom(localpart: Localpart, domainpart: Domainpart, resource: Resourcepart): FullJid {
        return fullFrom(entityBareFrom(localpart, domainpart), resource)
    }

    /**
     * 从一个裸 JID（BareJid）和一个资源部分（Resourcepart）构造一个完整 JID（FullJid）。
     *
     * @param bareJid 一个实体裸 JID。
     * @param resource 一个资源部分。
     * @return 一个完整 JID。
     */
    public static func fullFrom(bareJid: BareJid, resource: Resourcepart): FullJid {
        match (bareJid) {
            case entityBareJid: EntityBareJid => LocalDomainAndResourcepartJid(entityBareJid, resource)
            case _ => DomainAndResourcepartJid((bareJid as DomainBareJid)(), resource)
        }
    }

    /**
     * 从给定的字符串获取一个完整 JID（FullJid），如果输入不表示 JID，则返回 None。
     *
     * @param cs 输入的字符串。
     * @return 一个 JID 或 None。
     */
    public static func fullFromOrNull(cs: String): ?FullJid {
        try {
            return fullFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从一个 URL 编码的字符串获取一个完整 JID（FullJid）。
     *
     * @param cs 表示 URL 编码的完整 JID 的字符串。
     * @return 一个完整 JID。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func fullFromUrlEncoded(cs: String): FullJid {
        let decoded: String = urlDecode(cs)
        return fullFrom(decoded)
    }

    /**
     * 类似于 #entityFrom(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 EntityJid 的字符序列。
     * @return 如果没有异常发生，则返回 EntityJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #entityFrom(String)
     */
    public static func entityFromOrThrowUnchecked(cs: String): EntityJid {
        try {
            return entityFrom(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 获取一个表示给定字符串的实体 JID（EntityJid）。
     *
     * @param jidString JID 的字符串。
     * @return 表示给定字符串的实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFrom(jidString: String): EntityJid {
        return entityFrom(jidString, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的字符串获取一个 EntityJid。
     *
     * @param jidString JID 的字符串。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFrom(jidString: String, context: XmppContext): EntityJid {
        return entityFrom(jidString, false, context)
    }

    /**
     * 类似于 #entityFromUnescaped(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 EntityJid 的字符序列。
     * @return 如果没有异常发生，则返回 EntityJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #entityFromUnescaped(String)
     */
    public static func entityFromUnescapedOrThrowUnchecked(cs: String): EntityJid {
        return entityFromUnescapedOrThrowUnchecked(cs, XmppContext.getDefaultContext())
    }

    /**
     * 类似于 #entityFromUnescaped(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException，并且需要 XMPP 上下文。
     *
     * @param cs 应该转换为 EntityJid 的字符序列。
     * @param context XMPP 上下文。
     * @return 如果没有异常发生，则返回 EntityJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #entityFromUnescaped(String)
     */
    public static func entityFromUnescapedOrThrowUnchecked(cs: String, context: XmppContext): EntityJid {
        try {
            return entityFromUnescaped(cs, context)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的未转义字符串获取一个 EntityJid。
     *
     * @param jidString JID 的字符串。
     * @return 表示给定字符串的实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFromUnescaped(jidString: String): EntityJid {
        return entityFromUnescaped(jidString, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的未转义字符串获取一个 EntityJid。
     *
     * @param jidString JID 的字符串。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFromUnescaped(jidString: String, context: XmppContext): EntityJid {
        return entityFrom(jidString, true, context)
    }

    /**
     * 从给定的字符串获取一个 EntityJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func entityFromUnescapedOrNull(cs: String): ?EntityJid {
        try {
            return entityFromUnescaped(cs.toString())
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从给定的字符串和是否转义以及 XMPP 上下文获取一个 EntityJid。
     *
     * @param jidString JID 的字符串。
     * @param unescaped 是否未转义。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    private static func entityFrom(jidString: String, unescaped: Bool, context: XmppContext): EntityJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(jidString, context)
        }

        var entityJid: ?EntityJid = None
        if (jidStringAndStringprep.isSome()) {
            entityJid = ENTITYJID_CACHE.lookup(jidStringAndStringprep())
            if (entityJid.isSome()) {
                return entityJid()
            }
        }
        let localpartString: String = XmppStringUtils.parseLocalpart(jidString).getOrThrow {
            => XmppStringprepException("Does not contain a localpart", jidString)
        }
        var localpart: Localpart = try {
            if (unescaped) {
                Localpart.fromUnescaped(localpartString)
            } else {
                Localpart.froms(localpartString)
            }
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jidString, e)
        }

        let domainpartString: String = XmppStringUtils.parseDomain(jidString)
        var domainpart: Domainpart = try {
            Domainpart.froms(domainpartString)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jidString, e)
        }

        let resourceString: ?String = XmppStringUtils.parseResource(jidString)
        if (resourceString.isSome()) {
            var resourcepart: Resourcepart = try {
                Resourcepart.froms(resourceString)
            } catch (e: XmppStringprepException) {
                throw XmppStringprepException(jidString, e)
            }
            entityJid = entityFullFrom(localpart, domainpart, resourcepart)
        } else {
            entityJid = entityBareFrom(localpart, domainpart)
        }

        if (jidStringAndStringprep.isSome()) {
            ENTITYJID_CACHE.put(jidStringAndStringprep(), entityJid())
        }
        return entityJid()
    }

    /**
     * 从给定的字符串获取一个 EntityJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func entityFromOrNull(cs: String): ?EntityJid {
        try {
            return entityFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从 URL 编码的字符串获取一个 EntityJid。
     *
     * @param cs 表示 URL 编码的实体 JID 的字符串。
     * @return 实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func entityFromUrlEncoded(cs: String): EntityJid {
        let decoded: String = urlDecode(cs)
        return entityFrom(decoded)
    }

    /**
     * 类似于 #entityBareFrom(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 EntityBareJid 的字符序列。
     * @return 如果没有异常发生，则返回 EntityBareJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #entityBareFrom(String)
     */
    public static func entityBareFromOrThrowUnchecked(cs: String): EntityBareJid {
        try {
            return entityBareFrom(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的字符串获取一个 EntityBareJid。
     *
     * @param jid 输入字符串。
     * @return 表示给定字符串的裸实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityBareFrom(jid: String): EntityBareJid {
        return entityBareFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的字符串获取一个 EntityBareJid。
     *
     * @param jid 输入字符串。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的裸实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityBareFrom(jid: String, context: XmppContext): EntityBareJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(jid, context)
        }

        var bareJid: ?EntityBareJid = None
        if (jidStringAndStringprep.isSome()) {
            bareJid = ENTITY_BAREJID_CACHE.lookup(jidStringAndStringprep())
            if (bareJid.isSome()) {
                return bareJid()
            }
        }

        let localpart: ?String = XmppStringUtils.parseLocalpart(jid)
        let domainpart: String = XmppStringUtils.parseDomain(jid)
        try {
            bareJid = LocalAndDomainpartJid(localpart, domainpart, context)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jid, e)
        }

        if (jidStringAndStringprep.isSome()) {
            ENTITY_BAREJID_CACHE.put(jidStringAndStringprep(), bareJid())
        }
        return bareJid()
    }

    /**
     * 类似于 #entityBareFromUnescaped(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 EntityBareJid 的字符序列。
     * @return 如果没有异常发生，则返回 EntityBareJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #entityBareFromUnescaped(String)
     */
    public static func entityBareFromUnescapedOrThrowUnchecked(cs: String): EntityBareJid {
        try {
            return entityBareFromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的未转义字符串获取一个 EntityBareJid。
     *
     * @param unescapedJidString 输入字符串。
     * @return 表示给定字符串的裸实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityBareFromUnescaped(unescapedJidString: String): EntityBareJid {
        return entityBareFromUnescaped(unescapedJidString, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的未转义字符串获取一个 EntityBareJid。
     *
     * @param unescapedJidString 输入字符串。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的裸实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityBareFromUnescaped(unescapedJidString: String, context: XmppContext): EntityBareJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(unescapedJidString, context)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            if (let Some(bareJid) <- ENTITY_BAREJID_CACHE.lookup(jidstr)) {
                return bareJid
            }
        }

        var localpart: ?String = XmppStringUtils.parseLocalpart(unescapedJidString)
        // Some as froms(String), but we escape the localpart
        localpart = XmppStringUtils.escapeLocalpart(localpart)

        let domainpart: String = XmppStringUtils.parseDomain(unescapedJidString)
        let bareJid: EntityBareJid = try {
            LocalAndDomainpartJid(localpart, domainpart, context)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(unescapedJidString, e)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            ENTITY_BAREJID_CACHE.put(jidstr, bareJid)
        }

        return bareJid
    }

    /**
     * 从给定的字符串获取一个实体裸 JID（EntityBareJid），如果输入不表示 JID，则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func entityBareFromUnescapedOrNull(cs: String): ?EntityBareJid {
        try {
            return entityBareFromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从给定的本地部分和域裸 JID 构造一个 EntityBareJid。
     *
     * @param localpart 本地部分。
     * @param domainBareJid 域裸 JID。
     * @return 裸实体 JID。
     */
    public static func entityBareFrom(localpart: Localpart, domainBareJid: DomainBareJid): EntityBareJid {
        return entityBareFrom(localpart, domainBareJid.getDomain())
    }

    /**
     * 从给定的本地部分和域部分构造一个 EntityBareJid。
     *
     * @param localpart 本地部分。
     * @param domain 域部分。
     * @return 由给定部分构造的裸实体 JID。
     */
    public static func entityBareFrom(localpart: Localpart, domain: Domainpart): EntityBareJid {
        return LocalAndDomainpartJid(localpart, domain)
    }

    /**
     * 从给定的字符串获取一个 EntityBareJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func entityBareFromOrNull(cs: String): ?EntityBareJid {
        try {
            return entityBareFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从 URL 编码的字符串获取一个 EntityBareJid。
     *
     * @param cs 表示 URL 编码的实体裸 JID 的字符串。
     * @return 实体裸 JID。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func entityBareFromUrlEncoded(cs: String): EntityBareJid {
        let decoded: String = urlDecode(cs)
        return entityBareFrom(decoded)
    }

    /**
     * 类似于 #entityFullFrom(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 EntityFullJid 的字符序列。
     * @return 如果没有异常发生，则返回 EntityFullJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #entityFullFrom(String)
     */
    public static func entityFullFromOrThrowUnchecked(cs: String): EntityFullJid {
        try {
            return entityFullFrom(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的字符串获取一个 EntityFullJid。
     *
     * @param jid 表示 JID 的字符串。
     * @return 表示给定字符串的完整实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFullFrom(jid: String): EntityFullJid {
        return entityFullFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的字符串获取一个 EntityFullJid。
     *
     * @param jid JID 的字符串。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的完整实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFullFrom(jid: String, context: XmppContext): EntityFullJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(jid, context)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            if (let Some(fullJid) <- ENTITY_FULLJID_CACHE.lookup(jidstr)) {
                return fullJid
            }
        }

        let localpart: ?String = XmppStringUtils.parseLocalpart(jid)
        let domainpart: String = XmppStringUtils.parseDomain(jid)
        let resource: ?String = XmppStringUtils.parseResource(jid)
        let fullJid: EntityFullJid = try {
            entityFullFrom(localpart, domainpart, resource)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jid, e)
        }

        if (let Some(jidstr) <- jidStringAndStringprep) {
            ENTITY_FULLJID_CACHE.put(jidstr, fullJid)
        }

        return fullJid
    }

    /**
     * 从给定的字符串获取一个 EntityFullJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func entityFullFromOrNull(cs: String): ?EntityFullJid {
        try {
            return entityFullFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 类似于 #entityFullFromUnescaped(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 EntityFullJid 的字符序列。
     * @return 如果没有异常发生，则返回 EntityFullJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #entityFullFromUnescaped(String)
     */
    public static func entityFullFromUnescapedOrThrowUnchecked(cs: String): EntityFullJid {
        try {
            return entityFullFromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的未转义字符串获取一个 EntityFullJid。
     *
     * @param unescapedJidString JID 的字符串。
     * @return 表示给定字符串的完整实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFullFromUnescaped(unescapedJidString: String): EntityFullJid {
        return entityFullFromUnescaped(unescapedJidString, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的未转义字符串获取一个 EntityFullJid。
     *
     * @param unescapedJidString JID 的字符串。
     * @param context XMPP 上下文。
     * @return 表示给定字符串的完整实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFullFromUnescaped(unescapedJidString: String, context: XmppContext): EntityFullJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(unescapedJidString, context)
        }

        var fullJid: ?EntityFullJid = None
        if (jidStringAndStringprep.isSome()) {
            fullJid = ENTITY_FULLJID_CACHE.lookup(jidStringAndStringprep())
            if (fullJid.isSome()) {
                return fullJid()
            }
        }

        var localpart: ?String = XmppStringUtils.parseLocalpart(unescapedJidString)
        // Some as froms(String), but we escape the localpart
        localpart = XmppStringUtils.escapeLocalpart(localpart)

        let domainpart: String = XmppStringUtils.parseDomain(unescapedJidString)
        let resource: ?String = XmppStringUtils.parseResource(unescapedJidString)
        try {
            fullJid = LocalDomainAndResourcepartJid(localpart, domainpart, resource, context)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(unescapedJidString, e)
        }

        if (jidStringAndStringprep.isSome()) {
            ENTITY_FULLJID_CACHE.put(jidStringAndStringprep(), fullJid())
        }

        return fullJid()
    }

    /**
     * 从给定的字符串获取一个 EntityFullJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func entityFullFromUnescapedOrNull(cs: String): ?EntityFullJid {
        try {
            return entityFullFromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从给定的部分构造一个 EntityFullJid。
     *
     * @param localpart 本地部分。
     * @param domainpart 域部分。
     * @param resource 资源部分。
     * @return 完整实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFullFrom(localpart: ?String, domainpart: String, resource: ?String): EntityFullJid {
        return entityFullFrom(localpart, domainpart, resource, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的部分构造一个 EntityFullJid。
     *
     * @param localpart 本地部分。
     * @param domainpart 域部分。
     * @param resource 资源部分。
     * @param context XMPP 上下文。
     * @return 完整实体 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func entityFullFrom(localpart: ?String, domainpart: String, resource: ?String, context: XmppContext): EntityFullJid {
        var fullJid: ?EntityFullJid = None
        try {
            fullJid = LocalDomainAndResourcepartJid(localpart, domainpart, resource, context)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException("${localpart}@${domainpart}/${resource}", e)
        }
        return fullJid()
    }

    /**
     * 从给定的本地部分、域裸 JID 和资源部分构造一个 EntityFullJid。
     *
     * @param localpart 本地部分。
     * @param domainBareJid 域裸 JID。
     * @param resource 资源部分。
     * @return 完整实体 JID。
     */
    public static func entityFullFrom(localpart: Localpart, domainBareJid: DomainBareJid, resource: Resourcepart): EntityFullJid {
        return entityFullFrom(localpart, domainBareJid.getDomain(), resource)
    }

    /**
     * 从给定的部分构造一个实体完整 JID（EntityFullJid）。
     *
     * @param localpart 本地部分。
     * @param domainpart 域部分。
     * @param resource 资源部分。
     * @return 一个完整 JID。
     */
    public static func entityFullFrom(localpart: Localpart, domainpart: Domainpart, resource: Resourcepart): EntityFullJid {
        return entityFullFrom(entityBareFrom(localpart, domainpart), resource)
    }

    /**
     * 从一个实体裸 JID（EntityBareJid）和一个资源部分（Resourcepart）构造一个实体完整 JID（EntityFullJid）。
     *
     * @param bareJid 一个裸 JID。
     * @param resource 一个资源部分。
     * @return 一个完整 JID。
     */
    public static func entityFullFrom(bareJid: EntityBareJid, resource: Resourcepart): EntityFullJid {
        return LocalDomainAndResourcepartJid(bareJid, resource)
    }

    /**
     * 从一个 URL 编码的字符串获取一个实体完整 JID（EntityFullJid）。
     *
     * @param cs 表示 URL 编码的实体完整 JID 的字符串。
     * @return 一个实体完整 JID。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func entityFullFromUrlEncoded(cs: String): EntityFullJid {
        let decoded: String = urlDecode(cs)
        return entityFullFrom(decoded)
    }

    /**
     * 类似于 #domainBareFrom(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 EntityFullJid 的字符序列。
     * @return 如果没有异常发生，则返回 EntityFullJid。
     * @see #froms(String)
     */
    public static func domainBareFromOrThrowUnchecked(cs: String): DomainBareJid {
        try {
            return domainBareFrom(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 获取一个域裸 JID。
     *
     * @param jid JID 字符串。
     * @return 一个域裸 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func domainBareFrom(jid: String): DomainBareJid {
        return domainBareFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * 获取一个域裸 JID。
     *
     * @param jid JID 字符串。
     * @param context XMPP 上下文。
     * @return 一个域裸 JID。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func domainBareFrom(jid: String, context: XmppContext): DomainBareJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(jid, context)
        }

        var domainJid: ?DomainBareJid = None
        if (jidStringAndStringprep.isSome()) {
            domainJid = DOMAINJID_CACHE.lookup(jidStringAndStringprep())
            if (domainJid.isSome()) {
                return domainJid()
            }
        }

        let domain: String = XmppStringUtils.parseDomain(jid)
        try {
            domainJid = DomainpartJid(domain, context)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jid, e)
        }

        if (context.isCachingEnabled()) {
            DOMAINJID_CACHE.put(jidStringAndStringprep(), domainJid())
        }
        return domainJid()
    }

    /**
     * 从给定的域部分获取一个 DomainBareJid。
     *
     * @param domainpart 域部分。
     * @return 一个域裸 JID。
     */
    public static func domainBareFrom(domainpart: Domainpart): DomainBareJid {
        return DomainpartJid(domainpart)
    }

    /**
     * 从给定的字符串获取一个 DomainBareJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func domainBareFromOrNull(cs: String): ?DomainBareJid {
        try {
            return domainBareFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从 URL 编码的字符串获取一个 DomainBareJid。
     *
     * @param cs 表示 URL 编码的域裸 JID 的字符串。
     * @return 一个域裸 JID。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func domainBareFromUrlEncoded(cs: String): DomainBareJid {
        let decode: String = urlDecode(cs)
        return domainBareFrom(decode)
    }

    /**
     * 类似于 #domainFullFrom(String)，但如果输入不是有效的 JID，会抛出未检查的 IllegalArgumentException 而不是 XmppStringprepException。
     *
     * @param cs 应该转换为 DomainFullJid 的字符序列。
     * @return 如果没有异常发生，则返回 DomainFullJid。
     * @throws IllegalArgumentException 如果给定的输入不是有效的 JID。
     * @see #domainFullFrom(String)
     */
    public static func domainFullFromOrThrowUnchecked(cs: String): DomainFullJid {
        try {
            return domainFullFrom(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * 从给定的字符串获取一个域完整 JID。
     *
     * @param jid JID。
     * @return 一个 DomainFullJid。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func domainFullFrom(jid: String): DomainFullJid {
        return domainFullFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * 从给定的字符串获取一个域完整 JID。
     *
     * @param jid JID。
     * @param context XMPP 上下文。
     * @return 一个 DomainFullJid。
     * @throws XmppStringprepException 如果发生错误。
     */
    public static func domainFullFrom(jid: String, context: XmppContext): DomainFullJid {
        var jidStringAndStringprep: ?JidStringAndStringprep = None
        if (context.isCachingEnabled()) {
            jidStringAndStringprep = JidStringAndStringprep(jid, context)
        }

        var domainResourceJid: ?DomainFullJid = None
        if (jidStringAndStringprep.isSome()) {
            domainResourceJid = DOMAINRESOURCEJID_CACHE.lookup(jidStringAndStringprep())
            if (domainResourceJid.isSome()) {
                return domainResourceJid()
            }
        }

        let domain: String = XmppStringUtils.parseDomain(jid)
        let resource: ?String = XmppStringUtils.parseResource(jid)
        try {
            domainResourceJid = DomainAndResourcepartJid(domain, resource, context)
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException(jid, e)
        }

        if (jidStringAndStringprep.isSome()) {
            DOMAINRESOURCEJID_CACHE.put(jidStringAndStringprep(), domainResourceJid())
        }

        return domainResourceJid()
    }

    /**
     * 从给定的域部分和资源部分获取一个域完整 JID。
     *
     * @param domainpart 域部分。
     * @param resource 资源部分。
     * @return 一个域完整 JID。
     */
    public static func domainFullFrom(domainpart: Domainpart, resource: Resourcepart): DomainFullJid {
        return domainFullFrom(domainBareFrom(domainpart), resource)
    }

    /**
     * 从给定的域裸 JID 和资源部分获取一个域完整 JID。
     *
     * @param domainBareJid 域裸 JID。
     * @param resource 资源部分。
     * @return 一个域完整 JID。
     */
    public static func domainFullFrom(domainBareJid: DomainBareJid, resource: Resourcepart): DomainFullJid {
        return DomainAndResourcepartJid(domainBareJid, resource)
    }

    /**
     * 从给定的字符串获取一个 DomainFullJid 或如果输入不表示 JID 则返回 None。
     *
     * @param cs 输入字符串。
     * @return Jid 或 None。
     */
    public static func domainFullFromOrNull(cs: String): ?DomainFullJid {
        try {
            return domainFullFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * 从 URL 编码的字符串获取一个 DomainFullJid。
     *
     * @param cs 表示 URL 编码的域完整 JID 的字符串。
     * @return 一个域完整 JID。
     * @throws XmppStringprepException 如果发生错误。
     * @see URLDecoder
     */
    public static func domainFullFromUrlEncoded(cs: String): DomainFullJid {
        let decoded: String = urlDecode(cs)
        return domainFullFrom(decoded)
    }

    private static func urlDecode(cs: String): String {
        let url = URL.parse("${cs}")
        let urlScheme = if (url.scheme.isEmpty()) {
            ""
        } else {
            "${url.scheme}://"
        }
        let urlUserInfo = if (url.userInfo.toString().isEmpty()) {
            ""
        } else {
            "${url.userInfo}@"
        }
        let urlHostName = if (url.hostName.isEmpty()) {
            ""
        } else {
            "${url.hostName}"
        }
        let urlPath = if (url.path.isEmpty()) {
            ""
        } else {
            "${url.path}"
        }
        let urlQuery = if (let Some(v) <- url.query) {
            "?${v}"
        } else {
            ""
        }
        return "${urlScheme}${urlUserInfo}${urlHostName}${urlPath}${urlQuery}"
    }
}

class JidStringAndStringprep <: Hashable & Equatable<JidStringAndStringprep> {
    let jidString: String
    let stringprep: XmppStringprep

    init(jidString: String, context: XmppContext) {
        this(jidString, context.xmppStringprep)
    }

    init(jidString: String, stringprep: XmppStringprep) {
        this.jidString = jidString
        this.stringprep = stringprep
    }

    public operator func ==(other: JidStringAndStringprep): Bool {
        return jidString == other.jidString && stringprep == other.stringprep
    }

    private var hash: ?Int = None

    @OverflowWrapping
    public func hashCode(): Int {
        return if (let Some(v) <- hash) {
            v
        } else {
            var result = 17
            result = 31 * result + jidString.hashCode()
            result = 31 * result + stringprep.hashCode()
            hash = result
            result
        }
    }
}
