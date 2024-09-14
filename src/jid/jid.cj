/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

/**
 * XMPP 地址，也称为 JID（以前是 “Jabber Identifier” 的缩写），它在 XMPP 网络中作为全局唯一的地址。
 * <p>
 * JIDs 可以通过{@link xmpp4cj.jid.JidCreate}工具类从String创建。
 * </p>
 *
 * <pre>
 * let jid:Jid = JidCreate.froms("juliet@capulet.org/balcony");
 * let bareJid:EntityBareJid = JidCreate.entityBareFrom("romeo@montague.net");
 * </pre>
 * <p>
 * 这是所有 JID 类型的超接口，JID 由两个维度构建：裸（Bare）/ 全（Full）和 域（Domain）/ 实体（Entity）。
 * 1. 每个 JID 至少由一个域部分（{@link xmpp4cj.jid.Domainpart}）组成。
 * 2. 裸 JID 类型没有资源部分（{@link xmpp4cj.jid.Resourcepart}），全 JID 类型总是有资源部分。
 * 3. 域 JID 类型没有本地部分（{@link xmpp4cj.jid.Localpart}），而实体 JID 类型总是有本地部分。
 * </p>
 * <p>
 * 一些 JID 类型的示例：
 * </p>
 * <table>
 * <caption>XMPP Address Types</caption>
 * <tr>
 * <td>Example</td>
 * <td>Type</td>
 * </tr>
 * <tr>
 * <td><code>example.org</code></td>
 * <td>{@link xmpp4cj.jid.DomainBareJid}</td>
 * </tr>
 * <tr>
 * <td><code>example.org/resource</code></td>
 * <td>{@link xmpp4cj.jid.DomainFullJid}</td>
 * </tr>
 * <tr>
 * <td><code>user@example.org</code></td>
 * <td>{@link xmpp4cj.jid.EntityBareJid}</td>
 * </tr>
 * <tr>
 * <td><code>user@example.org/resource</code></td>
 * <td>{@link xmpp4cj.jid.EntityFullJid}</td>
 * </tr>
 * </table>
 * <p>
 * 可以使用 {@link #toString()} 方法获取表示 JID 的转义字符串，或者使用 {@link #asUnescapedString()} 方法获取 JID 的未转义字符串。
 * </p>
 * <h2>URL Encoded JIDs</h2>
 * <p>
 * 如果 JID 应该作为路径名的一部分存储，例如作为文件名，那么 JID 的 URL 编码表示是理想的。
 * 可以使用 {@link #asUrlEncodedString()} 方法获取此信息。
 * JidCreate API 提供了从 URL 编码的字符串创建 JIDs 的方法，如 {@link xmpp4cj.jid.JidCreate#fromUrlEncoded(String)} 。
 * </p>
 *
 * @see <a href="xmpp/org/rfcs/rfc6120.html#arch-addresses">RFC 6120 (XMPP: Core) § 2.1 Global Addresses</a>
 * @see <a href="xmpp/org/rfcs/rfc6122.html#addressing-fundamentals">RFC 6122 (XMPP: Address Format) § 2.1 Fundamentals</a>
 */
public interface Jid <: Equatable<Jid> & ToString & Hashable {

    /**
     * 用于获取这个 Jid 的Domainpart（域部分）
     *
     * @return 这个 Jid 的域部分对象
     */
    func getDomain(): Domainpart

    /**
     * 此方法用于返回这个 JID 的未转义字符串表示形式。
     * <p>
     * 由于某些 Unicode 码点在 JID 的本地部分（localpart）中是不被允许的，按照所需的 stringprep 规范，这些码点在实际的 JID 中需要被转义。未转义的 JID 表示形式仅用于向人类用户展示或用于与非 XMPP 系统进行交互。
     * </p>
     * 例如，如果用户输入 {@code 'at&t guy@example.com'}，使用{@link xmpp4cj.jid.JidCreate}创建的转义后的实际 JID 将是{@code 'at\26t\20guy@example.com'}，这是 {@link Jid#toString()} 方法将返回的结果。而 {@link Jid#asUnescapedString()} 方法将再次返回{@code 'at&t guy@example.com'}。
     *
     * @return 这个 JID 的未转义字符串表示。
     */
    func asUnescapedString(): String

    /**
     * 用于获取此 JID 的 URL 编码版本。
     *
     * @return 这个 JID 的 URL 编码形式。
     */
    func asUrlEncodedString(): String

    /**
     * Check if this is a {@link EntityBareJid} or {@link EntityFullJid}.
     *
     * @return true 若当前对象为 BareJid or FullJid.
     */
    func isEntityJid(): Bool

    /**
     * 检查是否为 {@link EntityBareJid}.
     *
     * @return true 若当前对象为 EntityBareJid
     */
    func isEntityBareJid(): Bool

    /**
     * 检查是否为 {@link EntityFullJid}.
     *
     * @return true 若当前对象为 EntityFullJid
     */
    func isEntityFullJid(): Bool

    /**
     * 检查是否为 {@link DomainBareJid}.
     *
     * @return true 若当前对象为 DomainBareJid
     */
    func isDomainBareJid(): Bool

    /**
     * 检查是否为 {@link DomainFullJid}.
     *
     * @return true 若当前对象为 DomainFullJid
     */
    func isDomainFullJid(): Bool

    /**
     * 检查是否为 {@link EntityBareJid} or {@link DomainBareJid}.
     *
     * @return true 若当前对象为 BareJid or DomainBareJid
     */
    func hasNoResource(): Bool

    /**
     * 检查是否为 Jid with a {@link Resourcepart}.
     *
     * @return true 若此 Jid 有 resourcepart.
     */
    func hasResource(): Bool

    /**
     * 检查是否为 Jid with a {@link Localpart}.
     *
     * @return true 若此 Jid 有 localpart.
     */
    func hasLocalpart(): Bool

    /**
     * 返回一个通过从这个 JID 中移除资源部分创建的 JID。
     *
     * @return 没有资源部分的这个 Jid。
     */
    func asBareJid(): BareJid

    /**
     * 如果可能，将这个 Jid 转换为一个实体裸 JID（EntityBareJid）。
     *
     * @return 对应的实体裸 JID 或 None。
     */
    func asEntityBareJidIfPossible(): ?EntityBareJid

    /**
     * 如果不可能将这个 Jid 转换为实体裸 JID（EntityBareJid），则抛出 IllegalStateException。
     *
     * @return 对应的实体裸 JID。
     */
    func asEntityBareJidOrThrow(): EntityBareJid

    /**
     * 如果可能，将这个 Jid 转换为一个实体完整 JID（EntityFullJid）。
     *
     * @return 对应的实体完整 JID 或 None。
     */
    func asEntityFullJidIfPossible(): ?EntityFullJid

    /**
     * 如果不可能将这个 Jid 转换为实体完整 JID（EntityFullJid），则抛出 IllegalStateException。
     *
     * @return 对应的实体完整 JID。
     */
    func asEntityFullJidOrThrow(): EntityFullJid

    /**
     * 如果可能，将这个 Jid 转换为一个实体 JID（EntityJid）。
     *
     * @return 对应的实体 JID 或 None。
     */
    func asEntityJidIfPossible(): ?EntityJid

    /**
     * 如果不可能将这个 Jid 转换为实体 JID（EntityJid），则抛出 IllegalStateException。
     *
     * @return 对应的实体 JID。
     */
    func asEntityJidOrThrow(): EntityJid

    /**
     * 如果可能，将这个 Jid 转换为一个完整 JID（FullJid）。
     *
     * @return 对应的完整 JID 或 None。
     */
    func asFullJidIfPossible(): ?FullJid

    /**
     * 如果不可能将这个 Jid 转换为完整 JID（FullJid），则抛出 IllegalStateException。
     *
     * @return 对应的完整 JID。
     */
    func asFullJidOrThrow(): EntityFullJid

    /**
     * 将这个 Jid 转换为一个域裸 JID（DomainBareJid）。
     * <p>
     * 注意，总是可以将一个 Jid 转换为域裸 JID，因为每个 Jid 都有一个域部分。
     * </p>
     *
     * @return 对应的域裸 JID。
     */
    func asDomainBareJid(): DomainBareJid

    /**
     * 如果可能，将这个 Jid 转换为一个域完整 JID（DomainFullJid）。
     *
     * @return 对应的域完整 JID 或 None。
     */
    func asDomainFullJidIfPossible(): ?DomainFullJid

    /**
     * 如果不可能将这个 Jid 转换为域完整 JID（DomainFullJid），则抛出 IllegalStateException。
     *
     * @return 对应的域完整 JID。
     */
    func asDomainFullJidOrThrow(): DomainFullJid

    /**
     * 获取这个 JID 的资源部分或 None。
     * <p>
     * 如果 JID 是 {@code <localpart@domain.example/resource>} 的形式，那么这个方法返回 'resource'。如果 JID 没有资源部分，那么返回 None。
     * </p>
     *
     * @return 这个 JID 的资源部分或 None。
     */
    func getResourceOrNull(): ?Resourcepart

    /**
     * 获取这个 JID 的资源部分或返回空资源部分。
     * <p>
     * 如果 JID 是 {@code <localpart@domain.example/resource>} 的形式，那么这个方法返回 'resource'。如果 JID 没有资源部分，那么返回 {@link xmpp.jid.parts.Resourcepart#EMPTY}。
     * </p>
     *
     * @return 这个 JID 的资源部分或空资源部分。
     */
    func getResourceOrEmpty(): Resourcepart

    /**
     * 获取这个 JID 的资源部分或抛出 IllegalStateException。
     * <p>
     * 如果 JID 是 {@code <localpart@domain.example/resource>} 的形式，那么这个方法返回 'resource'。如果 JID 没有资源部分，那么抛出 IllegalStateException。
     * </p>
     *
     * @return 这个 JID 的资源部分。
     */
    func getResourceOrThrow(): Resourcepart

    /**
     * 获取这个 JID 的本地部分或 None。
     * <p>
     * 如果 JID 是 {@code <localpart@domain.example>} 的形式，那么这个方法返回 'localpart'。如果 JID 没有本地部分，那么返回 None。
     * </p>
     *
     * @return 这个 JID 的本地部分或 None。
     */
    func getLocalpartOrNull(): ?Localpart

    /**
     * 获取这个 JID 的本地部分或抛出 IllegalStateException。
     * <p>
     * 如果 JID 是 {@code <localpart@domain.example>} 的形式，那么这个方法返回 'localpart'。如果 JID 没有本地部分，那么返回 None。
     * </p>
     *
     * @return 这个 JID 的本地部分。
     */
    func getLocalpartOrThrow(): Localpart

    /**
     * 用于检查当前的 JID 是否是另一个给定 JID 的 “父级”。“父级” 关系的定义如下：在 JID 的各个部分（本地部分、域部分和资源部分）相等的前提下，如果满足特定条件，则认为当前 JID 是另一个 JID 的父级。通过一个表格展示不同情况下的判断结果：
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
     *            要与之比较的另一个 JID
     * @return 如果这个 JID 是给定 JID 的父级，则返回 true。
     */
    func isParentOf(jid: Jid): Bool

    /**
     * 参见 {@link #isParentOf(Jid)}。
     *
     * @param bareJid 裸 JID。
     * @return 如果这个 JID 是给定 JID 的父级，则返回 true。
     */
    func isParentOf(bareJid: EntityBareJid): Bool

    /**
     * 参见 {@link #isParentOf(Jid)}。
     *
     * @param fullJid 完整 JID。
     * @return 如果这个 JID 是给定 JID 的父级，则返回 true。
     */
    func isParentOf(fullJid: EntityFullJid): Bool

    /**
     * 参见 {@link #isParentOf(Jid)}。
     *
     * @param domainBareJid 域裸 JID。
     * @return 如果这个 JID 是给定 JID 的父级，则返回 true。
     */
    func isParentOf(domainBareJid: DomainBareJid): Bool

    /**
     * 参见 {@link #isParentOf(Jid)}。
     *
     * @param domainFullJid 域完整 JID。
     * @return 如果这个 JID 是给定 JID 的父级，则返回 true。
     */
    func isParentOf(domainFullJid: DomainFullJid): Bool
}

/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个没有资源部分（{@link xmpp.jid.parts.Resourcepart}）的 JID。它可以是{@link EntityBareJid}或{@link DomainBareJid}类型。
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>localpart@domain.part</code></li>
 * <li><code>domain.part</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface BareJid <: Jid {}
/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个没有本地部分（{@link xmpp4cj.jid.Localpart}）的 JID，可以是{@link DomainBareJid}或{@link DomainFullJid}类型。
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>domain.part</code></li>
 * <li><code>domain.part/resourcepart</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface DomainJid <: Jid {}
/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个由域部分（domainpart）和资源部分（resourcepart）组成的完整 JID。例如 “xmpp.org/resource”。
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>domain.part/resource</code></li>
 * <li><code>example.net/8c6def89</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface DomainFullJid <: Jid & FullJid & DomainJid & Equatable<DomainFullJid> {
    operator override func !=(that: Jid): Bool {
        !(this == that)
    }
}

/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个具有资源部分（{@link Resourcepart}）的 JID，可以是{@link EntityFullJid}或{@link DomainFullJid}类型。
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>localpart@domain.part/resourcepart</code></li>
 * <li><code>domain.part/resourcepart</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface FullJid <: Jid {

    /**
     * 返回 JID 的资源部分 {@link Resourcepart}
     *
     * @return 资源部分
     */
    func getResourcepart(): Resourcepart
}
/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个具有本地部分（{@link Localpart}）的 JID. 可以是 {@link EntityBareJid} 或 {@link EntityFullJid}.
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>localpart@domain.part</code></li>
 * <li><code>localpart@domain.part/resourcepart</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface EntityJid <: Jid {
    /**
     * 返回这个 JID 的本地部分（Localpart）。
     *
     * @return 本地部分。
     */
    func getLocalpart(): Localpart

    /**
     * 返回这个实体 JID 的裸 JID（EntityBareJid）。
     *
     * @return 裸 JID。
     */
    func asEntityBareJid(): EntityBareJid

    /**
     * 返回这个完整 JID 的实体裸 JID 字符串。
     *
     * @return 裸 JID 字符串。
     */
    func asEntityBareJidString(): String
}
/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个由本地部分（localpart）、域部分（domainpart）和资源部分（resourcepart）组成的完整实体 JID。例如 “user@xmpp.org/resource”。
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>localpart@domain.part/resource</code></li>
 * <li><code>juliet@xmpp.org/balcony</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface EntityFullJid <: Jid & FullJid & EntityJid & Equatable<EntityFullJid> {
    operator override func !=(that: Jid): Bool {
        !(this == that)
    }
}
/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个由本地部分（localpart）和域部分（domainpart）组成的实体裸 JID。例如 “user@xmpp.org”。
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>localpart@domain.part</code></li>
 * <li><code>user@example.net</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface EntityBareJid <: Jid & EntityJid & BareJid & Equatable<EntityBareJid> {
    operator override func !=(that: Jid): Bool {
        !(this == that)
    }
}
/**
 * 这是一个关于 XMPP 地址（JID）的接口定义，代表一个仅由域部分（domainpart）组成的域裸 JID。例如 “xmpp.org”。
 * <p>
 * Examples:
 * </p>
 * <ul>
 * <li><code>xmpp.org</code></li>
 * <li><code>example.net</code></li>
 * </ul>
 *
 * @see Jid
 */
public interface DomainBareJid <: Jid & BareJid & DomainJid {
    operator override func !=(that: Jid): Bool {
        !(this == that)
    }
}

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
    public operator func ==(other: EntityFullJid): Bool {
        this.toString() == other.toString()
    }
    public operator func ==(other: EntityBareJid): Bool {
        this.toString() == other.toString()
    }
    public operator func ==(other: DomainFullJid): Bool {
        this.toString() == other.toString()
    }
}

/**
 * 代表一种特定类型的 XMPP 地址（JID），根据 RFC6122 2.4 标准，允许 JID 仅由域部分和资源部分组成。
 * <p>
 * 与LocalDomainAndResourcepartJid相比，这个实现不需要为未转义的字符串设置缓存。
 * </p>
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
        cache ?? {
            =>
            let str = "${domainBareJid}/${resource}"
            cache = str
            str
        }()
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
