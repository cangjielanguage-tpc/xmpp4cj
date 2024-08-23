/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class EmptyResultIQ <: IQ {
    init(iqBuilder: IqData) {
        super(iqBuilder, EMPTY_ELEMENT, EMPTY_NAMESPACE)
    }

    public init() {
        super(EMPTY_ELEMENT, EMPTY_NAMESPACE)
        typ = IQType.result
    }

    public init(request: IQ) {
        this(AbstractIqBuilder.createResponse(request))
    }

    protected override func getIQChildElementBuilder(_: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        return None
    }
}
