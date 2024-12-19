/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * public abstract class IqBuilder <: AbstractIqBuilder
 *
 * 抽象类，用于构建 XMPP IQ 数据包的 Builder。
 * 该类提供了通用的构建方法和类型安全的构建类型 IQ（信息查询）的方法。
 */
public abstract class IqBuilder <: AbstractIqBuilder {
    /**
     * 使用其他 IQ 对象和数据报文 ID 创建 Builder。
     *
     * @param other 现有的 IQ 对象。
     * @param stanzaId 数据报文 ID。
     */
    protected init(other: IQ, stanzaId: String) {
        super(other, stanzaId)
    }

    /**
     * 使用另一个抽象 IQ Builder 创建 Builder。
     *
     * @param other 现有的 AbstractIqBuilder 对象。
     */
    protected init(other: AbstractIqBuilder) {
        super(other)
    }

    /**
     * 使用给定的 XMPP 连接创建 Builder。
     *
     * @param connection 用于构建 IQ 的 XMPP 连接。
     */
    // TODO
    // protected init(connection: XMPPConnection) {
    //     super(connection.getStanzaFactory().getStanzaIdSource())
    // }

    /**
     * 使用给定的数据报文 ID 创建 Builder。
     *
     * @param stanzaId 数据报文 ID。
     */
    protected init(stanzaId: String) {
        super(stanzaId)
    }

    /**
     * 设置 IQ 的类型。
     *
     * @param type IQ 类型，不能为 null。
     * @return 当前 Builder 实例，以支持链式调用。
     * @throws NullPointerException 如果 type 为 null。
     */
    public open func ofType(typ: IQType): IqBuilder {
        this.typ = typ
        return this
    }

    /**
     * 构建并返回一个 IQ 实例。
     *
     * @return 构建的 IQ 实例。
     */
    public open override func build(): IQ
}
