/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 用于过滤 “from” 字段与指定 JID 完全匹配的数据包的过滤器。
 * 如果指定的地址是裸 JID，则过滤器将匹配任何裸 JID 与指定 JID 匹配的地址。
 * 如果指定的地址是完整 JID，则过滤器仅在数据包的发件人与指定资源匹配时才匹配。
 */
public class FromMatchesFilter <: AbstractFromToMatchesFilter {
    /**
     * 创建一个过滤器，该过滤器没有指定的“from”地址
     */
    public static let MATCH_NO_FROM_SET = create(None)

    /**  
     * 创建一个基于 “from” 字段的过滤器。发件人地址必须与过滤器地址相同。
     * 第二个参数指定比较是完整地址还是裸地址。
     *
     * @param address  要过滤的地址。如果给定 <code>null</code>，则数据包不得有 “from” 地址。
     * @param ignoreResourcepart Bool
     */
    public init(address: ?Jid, ignoreResourcepart: Bool) {
        super(address, ignoreResourcepart)
    }

    /**  
     * 创建一个基于 “from” 字段的过滤器。如果过滤器地址是裸地址，则将
     * 过滤器地址与裸的 “from” 地址进行比较。否则，将过滤器地址与完整的 “from” 地址进行比较。
     *
     * @param address 要过滤的地址。如果给定 <code>null</code>，则数据包不得有 “from” 地址。
     * @return 一个过滤器，用于匹配 “from” 地址。
     */
    public static func create(address: ?Jid): FromMatchesFilter {
        let isBool: Bool = if (let Some(v) <- address) {
            v.hasNoResource()
        } else {
            false
        }
        return FromMatchesFilter(address, isBool)
    }

    /**  
     * 创建一个基于 “from” 字段的过滤器。比较过滤器地址与 “from” 地址的裸版本。
     *
     * @param address 要过滤的地址。如果给定 <code>null</code>，则数据包不得有 “from” 地址。
     * @return 一个过滤器，匹配 “from” 地址的裸版本。
     */
    public static func createBare(address: ?Jid): FromMatchesFilter {
        return FromMatchesFilter(address, true)
    }

    /**  
     * 创建一个基于 “from” 字段的过滤器。比较过滤器地址与 “from” 地址的完整版本（如果可用）。
     *
     * @param address 要过滤的地址。如果给定 <code>null</code>，则数据包不得有 “from” 地址。
     * @return 一个过滤器，匹配 “from” 地址的完整版本。
     */
    public static func createFull(address: ?Jid): FromMatchesFilter {
        return FromMatchesFilter(address, false)
    }

    /**  
     * 从数据包中获取要比较的地址，这里是 “from” 字段的地址。
     *
     * @param stanza 要检查的 STANZA 数据包。
     * @return 返回数据包的 “from” 地址。
     */
    protected override func getAddressToCompare(stanza: Stanza): ?Jid {
        return stanza.getFrom()
    }

    public override func toString(): String {
        let matchMode: String = if (ignoreResourcepart) {
            "ignoreResourcepart"
        } else {
            "full"
        }
        return if (let Some(v) <- address) {
            "FromMatchesFilter (${matchMode}): ${v}"
        } else {
            "FromMatchesFilter (${matchMode}): None"
        }
    }
}
