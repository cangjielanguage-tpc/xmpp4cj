/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.jid

public class XmppStringUtils {
    /**
     * 返回XMPP地址（JID）的本地部分。
     * 例如，对于地址“user@xmpp.org/将返回Resource“，”user“。如果给定的JID没有localpart，则返回<code>None</code>。
     * 如果给定JID的localpart是空字符串（无效），则返回空字符串。
     *
     * @param jid 要解析的XMPP地址。
     * @return XMPP地址的名称部分，空字符串或<code>None</code>。
     */
    public static func parseLocalpart(jid: String): ?String {
        let atIndex = jid.indexOf("@") ?? return None
        if (atIndex == 0) {
            // '@' as first character, i.e. '@example.org". Return empty string as
            // localpart, to make it possible to differentiate this from 'example.org'
            // (which would return 'None' as localpart).
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
     * 返回XMPP地址（JID）的域。例如，对于地址“user@xmpp.org/返回资源“，”xmpp.org“。
     * 如果<code>jid</code>为<code>None</code]，则此方法也返回<code>None</code>.如果输入的String不是有效的jid或没有域部分，则此法将返回空String。
     *
     * @param jid 要解析的XMPP地址。
     * @return 返回XMPP地址的域部分，空字符串或<code>None</code>。
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
     * 返回XMPP地址（JID）的资源部分。
     * 例如，对于地址“user@xmpp.org/将返回资源“，source”。如果给定的JID没有资源部分，则返回<code>None</code>。
     * 如果给定的JID具有空资源部分（无效），则返回空字符串。
     *
     * @param jid 要解析的XMPP地址。
     * @return 返回XMPP地址的资源部分。
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
     * *根据“JID Escaping”（XEP-0106）逃离JID的本地部分。
     * 转义将Nodeprep禁止的字符替换为转义序列:
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
     * 当本地部分来自不符合Nodeprep的外部源时，此过程很有用。
     * 例如，LDAP中的用户名可能是“Joe Smith”。
     * 因为&lt；空间&gt；字符不是本地部分的有效部分，在将用户名转换为JID之前，应将其转义为“Joe\20Smith”
     * （例如“Joe”\20smith@example.com“在应用了案例折叠等之后）。
     * </p>
     *
     * 所有局部逃逸和解除逃逸必须在适当的时候手动执行；JID类不会自动逃逸或取消逃逸。
     *
     * @param localpart 表示本地部分。
     * @return localpart的转义版本。
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
                case b'"' => buf.appendAll(unsafe { "\\22".rawData() })
                case b'&' => buf.appendAll(unsafe { "\\26".rawData() })
                case b'\'' => buf.appendAll(unsafe { "\\27".rawData() })
                case b'/' => buf.appendAll(unsafe { "\\2f".rawData() })
                case b':' => buf.appendAll(unsafe { "\\3a".rawData() })
                case b'<' => buf.appendAll(unsafe { "\\3c".rawData() })
                case b'>' => buf.appendAll(unsafe { "\\3e".rawData() })
                case b'@' => buf.appendAll(unsafe { "\\40".rawData() })
                case b'\\' => buf.appendAll(unsafe { "\\5c".rawData() })
                case _ =>
                    if ((0x9 <= c && c <= 0xd) || c == 0x20) {
                        buf.appendAll(unsafe { "\\20".rawData() })
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
     * Un-escapes 根据“JID Escaping”（XEP-0106），JID的本地部分。
     * 转义将Nodeprep禁止的字符替换为转义序列，如下所示：:
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
     * 当本地部分来自不符合Nodeprep的外部源时，此过程很有用。
     * 例如，LDAP中的用户名可能是“Joe Smith”。
     * 因为&lt；空间&gt；字符不是本地部分的有效部分，在将用户名转换为JID之前，应将其转义为“Joe\20Smith”
     * （例如“Joe”\20smith@example.com“在应用了案例折叠等之后）。
     * </p>
     *
     * 所有局部逃逸和解除逃逸必须在适当的时候手动执行；JID类不会自动逃逸或取消逃逸。
     *
     * @param localpart 是localpart的转义版本。
     * @return localpart的未转义版本。
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
                    case b'4' =>
                        if (c3 == b'0') {
                            buf.append(b'@')
                            i += 2
                            doAppendC = false
                        }
                    case b'5' =>
                        if (c3 == b'c') {
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
            i++
        }
        let res = unsafe { String.fromUtf8Unchecked(buf.getRawArray()[..buf.size]) }
        LOCALPART_UNESCAPE_CACHE.put(localpart, res)
        return res
    }

    /**
     * 从给定的部分构造一个JID字符串。
     *
     * @param localpart 本地部分。
     * @param domainpart 领域部分。
     * @return 构建的JID字符串。
     */
    public static func completeJidFrom(localpart: ?String, domainpart: String): String {
        return completeJidFrom(localpart, domainpart, None)
    }

    /**
     * 从给定的部分构造一个JID字符串。
     *
     * @param localpart 本地部分。
     * @param domainpart 领域部分。
     * @param resource 资源部分。
     * @return 构建的JID字符串。
     */
    public static func completeJidFrom(localpart: ?String, domainpart: String, resource: ?String): String {
        var maxResLength = domainpart.size + 2
        maxResLength += localpart?.size ?? 0
        maxResLength += resource?.size ?? 0

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
     * 如果jid是一个完整的jid（即具有资源部分的jid），则返回true。
     *
     * @param jid 要检查的字符串。
     * @return 如果完整的JID返回true，否则返回false。
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
     * *如果<code>jid</code>是一个裸露的jid（“foo@bar.com")。
     * <p>
     * 对于不是有效JID的字符串（例如，由于Stringprep违规），此方法可能会返回true。
     * 考虑使用JidUtil.validateBareJid（String）代替此方法，因为异常提供了一个有意义的消息字符串，说明JID不是裸JID，并且还将检查Stringprep错误。
     * </p>
     *
     * @param jid 要检查的字符串。
     * @return 如果没有JID，则返回true，否则返回false。
     */
    public static func isBareJid(jid: String): Bool {
        let domain = parseDomain(jid)
        let resource = parseResource(jid)
        return (domain.size > 0 && (resource?.size ?? 0) == 0)
    }
}
