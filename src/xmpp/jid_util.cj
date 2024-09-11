/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

public class JidUtil {

    /**
     * 用于检查给定的字符序列是否代表一个典型且有效的实体裸 JID（EntityBareJid）。该方法执行与isValidEntityBareJid(CharSequence)相同的检查，并且还会额外验证 JID 的域部分是否至少包含一个点（'.'）字符。
     * <p>
     * 对于不同验证方法的更多信息，可以参考validateEntityBareJid(CharSequence)方法。
     * </p>
     *
     * @param jid 要检查的字符序列
     * @return 如果jid表示一个有效的实体裸 JID，则返回true；否则返回false。
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
     * 用于检查给定的字符序列是否是一个典型且有效的实体裸 JID。该方法执行与isValidEntityBareJid(CharSequence)相同的检查，并且还额外验证 JID 的域部分是否至少包含一个点（'.'）字符。
     * <p>
     * “…TypicalValidEntityBareJid (CharSequence)” 方法在你期望用户始终输入完全限定域名（FQDN）作为域部分时很有用。而 “isValidEntityBareJid (CharSequence)” 和 “validateEntityBareJid” 方法也接受像 “foo@example” 这样的输入，但 “是典型 JID” 方法要求域部分包含一个点，例如 “foo@example.org”。
     * </p>
     *
     * @param jidcs 要检查的 JID 字符序列。
     * @return 如果输入是有效的典型实体裸 JID，则返回一个EntityBareJid实例，表示给定的 JID 字符序列。
     * @throws NotAEntityBareJidStringException 如果给定的字符序列不是裸 JID
     * @throws XmppStringprepException 如果发生错误
     */
    public static func validateTypicalEntityBareJid(jidcs: String): EntityBareJid {
        let jid = validateEntityBareJid(jidcs)
        if (jid.getDomain().toString().indexOf(".").isNone()) {
            throw NotAEntityBareJidStringException("Domainpart does not include a dot ('.') character")
        }
        return jid
    }

    /**
     * 用于检查给定的字符序列是否代表一个有效的实体裸 JID（EntityBareJid）。也就是说，它必须正好由一个本地部分（localpart）和一个域部分（domainpart）组成（<localpart@domainpart>）。
     * <p>
     * 此方法旨在验证用户输入，并快速反馈（例如通过红灯或绿灯）用户输入的字符序列是否表示一个裸 JID
     * </p>
     *
     * @param jid 要检查的字符序列。
     * @return 如果jid表示一个有效的实体裸 JID，则返回true；否则返回false。
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
     * 检查给定的字符序列是否是一个有效的实体裸 JID。也就是说，它必须正好由一个本地部分和一个域部分组成（<localpart@domainpart>）。
     * <p>
     * 这是一个方便的方法，用于验证用户输入的裸 JID。如果给定的 jid 不是一个有效的裸 JID，那么这个方法将抛出 NotAEntityBareJidStringException 或 XmppStringprepException。NotABareJidStringException 将包含一个有意义的消息，解释为什么给定的字符序列不是一个有效的裸 JID（例如“不包含‘@’字符”）。
     * </p>
     *
     * @param jidcs JID 字符序列。
     * @return 表示给定 JID 字符序列的 BareJid 实例。
     * @throws NotAEntityBareJidStringException 如果给定的字符序列不是裸 JID。
     * @throws XmppStringprepException 如果发生错误。
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
     * 过滤所有实体裸 JID。
     *
     * @param in 输入集合。
     * @param appendFunc 将过滤后的 JID 添加到的集合。
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
     * 过滤所有实体裸 JID。
     *
     * @param input 输入集合。
     * @return 包含输入集合中所有裸 JID 的集合。
     */
    public static func filterEntityBareJidSet(input: Collection<Jid>): Set<EntityBareJid> {
        let res = HashSet<EntityBareJid>(input.size)
        filterEntityBareJid(input, {r => res.put(r)})
        return res
    }

    /**
     * 过滤所有实体裸 JID。
     *
     * @param input 输入集合。
     * @return 包含输入集合中所有裸 JID 的列表。
     */
    public static func filterEntityBareJidList(input: Collection<Jid>): ArrayList<EntityBareJid> {
        let res = ArrayList<EntityBareJid>(input.size)
        filterEntityBareJid(input, res.append)
        return res
    }

    /**
     * 过滤所有实体完整 JID。
     *
     * @param in 输入集合。
     * @param appendFunc 将过滤后的 JID 回调到的函数。
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
     * 过滤所有完整 JID。
     *
     * @param input 输入集合。
     * @return 包含输入集合中所有完整 JID 的集合。
     */
    public static func filterEntityFullJidSet(input: Collection<Jid>): Set<EntityFullJid> {
        let res = HashSet<EntityFullJid>(input.size)
        filterEntityFullJid(input, {r => res.put(r)})
        return res
    }

    /**
     * 过滤所有完整 JID。
     *
     * @param input 输入集合。
     * @return 包含输入集合中所有完整 JID 的列表。
     */
    public static func filterEntityFullJidList(input: Collection<Jid>): ArrayList<EntityFullJid> {
        let res = ArrayList<EntityFullJid>(input.size)
        filterEntityFullJid(input, res.append)
        return res
    }

    /**
     * 过滤所有域完整 JID。
     *
     * @param in 输入集合。
     * @param appendFunc 将过滤后的 JID 添加到的回调函数。
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
     * 过滤所有域完整 JID。
     *
     * @param input 输入集合。
     * @return 包含输入集合中所有域完整 JID 的集合。
     */
    public static func filterDomainFullJidSet(input: Collection<Jid>): Set<DomainFullJid> {
        let res = HashSet<DomainFullJid>(input.size)
        filterDomainFullJid(input, {r => res.put(r)})
        return res
    }

    /**
     * 过滤所有域完整 JID。
     *
     * @param input 输入集合。
     * @return 包含输入集合中所有域完整 JID 的列表。
     */
    public static func filterDomainFullJidList(input: Collection<Jid>): ArrayList<DomainFullJid> {
        let res = ArrayList<DomainFullJid>(input.size)
        filterDomainFullJid(input, res.append)
        return res
    }

    /**
     * 将给定的字符序列集合转换为裸 JID 集合。
     *
     * @param jidStrings 字符序列集合。
     * @return 裸 JID 集合。
     */
    public static func entityBareJidSetFrom(jidStrings: Collection<String>): Set<EntityBareJid> {
        let res = HashSet<EntityBareJid>(jidStrings.size)
        entityBareJidsFrom(jidStrings, {r => res.put(r)}, None)
        return res
    }

    /**
     * 将字符串集合转换为 EntityBareJid 集合。
     * <p>
     * 如果给定可选参数 exceptions，则在转换过程中抛出的所有 XmppStringprepException 将被添加到列表中。否则，如果抛出 XmppStringprepException，它将被包装在 AssertionError 异常中并抛出。
     * </p>
     *
     * @param jidStrings 要转换的字符串集合。
     * @param appendFunc BareJid 将被添加到的回调函数。
     * @param exceptions 转换过程中抛出的异常列表。
     */
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
     * 将给定的字符串数组转换为 JID 集合。
     * <p>
     * 注意，在转换字符串时发生的错误将被静默忽略。
     * </p>
     *
     * @param jids JID 字符串数组。
     * @return JID 集合。
     */
    public static func jidSetFrom(jids: Array<String>): Set<Jid> {
        let strs: Collection<String> = jids
        return jidSetFrom(strs)
    }

    /**
     * 将给定的字符序列集合转换为 JID 集合。
     *
     * @param jidStrings 字符序列集合。
     * @return JID 集合。
     */
    public static func jidSetFrom(jidStrings: Collection<String>): Set<Jid> {
        let res: HashSet<Jid> = HashSet<Jid>(jidStrings.size)
        jidsFrom(jidStrings, {r => res.put(r)}, None)
        return res
    }

    /**
     * 将字符串集合转换为 Jid 集合。
     * <p>
     * 如果给定可选参数 exceptions，则在转换过程中抛出的所有 XmppStringprepException 将被添加到列表中。否则，如果抛出 XmppStringprepException，它将被包装在 AssertionError 异常中并抛出。
     * </p>
     *
     * @param jidStrings 要转换的字符串集合。
     * @param appendFunc Jid 将被添加到的回调函数。
     * @param exceptions 转换过程中抛出的异常列表。
     */
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
     * 将 JID 集合转换为表示这些 JID 的字符串列表。
     *
     * @param jids JID 集合。
     * @return 字符串列表。
     */
    public static func toStringList(jids: Collection<Jid>): ArrayList<String> {
        let res = ArrayList<String>(jids.size)
        toStrings(jids, res.append)
        return res
    }

    /**
     * 将 JID 集合转换为表示这些 JID 的字符串集合。
     *
     * @param jids JID 集合。
     * @return 字符串集合。
     */
    public static func toStringSet(jids: Collection<Jid>): Set<String> {
        let res: Set<String> = HashSet<String>(jids.size)
        toStrings(jids, {r => res.put(r)})
        return res
    }

    /**
     * 将 JID 集合转换为字符串集合。
     *
     * @param jids 要转换的字符串集合。
     * @param appendFunc 要添加到的字符串回调函数。
     */
    public static func toStrings(jids: Collection<Jid>, appendFunc: (String) -> Unit): Unit {
        for (jid in jids) {
            appendFunc(jid.toString())
        }
    }

    /**
     * 检查两个 JID 是否相等。考虑 null 值。这意味着如果两个 JID 都是 null，则此方法将返回 true。
     *
     * @param jidOne 要比较的第一个 JID。
     * @param jidTwo 要比较的第二个 JID。
     * @return 如果两个 JID 相等，则返回 true。
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
