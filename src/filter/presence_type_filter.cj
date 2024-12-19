/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**
 * 用于过滤 Presence 类型的过滤器。只有当 Stanza 是 Presence Stanza 并且匹配构造函数提供的类型时，返回 true。
 */
public class PresenceTypeFilter <: FlexibleStanzaTypeFilter<Presence> {
    /**
     * 可用的
     */
    public static let AVAILABLE = PresenceTypeFilter(PresenceType.available)

    /**
     * 不可用的
     */
    public static let UNAVAILABLE = PresenceTypeFilter(PresenceType.unavailable)

    /**
     * 订阅
     */
    public static let SUBSCRIBE = PresenceTypeFilter(PresenceType.subscribe)

    /**
     * 认购
     */
    public static let SUBSCRIBED = PresenceTypeFilter(PresenceType.subscribed)

    /**
     * 取消订阅
     */
    public static let UNSUBSCRIBE = PresenceTypeFilter(PresenceType.unsubscribe)

    /**
     * 取消认购
     */
    public static let UNSUBSCRIBED = PresenceTypeFilter(PresenceType.unsubscribed)

    /**
     * 错误
     */
    public static let ERROR = PresenceTypeFilter(PresenceType.error)

    /**
     * 探查
     */
    public static let PROBE = PresenceTypeFilter(PresenceType.probe)

    /**
     * 定义一个过滤器，用于匹配正在进行的可用性广播中的 Presence
     */
    public static let OUTGOING_PRESENCE_BROADCAST: StanzaFilter = AndFilter([AVAILABLE, EmptyToMatcher.INSTANCE])

    /**
     * 存储待匹配的 Presence 类型
     */
    private let presenceType: PresenceType

    /**
     * 私有构造函数，用于创建一个新的 Presence 类型过滤器。
     *
     * @param type 需要匹配的 Presence 类型。
     * @throws NullPointerException 如果传入的 type 为 null。
     */
    private init(presenceType: PresenceType) {
        super("Presence")
        this.presenceType = Objects.requireNonNull(presenceType, "type must not be null")
    }

    /**
     * 检查特定的 Presence 是否匹配预设的类型。
     *
     * @param presence 要检查的 Presence 对象。
     * @return 如果给定的 Presence 类型与过滤器类型匹配，则返回 true；否则返回 false。
     */
    protected override func acceptSpecific(presence: Presence): Bool {
        return presence.getType() == presenceType
    }

    /**
     * 返回过滤器的字符串表示形式，包含类型信息。
     *
     * @return 过滤器的字符串表示。
     */
    public override func toString(): String {
        return "PresenceTypeFilter: type=${presenceType.toString()}"
    }
}
