/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 * 管理用于解析 XMPP 数据包的自定义 XML 子文档的提供程序。存在两种类型的提供程序：<ul>
 *      <li>IQProvider -- 将 IQ 请求解析为对象。
 *      <li>PacketExtension -- 将附加到数据包的 XML 子文档解析为 PacketExtension 实例。</ul>
 *
 * <b>IQProvider</b><p>
 *
 * 默认情况下，Xmpp 仅知道如何处理具有子包的 IQ 数据包，这些子包位于少数几个命名空间中，例如：<ul>
 *      <li>jabber:iq:auth
 *      <li>jabber:iq:roster
 *      <li>jabber:iq:register</ul>
 *
 * 由于 XMPP 及其扩展中有更多的 IQ 类型，因此提供了一个可插拔的 IQ 解析机制。IQ 提供程序可以通过编程方式注册，也可以通过创建提供程序文件进行注册。该文件是一个 XML 文档，其中包含一个或多个 iqProvider 条目，如下例所示：
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
 * 每个 IQ 提供程序都与一个元素名称和一个命名空间相关联。如果多个提供程序条目试图注册以处理相同的命名空间，则从类路径加载的第一个条目将具有优先权。IQ 提供程序类可以实现 IQProvider 接口，也可以扩展 IQ 类。在前一种情况下，每个 IQProvider 负责解析原始 XML 流以创建一个 IQ 实例。在后一种情况下，使用 bean 内省来尝试使用在 IQ 节 XML 中找到的值自动设置 IQ 实例的属性。例如，一个 XMPP 时间节类似于以下内容：
 * <pre>
 * &lt;iq type='result' to='joe@example.com' from='mary@example.com' id='time_1'&gt;
 *     &lt;query xmlns='jabber:iq:time'&gt;
 *         &lt;utc&gt;20020910T17:58:35&lt;/utc&gt;
 *         &lt;tz&gt;MDT&lt;/tz&gt;
 *         &lt;display&gt;Tue Sep 10 12:58:35 2002&lt;/display&gt;
 *     &lt;/query&gt;
 * &lt;/iq&gt;</pre>
 *
 * 为了使这个节自动映射到上面提供程序文件中列出的 Time 对象，它必须具有 setUtc(String)、setTz(String) 和 setDisplay(String) 方法。内省服务将自动尝试根据 IQ 实例期望的类型将 XML 中的字符串值转换为布尔值、整数、长整数、浮点数、双精度数或类。<p>
 *
 * 还存在一个用于节扩展的可插拔系统，即消息和存在数据包的自定义命名空间中的子元素。每个扩展提供程序都在 xmpp.providers 文件中使用名称空间进行注册，如下例所示：
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
 * 如果多个提供程序条目试图注册以处理相同的元素名称和命名空间，则从类路径加载的第一个条目将具有优先权。每当在数据包中找到节扩展时，解析将传递给正确的提供程序。每个提供程序都可以实现 PacketExtensionProvider 接口。在前一种情况下，每个扩展提供程序负责解析原始 XML 流以构造一个对象。在后一种情况下，使用 bean 内省来尝试使用在节扩展子元素中的值自动设置类的属性。当没有为元素名称和命名空间组合注册扩展提供程序时，将把子包的所有顶级元素存储在 DefaultPacketExtension 对象中，然后将其附加到数据包上。<p>
 */
public class ProviderManager {
    /**  
     * 构造函数，初始化 ProviderManager 实例。
     */
    public init() {}

    private static let extensionProviders = ConcurrentHashMap<QName, ExtensionElementProvider<ExtensionElement>>()
    private static let iqProviders = ConcurrentHashMap<QName, IqProvider<IQ>>()
    private static let streamFeatureProviders = ConcurrentHashMap<QName, ExtensionElementProvider<ExtensionElement>>()
    private static let nonzaProviders = ConcurrentHashMap<QName, NonzaProvider<Nonza>>()

    static init() {
        // Ensure that Xmpp is initialized by calling getVersion,
        // so that user registered providers do not get overwritten by a following Xmpp initialization.
        // This guarantees that Xmpp is initialized before a new provider is registered
        // Xmpp.ensureInitialized() // TODO
    }

    /**  
     * 添加提供程序加载器，允许注册多个 IQ 提供程序和扩展提供程序。
     *
     * @param loader 要添加的 {@link ProviderLoader} 实例。
     */
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
                info.getProvider()
            )
        }
    }

    /**
     * 返回注册到指定 XML 元素名称和命名空间的 IQ 提供程序。例如，如果一个提供程序注册到元素名称为“query”且命名空间为“jabber:iq:time”，那么以下节将触发该提供程序：
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
     * <p>注意：此方法通常仅由内部 Xmpp 类调用。
     *
     * @param elementName XML 元素名称。
     * @param namespace XML 命名空间。
     * @return IQ 提供程序。
     */
    public static func getIQProvider(elementName: String, namespace: String): ?IqProvider<IQ> {
        let key = getQName(elementName, namespace)
        return iqProviders.get(key)
    }

    /**
     * 返回所有 IQProvider 实例的不可修改集合。集合中的每个对象要么是一个 IQProvider 实例，要么是实现 IQProvider 接口的 Class 对象。
     *
     * @return 所有 IQProvider 实例。
     */
    public static func getIQProviders(): ArrayList<IqProvider<IQ>> {
        let providers = ArrayList<IqProvider<IQ>>(iqProviders.size)
        for (value in iqProviders.values()) {
            providers.append(value)
        }
        return providers
    }

    /**
     * 添加具有指定元素名称和命名空间的 IQ 提供程序（必须是 IQProvider 的实例或实现 IQProvider 的 Class 对象）。该提供程序将覆盖通过类路径加载的任何提供程序。
     *
     * @param elementName XML 元素名称。
     * @param namespace XML 命名空间。
     * @param provider IQ 提供程序。
     */
    public static func addIQProvider<I>(elementName: String, namespace: String, provider: IqProvider<I>): Unit where I <: IQ {
        validate(elementName, namespace)
        let key = removeIQProvider(elementName, namespace)
        let v = IqProviderWrapper(provider.getElementClass(), provider.parse)
        iqProviders.put(key, v)
    }

    /**
     * 移除具有指定元素名称和命名空间的 IQ 提供程序。此方法通常用于清理通过 {@link #addIQProvider(String, String, Object) addIQProvider} 方法以编程方式添加的提供程序。
     *
     * @param elementName XML 元素名称。
     * @param namespace XML 命名空间。
     * @return 已移除提供程序的 QName。
     */
    public static func removeIQProvider(elementName: String, namespace: String): QName {
        let key = getQName(elementName, namespace)
        iqProviders.remove(key)
        return key
    }

    /**
     * 返回注册到指定 XML 元素名称和命名空间的节扩展提供程序。例如，如果一个提供程序注册到元素名称为“x”且命名空间为“jabber:x:event”，那么以下节将触发该提供程序：
     *
     * <pre>
     * &lt;message to='romeo@montague.net' id='message_1'&gt;
     *     &lt;body&gt;Art thou not Romeo, and a Montague?&lt;/body&gt;
     *     &lt;x xmlns='jabber:x:event'&gt;
     *         &lt;composing/&gt;
     *     &lt;/x&gt;
     * &lt;/message&gt;</pre>
     *
     * <p>注意：此方法通常仅由内部 Xmpp 类调用。
     *
     * @param elementName 与扩展提供程序相关联的元素名称。
     * @param namespace 与扩展提供程序相关联的命名空间。
     * @return 扩展提供程序。
     */
    public static func getExtensionProvider(elementName: String, namespace: String): ?ExtensionElementProvider<ExtensionElement> {
        let key = getQName(elementName, namespace)
        return getExtensionProvider(key)
    }

    /**  
     * 根据给定的 QName 获取注册的扩展元素提供程序。
     *
     * @param qname 对应于扩展元素的 QName。
     * @return 匹配的扩展元素提供程序，如果未找到则返回 null。
     */
    public static func getExtensionProvider(qname: QName): ?ExtensionElementProvider<ExtensionElement> {
        return extensionProviders.get(qname)
    }

    /**
     * 添加具有指定元素名称和命名空间的扩展提供程序。该提供程序将覆盖通过类路径加载的任何提供程序。提供程序必须是 PacketExtensionProvider 实例。
     *
     * @param elementName XML 元素名称。
     * @param namespace XML 命名空间。
     * @param provider 扩展提供程序。
     */
    public static func addExtensionProvider<E>(elementName: String, namespace: String,
        provider: ExtensionElementProvider<E>): Unit where E <: ExtensionElement {
        validate(elementName, namespace)
        let key = removeExtensionProvider(elementName, namespace)
        let v = ExtensionElementProviderWrapper(provider.getElementClass(), provider.parse)
        extensionProviders.put(key, v)
    }

    /**
     * 移除具有指定元素名称和命名空间的扩展提供程序。此方法通常用于清理通过 {@link #addExtensionProvider(String, String, Object) addExtensionProvider} 方法以编程方式添加的提供程序。
     *
     * @param elementName XML 元素名称。
     * @param namespace XML 命名空间。
     * @return 已移除的节扩展提供程序的 QName。
     */
    public static func removeExtensionProvider(elementName: String, namespace: String): QName {
        let key = getQName(elementName, namespace)
        extensionProviders.remove(key)
        return key
    }

    /**
     * 返回所有 PacketExtensionProvider 实例的不可修改集合。集合中的每个对象要么是一个 PacketExtensionProvider 实例，要么是实现 PacketExtensionProvider 接口的 Class 对象。
     *
     * @return 所有 PacketExtensionProvider 实例。
     */
    public static func getExtensionProviders(): ArrayList<ExtensionElementProvider<ExtensionElement>> {
        let providers = ArrayList<ExtensionElementProvider<ExtensionElement>>(extensionProviders.size)
        for (value in extensionProviders.values()) {
            providers.append(value)
        }
        return providers
    }

    /**  
     * 根据元素名称和命名空间获取流特性提供程序。
     *
     * @param elementName 流特性元素的名称。
     * @param namespace 流特性元素的命名空间。
     * @return 返回与给定元素名称和命名空间匹配的流特性提供程序。
     */
    public static func getStreamFeatureProvider(elementName: String, namespace: String): ?ExtensionElementProvider<ExtensionElement> {
        let key = getQName(elementName, namespace)
        return streamFeatureProviders.get(key)
    }

    /**  
     * 添加流特性提供程序。该提供程序将与指定的元素名称和命名空间相关联。
     *
     * @param elementName 流特性元素的名称。
     * @param namespace 流特性元素的命名空间。
     * @param provider 要添加的流特性提供程序。
     */
    public static func addStreamFeatureProvider<E>(
        elementName: String,
        namespace: String,
        provider: ExtensionElementProvider<E>
    ): Unit where E <: ExtensionElement {
        validate(elementName, namespace)
        let key = getQName(elementName, namespace)
        streamFeatureProviders.put(key, ExtensionElementProviderWrapper(provider.getElementClass(), provider.parse))
    }

    /**  
     * 移除指定元素名称和命名空间的流特性提供程序。
     *
     * @param elementName 流特性元素的名称。
     * @param namespace 流特性元素的命名空间。
     */
    public static func removeStreamFeatureProvider(elementName: String, namespace: String): Unit {
        let key = getQName(elementName, namespace)
        streamFeatureProviders.remove(key)
    }

    /**  
     * 根据指定的元素名称和命名空间获取 Nonza 提供程序。
     *
     * @param elementName Nonza 元素的名称。
     * @param namespace Nonza 元素的命名空间。
     * @return 匹配的 Nonza 提供程序，如果未找到则返回 null。
     */
    public static func getNonzaProvider(elementName: String, namespace: String): ?NonzaProvider<Nonza> {
        let key = getQName(elementName, namespace)
        return getNonzaProvider(key)
    }

    /**  
     * 根据 QName 获取 Nonza 提供程序。
     *
     * @param key 对应于 Nonza 元素的 QName。
     * @return 匹配的 Nonza 提供程序，如果未找到则返回 null。
     */
    public static func getNonzaProvider(key: QName): ?NonzaProvider<Nonza> {
        return nonzaProviders.get(key)
    }

    /**  
     * 添加 Nonza 提供程序。
     *
     * @param nonzaProvider 要添加的 Nonza 提供程序。
     */
    public static func addNonzaProvider<N>(nonzaProvider: NonzaProvider<N>): Unit where N <: Nonza {
        let nonzaClass = nonzaProvider.getElementClass()
        let key = XmppElementUtil.getQNameFor(nonzaClass)
        let wrapper = NonzaProviderWrapper(nonzaProvider.getElementClass(), nonzaProvider.parse)
        nonzaProviders.put(key, wrapper)
    }

    /**  
     * 根据 Nonza 类移除相应的 Nonza 提供程序。
     *
     * @param nonzaClass 需要移除的 Nonza 类。
     */
    public static func removeNonzaProvider(nonzaClass: ClassId): Unit {
        let key = XmppElementUtil.getQNameFor(nonzaClass)
        nonzaProviders.remove(key)
    }

    /**  
     * 根据元素名称和命名空间移除 Nonza 提供程序。
     *
     * @param elementName Nonza 元素的名称。
     * @param namespace Nonza 元素的命名空间。
     */
    public static func removeNonzaProvider(elementName: String, namespace: String): Unit {
        let key = getQName(elementName, namespace)
        nonzaProviders.remove(key)
    }

    /**  
     * 根据元素名称和命名空间创建 QName。
     *
     * @param elementName XML 元素名称。
     * @param namespace XML 命名空间。
     * @return 返回创建的 QName 对象。
     */
    private static func getQName(elementName: String, namespace: String): QName {
        return QName(namespace, elementName)
    }

    /**  
     * 验证元素名称和命名空间是否有效。
     *
     * @param elementName XML 元素名称。
     * @param namespace XML 命名空间。
     * @throws IllegalArgumentException 如果元素名称或命名空间为空或无效。
     */
    private static func validate(elementName: String, namespace: String): Unit {
        if (StringUtils.isNullOrEmpty(elementName)) {
            throw IllegalArgumentException("elementName must not be None or empty")
        }
        if (StringUtils.isNullOrEmpty(namespace)) {
            throw IllegalArgumentException("namespace must not be None or empty")
        }
    }
}
