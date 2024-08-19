/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public abstract class IqBuilder <: AbstractIqBuilder {
    protected init(other: IQ, stanzaId: String) {
        super(other, stanzaId)
    }

    protected init(other: AbstractIqBuilder) {
        super(other)
    }
    /* TODO
    protected init(connection: XMPPConnection) {
        super(connection.getStanzaFactory().getStanzaIdSource())
    }
     */
    protected init(stanzaId: String) {
        super(stanzaId)
    }

    public open func ofType(typ: IQType): IqBuilder {
        this.typ = typ
        return this
    }

    public open override func build(): IQ
}
