/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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
     * 不支持此操作，调用此方法将抛出 {@link UnsupportedException}。
     * </p>
     *
     * @return 将会抛出异常。
     * @throws UnsupportedException 因此操作不被支持。
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

    /**
     * 设置节的接收方地址。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #to(Jid)
     */
    public override func to(to: String): IqData {
        super.to(to)
        getThis()
    }

    /**
     * 设置节要发送给谁。
     * XMPP 协议通常使“to”属性是可选的，所以它并不总是需要被设置。
     *
     * @param to 节要发送给谁。
     * @return 对这个构建器的引用。
     */
    public override func to(to: ?Jid): IqData {
        super.to(to)
        getThis()
    }

    /**
     * 设置节从谁那里发送。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     * @throws XmppStringprepException 如果提供的字符序列不是有效的 XMPP 地址。
     * @see #froms(Jid)
     */
    public override func froms(froms: String): IqData {
        super.froms(froms)
        getThis()
    }

    /**
     * 设置节从谁那里发送。
     * XMPP 协议通常使“from”属性是可选的，所以它并不总是需要被设置。
     *
     * @param froms 节从谁那里发送。
     * @return 对这个构建器的引用。
     */
    public override func froms(froms: ?Jid): IqData {
        super.froms(froms)
        getThis()
    }

    /**
     * 设置这个节的错误。
     *
     * @param stanzaError 要与这个节关联的错误。
     * @return 对这个构建器的引用。
     */
    public override func setError(stanzaError: ?StanzaError): IqData {
        super.setError(stanzaError)
        getThis()
    }

    /**
     * 设置这个节的 xml:lang。
     *
     * @param language 这个节的 xml:lang。
     * @return 对这个构建器的引用。
     */
    public override func setLanguage(language: ?String): IqData {
        super.setLanguage(language)
        getThis()
    }

    /**  
     * 添加子元素到构建器中。
     *
     * @param extensionElement 要添加的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addExtension(extensionElement: ExtensionElement): IqData {
        super.addExtension(extensionElement)
        getThis()
    }

    /**  
     * 添加可选的多个子元素。
     *
     * @param extensionElements 要添加的子元素集（可以为空，但不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addOptExtensions(extensionElements: ?Collection<ExtensionElement>): IqData {
        super.addOptExtensions(extensionElements)
        getThis()
    }

    /**  
     * 添加多个子元素。
     *
     * @param extensionElements 要添加的子元素集（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func addExtensions(extensionElements: Collection<ExtensionElement>): IqData {
        super.addExtensions(extensionElements)
        getThis()
    }

    /**  
     * 替换现有的子元素。
     *
     * @param extensionElement 要替换的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func overrideExtension(extensionElement: ExtensionElement): IqData {
        super.overrideExtension(extensionElement)
        getThis()
    }

    /**  
     * 移除指定的子元素。
     *
     * @param elementName 要移除的元素名称
     * @param namespace 该元素的命名空间
     * @return 当前的构建器实例，以便进行方法链调用
     */
    public override func removeExtension(elementName: String, namespace: String): IqData {
        super.removeExtension(elementName, namespace)
        getThis()
    }

    /**  
     * 移除指定的子元素。
     *
     * @param extension 要移除的子元素（不能为 null）
     * @return 当前的构建器实例，以便进行方法链调用
     */
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
