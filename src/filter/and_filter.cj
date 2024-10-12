/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 实现多个 STANZA 过滤器的逻辑与操作。即，只有当数据包通过<b>所有</b>过滤器时，才会被接受。
 */
public class AndFilter <: AbstractListFilter {
    /**  
     * 创建一个空的 AND 过滤器。可以使用 {@link #addFilter(StanzaFilter)} 方法添加过滤器。
     */
    public init() {
        super()
    }

    /**  
     * 使用指定的过滤器创建 AND 过滤器。
     *
     * @param filters 要添加的过滤器。
     */
    public init(filters: Array<StanzaFilter>) {
        super(filters)
    }

    /**  
     * 使用指定的过滤器创建 AND 过滤器。
     *
     * @param filters 要添加的过滤器。
     */
    public init(filters: ArrayList<StanzaFilter>) {
        super(filters)
    }

    /**  
     * 检查给定的 STANZA 是否被接受。如果数据包通过所有的过滤器，则返回 true。
     *
     * @param packet 要检查的 STANZA 数据包。
     * @return 如果 STANZA 通过所有过滤器，则返回 true；否则返回 false。
     */
    public override func accept(packet: Stanza): Bool {
        for (filter in filters) {
            if (!filter.accept(packet)) {
                return false
            }
        }
        return true
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("AndFilter")
        sb.append(": (")
        sb.append(StringUtils.toStringBuilder(filters, ", "))
        sb.append(r')')
        return sb.toString()
    }
}
