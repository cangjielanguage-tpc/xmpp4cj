/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * An IQ stanzas that could not be parsed because no provider was found.
 */
public class UnparsedIQ <: IQ {
    public init(element: String, namespace: String, content: String) {
        super(element, namespace)
        this.content = content
    }

    private let content: String

    public func getContent(): String {
        return content
    }

    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.escape(content)
        return xml
    }
}
