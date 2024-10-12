/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 实现对两个或多个 Stanza 过滤器的逻辑“或”操作。
 * 换句话说，数据包通过此过滤器仅在通过 <b>任意一个</b> 过滤器时。
 */
public class OrFilter <: AbstractListFilter {
    /**  
     * 创建一个空的 OR 过滤器。过滤器应通过
     * {@link #addFilter(StanzaFilter)} 方法添加。
     */
    public init() {
        super()
    }

    /**  
     * 使用指定的过滤器创建一个 OR 过滤器。
     *
     * @param filters 要添加的过滤器。
     */
    public init(filters: Array<StanzaFilter>) {
        super(filters)
    }

    /**  
     * 检查给定的数据包是否通过了任何一个过滤器。
     *
     * @param packet 要检查的 Stanza 数据包。
     * @return 如果数据包通过了任何过滤器，则返回 true；否则返回 false。
     */
    public override func accept(packet: Stanza): Bool {
        for (filter in filters) {
            if (filter.accept(packet)) {
                return true
            }
        }
        return false
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("OrFilter")
        sb.append(": (")
        sb.append(StringUtils.toStringBuilder(filters, ", "))
        sb.append(r')')
        return sb.toString()
    }
}
