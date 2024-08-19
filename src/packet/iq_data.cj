/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class IqData <: AbstractIqBuilder {
    static let EMPTY = IqData(StandardStanzaIdSource.DEFAULT)

    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    init(stanzaId: ?String) {
        super(stanzaId)
    }

    public func ofType(typ: IQType): IqData {
        this.typ = typ
        return getThis()
    }

    public override func getThis(): IqData {
        return this
    }

    public override func build(): Stanza {
        throw UnsupportedException()
    }
}

extend IqData <: Equatable<IqData> {
    public operator func ==(that: IqData): Bool {
        return refEq(this, that)
    }

    public operator func !=(that: IqData): Bool {
        return !(this == that)
    }
}
