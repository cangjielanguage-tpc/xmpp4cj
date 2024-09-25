/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 * Loads the {@link IQProvider} and {@link ExtensionElementProvider} information from a standard provider file in preparation
 * for loading into the {@link ProviderManager}.
 */
public class ProviderFileLoader <: ProviderLoader {
    private static let LOGGER = getGlobalLogger(("name", "ProviderFileLoader"))

    private let iqProviders: LinkedList<IQProviderInfo> = LinkedList<IQProviderInfo>()

    private let extProviders: LinkedList<ExtensionProviderInfo> = LinkedList<ExtensionProviderInfo>()

    private let sfProviders: LinkedList<StreamFeatureProviderInfo> = LinkedList<StreamFeatureProviderInfo>()

    private var exceptions: LinkedList<Exception> = LinkedList<Exception>()

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
                                    case _ => LOGGER.warn("Unknown provider type: " + (typeName))
                                }
                            } catch (cnfe: InfoNotFoundException) {
                                LOGGER.log(LogLevel.FATAL, "Could not find provider class", ("Exception", cnfe))
                                exceptions.append(cnfe)
                            } catch (ie: ReflectException) {
                                LOGGER.log(LogLevel.FATAL, "Could not instanciate " + (className), ("Exception", ie))
                                exceptions.append(ie)
                            }
                        }
                    } catch (illExc: IllegalArgumentException) {
                        LOGGER.log(
                            LogLevel.FATAL,
                            "Invalid provider type found [" + (typeName) +
                                "] when expecting iqProvider or extensionProvider",
                            ("Exception", illExc)
                        )
                        exceptions.append(illExc)
                    }
                }
                eventType = parser.next()
            } while (eventType != XmlPullParserEvent.END_DOCUMENT)
        } catch (e: Exception) {
            LOGGER.log(LogLevel.FATAL, "Unknown error occurred while parsing provider file", ("Exception", e))
            exceptions.append(e)
        } finally {
            (providerStream as Resource)?.close()
        }
    }

    public override func getIQProviderInfo(): Collection<IQProviderInfo> {
        return iqProviders
    }

    public override func getExtensionProviderInfo(): Collection<ExtensionProviderInfo> {
        return extProviders
    }

    public override func getStreamFeatureProviderInfo(): Collection<StreamFeatureProviderInfo> {
        return sfProviders
    }

    public func getLoadingExceptions(): Collection<Exception> {
        return exceptions
    }
}
