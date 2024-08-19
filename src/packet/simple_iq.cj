/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * A simple IQ.
 * <p>
 * Simple IQs child elements do not contain further attributes besides 'xmlns'.
 * They may contain additional packet extensions.
 * </p>
 */
public abstract class SimpleIQ <: IQ {
    protected init(childElementName: String, childElementNamespace: String) {
        super(childElementName, childElementNamespace)
    }

    protected init(iqBuilder: IqData, childElementName: String, childElementNamespace: String) {
        super(iqBuilder, childElementName, childElementNamespace)
    }

    protected override func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.setEmptyElement()
        return xml
    }
}
