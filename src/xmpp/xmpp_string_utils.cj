/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

class XmppStringUtils {
    /**
     * Returns the localpart of an XMPP address (JID). For example, for the address "user@xmpp.org/Resource", "user"
     * would be returned. Returns <code>null</code> if the given JID has no localpart. Returns the empty string if
     * the given JIDs localpart is the empty string (which is invalid).
     *
     * @param jid
     *            the XMPP address to parse.
     * @return the name portion of the XMPP address, the empty String or <code>null</code>.
     */
    public static func parseLocalpart(jid: String): ?String {
        let atIndex = jid.indexOf("@") ?? -1
        if (atIndex < 0) {
            return None
        }
        if (atIndex == 0) {
            // '@' as first character, i.e. '@example.org". Return empty string as
            // localpart, to make it possible to differentiate this from 'example.org'
            // (which would return 'null' as localpart).
            return ""
        }

        let slashIndex = jid.indexOf("/") ?? -1
        if (slashIndex >= 0 && slashIndex < atIndex) {
            // This is an '@' character in the resourcepart.
            return None
        }

        return jid[..atIndex]
    }

    /**
     * Returns the domain of an XMPP address (JID). For example, for the address "user@xmpp.org/Resource", "xmpp.org"
     * would be returned. If <code>jid</code> is <code>null</code>, then this method returns also <code>null</code>. If
     * the input String is no valid JID or has no domainpart, then this method will return the empty String.
     *
     * @param jid
     *            the XMPP address to parse.
     * @return the domainpart of the XMPP address, the empty String or <code>null</code>.
     */
    public static func parseDomain(jid: String): String {
        let atIndex = jid.indexOf("@") ?? -1
        let slashIndex = jid.indexOf("/") ?? -1
        if (slashIndex >= 0) {
            // 'local@domain.foo/resource' and 'local@domain.foo/res@otherres' case
            if (slashIndex > atIndex) {
                return jid[atIndex + 1..slashIndex]
            // 'domain.foo/res@otherres' case
            } else {
                return jid[..slashIndex]
            }
        } else {
            return jid[atIndex + 1..]
        }
    }

    /**
     * Returns the resource portion of an XMPP address (JID). For example, for the address "user@xmpp.org/Resource",
     * "Resource" would be returned. Returns <code>null</code> if the given JID has no resourcepart. Returns the
     * empty string if the given JID has an empty resourcepart (which is invalid).
     *
     * @param jid
     *            the XMPP address to parse.
     * @return the resource portion of the XMPP address.
     */
    public static func parseResource(jid: String): ?String {
        let slashIndex = jid.indexOf("/") ?? -1
        if (slashIndex < 0) {
            return None
        }
        return jid[slashIndex + 1..]
    }

    private static let LOCALPART_ESCAPE_CACHE: LruCache<String, String> = LruCache<String, String>(100)
    private static let LOCALPART_UNESCAPE_CACHE: LruCache<String, String> = LruCache<String, String>(100)

    /**
     * Escapes the localpart of a JID according to "JID Escaping" (XEP-0106).
     * Escaping replaces characters prohibited by Nodeprep with escape sequences,
     * as follows:
     * <table border="1">
     * <caption>Character mappings</caption>
     * <tr><td><b>Unescaped Character</b></td><td><b>Encoded Sequence</b></td></tr>
     * <tr><td>&lt;space&gt;</td><td>\20</td></tr>
     * <tr><td>"</td><td>\22</td></tr>
     * <tr><td>&amp;</td><td>\26</td></tr>
     * <tr><td>'</td><td>\27</td></tr>
     * <tr><td>/</td><td>\2f</td></tr>
     * <tr><td>:</td><td>\3a</td></tr>
     * <tr><td>&lt;</td><td>\3c</td></tr>
     * <tr><td>&gt;</td><td>\3e</td></tr>
     * <tr><td>@</td><td>\40</td></tr>
     * <tr><td>\</td><td>\5c</td></tr>
     * </table>
     *
     * <p>
     * This process is useful when the localpart comes from an external source that doesn't
     * conform to Nodeprep. For example, a username in LDAP may be "Joe Smith". Because
     * the &lt;space&gt; character isn't a valid part of a localpart, the username should
     * be escaped to "Joe\20Smith" before being made into a JID (e.g. "joe\20smith@example.com"
     * after case-folding, etc. has been applied).
     * </p>
     *
     * All localpart escaping and un-escaping must be performed manually at the appropriate
     * time; the JID class will not escape or un-escape automatically.
     *
     * @param localpart the localpart.
     * @return the escaped version of the localpart.
     * @see XEP-106: JID Escaping
     */
    public static func escapeLocalpart(localpartOption: ?String): ?String {
        let localpart = if (let Some(v) <- localpartOption) {
            v
        } else {
            return None
        }
        if (let Some(res) <- LOCALPART_ESCAPE_CACHE.lookup(localpart)) {
            return res
        }
        let buf: ArrayList<Byte> = ArrayList<Byte>(localpart.size + 8)
        for (c in localpart) {
            match (c) {
                case b'"' => buf.appendAll("\\22".toArray())
                case b'&' => buf.appendAll("\\26".toArray())
                case b'\'' => buf.appendAll("\\27".toArray())
                case b'/' => buf.appendAll("\\2f".toArray())
                case b':' => buf.appendAll("\\3a".toArray())
                case b'<' => buf.appendAll("\\3c".toArray())
                case b'>' => buf.appendAll("\\3e".toArray())
                case b'@' => buf.appendAll("\\40".toArray())
                case b'\\' => buf.appendAll("\\5c".toArray())
                case _ => if (Rune(c).isWhiteSpace()) {
                    buf.appendAll("\\20".toArray())
                } else {
                    buf.append(c)
                }
            }
        }
        let res = unsafe { String.fromUtf8Unchecked(buf.getRawArray()[..buf.size]) }
        LOCALPART_ESCAPE_CACHE.put(localpart, res)
        return res
    }

    /**
     * Un-escapes the localpart of a JID according to "JID Escaping" (XEP-0106).
     * Escaping replaces characters prohibited by Nodeprep with escape sequences,
     * as follows:
     *
     * <table border="1">
     * <caption>Character mapping</caption>
     * <tr><td><b>Unescaped Character</b></td><td><b>Encoded Sequence</b></td></tr>
     * <tr><td>&lt;space&gt;</td><td>\20</td></tr>
     * <tr><td>"</td><td>\22</td></tr>
     * <tr><td>&amp;</td><td>\26</td></tr>
     * <tr><td>'</td><td>\27</td></tr>
     * <tr><td>/</td><td>\2f</td></tr>
     * <tr><td>:</td><td>\3a</td></tr>
     * <tr><td>&lt;</td><td>\3c</td></tr>
     * <tr><td>&gt;</td><td>\3e</td></tr>
     * <tr><td>@</td><td>\40</td></tr>
     * <tr><td>\</td><td>\5c</td></tr>
     * </table>
     *
     * <p>
     * This process is useful when the localpart comes from an external source that doesn't
     * conform to Nodeprep. For example, a username in LDAP may be "Joe Smith". Because
     * the &lt;space&gt; character isn't a valid part of a localpart, the username should
     * be escaped to "Joe\20Smith" before being made into a JID (e.g. "joe\20smith@example.com"
     * after case-folding, etc. has been applied).
     * </p>
     *
     * All localpart escaping and un-escaping must be performed manually at the appropriate
     * time; the JID class will not escape or un-escape automatically.
     *
     * @param localpart the escaped version of the localpart.
     * @return the un-escaped version of the localpart.
     * @see XEP-106: JID Escaping
     */
    public static func unescapeLocalpart(localpart: String): String {
        if (let Some(res) <- LOCALPART_UNESCAPE_CACHE.lookup(localpart)) {
            return res
        }
        let buf: ArrayList<Byte> = ArrayList<Byte>(localpart.size)
        var i = 0
        while (i < localpart.size) {
            let c = localpart[i]
            var doAppendC = true
            if (c == b'\\' && i + 2 < localpart.size) {
                let c2 = localpart[i + 1]
                let c3 = localpart[i + 2]
                match (c2) {
                    case b'2' => match (c3) {
                        case b'0' =>
                            buf.append(b' ')
                            i += 2
                            doAppendC = false
                        case b'2' =>
                            buf.append(b'"')
                            i += 2
                            doAppendC = false
                        case b'6' =>
                            buf.append(b'&')
                            i += 2
                            doAppendC = false
                        case b'7' =>
                            buf.append(b'\'')
                            i += 2
                            doAppendC = false
                        case b'f' =>
                            buf.append(b'/')
                            i += 2
                            doAppendC = false
                        case _ => ()
                    }
                    case b'3' => match (c3) {
                        case b'a' =>
                            buf.append(b':')
                            i += 2
                            doAppendC = false
                        case b'c' =>
                            buf.append(b'<')
                            i += 2
                            doAppendC = false
                        case b'e' =>
                            buf.append(b'>')
                            i += 2
                            doAppendC = false
                        case _ => ()
                    }
                    case b'4' => if (c3 == b'0') {
                        buf.append(b'@')
                        i += 2
                        doAppendC = false
                    }
                    case b'5' => if (c3 == b'c') {
                        buf.append(b'\\')
                        i += 2
                        doAppendC = false
                    }
                    case _ => ()
                }
            }
            if (doAppendC) {
                buf.append(c)
            }
        }
        let res = unsafe { String.fromUtf8Unchecked(buf.getRawArray()[..buf.size]) }
        LOCALPART_UNESCAPE_CACHE.put(localpart, res)
        return res
    }

    /**
     * Construct a JID String from the given parts.
     *
     * @param localpart the localpart.
     * @param domainpart the domainpart.
     * @param resource the resourcepart.
     * @return the constructed JID String.
     */
    public static func completeJidFrom(localpart: ?String, domainpart: String, resource: ?String): String {
        var maxResLength = domainpart.size
        maxResLength += localpart?.size ?? -1 + 1
        maxResLength += resource?.size ?? -1 + 1

        let sb = StringBuilder(maxResLength)
        if (let Some(v) <- localpart) {
            sb.append(v)
            sb.append("@")
        }
        sb.append(domainpart)
        if (let Some(v) <- resource) {
            sb.append("/")
            sb.append(v)
        }
        return sb.toString()
    }

    /**
     * Returns true if jid is a full JID (i.e. a JID with resource part).
     *
     * @param jid the String to check.
     * @return true if full JID, false otherwise
     */
    public static func isFullJID(jid: String): Bool {
        let domain = parseDomain(jid)
        let resource = parseResource(jid)
        if (domain.size == 0 || (resource?.size ?? 0) == 0) {
            return false
        }
        return true
    }

    /**
     * Returns true if <code>jid</code> is a bare JID ("foo@bar.com").
     * <p>
     * This method may return true for Strings that are not valid JIDs (e.g. because of Stringprep violations).
     * Consider using JidUtil.validateBareJid(String) instead of this method as it
     * exceptions provide a meaningful message string why the JID is not a bare JID and will also check for Stringprep
     * errors.
     * </p>
     *
     * @param jid the String to check.
     * @return true if bare JID, false otherwise
     */
    public static func isBareJid(jid: String): Bool {
        let domain = parseDomain(jid)
        let resource = parseResource(jid)
        return (domain.size > 0 && (resource?.size ?? 0) == 0)
    }
}
