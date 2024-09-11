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

    public override func build(): Stanza {
        throw UnsupportedException()
    }

    public override func getThis(): IqData {
        return this
    }
    public override func to(to: String): IqData {
        super.to(to)
        getThis()
    }
    public override func to(to: ?Jid): IqData {
        super.to(to)
        getThis()
    }
    public override func froms(froms: String): IqData {
        super.froms(froms)
        getThis()
    }
    public override func froms(froms: ?Jid): IqData {
        super.froms(froms)
        getThis()
    }
    public override func setError(stanzaError: StanzaError): IqData {
        super.setError(stanzaError)
        getThis()
    }
    public override func setLanguage(language: String): IqData {
        super.setLanguage(language)
        getThis()
    }
    public override func addExtension(extensionElement: ExtensionElement): IqData {
        super.addExtension(extensionElement)
        getThis()
    }
    public override func addOptExtensions(extensionElements: ?Collection<ExtensionElement>): IqData {
        super.addOptExtensions(extensionElements)
        getThis()
    }
    public override func addExtensions(extensionElements: Collection<ExtensionElement>): IqData {
        super.addExtensions(extensionElements)
        getThis()
    }
    public override func overrideExtension(extensionElement: ExtensionElement): IqData {
        super.overrideExtension(extensionElement)
        getThis()
    }
    public override func removeExtension(elementName: String, namespace: String): IqData {
        super.removeExtension(elementName, namespace)
        getThis()
    }
    public override func removeExtension(extension: ExtensionElement): IqData {
        super.removeExtension(extension)
        getThis()
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
