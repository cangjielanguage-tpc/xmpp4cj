/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Manages providers for parsing custom XML sub-documents of XMPP packets. Two types of
 * providers exist:<ul>
 *      <li>IQProvider -- parses IQ requests into objects.
 *      <li>PacketExtension -- parses XML sub-documents attached to packets into
 *          PacketExtension instances.</ul>
 *
 * <b>IQProvider</b><p>
 *
 * By default, Xmpp only knows how to process IQ packets with sub-packets that
 * are in a few namespaces such as:<ul>
 *      <li>jabber:iq:auth
 *      <li>jabber:iq:roster
 *      <li>jabber:iq:register</ul>
 *
 * Because many more IQ types are part of XMPP and its extensions, a pluggable IQ parsing
 * mechanism is provided. IQ providers are registered programmatically or by creating a
 * providers file. The file is an XML
 * document that contains one or more iqProvider entries, as in the following example:
 *
 * <pre>
 * &lt;?xml version="1.0"?&gt;
 * &lt;xmppProviders&gt;
 *     &lt;iqProvider&gt;
 *         &lt;elementName&gt;query&lt;/elementName&gt;
 *         &lt;namespace&gt;jabber:iq:time&lt;/namespace&gt;
 *         &lt;className&gt;Time&lt;/className&gt;
 *     &lt;/iqProvider&gt;
 * &lt;/xmppProviders&gt;</pre>
 *
 * Each IQ provider is associated with an element name and a namespace. If multiple provider
 * entries attempt to register to handle the same namespace, the first entry loaded from the
 * classpath will take precedence. The IQ provider class can either implement the IQProvider
 * interface, or extend the IQ class. In the former case, each IQProvider is responsible for
 * parsing the raw XML stream to create an IQ instance. In the latter case, bean introspection
 * is used to try to automatically set properties of the IQ instance using the values found
 * in the IQ stanza XML. For example, an XMPP time stanza resembles the following:
 * <pre>
 * &lt;iq type='result' to='joe@example.com' from='mary@example.com' id='time_1'&gt;
 *     &lt;query xmlns='jabber:iq:time'&gt;
 *         &lt;utc&gt;20020910T17:58:35&lt;/utc&gt;
 *         &lt;tz&gt;MDT&lt;/tz&gt;
 *         &lt;display&gt;Tue Sep 10 12:58:35 2002&lt;/display&gt;
 *     &lt;/query&gt;
 * &lt;/iq&gt;</pre>
 *
 * In order for this stanza to be automatically mapped to the Time object listed in the
 * providers file above, it must have the methods setUtc(String), setTz(String), and
 * setDisplay(String). The introspection service will automatically try to convert the String
 * value from the XML into a boolean, int, long, float, double, or Class depending on the
 * type the IQ instance expects.<p>
 *
 * A pluggable system for stanza extensions, child elements in a custom namespace for
 * message and presence packets, also exists. Each extension provider
 * is registered with a name space in the xmpp.providers file as in the following example:
 *
 * <pre>
 * &lt;?xml version="1.0"?&gt;
 * &lt;xmppProviders&gt;
 *     &lt;extensionProvider&gt;
 *         &lt;elementName&gt;x&lt;/elementName&gt;
 *         &lt;namespace&gt;jabber:iq:event&lt;/namespace&gt;
 *         &lt;className&gt;MessageEvent&lt;/className&gt;
 *     &lt;/extensionProvider&gt;
 * &lt;/xmppProviders&gt;</pre>
 *
 * If multiple provider entries attempt to register to handle the same element name and namespace,
 * the first entry loaded from the classpath will take precedence.
 * Whenever a stanza extension is found in a packet, parsing will be passed to the correct provider.
 * Each provider can implement the PacketExtensionProvider interface.
 * In the former case, each extension provider is responsible for parsing the raw XML stream to
 * construct an object. In the latter case, bean introspection is used to try to automatically
 * set the properties of th class using the values in the stanza extension sub-element. When an
 * extension provider is not registered for an element name and namespace combination, will
 * store all top-level elements of the sub-packet in DefaultPacketExtension object and then
 * attach it to the packet.<p>
 */
public class ProviderManager {
    public init() {}

    private static let extensionProviders = ConcurrentHashMap<QName, ExtensionElementProvider<ExtensionElement>>()
    private static let iqProviders = ConcurrentHashMap<QName, IqProvider<IQ>>()
    private static let streamFeatureProviders = ConcurrentHashMap<QName, ExtensionElementProvider<ExtensionElement>>()
    private static let nonzaProviders = ConcurrentHashMap<QName, NonzaProvider<Nonza>>()

    private static let Xmpp_EnsureInitialized = {
        =>
    // Ensure that Xmpp is initialized by calling getVersion,
    // so that user registered providers do not get overwritten by a following Xmpp initialization.
    // This guarantees that Xmpp is initialized before a new provider is registered
    // Xmpp.ensureInitialized() // TODO
    }()

    public static func addLoader(loader: ProviderLoader): Unit {
        for (info in loader.getIQProviderInfo()) {
            addIQProvider(info.getElementName(), info.getNamespace(), info.getProvider())
        }
        for (info in loader.getExtensionProviderInfo()) {
            addExtensionProvider(info.getElementName(), info.getNamespace(), info.getProvider())
        }
        for (info in loader.getStreamFeatureProviderInfo()) {
            addStreamFeatureProvider(
                info.getElementName(),
                info.getNamespace(),
                (info.getProvider() as ExtensionElementProvider<ExtensionElement>).getOrThrow()
            )
        }
    }
    /**
     * Returns the IQ provider registered to the specified XML element name and namespace.
     * For example, if a provider was registered to the element name "query" and the
     * namespace "jabber:iq:time", then the following stanza would trigger the provider:
     *
     * <pre>
     * &lt;iq type='result' to='joe@example.com' from='mary@example.com' id='time_1'&gt;
     *     &lt;query xmlns='jabber:iq:time'&gt;
     *         &lt;utc&gt;20020910T17:58:35&lt;/utc&gt;
     *         &lt;tz&gt;MDT&lt;/tz&gt;
     *         &lt;display&gt;Tue Sep 10 12:58:35 2002&lt;/display&gt;
     *     &lt;/query&gt;
     * &lt;/iq&gt;</pre>
     *
     * <p>Note: this method is generally only called by the internal Xmpp classes.
     *
     * @param elementName the XML element name.
     * @param namespace the XML namespace.
     * @return the IQ provider.
     */
    public static func getIQProvider(elementName: String, namespace: String): ?IqProvider<IQ> {
        let key = getQName(elementName, namespace)
        return iqProviders.get(key)
    }

    /**
     * Returns an unmodifiable collection of all IQProvider instances.
     * Each object in the collection will either be an IQProvider instance,
     * or a Class object that implements the IQProvider interface.
     *
     * @return all IQProvider instances.
     */
    public static func getIQProviders(): ArrayList<IqProvider<IQ>> {
        let providers = ArrayList<IqProvider<IQ>>(iqProviders.size)
        for (value in iqProviders.values()) {
            providers.append(value)
        }
        return providers
    }

    /**
     * Adds an IQ provider (must be an instance of IQProvider or Class object that is an IQ)
     * with the specified element name and name space. The provider will override any providers
     * loaded through the classpath.
     *
     * @param elementName the XML element name.
     * @param namespace the XML namespace.
     * @param provider the IQ provider.
     */
    public static func addIQProvider(elementName: String, namespace: String, provider: Any): Unit {
        validate(elementName, namespace)
        let key = removeIQProvider(elementName, namespace)
        match (provider) {
            case v: IqProvider<IQ> => iqProviders.put(key, v)
            case _ => throw IllegalArgumentException("Provider must be an instance of IqProvider")
        }
    }

    /**
     * Removes an IQ provider with the specified element name and namespace. This
     * method is typically called to cleanup providers that are programmatically added
     * using the {@link #addIQProvider(String, String, Object) addIQProvider} method.
     *
     * @param elementName the XML element name.
     * @param namespace the XML namespace.
     * @return the QName of the removed provider
     */
    public static func removeIQProvider(elementName: String, namespace: String): QName {
        let key = getQName(elementName, namespace)
        iqProviders.remove(key)
        return key
    }

    /**
     * Returns the stanza extension provider registered to the specified XML element name
     * and namespace. For example, if a provider was registered to the element name "x" and the
     * namespace "jabber:x:event", then the following stanza would trigger the provider:
     *
     * <pre>
     * &lt;message to='romeo@montague.net' id='message_1'&gt;
     *     &lt;body&gt;Art thou not Romeo, and a Montague?&lt;/body&gt;
     *     &lt;x xmlns='jabber:x:event'&gt;
     *         &lt;composing/&gt;
     *     &lt;/x&gt;
     * &lt;/message&gt;</pre>
     *
     * <p>Note: this method is generally only called by the internal Xmpp classes.
     *
     * @param elementName element name associated with extension provider.
     * @param namespace namespace associated with extension provider.
     * @return the extension provider.
     */
    public static func getExtensionProvider(elementName: String, namespace: String): ?ExtensionElementProvider<ExtensionElement> {
        let key = getQName(elementName, namespace)
        return getExtensionProvider(key)
    }

    public static func getExtensionProvider(qname: QName): ?ExtensionElementProvider<ExtensionElement> {
        return extensionProviders.get(qname)
    }

    /**
     * Adds an extension provider with the specified element name and name space.
     * The provider will override any providers loaded through the classpath.
     * The provider must be either a PacketExtensionProvider instance.
     *
     * @param elementName the XML element name.
     * @param namespace the XML namespace.
     * @param provider the extension provider.
     */
    public static func addExtensionProvider(elementName: String, namespace: String, provider: Any): Unit {
        validate(elementName, namespace)
        let key = removeExtensionProvider(elementName, namespace)
        match (provider) {
            case v: ExtensionElementProvider<ExtensionElement> => extensionProviders.put(key, v)
            case _ => throw IllegalArgumentException("Provider must be a PacketExtensionProvider")
        }
    }

    /**
     * Removes an extension provider with the specified element name and namespace. This
     * method is typically called to cleanup providers that are programmatically added
     * using the {@link #addExtensionProvider(String, String, Object) addExtensionProvider} method.
     *
     * @param elementName the XML element name.
     * @param namespace the XML namespace.
     * @return the QName of the removed stanza extension provider
     */
    public static func removeExtensionProvider(elementName: String, namespace: String): QName {
        let key = getQName(elementName, namespace)
        extensionProviders.remove(key)
        return key
    }

    /**
     * Returns an unmodifiable collection of all PacketExtensionProvider instances.
     * Each object in the collection will either be a PacketExtensionProvider instance,
     * or a Class object that implements the PacketExtensionProvider interface.
     *
     * @return all PacketExtensionProvider instances.
     */
    public static func getExtensionProviders(): ArrayList<ExtensionElementProvider<ExtensionElement>> {
        let providers = ArrayList<ExtensionElementProvider<ExtensionElement>>(extensionProviders.size)
        for (value in extensionProviders.values()) {
            providers.append(value)
        }
        return providers
    }

    public static func getStreamFeatureProvider(elementName: String, namespace: String): ?ExtensionElementProvider<ExtensionElement> {
        let key = getQName(elementName, namespace)
        return streamFeatureProviders.get(key)
    }

    public static func addStreamFeatureProvider(
        elementName: String,
        namespace: String,
        provider: ExtensionElementProvider<ExtensionElement>
    ): Unit {
        validate(elementName, namespace)
        let key = getQName(elementName, namespace)
        streamFeatureProviders.put(key, provider)
    }

    public static func removeStreamFeatureProvider(elementName: String, namespace: String): Unit {
        let key = getQName(elementName, namespace)
        streamFeatureProviders.remove(key)
    }

    public static func getNonzaProvider(elementName: String, namespace: String): ?NonzaProvider<Nonza> {
        let key = getQName(elementName, namespace)
        return getNonzaProvider(key)
    }

    public static func getNonzaProvider(key: QName): ?NonzaProvider<Nonza> {
        return nonzaProviders.get(key)
    }

    public static func addNonzaProvider(nonzaProvider: NonzaProvider<Nonza>): Unit {
        let nonzaClass = nonzaProvider.getElementClass()
        let key = XmppElementUtil.getQNameFor(nonzaClass)
        nonzaProviders.put(key, nonzaProvider)
    }

    public static func removeNonzaProvider(nonzaClass: ClassId): Unit {
        let key = XmppElementUtil.getQNameFor(nonzaClass)
        nonzaProviders.remove(key)
    }

    public static func removeNonzaProvider(elementName: String, namespace: String): Unit {
        let key = getQName(elementName, namespace)
        nonzaProviders.remove(key)
    }

    private static func getQName(elementName: String, namespace: String): QName {
        return QName(namespace, elementName)
    }

    private static func validate(elementName: String, namespace: String): Unit {
        if (StringUtils.isNullOrEmpty(elementName)) {
            throw IllegalArgumentException("elementName must not be None or empty")
        }
        if (StringUtils.isNullOrEmpty(namespace)) {
            throw IllegalArgumentException("namespace must not be None or empty")
        }
    }
}
