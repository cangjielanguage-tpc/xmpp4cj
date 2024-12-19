/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**
 * ToMatchesFilter 是一个用于过滤与 "to" 字段匹配的地址的过滤器。
 * 该类扩展了 AbstractFromToMatchesFilter，允许根据给定的 JID 进行过滤。
 */
public class ToMatchesFilter <: AbstractFromToMatchesFilter {
    /**
     * 匹配未设置 "to" 的过滤器
     */
    public static let MATCH_NO_TO_SET = create(None)

    /**
     * 构造一个 ToMatchesFilter 实例。
     *
     * @param address 要过滤的 JID 地址
     * @param ignoreResourcepart 是否忽略资源部分
     */
    public init(address: ?Jid, ignoreResourcepart: Bool) {
        super(address, ignoreResourcepart)
    }

    /**
     * 创建一个匹配 "to" 字段的过滤器。如果过滤地址是裸 JID，则比较
     * 过滤地址与裸 "from" 地址；否则，比较过滤地址与全 "from" 地址。
     *
     * @param address 要过滤的地址。如果给定 <code>null</code>，则 Stanza 不能有 "from" 地址。
     * @return 一个匹配 "to" 地址的过滤器。
     */
    public static func create(address: ?Jid): ToMatchesFilter {
        let isBool: Bool = if (let Some(v) <- address) {
            v.hasNoResource()
        } else {
            false
        }
        return ToMatchesFilter(address, isBool)
    }

    /**
     * 创建一个匹配 "to" 字段的过滤器。比较 "to" 和过滤地址的裸版本。
     *
     * @param address 要过滤的地址。如果给定 <code>null</code>，则 Stanza 不能有 "from" 地址。
     * @return 一个匹配 "to" 地址的过滤器。
     */
    public static func createBare(address: ?Jid): ToMatchesFilter {
        return ToMatchesFilter(address, true)
    }

    /**
     * 创建一个匹配 "to" 字段的过滤器。比较 "to" 和过滤地址的全版本，如果可用的话。
     *
     * @param address 要过滤的地址。如果给定 <code>null</code>，则 Stanza 不能有 "from" 地址。
     * @return 一个匹配 "to" 地址的过滤器。
     */
    public static func createFull(address: ?Jid): ToMatchesFilter {
        return ToMatchesFilter(address, false)
    }

    /**
     * 获取要比较的地址。
     *
     * @param stanza 要比较的 Stanza
     * @return 该 Stanza 的目标 JID
     */
    protected override func getAddressToCompare(stanza: Stanza): ?Jid {
        return stanza.getTo()
    }

    public override func toString(): String {
        let matchMode: String = if (ignoreResourcepart) {
            "ignoreResourcepart"
        } else {
            "full"
        }
        return if (let Some(v) <- address) {
            "ToMatchesFilter (${matchMode}): ${v}"
        } else {
            "ToMatchesFilter (${matchMode}): None"
        }
    }
}
