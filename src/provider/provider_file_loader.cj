/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 * 从准备中的标准提供程序文件加载｛@link IQProvider｝和｛@link ExtensionElementProvider｝信息
 * 用于加载到｛@link ProviderManager｝中。
 */
public class ProviderFileLoader <: ProviderLoader {
    private static let LOGGER = getGlobalLogger(("name", "ProviderFileLoader"))

    private let iqProviders: LinkedList<IQProviderInfo> = LinkedList<IQProviderInfo>()

    private let extProviders: LinkedList<ExtensionProviderInfo> = LinkedList<ExtensionProviderInfo>()

    private let sfProviders: LinkedList<StreamFeatureProviderInfo> = LinkedList<StreamFeatureProviderInfo>()

    private var exceptions: LinkedList<Exception> = LinkedList<Exception>()

    /**  
     * 根据提供的输入流初始化 ProviderFileLoader 实例。
     *
     * @param providerStream 输入流，包含提供程序的 XML 配置
     */
    public init(providerStream: InputStream) {
        try {
            let parser = PacketParserUtils.getParserFor(providerStream)
            var eventType = parser.getEventType()
            do {
                if (eventType == XmlPullParserEvent.START_ELEMENT) {
                    let typeName = parser.getName()
                    try {
                        if ("xmppProviders" != typeName) {
                            parser.next()
                            parser.next()
                            let elementName = parser.nextText()
                            parser.next()
                            parser.next()
                            let namespace = parser.nextText()
                            parser.next()
                            parser.next()
                            let className = parser.nextText()
                            try {
                                let provider = (TypeInfo.get(className) as ClassTypeInfo).getOrThrow(
                                    {=> ReflectException()})
                                match (typeName) {
                                    case "iqProvider" => if (provider.isSubtypeOf(TypeInfo.of<IqProvider<IQ>>())) {
                                        let iqProvider = (provider.getConstructor().apply() as IqProvider<IQ>).
                                            getOrThrow({=> ReflectException()})
                                        iqProviders.append(IQProviderInfo(elementName, namespace, iqProvider))
                                    } else {
                                        exceptions.append(IllegalArgumentException((className) + " is not a IQProvider")
                                        )
                                    }
                                    case "extensionProvider" => if (provider.isSubtypeOf(
                                        TypeInfo.of<ExtensionElementProvider<ExtensionElement>>())) {
                                        let extensionElementProvider = (provider.getConstructor().apply() as ExtensionElementProvider<ExtensionElement>).
                                            getOrThrow({=> ReflectException()})
                                        extProviders.append(
                                            ExtensionProviderInfo(elementName, namespace, extensionElementProvider))
                                    } else {
                                        exceptions.append(
                                            IllegalArgumentException((className) + " is not a PacketExtensionProvider"))
                                    }
                                    case "streamFeatureProvider" =>
                                        let streamFeatureProvider = (provider.getConstructor().apply() as ExtensionElementProvider<ExtensionElement>).
                                            getOrThrow({=> ReflectException()})
                                        sfProviders.append(
                                            StreamFeatureProviderInfo(elementName, namespace, streamFeatureProvider))
                                    case _ => LOGGER.warn("Unknown provider type: ${typeName}")
                                }
                            } catch (cnfe: InfoNotFoundException) {
                                LOGGER.log(LogLevel.ERROR, "Could not find provider class", ("Exception", cnfe))
                                exceptions.append(cnfe)
                            } catch (ie: ReflectException) {
                                LOGGER.log(LogLevel.ERROR, "Could not instanciate ${className}", ("Exception", ie))
                                exceptions.append(ie)
                            }
                        }
                    } catch (illExc: IllegalArgumentException) {
                        LOGGER.log(
                            LogLevel.ERROR,
                            "Invalid provider type found [${typeName}] when expecting iqProvider or extensionProvider",
                            illExc
                        )
                        exceptions.append(illExc)
                    }
                }
                eventType = parser.next()
            } while (eventType != XmlPullParserEvent.END_DOCUMENT)
        } catch (e: Exception) {
            LOGGER.log(LogLevel.ERROR, "Unknown error occurred while parsing provider file", ("Exception", e))
            exceptions.append(e)
        } finally {
            (providerStream as Resource)?.close()
        }
    }

    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的 IQ 提供者的 IQ 提供者信息。
     *
     * @return 要加载的 IQ 提供者信息。
     */
    public override func getIQProviderInfo(): Collection<IQProviderInfo> {
        return iqProviders
    }

    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的扩展提供者的扩展提供者信息。
     *
     * @return 要加载的扩展提供者信息。
     */
    public override func getExtensionProviderInfo(): Collection<ExtensionProviderInfo> {
        return extProviders
    }

    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的流特征提供者的流特征提供者信息。
     *
     * @return 要加载的扩展提供者信息。
     */
    public override func getStreamFeatureProviderInfo(): Collection<StreamFeatureProviderInfo> {
        return sfProviders
    }

    /**  
     * 返回加载过程中发生的异常列表。
     *
     * @return 不可修改的异常列表
     */
    public func getLoadingExceptions(): Collection<Exception> {
        return exceptions
    }
}
