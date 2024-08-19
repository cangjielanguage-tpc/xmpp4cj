/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

/**
    An XMPP address, also known as JID (formerly for "Jabber Identifier"), which acts as globally unique address within the XMPP network.
    JIDs are created from String or CharSequence with the JidCreate utility.
    let jid:Jid = JidCreate.froms("juliet@capulet.org/balcony")
    let bareJid:EntityBareJid = JidCreate.entityBareFrom("romeo@montague.net")

    This is the super interface for all JID types, which are constructed from two dimensions: Bare/ Full and Domain/ Entity.
    Every JID consists at least of a Domainpart.
    Bare JID types do not come with a Resourcepart, full JID types always have a Resourcepart.
    Domain JID types do not possess a Localpart, whereas entity JID types always do.
    The following table shows a few examples of JID types.
                XMPP Address Types
        Example                   Type
        example.org               DomainBareJid
        example.org/resource      DomainFullJid
        user@example.org          EntityBareJid
        user@example.org/resource EntityFullJid
    You can retrieve the escaped String representing the Jid with toString() or the unescaped String of the JID with asUnescapedString().

    URL Encoded JIDs
    The URL encoded representation of a JID is ideal if a JID should be stored as part of a path name, e.g. as file name.
    You can retrieve this information using asUrlEncodedString().
    The JidCreate API provides methods to create JIDs from URL encoded Strings like JidCreate.fromUrlEncoded(String).
    See Also:
        RFC 6120 (XMPP: Core) § 2.1 Global Addresses , RFC 6122 (XMPP: Address Format) § 2.1 Fundamentals
 */
public interface Jid <: Equatable<Jid> & ToString & Hashable {

    /**
     * Get the {@link Domainpart} of this Jid.
     *
     * @return the domainpart.
     */
    func getDomain(): Domainpart

    /**
     * Return the <b>unescaped</b> String representation of this JID.
     * <p>
     * Since certain Unicode code points are disallowed in the localpart of a JID by the required stringprep profile,
     * those need to get escaped when used in a real JID. The unescaped representation of the JID is only for
     * presentation to a human user or for gatewaying to a non-XMPP system.
     * </p>
     * For example, if the users inputs {@code 'at&t guy@example.com'}, the escaped real JID created with
     * {@link xmpp.jid.impl.JidCreate} will be {@code 'at\26t\20guy@example.com'}, which is what
     * {@link Jid#toString()} will return. But {@link Jid#asUnescapedString()} will return again
     * {@code 'at&t guy@example.com'}.
     *
     * @return the unescaped String representation of this JID.
     */
    func asUnescapedString(): String

    /**
     * Get the URL encoded version of this JID.
     *
     * @return the URL encoded version of this JID.
     */
    func asUrlEncodedString(): String

    /**
     * Check if this is a {@link EntityBareJid} or {@link EntityFullJid}.
     *
     * @return true if this is an instance of BareJid or FullJid.
     */
    func isEntityJid(): Bool

    /**
     * Check if this is an instance of {@link EntityBareJid}.
     *
     * @return true if this is an instance of EntityBareJid
     */
    func isEntityBareJid(): Bool

    /**
     * Check if this is an instance of {@link EntityFullJid}.
     *
     * @return true if this is an instance of EntityFullJid
     */
    func isEntityFullJid(): Bool

    /**
     * Check if this is an instance of {@link DomainBareJid}.
     *
     * @return true if this is an instance of DomainBareJid
     */
    func isDomainBareJid(): Bool

    /**
     * Check if this is an instance of {@link DomainFullJid}.
     *
     * @return true if this is an instance of DomainFullJid
     */
    func isDomainFullJid(): Bool

    /**
     * Check if this is an instance of {@link EntityBareJid} or {@link DomainBareJid}.
     *
     * @return true if this is an instance of BareJid or DomainBareJid
     */
    func hasNoResource(): Bool

    /**
     * Check if this is a Jid with a {@link Resourcepart}.
     *
     * @return true if this Jid has a resourcepart.
     */
    func hasResource(): Bool

    /**
     * Check if this is a Jid with a {@link Localpart}.
     *
     * @return true if this Jid has a localpart.
     */
    func hasLocalpart(): Bool

    /**
     * Return a JID created by removing the Resourcepart from this JID.
     *
     * @return this Jid without a Resourcepart.
     */
    func asBareJid(): BareJid

    /**
     * Convert this Jid to a {@link EntityBareJid} if possible.
     *
     * @return the corresponding {@link EntityBareJid} or None.
     */
    func asEntityBareJidIfPossible(): ?EntityBareJid

    /**
     * Convert this Jid to a {@link EntityBareJid} or throw an {@code IllegalStateException} if this is not possible.
     *
     * @return the corresponding {@link EntityBareJid}.
     */
    func asEntityBareJidOrThrow(): EntityBareJid

    /**
     * Convert this Jid to a {@link EntityFullJid} if possible.
     *
     * @return the corresponding {@link EntityFullJid} or None.
     */
    func asEntityFullJidIfPossible(): ?EntityFullJid

    /**
     * Convert this Jid to a {@link EntityFullJid} or throw an {@code IllegalStateException} if this is not possible.
     *
     * @return the corresponding {@link EntityFullJid}.
     */
    func asEntityFullJidOrThrow(): EntityFullJid

    /**
     * Convert this Jid to a {@link EntityJid} if possible.
     *
     * @return the corresponding {@link EntityJid} or None.
     */
    func asEntityJidIfPossible(): ?EntityJid

    /**
     * Convert this Jid to a {@link EntityJid} or throw an {@code IllegalStateException} if this is not possible.
     *
     * @return the corresponding {@link EntityJid}.
     */
    func asEntityJidOrThrow(): EntityJid

    /**
     * Convert this Jid to a {@link FullJid} if possible.
     *
     * @return the corresponding {@link FullJid} or None.
     */
    func asFullJidIfPossible(): ?FullJid

    /**
     * Convert this Jid to a {@link FullJid} or throw an {@code IllegalStateException} if this is not possible.
     *
     * @return the corresponding {@link FullJid}.
     */
    func asFullJidOrThrow(): EntityFullJid

    /**
     * Convert this Jid to a {@link DomainBareJid}.
     * <p>
     * Note that it is always possible to convert a Jid to a DomainBareJid, since every Jid has a domain part.
     * </p>
     *
     * @return the corresponding DomainBareJid.
     */
    func asDomainBareJid(): DomainBareJid

    /**
     * Convert this Jid to a {@link DomainFullJid} if possible.
     *
     * @return the corresponding DomainFullJid or None.
     */
    func asDomainFullJidIfPossible(): ?DomainFullJid

    /**
     * Convert this Jid to a {@link DomainFullJid} or throw an {@code IllegalStateException} if this is not possible.
     *
     * @return the corresponding {@link DomainFullJid}.
     */
    func asDomainFullJidOrThrow(): DomainFullJid

    /**
     * Get the resourcepart of this JID or None.
     * <p>
     * If the JID is of form {@code <localpart@domain.example/resource>} then this method returns 'resource'. If the JID no
     * resourcepart, then <code>None</code> is returned.
     * </p>
     *
     * @return the resource of this JID or None.
     */
    func getResourceOrNull(): ?Resourcepart

    /**
     * Get the resourcepart of this JID or return the empty resourcepart.
     * <p>
     * If the JID is of form {@code <localpart@domain.example/resource>} then this method returns 'resource'. If the JID no
     * resourcepart, then {@link xmpp.jid.parts.Resourcepart#EMPTY} is returned.
     * </p>
     *
     * @return the resource of this JID or the empty resourcepart.
     */
    func getResourceOrEmpty(): Resourcepart

    /**
     * Get the resourcepart of this JID or throw an {@code IllegalStateException}.
     * <p>
     * If the JID is of form {@code <localpart@domain.example/resource>} then this method returns 'resource'. If the JID no
     * resourcepart, then an {@code IllegalStateException} is thrown.
     * </p>
     *
     * @return the resource of this JID.
     */
    func getResourceOrThrow(): Resourcepart

    /**
     * Get the localpart of this JID or None.
     * <p>
     * If the JID is of form {@code <localpart@domain.example>} then this method returns 'localpart'. If the JID has no
     * localpart, then <code>None</code> is returned.
     * </p>
     *
     * @return the localpart of this JID or None.
     */
    func getLocalpartOrNull(): ?Localpart

    /**
     * Get the localpart of this JID or throw an {@code IllegalStateException}.
     * <p>
     * If the JID is of form {@code <localpart@domain.example>} then this method returns 'localpart'. If the JID has no
     * localpart, then <code>None</code> is returned.
     * </p>
     *
     * @return the localpart of this JID.
     */
    func getLocalpartOrThrow(): Localpart

    /**
     * Check if this JID is the parent of another JID. The <b>parent of</b> relation is defined, under the
     * precondition that the JID parts (localpart, domainpart and resourcepart) are equal, as follows:
     * <pre>
     * | this JID (parentOf) | other JID           | result |
     * |---------------------+---------------------+--------|
     * | dom.example         | dom.example         | true   |
     * | dom.example         | dom.example/res     | true   |
     * | dom.example         | loc@dom.example     | true   |
     * | dom.example         | loc@dom.example/res | true   |
     * | dom.example/res     | dom.exmple          | false  |
     * | dom.example/res     | dom.example/res     | true   |
     * | dom.example/res     | loc@dom.example     | false  |
     * | dom.example/res     | loc@dom.example/res | false  |
     * | loc@dom.example     | dom.example         | false  |
     * | loc@dom.example     | dom.example/res     | false  |
     * | loc@dom.example     | loc@dom.example     | true   |
     * | loc@dom.example     | loc@dom.example/res | true   |
     * | loc@dom.example/res | dom.example         | false  |
     * | loc@dom.example/res | dom.example/res     | false  |
     * | loc@dom.example/res | loc@dom.example     | false  |
     * | loc@dom.example/res | loc@dom.example/res | true   |
     * </pre>
     *
     * @param jid
     *            the other JID to compare with
     * @return true if this JID is a parent of the given JID.
     */
    func isParentOf(jid: Jid): Bool

    /**
     * See {@link #isParentOf(Jid)}.
     *
     * @param bareJid the bare JID.
     * @return true if this JID is a parent of the given JID.
     */
    func isParentOf(bareJid: EntityBareJid): Bool

    /**
     * See {@link #isParentOf(Jid)}.
     *
     * @param fullJid the full JID.
     * @return true if this JID is a parent of the given JID.
     */
    func isParentOf(fullJid: EntityFullJid): Bool

    /**
     * See {@link #isParentOf(Jid)}.
     *
     * @param domainBareJid the domain bare JID.
     * @return true if this JID is a parent of the given JID.
     */
    func isParentOf(domainBareJid: DomainBareJid): Bool

    /**
     * See {@link #isParentOf(Jid)}.
     *
     * @param domainFullJid the domain full JID.
     * @return true if this JID is a parent of the given JID.
     */
    func isParentOf(domainFullJid: DomainFullJid): Bool
}

/**
 * An XMPP address (JID) which has no {@link xmpp.jid.parts.Resourcepart}. Either
 * {@link EntityBareJid} or {@link DomainBareJid}.
 * Examples:
 *  localpart@domain.part
 *  domain.part
 *
 * @see Jid
 */
public interface BareJid <: Jid {}
/**
 * An XMPP address (JID) which has no {@link xmpp.jid.parts.Localpart}. Either
 * {@link DomainBareJid} or {@link DomainFullJid}.
 * Examples:
 *  domain.part
 *  domain.part/resourcepart
 *
 * @see Jid
 */
public interface DomainJid <: Jid {}
/**
 * An XMPP address (JID) consisting of a domainpart and a resourcepart.
 * Examples:
 *  domain.part/resource
 *  example.net/8c6def89
 *
 * @see Jid
 */
public interface DomainFullJid <: Jid & FullJid & DomainJid & Equatable<DomainFullJid> {}

/**
 * An XMPP address (JID) which has a {@link Resourcepart}. Either {@link EntityFullJid} or {@link DomainFullJid}.
 * Examples:
 *  localpart@domain.part/resourcepart
 *  domain.part/resourcepart
 *
 * @see Jid
 */
public interface FullJid <: Jid {

    /**
     * Return the {@link Resourcepart} of this JID.
     *
     * @return the resourcepart.
     */
    func getResourcepart(): Resourcepart
}
/**
 * An XMPP address (JID) which has a {@link Localpart}. Either {@link EntityBareJid} or {@link EntityFullJid}.
 * Examples:
 *  localpart@domain.part
 *  localpart@domain.part/resourcepart
 *
 * @see Jid
 */
public interface EntityJid <: Jid {

    /**
     * Return the {@link Localpart} of this JID.
     *
     * @return the localpart.
     */
    func getLocalpart(): Localpart

    /**
     * Return the bare JID of this entity JID.
     *
     * @return the bare JID.
     */
    func asEntityBareJid(): EntityBareJid

    /**
     * Return the bare JID string of this full JID.
     *
     * @return the bare JID string.
     */
    func asEntityBareJidString(): String
}
/**
 * An XMPP address (JID) consisting of a localpart, domainpart and resourcepart.
 * Examples:
 *  localpart@domain.part/resource
 *  juliet@xmpp.org/balcony
 *
 * @see Jid
 */
public interface EntityFullJid <: Jid & FullJid & EntityJid & Equatable<EntityFullJid> {}
/**
 * An XMPP address (JID) consisting of a localpart and a domainpart.
 * Examples:
 *  localpart@domain.part
 *  user@example.net
 *
 * @see Jid
 */
public interface EntityBareJid <: Jid & EntityJid & BareJid & Equatable<EntityBareJid> {}
/**
 * An XMPP address (JID) consisting of the domainpart.
 * Examples:
 *  xmpp.org
 *  example.net
 *
 * @see Jid
 */
public interface DomainBareJid <: Jid & BareJid & DomainJid {}

public abstract class AbstractJid <: Jid {
    /**
     * Cache for the String representation of this JID.
     */
    protected var cache: ?String = None

    public override func isEntityJid(): Bool {
        return isEntityBareJid() || isEntityFullJid()
    }

    public override func isEntityBareJid(): Bool {
        return this is EntityBareJid
    }

    public override func isEntityFullJid(): Bool {
        return this is EntityFullJid
    }

    public override func isDomainBareJid(): Bool {
        return this is DomainBareJid
    }

    public override func isDomainFullJid(): Bool {
        return this is DomainFullJid
    }

    public override func hasResource(): Bool {
        return this is FullJid
    }

    public override func hasLocalpart(): Bool {
        return this is EntityJid
    }

    public override func asEntityBareJidOrThrow(): EntityBareJid {
        let entityBareJid: ?EntityBareJid = asEntityBareJidIfPossible()
        if (entityBareJid.isNone()) {
            throwIse("can not be converted to EntityBareJid")
        }
        return entityBareJid()
    }

    public override func asEntityFullJidOrThrow(): EntityFullJid {
        let entityFullJid: ?EntityFullJid = asEntityFullJidIfPossible()
        if (entityFullJid.isNone()) {
            throwIse("can not be converted to EntityFullJid")
        }
        return entityFullJid()
    }

    public override func asEntityJidOrThrow(): EntityJid {
        let entityJid: ?EntityJid = asEntityJidIfPossible()
        if (entityJid.isNone()) {
            throwIse("can not be converted to EntityJid")
        }
        return entityJid()
    }

    public override func asFullJidOrThrow(): EntityFullJid {
        let entityFullJid: ?EntityFullJid = asEntityFullJidIfPossible()
        if (entityFullJid.isNone()) {
            throwIse("can not be converted to EntityBareJid")
        }
        return entityFullJid()
    }

    public override func asDomainFullJidOrThrow(): DomainFullJid {
        let domainFullJid: ?DomainFullJid = asDomainFullJidIfPossible()
        if (domainFullJid.isNone()) {
            throwIse("can not be converted to DomainFullJid")
        }
        return domainFullJid()
    }

    public override func getResourceOrEmpty(): Resourcepart {
        let resourcepart: ?Resourcepart = getResourceOrNull()
        return resourcepart ?? Resourcepart.EMPTY
    }

    public override func getResourceOrThrow(): Resourcepart {
        let resourcepart: ?Resourcepart = getResourceOrNull()
        if (resourcepart.isNone()) {
            throwIse("has no resourcepart")
        }
        return resourcepart()
    }

    public override func getLocalpartOrThrow(): Localpart {
        let localpart: ?Localpart = getLocalpartOrNull()
        if (localpart.isNone()) {
            throwIse("has no localpart")
        }
        return localpart()
    }

    public override func isParentOf(jid: Jid): Bool {
        let fullJid: ?EntityFullJid = jid.asEntityFullJidIfPossible()
        if (let Some(v) <- fullJid) {
            return isParentOf(v)
        }
        let bareJid: ?EntityBareJid = jid.asEntityBareJidIfPossible()
        if (let Some(v) <- bareJid) {
            return isParentOf(v)
        }
        let domainFullJid: ?DomainFullJid = jid.asDomainFullJidIfPossible()
        if (let Some(v) <- domainFullJid) {
            return isParentOf(v)
        }

        return isParentOf(jid.asDomainBareJid())
    }

    @OverflowWrapping
    public override func hashCode(): Int {
        return toString().hashCode()
    }

    private var urlEncodedCache: ?String = None

    public override func asUrlEncodedString(): String {
        return if (let Some(v) <- urlEncodedCache) {
            v
        } else {
            let v = toString()
            urlEncodedCache = v
            v
        }
    }

    private func throwIse(message: String): Unit {
        let exceptionMessage: String = "The JID '${this}' ${message}"
        throw IllegalStateException(exceptionMessage)
    }

    public operator override func ==(other: Jid): Bool {
        return this.toString() == other.toString()
    }
    public operator override func !=(other: Jid): Bool {
        return this.toString() != other.toString()
    }
    public operator func ==(other: EntityFullJid): Bool {
        this.toString() == other.toString()
    }
    public operator func !=(other: EntityFullJid): Bool {
        this.toString() != other.toString()
    }
    public operator func ==(other: EntityBareJid): Bool {
        this.toString() == other.toString()
    }
    public operator func !=(other: EntityBareJid): Bool {
        this.toString() != other.toString()
    }
    public operator func ==(other: DomainFullJid): Bool {
        this.toString() == other.toString()
    }
    public operator func !=(other: DomainFullJid): Bool {
        this.toString() != other.toString()
    }
}

/**
 * RFC6122 2.4 allows JIDs with only a domain and resource part.
 * <p>
 * Note that this implementation does not require an cache for the unescaped
 * string, compared to {@link LocalDomainAndResourcepartJid}.
 * </p>
 *
 */
public class DomainAndResourcepartJid <: AbstractJid & DomainFullJid {
    private let domainBareJid: DomainBareJid
    private let resource: Resourcepart

    init(domain: String, resource: ?String, context: XmppContext) {
        this(DomainpartJid(domain, context), Resourcepart.froms(resource, context))
    }

    init(domainBareJid: DomainBareJid, resource: Resourcepart) {
        this.domainBareJid = domainBareJid
        this.resource = resource
    }

    public override func toString(): String {
        if (cache.isSome()) {
            return cache()
        }
        cache = "${domainBareJid}/${resource}"
        return cache()
    }

    public override func asDomainBareJid(): DomainBareJid {
        return domainBareJid
    }

    public override func hasNoResource(): Bool {
        return false
    }

    public override func asEntityBareJidIfPossible(): ?EntityBareJid {
        return None
    }

    public override func asEntityFullJidIfPossible(): ?EntityFullJid {
        return None
    }

    public override func asDomainFullJidIfPossible(): ?DomainFullJid {
        return this
    }

    public override func getResourceOrNull(): ?Resourcepart {
        return getResourcepart()
    }

    public override func isParentOf(_: EntityBareJid): Bool {
        return false
    }

    public override func isParentOf(_: EntityFullJid): Bool {
        return false
    }

    public override func isParentOf(_: DomainBareJid): Bool {
        return false
    }

    public override func isParentOf(domainFullJid: DomainFullJid): Bool {
        return domainBareJid.toString() == domainFullJid.getDomain().toString() && resource ==
            domainFullJid.getResourcepart()
    }

    public override func getResourcepart(): Resourcepart {
        return resource
    }

    public override func asBareJid(): BareJid {
        return asDomainBareJid()
    }

    public override func getDomain(): Domainpart {
        return domainBareJid.getDomain()
    }

    public override func asUnescapedString(): String {
        return toString()
    }

    public override func asEntityJidIfPossible(): ?EntityJid {
        return None
    }

    public override func asFullJidIfPossible(): ?FullJid {
        return this
    }

    public override func getLocalpartOrNull(): ?Localpart {
        return None
    }
}

public class DomainpartJid <: AbstractJid & DomainBareJid {
    let domain: Domainpart

    init(domain: String, context: XmppContext) {
        this(Domainpart.froms(domain, context))
    }

    init(domain: Domainpart) {
        this.domain = domain
    }

    public override func getDomain(): Domainpart {
        return domain
    }

    public override func toString(): String {
        // Prefer the cached version over the domain.toString() one, since the cached version may
        // also be the internalized representation of the String. Which, e.g. provides benefits when
        // comparing JIDs.
        return if (let Some(v) <- cache) {
            v
        } else {
            let v = domain.toString()
            cache = v
            v
        }
    }

    public override func asUnescapedString(): String {
        // No un-escaping necessary for DomainpartJid
        return toString()
    }

    public override func asDomainBareJid(): DomainBareJid {
        return this
    }

    public override func hasNoResource(): Bool {
        return true
    }

    public override func asEntityBareJidIfPossible(): ?EntityBareJid {
        return None
    }

    public override func asEntityFullJidIfPossible(): ?EntityFullJid {
        return None
    }

    public override func asDomainFullJidIfPossible(): ?DomainFullJid {
        return None
    }

    public override func isParentOf(bareJid: EntityBareJid): Bool {
        return domain == bareJid.getDomain()
    }

    public override func isParentOf(fullJid: EntityFullJid): Bool {
        return domain == fullJid.getDomain()
    }

    public override func isParentOf(domainBareJid: DomainBareJid): Bool {
        return domain == domainBareJid.getDomain()
    }

    public override func isParentOf(domainFullJid: DomainFullJid): Bool {
        return domain == domainFullJid.getDomain()
    }

    public override func asBareJid(): BareJid {
        return this
    }

    public override func asEntityJidIfPossible(): ?EntityJid {
        return None
    }

    public override func asFullJidIfPossible(): ?FullJid {
        return None
    }

    public override func getResourceOrNull(): ?Resourcepart {
        return None
    }

    public override func getLocalpartOrNull(): ?Localpart {
        return None
    }
}

public class LocalAndDomainpartJid <: AbstractJid & EntityBareJid {
    private let domainBareJid: DomainBareJid
    private let localpart: Localpart

    private var unescapedCache: ?String = None

    init(localpart: ?String, domain: String, context: XmppContext) {
        this.domainBareJid = DomainpartJid(domain, context)
        this.localpart = Localpart.froms(localpart, context)
    }

    init(localpart: Localpart, domain: Domainpart) {
        this.localpart = localpart
        this.domainBareJid = DomainpartJid(domain)
    }

    public override func getLocalpart(): Localpart {
        return localpart
    }

    public override func toString(): String {
        if (cache.isSome()) {
            return cache()
        }
        cache = "${getLocalpart()}@${domainBareJid}"
        return cache()
    }

    public override func asUnescapedString(): String {
        if (unescapedCache.isSome()) {
            return unescapedCache()
        }
        unescapedCache = getLocalpart().asUnescapedString() + "@" + domainBareJid.toString()
        return unescapedCache()
    }

    public override func asEntityBareJidIfPossible(): ?EntityBareJid {
        return this
    }

    public override func asEntityFullJidIfPossible(): ?EntityFullJid {
        return None
    }

    public override func asDomainFullJidIfPossible(): ?DomainFullJid {
        return None
    }

    public override func isParentOf(bareJid: EntityBareJid): Bool {
        return domainBareJid.toString() == bareJid.getDomain().toString() && localpart == bareJid.getLocalpart()
    }

    public override func isParentOf(fullJid: EntityFullJid): Bool {
        return isParentOf(fullJid.asBareJid())
    }

    public override func isParentOf(_: DomainBareJid): Bool {
        return false
    }

    public override func isParentOf(_: DomainFullJid): Bool {
        return false
    }

    public override func asDomainBareJid(): DomainBareJid {
        return domainBareJid
    }

    public override func getDomain(): Domainpart {
        return domainBareJid.getDomain()
    }

    public override func asBareJid(): BareJid {
        return this
    }

    public override func hasNoResource(): Bool {
        return true
    }

    public override func asEntityJidIfPossible(): ?EntityJid {
        return this
    }

    public override func asFullJidIfPossible(): ?FullJid {
        return None
    }

    public override func asEntityBareJid(): EntityBareJid {
        return this
    }

    public override func getResourceOrNull(): ?Resourcepart {
        return None
    }

    public override func getLocalpartOrNull(): ?Localpart {
        return getLocalpart()
    }

    public override func asEntityBareJidString(): String {
        return toString()
    }
}

public class LocalDomainAndResourcepartJid <: AbstractJid & EntityFullJid {
    private let bareJid: EntityBareJid
    private let resource: Resourcepart

    private var unescapedCache: ?String = None

    init(localpart: ?String, domain: String, resource: ?String, context: XmppContext) {
        this(LocalAndDomainpartJid(localpart, domain, context), Resourcepart.froms(resource, context))
    }

    init(bareJid: EntityBareJid, resource: Resourcepart) {
        this.bareJid = bareJid
        this.resource = resource
    }

    public override func toString(): String {
        if (cache.isSome()) {
            return cache()
        }
        cache = bareJid.toString() + "/" + resource.toString()
        return cache()
    }

    public override func asUnescapedString(): String {
        if (unescapedCache.isSome()) {
            return unescapedCache()
        }
        unescapedCache = bareJid.asUnescapedString() + "/" + resource.toString()
        return unescapedCache()
    }

    public override func asEntityBareJid(): EntityBareJid {
        return bareJid
    }

    public override func asEntityBareJidString(): String {
        return asEntityBareJid().toString()
    }

    public override func hasNoResource(): Bool {
        return false
    }

    public override func asEntityBareJidIfPossible(): ?EntityBareJid {
        return asEntityBareJid()
    }

    public override func asEntityFullJidIfPossible(): ?EntityFullJid {
        return this
    }

    public override func asDomainFullJidIfPossible(): ?DomainFullJid {
        return None
    }

    public override func getLocalpartOrNull(): ?Localpart {
        return bareJid.getLocalpart()
    }

    public override func getResourceOrNull(): ?Resourcepart {
        return getResourcepart()
    }

    public override func isParentOf(_: EntityBareJid): Bool {
        return false
    }

    public override func isParentOf(fullJid: EntityFullJid): Bool {
        return this == fullJid
    }

    public override func isParentOf(_: DomainBareJid): Bool {
        return false
    }

    public override func isParentOf(_: DomainFullJid): Bool {
        return false
    }

    public override func asDomainBareJid(): DomainBareJid {
        return bareJid.asDomainBareJid()
    }

    public override func getResourcepart(): Resourcepart {
        return resource
    }

    public override func asBareJid(): BareJid {
        return asEntityBareJid()
    }

    public override func getDomain(): Domainpart {
        return bareJid.getDomain()
    }

    public override func getLocalpart(): Localpart {
        return bareJid.getLocalpart()
    }

    public override func asEntityJidIfPossible(): ?EntityJid {
        return this
    }

    public override func asFullJidIfPossible(): ?FullJid {
        return this
    }
}

extend LocalAndDomainpartJid {}
