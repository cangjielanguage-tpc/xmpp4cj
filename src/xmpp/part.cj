/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

public abstract class Part <: ToString & Hashable & Equatable<Part> {
    private let part: String

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

    protected static func assertNotLongerThan1023BytesOrEmpty(string: String): Unit {
        let bytes = string

        // Better throw XmppStringprepException instead of IllegalArgumentException here, because users don't expect an
        // IAE and it also makes the error handling for users easier.
        if (bytes.size > 1023) {
            throw XmppStringprepException(string, "Given string is longer then 1023 bytes")
        } else if (bytes.size == 0) {
            throw XmppStringprepException(string, "Argument can't be the empty string")
        }
    }
}

/**
 * A <i>localpart</i> of an XMPP address (JID). The localpart is the part before the
 * first @ sign in an XMPP address and usually identifies the user (or the XMPP
 * entity) within an XMPP service. It is also often referred to as "username",
 * but note that the actual username used to login may be different from the
 * resulting localpart of the user's JID.
 * <p>
 * You can create instances of this class from Strings using {@link #from(String)}.
 * </p>
 *
 * @see RFC 6122 § 2.3. Localpart
 */
public class Localpart <: Part {
    private var unescapedCache: ?String = None

    private init(localpart: String) {
        super(localpart)
    }

    /**
     * Return the <b>unescaped</b> String representation of this Localpart.
     * <p>
     * Since certain Unicode code points are disallowed in the localpart of a JID by the required stringprep profile,
     * those need to get escaped when used in a real JID. The unescaped representation of the JID is only for
     * presentation to a human user or for gatewaying to a non-XMPP system.
     * </p>
     *
     * @return the unescaped String representation of this JID.
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
     * Like {@link #from(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link Localpart}
     * @return the {@link Localpart} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid {@link Localpart}
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
     * Like {@link #fromUnescaped(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link Localpart}
     * @return the {@link Localpart} if no exception occurs
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
     * Get a {@link Localpart} from a given {@link CharSequence} or {@code None} if the input is not a valid localpart.
     *
     * @param cs the input CharSequence
     * @return a Localpart or {@code None}
     */
    public static func formUnescapedOrNull(cs: String): ?Localpart {
        try {
            return fromUnescaped(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get a {@link Localpart} from an unescaped String.
     *
     * @param unescapedLocalpart an unescaped String representing a Localpart.
     * @return a Localpart
     * @throws XmppStringprepException if an error occurs.
     */
    public static func fromUnescaped(unescapedLocalpart: String): Localpart {
        let escapedLocalpartString: ?String = XmppStringUtils.escapeLocalpart(unescapedLocalpart)
        return froms(escapedLocalpartString)
    }

    /**
     * Get a {@link Localpart} from a given {@link CharSequence} or {@code None} if the input is not a valid localpart.
     *
     * @param cs the input CharSequence
     * @return a Localpart or {@code None}
     */
    public static func fromOrNull(cs: String): ?Localpart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Get the {@link Localpart} representing the input String.
     *
     * @param localpart the input String.
     * @return the localpart.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(localpart: ?String): Localpart {
        return froms(localpart, XmppContext.getDefaultContext())
    }

    /**
     * Get the {@link Localpart} representing the input String.
     *
     * @param localpart the input String.
     * @param context the XMPP context.
     * @return the localpart.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(localpartStr: ?String, context: XmppContext): Localpart {
        let localpart = XmppStringPrepUtil.localprep(localpartStr, context)
        // First prep the String, then assure the limits of the *result*
        assertNotLongerThan1023BytesOrEmpty(localpart)
        return Localpart(localpart)
    }
}

/**
 * A <i>resourcepart</i> of an XMPP address (JID).
 * <p>
 * You can create instances of this class from Strings using {@link #from(String)}.
 * </p>
 *
 * @see RFC 6122 § 2.4. Resourcepart
 */
public class Resourcepart <: Part {

    /**
     * The empty resource part.
     * <p>
     * This empty resource part is the part that is represented by the empty String. This is useful in cases where you
     * have a collection of Resourceparts that does not allow <code>None</code> values, but you want to deal with the
     * "no resource" case.
     * </p>
     */
    public static let EMPTY: Resourcepart = Resourcepart("")

    private Resourcepart(resource: String) {
        super(resource)
    }

    /**
     * Get a {@link Resourcepart} from a given {@link CharSequence} or {@code None} if the input is not a valid resourcepart.
     *
     * @param cs the input CharSequence
     * @return a Resourcepart or {@code None}
     */
    public static func fromOrNull(cs: String): ?Resourcepart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Like {@link #from(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link Resourcepart}
     * @return the {@link Resourcepart} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid {@link Resourcepart}
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
     * Get the {@link Resourcepart} representing the input String.
     *
     * @param resource the input String.
     * @return the resource part.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(resource: ?String): Resourcepart {
        return froms(resource, XmppContext.getDefaultContext())
    }

    /**
     * Get the {@link Resourcepart} representing the input String.
     *
     * @param resource the input String.
     * @param context the XMPP context.
     * @return the resource part.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(resource: ?String, context: XmppContext): Resourcepart {
        let str = XmppStringPrepUtil.resourceprep(resource, context)
        // First prep the String, then assure the limits of the *result*
        assertNotLongerThan1023BytesOrEmpty(str)
        return Resourcepart(str)
    }
}

/**
 * A <i>domainpart</i> of an XMPP address (JID).
 * <p>
 * You can create instances of this class from Strings using {@link #from(String)}.
 * </p>
 *
 * @see RFC 6122 § 2.2. Domainpart
 */
public class Domainpart <: Part {
    private Domainpart(domain: String) {
        super(domain)
    }

    /**
     * Get a {@link Domainpart} from a given {@link CharSequence} or {@code None} if the input is not a valid domainpart.
     *
     * @param cs the input CharSequence
     * @return a Domainpart or {@code None}
     */
    public static func fromOrNull(cs: String): ?Domainpart {
        try {
            return froms(cs)
        } catch (e: XmppStringprepException) {
            return None
        }
    }

    /**
     * Like {@link #from(String)} but does throw an unchecked {@link IllegalArgumentException} instead of a
     * {@link XmppStringprepException}.
     *
     * @param cs the character sequence which should be transformed to a {@link Domainpart}
     * @return the {@link Domainpart} if no exception occurs
     * @throws IllegalArgumentException if the given input is not a valid {@link Domainpart}
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
     * Get the {@link Domainpart} representing the input String.
     *
     * @param domain the input String.
     * @return the domainpart.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(domain: String): Domainpart {
        return froms(domain, XmppContext.getDefaultContext())
    }

    /**
     * Get the {@link Domainpart} representing the input String.
     *
     * @param domain the input String.
     * @param context the XMPP context.
     * @return the domainpart.
     * @throws XmppStringprepException if an error occurs.
     */
    public static func froms(domainStr: String, context: XmppContext): Domainpart {
        // RFC 6122 § 2.2 "If the domainpart includes a final character considered to be a label
        // separator (dot) by [IDNA2003] or [DNS], this character MUST be stripped …"
        var domain = domainStr
        if (domain.size > 0 && domain[domain.size - 1] == b'.') {
            domain = domain[..domain.size]
        }
        domain = XmppStringPrepUtil.domainprep(domain, context)
        // First prep the String, then assure the limits of the *result*
        assertNotLongerThan1023BytesOrEmpty(domain)
        return Domainpart(domain)
    }
}
