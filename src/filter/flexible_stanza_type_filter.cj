/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.filter

/**
 * public abstract class FlexibleStanzaTypeFilter<S> <: StanzaFilter where S <: Stanza
 *
 * 过滤特定类型的 STANZA，并允许自定义方法进一步过滤数据包。
 */
public abstract class FlexibleStanzaTypeFilter<S> <: StanzaFilter where S <: Stanza {
    /**
     * 存储 STANZA 类型的 Class 对象
     */
    protected let stanzaType: ClassId

    /**
     * 构造函数，根据给定的 STANZA 类型创建过滤器。
     *
     * @param packetType 要过滤的 STANZA 类型。不能为空。
     */
    public init(packetType: ClassId) {
        this.stanzaType = Objects.requireNonNull(packetType, "Type must not be null")
    }

    /**
     * 默认构造函数，使用反射获取泛型类型参数。
     */
    public init() {
        stanzaType = "Stanza"
    }

    /**
     * 检查给定的 STANZA 数据包是否被接受。
     *
     * @param packet 要检查的 STANZA 数据包。
     * @return 如果数据包符合过滤条件，则返回 true；否则返回 false。
     */
    public func accept(packet: Stanza): Bool {
        if (packet is S) {
            return acceptSpecific((packet as S).getOrThrow())
        }
        return false
    }

    /**
     * 子类需要实现的具体接受方法，根据特定条件进一步过滤数据包。
     *
     * @param packet 数据包
     * @return 如果数据包符合特定条件，则返回 true；否则返回 false。
     */
    protected func acceptSpecific(packet: S): Bool

    /**
     * 返回过滤器的字符串表示，包括类名和 STANZA 类型。
     *
     * @return 过滤器的描述信息
     */
    public open override func toString(): String {
        return "FlexibleStanzaTypeFilter: ${stanzaType.toString()}" // 返回类名和类型信息  
    }
}
