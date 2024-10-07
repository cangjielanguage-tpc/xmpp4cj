/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**  
 * 表示 IQ 数据的构造器，用于创建和配置 XMPP IQ 数据包。
 * <p>
 * 此类是抽象 IQ 数据包构造器的一个具体实现，主要用于在构建 IQ 数据包时提供类型、安全等功能。
 * </p>
 */
public class IqData <: AbstractIqBuilder {
    /**  
     * 一个空的 IqData 实例，用于表示没有有效数据的情况。
     */
    static let EMPTY = IqData(StandardStanzaIdSource.DEFAULT)

    /**  
     * 使用默认的 {@link StanzaIdSource} 初始化 IqData 对象。
     *
     * @param stanzaIdSource 发送数据包的 ID 源。
     */
    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    /**  
     * 使用指定的 Stanza ID 初始化 IqData 对象。
     *
     * @param stanzaId 数据包的 ID
     */
    init(stanzaId: ?String) {
        super(stanzaId)
    }

    /**  
     * 设置 IQ 的类型，并返回当前构造器实例。
     *
     * @param type 要设置的 IQ 类型。必须非空。
     * @return 当前的 IqData 实例。
     * @throws NullPointerException 如果提供的类型为 null。
     */
    public func ofType(typ: IQType): IqData {
        this.typ = typ
        return getThis()
    }

    /**  
     * 构建并返回一个 Stanza 实例。
     * <p>
     * 不支持此操作，调用此方法将抛出 {@link UnsupportedOperationException}。
     * </p>
     *
     * @return 将会抛出异常。
     * @throws UnsupportedOperationException 因此操作不被支持。
     */
    public override func build(): Stanza {
        throw UnsupportedException()
    }

    /**  
     * 返回当前构造器的实例。
     *
     * @return 当前的 IqData 实例。
     */
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

    public override func setError(stanzaError: ?StanzaError): IqData {
        super.setError(stanzaError)
        getThis()
    }

    public override func setLanguage(language: ?String): IqData {
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
}
