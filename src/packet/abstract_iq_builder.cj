/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public abstract class AbstractIqBuilder <: StanzaBuilder & IqView {
    protected var typ: IQType = IQType.get

    init(other: IQ, stanzaId: String) {
        super(other, stanzaId)
    }

    init(other: AbstractIqBuilder) {
        super(other)
        typ = other.typ
    }

    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    init(stanzaId: ?String) {
        super(stanzaId)
    }

    public static func createResponse(request: IqView): IqData {
        return createResponse(request, IQResponseType.result)
    }

    public static func createErrorResponse(request: IqView): IqData {
        return createResponse(request, IQResponseType.error)
    }

    protected static func createResponse(request: IqView, responseType: IQResponseType): IqData {
        if (!request.isRequestIQ()) {
            throw IllegalArgumentException("IQ request must be of type 'set' or 'get'. Original IQ: ${request}")
        }
        let commonResponseIqData: IqData = StanzaBuilder.buildResponse(request, {s => StanzaBuilder.buildIqData(s)})
        commonResponseIqData.ofType(responseType.getType())
        return commonResponseIqData
    }

    protected override func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit {
        builder.addValue("type", getType())
    }

    public override func getType(): IQType {
        return typ
    }
}
