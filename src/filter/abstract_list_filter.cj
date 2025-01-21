/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**
 * public abstract class AbstractListFilter <: StanzaFilter
 *
 * 抽象类，表示一个 STANZA 过滤器列表。该类实现了 StanzaFilter 接口，
 * 用于管理多个过滤器的逻辑关系。
 */
public abstract class AbstractListFilter <: StanzaFilter {
    /**
     * 过滤器列表，存储多个 STANZA 过滤器。
     */
    protected let filters: ArrayList<StanzaFilter>

    /**
     * 创建一个空的过滤器列表。
     */
    protected init() {
        filters = ArrayList<StanzaFilter>() // 初始化一个空的过滤器列表 
    }

    /**
     * 使用指定的过滤器创建一个过滤器列表。
     *
     * @param filters 要添加的过滤器。
     */
    protected init(filters: Array<StanzaFilter>) {
        this(ArrayList<StanzaFilter>(filters))
    }
    /**
     * 使用指定的过滤器列表创建一个过滤器列表。
     *
     * @param filters 要添加的过滤器列表。
     */
    protected init(filters: ArrayList<StanzaFilter>) {
        Objects.requireNonNull(filters, "Parameter must not be null.")
        for (filter in filters) {
            Objects.requireNonNull(filter, "Parameter must not be null.")
        }
        this.filters = filters
    }

    /**
     * 向过滤器列表中添加一个过滤器。数据包只有在列表中的所有过滤器都接受时，才会通过过滤器。
     *
     * @param filter 要添加到过滤器列表的过滤器。
     */
    public func addFilter(filter: StanzaFilter): Unit {
        Objects.requireNonNull(filter, "Parameter must not be null.")
        filters.add(filter)
    }

    /**
     * 返回类的字符串表示，包含类名和过滤器列表。
     *
     * @return 类的字符串表示
     */
    public open override func toString(): String {
        let sb = StringBuilder()
        sb.append("AbstractListFilter")
        sb.append(": (")
        sb.append(StringUtils.toStringBuilder(filters, ", "))
        sb.append(r')')
        return sb.toString()
    }
}
