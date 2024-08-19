/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

public class JidUtil {

    /**
     * Check if the given CharSequence represents a typical and valid entity bare JID. This method does perform the same
     * check as {@link #isValidEntityBareJid(CharSequence)} and additionally verifies that the domainpart of the JID
     * contains at least one dot ('.') character.
     * <p>
     * For more information about the different verification methods see {@link #validateEntityBareJid(CharSequence)}.
     * </p>
     *
     * @param jid the CharSequence to check.
     * @return true if @{code jid} represents a valid entity bare JID, false otherwise
     * @see #isValidEntityBareJid(CharSequence)
     * @see EntityBareJid
     */
    public static func isTypicalValidEntityBareJid(jid: String): Bool {
        try {
            validateTypicalEntityBareJid(jid)
        } catch (e: Exception) {
            return false
        }
        return true
    }

    /**
     * Check if the given CharSequence is a typical and valid entity bare JID. This method does perform the same
     * check as {@link #isValidEntityBareJid(CharSequence)} and additionally verifies that the domainpart of the JID
     * contains at least one dot ('.') character.
     * <p>
     * The <code>…TypicalValidEntityBareJid(CharSequence)</code> methods are useful if you expect your users to always
     * enter a FQDN as domainpart. Whereas <code>isValidEntityBareJid(CharSequence)</code> and
     * <code>validateEntityBareJid</code> accept also inputs like "foo@example", the "is typical JID" methods require
     * the domainpart to contain a dot, e.g. "foo@example.org".
     * </p>
     *
     * @param jidcs the JID CharSequence
     * @return a BareJid instance representing the given JID CharSequence
     * @throws NotAEntityBareJidStringException if the given CharSequence is not a bare JID.
     * @throws XmppStringprepException if an error happens.
     */
    public static func validateTypicalEntityBareJid(jidcs: String): EntityBareJid {
        let jid = validateEntityBareJid(jidcs)
        if (jid.getDomain().toString().indexOf(".").isNone()) {
            throw NotAEntityBareJidStringException("Domainpart does not include a dot ('.') character")
        }
        return jid
    }

    /**
     * Check if the given CharSequence represents a valid entity bare JID. That
     * is, it must consists exactly of a local- and a domainpart
     * (&lt;localpart@domainpart&gt;).
     * <p>
     * This method is meant to validate user input and give fast feedback (e.g.
     * with a red or green light) about if the user entered CharSequence
     * represents a bare JID.
     * </p>
     *
     * @param jid
     *            the CharSequence to check.
     * @return true if @{code jid} represents a valid entity bare JID, false otherwise
     * @see EntityBareJid
     */
    public static func isValidEntityBareJid(jid: String): Bool {
        try {
            validateEntityBareJid(jid)
        } catch (e: Exception) {
            return false
        }
        return true
    }

    /**
     * Check if the given CharSequence is a valid entity bare JID. That
     * is, it must consists exactly of a local- and a domainpart
     * (&lt;localpart@domainpart&gt;).
     * <p>
     * This is a convenience method meant to validate user entered bare JIDs. If
     * the given {@code jid} is not a valid bare JID, then this method will
     * throw either {@link NotAEntityBareJidStringException} or
     * {@link XmppStringprepException}. The NotABareJidStringException will
     * contain a meaningful message explaining why the given CharSequence is not a
     * valid bare JID (e.g. "does not contain a '@' character").
     * </p>
     *
     * @param jidcs the JID CharSequence
     * @return a BareJid instance representing the given JID CharSequence
     * @throws NotAEntityBareJidStringException if the given CharSequence is not a bare JID.
     * @throws XmppStringprepException if an error happens.
     */
    public static func validateEntityBareJid(jidcs: String): EntityBareJid {
        let jid: String = jidcs
        let atIndex = jid.indexOf("@") ?? -1
        if (atIndex == -1) {
            throw NotAEntityBareJidStringException("'${jid}' does not contain a '@' character")
        } else if ((jid.indexOf("@", atIndex + 1) ?? -1) != -1) {
            throw NotAEntityBareJidStringException("'${jid}' contains multiple '@' characters")
        }
        let localpart = XmppStringUtils.parseLocalpart(jid)
        if (localpart.isNone() || (localpart?.size ?? 0) == 0) {
            throw NotAEntityBareJidStringException("'${jid}' has empty localpart")
        }
        let domainpart = XmppStringUtils.parseDomain(jid)
        if (domainpart.isEmpty() || Int64(domainpart.size) == 0) {
            throw NotAEntityBareJidStringException("'${jid}' has empty domainpart")
        }
        return JidCreate.entityBareFromUnescaped(jid)
    }

    /**
     * Filter all entity bare JIDs.
     *
     * @param in the input collection.
     * @param out the collection where the filtered JIDs are added to.
     */
    public static func filterEntityBareJid(input: Collection<Jid>, appendFunc: (EntityBareJid) -> Unit): Unit {
        for (jid in input) {
            let bareJid = jid.asEntityBareJidIfPossible()
            if (let Some(bareJid) <- bareJid) {
                appendFunc(bareJid)
            }
        }
    }

    /**
     * Filter all entity bare JIDs.
     *
     * @param input the input collection.
     * @return a set containing all bare JIDs of the input collection.
     */
    public static func filterEntityBareJidSet(input: Collection<Jid>): Set<EntityBareJid> {
        let res = HashSet<EntityBareJid>(input.size)
        filterEntityBareJid(input, {r => res.put(r)})
        return res
    }

    /**
     * Filter all entity bare JIDs.
     *
     * @param input the input collection.
     * @return a list containing all bare JIDs of the input collection.
     */
    public static func filterEntityBareJidList(input: Collection<Jid>): ArrayList<EntityBareJid> {
        let res = ArrayList<EntityBareJid>(input.size)
        filterEntityBareJid(input, res.append)
        return res
    }

    /**
     * Filter all entity full JIDs.
     *
     * @param in the input collection.
     * @param out the collection where the filtered JIDs are added to.
     */
    public static func filterEntityFullJid(input: Collection<Jid>, appendFunc: (EntityFullJid) -> Unit): Unit {
        for (jid in input) {
            let fullJid = jid.asEntityFullJidIfPossible()
            if (let Some(fullJid) <- fullJid) {
                appendFunc(fullJid)
            }
        }
    }

    /**
     * Filter all full JIDs.
     *
     * @param input the input collection.
     * @return a set containing all full JIDs of the input collection.
     */
    public static func filterEntityFullJidSet(input: Collection<Jid>): Set<EntityFullJid> {
        let res = HashSet<EntityFullJid>(input.size)
        filterEntityFullJid(input, {r => res.put(r)})
        return res
    }

    /**
     * Filter all full JIDs.
     *
     * @param input the input collection.
     * @return a list containing all full JIDs of the input collection.
     */
    public static func filterEntityFullJidList(input: Collection<Jid>): ArrayList<EntityFullJid> {
        let res = ArrayList<EntityFullJid>(input.size)
        filterEntityFullJid(input, res.append)
        return res
    }

    /**
     * Filter all domain full JIDs.
     *
     * @param in the input collection.
     * @param out the collection where the filtered JIDs are added to.
     */
    public static func filterDomainFullJid(input: Collection<Jid>, appendFunc: (DomainFullJid) -> Unit): Unit {
        for (jid in input) {
            let domainFullJid = jid.asDomainFullJidIfPossible()
            if (let Some(domainFullJid) <- domainFullJid) {
                appendFunc(domainFullJid)
            }
        }
    }

    /**
     * Filter all domain full JIDs.
     *
     * @param input the input collection.
     * @return a set containing all domain full JIDs of the input collection.
     */
    public static func filterDomainFullJidSet(input: Collection<Jid>): Set<DomainFullJid> {
        let res = HashSet<DomainFullJid>(input.size)
        filterDomainFullJid(input, {r => res.put(r)})
        return res
    }

    /**
     * Filter all domain full JIDs.
     *
     * @param input the input collection.
     * @return a list containing all domain full JIDs of the input collection.
     */
    public static func filterDomainFullJidList(input: Collection<Jid>): ArrayList<DomainFullJid> {
        let res = ArrayList<DomainFullJid>(input.size)
        filterDomainFullJid(input, res.append)
        return res
    }

    /**
     * Convert the given collection of CharSequences to bare JIDs.
     *
     * @param jidStrings the collection of CharSequences.
     * @return a set of bare JIDs.
     */
    public static func entityBareJidSetFrom(jidStrings: Collection<String>): Set<EntityBareJid> {
        let res = HashSet<EntityBareJid>(jidStrings.size)
        entityBareJidsFrom(jidStrings, {r => res.put(r)}, None)
        return res
    }

    public static func entityBareJidsFrom(jidStrings: Collection<String>, appendFunc: (EntityBareJid) -> Unit,
        exceptions: ?ArrayList<XmppStringprepException>): Unit {
        for (jid in jidStrings) {
            try {
                let bareJid = JidCreate.entityBareFrom(jid)
                appendFunc(bareJid)
            } catch (e: XmppStringprepException) {
                if (exceptions.isSome()) {
                    exceptions?.append(e)
                } else {
                    throw Exception("AssertionError ${e}")
                }
            }
        }
    }

    /**
     * Convert the given array of Strings to JIDs.
     * <p>
     * Note that errors while converting the Strings will be silently ignored.
     * </p>
     *
     * @param jids a array of JID Strings.
     * @return a set of JIDs.
     */
    public static func jidSetFrom(jids: Array<String>): Set<Jid> {
        return jidSetFrom(jids)
    }

    /**
     * Convert the given collection of CharSequences to JIDs.
     *
     * @param jidStrings the collection of CharSequences.
     * @return a set of JIDs.
     */
    public static func jidSetFrom(jidStrings: Collection<String>): Set<Jid> {
        let res: HashSet<Jid> = HashSet<Jid>(jidStrings.size)
        jidsFrom(jidStrings, {r => res.put(r)}, None)
        return res
    }

    public static func jidsFrom(jidStrings: Collection<String>, appendFunc: (Jid) -> Unit,
        exceptions: ?ArrayList<XmppStringprepException>): Unit {
        for (jidString in jidStrings) {
            try {
                let jid = JidCreate.froms(jidString)
                appendFunc(jid)
            } catch (e: XmppStringprepException) {
                if (exceptions.isSome()) {
                    exceptions?.append(e)
                } else {
                    throw Exception("AssertionError ${e}")
                }
            }
        }
    }

    /**
     * Convert a collection of JIDs to a list of Strings representing those JIDs.
     *
     * @param jids a collection of JIDs.
     * @return a list of Strings.
     */
    public static func toStringList(jids: Collection<Jid>): ArrayList<String> {
        let res = ArrayList<String>(jids.size)
        toStrings(jids, res.append)
        return res
    }

    /**
     * convert a collection of JIDs to a set of Strings representing those JIDs.
     *
     * @param jids a collection of JIDs.
     * @return a set of String.
     */
    public static func toStringSet(jids: Collection<Jid>): Set<String> {
        let res: Set<String> = HashSet<String>(jids.size)
        toStrings(jids, {r => res.put(r)})
        return res
    }

    /**
     * Convert a collection of JIDs to a Collection of Strings.
     *
     * @param jids the collection of Strings to convert.
     * @param jidStrings the collection of Strings to append to.
     */
    public static func toStrings(jids: Collection<Jid>, appendFunc: (String) -> Unit): Unit {
        for (jid in jids) {
            appendFunc(jid.toString())
        }
    }

    /**
     * Check if two JIDs are equals. Takes <code>None</code> values into consideration. Which means that this method will return <code>true</code> if both JIDs are <code>None</code>.
     *
     * @param jidOne The first JID to compare.
     * @param jidTwo The second JID to compare.
     * @return <code>true</code> if both JIDs are equals.
     */
    public static func equals(jidOne: ?Jid, jidTwo: ?Jid): Bool {
        return match ((jidOne, jidTwo)) {
            case (None, None) => true
            case (Some(jidOne), Some(jidTwo)) => jidOne == jidTwo
            case _ => false
        }
    }
}

public class NotAEntityBareJidStringException <: Exception {
    public init(message: String) {
        super(message)
    }
}
