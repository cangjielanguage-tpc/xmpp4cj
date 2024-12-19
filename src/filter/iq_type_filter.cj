/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**
 * IQ 数据包类型的过滤器。仅当数据包是 IQ 包并且与构造函数中提供的类型匹配时返回 true。
 */
public class IQTypeFilter <: FlexibleStanzaTypeFilter<IQ> {
    /**
     * GET 类型 IQ
     */
    public static let GET: StanzaFilter = IQTypeFilter(IQType.get)

    /**
     * SET 类型 IQ
     */
    public static let SET: StanzaFilter = IQTypeFilter(IQType.set)

    /**
     * RESULT 类型 IQ
     */
    public static let RESULT: StanzaFilter = IQTypeFilter(IQType.result)

    /**
     *  ERROR 类型 IQ
     */
    public static let ERROR: StanzaFilter = IQTypeFilter(IQType.error)

    /**
     * GET 或 SET 类型 IQ
     */
    public static let GET_OR_SET: StanzaFilter = OrFilter([GET, SET])

    private let iqType: IQType // 存储 IQ 类型

    /**
     * 使用指定的 IQ 类型创建一个新的 IQ 类型过滤器。
     *
     * @param type IQ 类型。
     * @throws NullPointerException 如果类型为 null。
     */
    private init(iqType: IQType) {
        super("IQ")
        this.iqType = Objects.requireNonNull(iqType, "Type must not be null")
    }

    /**
     * 检查指定的 IQ 数据包是否匹配当前的 IQ 类型。
     *
     * @param iq 要检查的 IQ 数据包对象。
     * @return 如果 IQ 数据包的类型与当前过滤器的类型相同，则返回 true；否则返回 false。
     */
    protected override func acceptSpecific(iq: IQ): Bool {
        return iq.getType() == iqType // 检查类型是否匹配  
    }

    public override func toString(): String {
        return "IQTypeFilter: type=${iqType}" // 返回类名和 IQ 类型的字符串表示 
    }
}
