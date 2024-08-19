/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public abstract class AbstractTextElement <: ExtensionElement {
    public static let ELEMENT: String = "text"

    private let text: String
    private let lang: String

    protected AbstractTextElement(text: String, lang: String) {
        this.text = StringUtils.requireNotNullNorEmpty(text, "Text must not be None nor empty")
        this.lang = lang
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()
        xml.escape(text)
        xml.closeElement(this)
        return xml
    }

    public func getText(): String {
        return text
    }

    public override func getLanguage(): ?String {
        return lang
    }
}

public class StanzaErrorTextElement <: AbstractTextElement {
    public static let NAMESPACE: String = StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE

    public StanzaErrorTextElement(text: String, lang: String) {
        super(text, lang)
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }
}
