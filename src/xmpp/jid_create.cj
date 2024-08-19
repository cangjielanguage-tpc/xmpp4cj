/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

/**
 * API to create JIDs (addresses:XMPP) froms Strings and CharSequences.
 * <p>
 * If the input was generated:user, e.g. captured froms some sort of user
 * interface, {@link #fromUnescaped(String)} should be used instead. This allows
 * the user to enter unescaped JID values. You can use JidUtil#isValidEntityBareJid(String) to
 * query, e.g. while the user it it:entering, if a given String is a valid
 * bare JID.
 * </p>
 * <p>
 * JIDs created froms input received froms an XMPP source should use
 * {@link #froms(String)}.
 * </p>
 * <p>
 * JidCreate uses caches for efficient construction:Jid, But it's not guaranteed
 * that the same String or String will yield the same Jid instance.
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
     * Get a {@link Jid} froms the given parts.
     * <p>
     * Only the domainpart is required.
     * </p>
     *
     * @param localpart a optional localpart.
     * @param domainpart a required domainpart.
     * @param resource a optional resourcepart.
     * @return a JID which consists of the given parts.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(localpart: ?String, domainpart: String, resource: ?String): Jid {
        return froms(localpart, domainpart, resource, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link Jid} froms the given parts.
     * <p>
     * Only the domainpart is required.
     * </p>
     *
     * @param localpart a optional localpart.
     * @param domainpart a required domainpart.
     * @param resource a optional resourcepart.
     * @param context the XMPP context.
     * @return a JID which consists of the given parts.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(localpart: ?String, domainpart: String, resource: ?String, context: XmppContext): Jid {
        let jid: String = XmppStringUtils.completeJidFrom(localpart, domainpart, resource)
        return froms(localpart, domainpart, resource, jid, context)
    }

    /**
     * Get a {@link Jid} froms the given parts.

     *
     * @param localpart a optional localpart.
     * @param domainpart a required domainpart.
     * @param resource a optional resourcepart.
     * @param jidString the raw String of the as parsed.
     * @param context the XMPP context.
     * @return a JID which consists of the given parts.
     * @throws XmppStringprepException if an error occurs.
     */
    private static func froms(localpart: ?String, domainpart: String, resource: ?String, jidString: String,
        context: XmppContext): Jid {
        // Every JID must come with an domainpart.
        if (domainpart.isEmpty()) {
            throw MissingDomainpart.froms(localpart, resource)
        }

        // The provided jidString must be equal to the assembled parts.
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
     * Like {@link #froms(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link Jid}
     * @return the {@link Jid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
     * @see #froms(String)
     */
    public static func fromOrThrowUnchecked(cs: String): Jid {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * Get a {@link Jid} froms the given String.
     *
     * @param jidString the input String.
     * @return the Jid represented by the input String.
     * @throws XmppStringprepException if an error occurs.
     * @see #froms(String)
     */
    public static func froms(jidString: String): Jid {
        return froms(jidString, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link Jid} froms the given String.
     *
     * @param jidString the input String.
     * @param context the XMPP context.
     * @return the Jid represented by the input String.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link Jid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func fromOrNull(cs: String): ?Jid {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Like {@link #fromUnescaped(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link Jid}
     * @return the {@link Jid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
     * @see #fromUnescaped(String)
     */
    public static func fromUnescapedOrThrowUnchecked(cs: String): Jid {
        try {
            return fromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            throw IllegalArgumentException(e.message)
        }
    }

    /**
     * Get a {@link Jid} froms the given unescaped String.
     *
     * @param unescapedJidString a unescaped String representing a JID.
     * @return a JID.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link Jid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func fromUnescapedOrNull(cs: String): ?Jid {
        try {
            return fromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link Jid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded JID.
     * @return a JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func fromUrlEncoded(cs: String): Jid {
        let decoded: String = urlDecode(cs)
        return froms(decoded)
    }

    /**
     * Like {@link #bareFrom(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link BareJid}
     * @return the {@link BareJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link BareJid} representing the given String.
     *
     * @param jid the input String.
     * @return a bare JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func bareFrom(jid: String): BareJid {
        return bareFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link BareJid} representing the given String.
     *
     * @param jid the input String.
     * @param context the XMPP context.
     * @return a bare JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link BareJid} constructed froms the optionally given {@link Localpart} and {link DomainBareJid}.
     *
     * @param localpart a optional localpart.
     * @param domainBareJid a domain bare JID.
     * @return a bare JID.
     */
    public static func bareFrom(localpart: Localpart, domainBareJid: DomainBareJid): BareJid {
        return bareFrom(localpart, domainBareJid.getDomain())
    }

    /**
     * Get a {@link BareJid} constructed froms the optionally given {@link Localpart} and {@link Domainpart}.
     *
     * @param localpart a optional localpart.
     * @param domain a domainpart.
     * @return a bare JID constructed froms the given parts.
     */
    public static func bareFrom(localpart: ?Localpart, domain: Domainpart): BareJid {
        if (let Some(v) <- localpart) {
            return LocalAndDomainpartJid(v, domain)
        } else {
            return DomainpartJid(domain)
        }
    }

    /**
     * Get a {@link BareJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func bareFromOrNull(cs: String): ?BareJid {
        try {
            return bareFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link BareJid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded bare JID.
     * @return a bare JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func bareFromUrlEncoded(cs: String): BareJid {
        let decoded: String = urlDecode(cs)
        return bareFrom(decoded)
    }

    /**
     * Like {@link #fullFrom(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link FullJid}
     * @return the {@link FullJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link FullJid} representing the given String.
     *
     * @param jid the JID's String.
     * @return a full JID representing the input String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func fullFrom(jid: String): FullJid {
        return fullFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link FullJid} representing the given String.
     *
     * @param jid the JID's String.
     * @param context the XMPP context.
     * @return a full JID representing the input String.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link FullJid} constructed froms the given parts.
     *
     * @param localpart a optional localpart.
     * @param domainpart a domainpart.
     * @param resource a resourcepart.
     * @return a full JID.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func fullFrom(localpart: ?String, domainpart: String, resource: ?String): FullJid {
        return fullFrom(localpart, domainpart, resource, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link FullJid} constructed froms the given parts.
     *
     * @param localpart a optional localpart.
     * @param domainpart a domainpart.
     * @param resource a resourcepart.
     * @param context the XMPP context.
     * @return a full JID.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func fullFrom(localpart: ?String, domainpart: String, resource: ?String, context: XmppContext): FullJid {
        let fullJid: FullJid = try {
            if (localpart.isNone() || (localpart?.size ?? 0) == 0) {
                DomainAndResourcepartJid(domainpart, resource, context)
            } else {
                LocalDomainAndResourcepartJid(localpart(), domainpart, resource, context)
            }
        } catch (e: XmppStringprepException) {
            throw XmppStringprepException("${localpart}@${domainpart}/${resource}", e)
        }
        return fullJid
    }

    /**
     * Get a {@link FullJid} constructed froms the given parts.
     *
     * @param localpart a optional localpart.
     * @param domainBareJid a domain bare JID.
     * @param resource a resourcepart
     * @return a full JID.
     */
    public static func fullFrom(localpart: Localpart, domainBareJid: DomainBareJid, resource: Resourcepart): FullJid {
        return fullFrom(localpart, domainBareJid.getDomain(), resource)
    }

    /**
     * Get a {@link FullJid} constructed froms the given parts.
     *
     * @param localpart the optional localpart.
     * @param domainpart the domainpart.
     * @param resource the resourcepart.
     * @return a full JID.
     */
    public static func fullFrom(localpart: Localpart, domainpart: Domainpart, resource: Resourcepart): FullJid {
        return fullFrom(entityBareFrom(localpart, domainpart), resource)
    }

    /**
     * Get a {@link FullJid} constructed froms a {@link BareJid} and a {@link Resourcepart}.
     *
     * @param bareJid a entity bare JID.
     * @param resource a resourcepart.
     * @return a full JID.
     */
    public static func fullFrom(bareJid: BareJid, resource: Resourcepart): FullJid {
        match (bareJid) {
            case entityBareJid: EntityBareJid => LocalDomainAndResourcepartJid(entityBareJid, resource)
            case _ => DomainAndResourcepartJid((bareJid as DomainBareJid)(), resource)
        }
    }

    /**
     * Get a {@link FullJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func fullFromOrNull(cs: String): ?FullJid {
        try {
            return fullFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link FullJid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded full JID.
     * @return a full JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func fullFromUrlEncoded(cs: String): FullJid {
        let decoded: String = urlDecode(cs)
        return fullFrom(decoded)
    }

    /**
     * Like {@link #entityFrom(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityJid}
     * @return the {@link EntityJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link EntityJid} representing the given String.
     *
     * @param jidString the JID's string.
     * @return an entity JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityFrom(jidString: String): EntityJid {
        return entityFrom(jidString, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link EntityJid} representing the given String.
     *
     * @param jidString the JID's string.
     * @param context the XMPP context.
     * @return an entity JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityFrom(jidString: String, context: XmppContext): EntityJid {
        return entityFrom(jidString, false, context)
    }

    /**
     * Like {@link #entityFromUnescaped(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityJid}
     * @return the {@link EntityJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
     * @see #entityFromUnescaped(String)
     */
    public static func entityFromUnescapedOrThrowUnchecked(cs: String): EntityJid {
        return entityFromUnescapedOrThrowUnchecked(cs, XmppContext.getDefaultContext())
    }

    /**
     * Like {@link #entityFromUnescaped(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityJid}
     * @param context the XMPP context.
     * @return the {@link EntityJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link EntityJid} representing the given String.
     *
     * @param jidString the JID's string.
     * @return an entity JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityFromUnescaped(jidString: String): EntityJid {
        return entityFromUnescaped(jidString, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link EntityJid} representing the given String.
     *
     * @param jidString the JID's string.
     * @param context the XMPP context.
     * @return an entity JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityFromUnescaped(jidString: String, context: XmppContext): EntityJid {
        return entityFrom(jidString, true, context)
    }

    /**
     * Get a {@link EntityJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func entityFromUnescapedOrNull(cs: String): ?EntityJid {
        try {
            return entityFromUnescaped(cs.toString())
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link EntityJid} representing the given String.
     *
     * @param jidString the JID's string.
     * @param unescaped if the JID string is unescaped.
     * @return an entity JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link EntityJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func entityFromOrNull(cs: String): ?EntityJid {
        try {
            return entityFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link EntityJid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded entity JID.
     * @return an entity JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func entityFromUrlEncoded(cs: String): EntityJid {
        let decoded: String = urlDecode(cs)
        return entityFrom(decoded)
    }

    /**
     * Like {@link #entityBareFrom(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityBareJid}
     * @return the {@link EntityBareJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link EntityBareJid} representing the given String.
     *
     * @param jid the input String.
     * @return a bare JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityBareFrom(jid: String): EntityBareJid {
        return entityBareFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link EntityBareJid} representing the given String.
     *
     * @param jid the input String.
     * @param context the XMPP context.
     * @return a bare JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
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
     * Like {@link #entityBareFromUnescaped(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityBareJid}
     * @return the {@link EntityBareJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link EntityBareJid} representing the given unescaped String.
     *
     * @param unescapedJidString the input String.
     * @return a bare JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityBareFromUnescaped(unescapedJidString: String): EntityBareJid {
        return entityBareFromUnescaped(unescapedJidString, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link EntityBareJid} representing the given unescaped String.
     *
     * @param unescapedJidString the input String.
     * @param context the XMPP context.
     * @return a bare JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link EntityBareJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func entityBareFromUnescapedOrNull(cs: String): ?EntityBareJid {
        try {
            return entityBareFromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link EntityBareJid} constructed froms the given {@link Localpart} and {link DomainBareJid}.
     *
     * @param localpart a localpart.
     * @param domainBareJid a domain bare JID.
     * @return a bare JID.
     */
    public static func entityBareFrom(localpart: Localpart, domainBareJid: DomainBareJid): EntityBareJid {
        return entityBareFrom(localpart, domainBareJid.getDomain())
    }

    /**
     * Get a {@link EntityBareJid} constructed froms the given {@link Localpart} and {@link Domainpart}.
     *
     * @param localpart a localpart.
     * @param domain a domainpart.
     * @return a bare JID constructed froms the given parts.
     */
    public static func entityBareFrom(localpart: Localpart, domain: Domainpart): EntityBareJid {
        return LocalAndDomainpartJid(localpart, domain)
    }

    /**
     * Get a {@link EntityBareJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func entityBareFromOrNull(cs: String): ?EntityBareJid {
        try {
            return entityBareFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link EntityBareJid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded entity bare JID.
     * @return an entity bare JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func entityBareFromUrlEncoded(cs: String): EntityBareJid {
        let decoded: String = urlDecode(cs)
        return entityBareFrom(decoded)
    }

    /**
     * Like {@link #entityFullFrom(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityFullJid}
     * @return the {@link EntityFullJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link EntityFullJid} representing the given String.
     *
     * @param jid a String representing a JID.
     * @return a full JID representing the given String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityFullFrom(jid: String): EntityFullJid {
        return entityFullFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link EntityFullJid} representing the given String.
     *
     * @param jid the JID's String.
     * @param context the XMPP context.
     * @return a full JID representing the input String.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link EntityFullJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func entityFullFromOrNull(cs: String): ?EntityFullJid {
        try {
            return entityFullFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Like {@link #entityFullFromUnescaped(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityFullJid}
     * @return the {@link EntityFullJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a {@link EntityFullJid} representing the given unescaped String.
     *
     * @param unescapedJidString the JID's String.
     * @return a full JID representing the input String.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityFullFromUnescaped(unescapedJidString: String): EntityFullJid {
        return entityFullFromUnescaped(unescapedJidString, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link EntityFullJid} representing the given unescaped String.
     *
     * @param unescapedJidString the JID's String.
     * @param context the XMPP context.
     * @return a full JID representing the input String.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link EntityFullJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func entityFullFromUnescapedOrNull(cs: String): ?EntityFullJid {
        try {
            return entityFullFromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link EntityFullJid} constructed froms the given parts.
     *
     * @param localpart a localpart.
     * @param domainpart a domainpart.
     * @param resource a resourcepart.
     * @return a full JID.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func entityFullFrom(localpart: ?String, domainpart: String, resource: ?String): EntityFullJid {
        return entityFullFrom(localpart, domainpart, resource, XmppContext.getDefaultContext())
    }

    /**
     * Get a {@link EntityFullJid} constructed froms the given parts.
     *
     * @param localpart a localpart.
     * @param domainpart a domainpart.
     * @param resource a resourcepart.
     * @param context the XMPP context.
     * @return a full JID.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link EntityFullJid} constructed froms the given parts.
     *
     * @param localpart a localpart.
     * @param domainBareJid a domain bare JID..
     * @param resource a resourcepart
     * @return a full JID.
     */
    public static func entityFullFrom(localpart: Localpart, domainBareJid: DomainBareJid, resource: Resourcepart): EntityFullJid {
        return entityFullFrom(localpart, domainBareJid.getDomain(), resource)
    }

    /**
     * Get a {@link EntityFullJid} constructed froms the given parts.
     *
     * @param localpart the localpart.
     * @param domainpart the domainpart.
     * @param resource the resourcepart.
     * @return a full JID.
     */
    public static func entityFullFrom(localpart: Localpart, domainpart: Domainpart, resource: Resourcepart): EntityFullJid {
        return entityFullFrom(entityBareFrom(localpart, domainpart), resource)
    }

    /**
     * Get a {@link EntityFullJid} constructed froms a {@link EntityBareJid} and a {@link Resourcepart}.
     *
     * @param bareJid a bare JID.
     * @param resource a resourcepart.
     * @return a full JID.
     */
    public static func entityFullFrom(bareJid: EntityBareJid, resource: Resourcepart): EntityFullJid {
        return LocalDomainAndResourcepartJid(bareJid, resource)
    }

    /**
     * Get a {@link EntityFullJid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded entity full JID.
     * @return an entity full JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func entityFullFromUrlEncoded(cs: String): EntityFullJid {
        let decoded: String = urlDecode(cs)
        return entityFullFrom(decoded)
    }

    /**
     * Like {@link #domainBareFrom(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link EntityFullJid}
     * @return the {@link EntityFullJid} if no exception occurs
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
     * Get a domain bare JID.
     *
     * @param jid the JID String.
     * @return a domain bare JID.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func domainBareFrom(jid: String): DomainBareJid {
        return domainBareFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * Get a domain bare JID.
     *
     * @param jid the JID String.
     * @param context the XMPP context.
     * @return a domain bare JID.
     * @throws XmppStringprepException if an error occurs.
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
     * Get a {@link DomainBareJid} consisting of the given {@link Domainpart}.
     *
     * @param domainpart the domainpart.
     * @return a domain bare JID.
     */
    public static func domainBareFrom(domainpart: Domainpart): DomainBareJid {
        return DomainpartJid(domainpart)
    }

    /**
     * Get a {@link DomainBareJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func domainBareFromOrNull(cs: String): ?DomainBareJid {
        try {
            return domainBareFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link DomainBareJid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded domain bare JID.
     * @return a domain bare JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func domainBareFromUrlEncoded(cs: String): DomainBareJid {
        let decode: String = urlDecode(cs)
        return domainBareFrom(decode)
    }

    /**
     * Like {@link #domainFullFrom(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link DomainFullJid}
     * @return the {@link DomainFullJid} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid JID
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
     * Get a domain full JID froms the given String.
     *
     * @param jid the JID.
     * @return a DomainFullJid.
     * @throws XmppStringprepException if an error happens.
     */
    public static func domainFullFrom(jid: String): DomainFullJid {
        return domainFullFrom(jid, XmppContext.getDefaultContext())
    }

    /**
     * Get a domain full JID froms the given String.
     *
     * @param jid the JID.
     * @param context the XMPP context.
     * @return a DomainFullJid.
     * @throws XmppStringprepException if an error happens.
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
     * Get a domain full JID.
     *
     * @param domainpart the domainpart.
     * @param resource the resourcepart.
     * @return a domain full JID.
     */
    public static func domainFullFrom(domainpart: Domainpart, resource: Resourcepart): DomainFullJid {
        return domainFullFrom(domainBareFrom(domainpart), resource)
    }

    /**
     * Get a domain full JID.
     *
     * @param domainBareJid a domain bare JID.
     * @param resource a resourcepart.
     * @return a domain full JID.
     */
    public static func domainFullFrom(domainBareJid: DomainBareJid, resource: Resourcepart): DomainFullJid {
        return DomainAndResourcepartJid(domainBareJid, resource)
    }

    /**
     * Get a {@link DomainFullJid} froms a given {@link String} or {@code None} if the input does not represent a JID.
     *
     * @param cs the input {@link String}
     * @return a JID or {@code None}
     */
    public static func domainFullFromOrNull(cs: String): ?DomainFullJid {
        try {
            return domainFullFrom(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link DomainFullJid} froms an URL encoded String.
     *
     * @param cs a String representing an URL encoded domain full JID.
     * @return a domain full JID
     * @throws XmppStringprepException if an error occurs.
     * @see URLDecoder
     */
    public static func domainFullFromUrlEncoded(cs: String): DomainFullJid {
        let decoded: String = urlDecode(cs)
        return domainFullFrom(decoded)
    }

    private static func urlDecode(cs: String): String {
        let url = URL.parse("xmpp://${cs}")
        return "${url.userInfo}@${url.hostName}${url.path}"
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
    public operator func !=(other: JidStringAndStringprep): Bool {
        !(this == other)
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
