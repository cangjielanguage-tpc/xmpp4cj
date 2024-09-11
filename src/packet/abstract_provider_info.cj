/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public abstract class AbstractProviderInfo {
    private let element: String
    private let ns: String
    private let provider: Object

    AbstractProviderInfo(elementName: String, namespace: String, iqOrExtProvider: Object) {
        element = elementName
        ns = namespace
        provider = iqOrExtProvider
    }

    public func getElementName(): String {
        return element
    }

    public func getNamespace(): String {
        return ns
    }

    func getProvider(): Object {
        return provider
    }
}

/**
 * 定义了在使用 {@link ProviderLoader} 时向 {@link ProviderManager} 注册一个 IQ 提供者所需的信息。
 */
public class IQProviderInfo <: AbstractProviderInfo {
    /**
     * 定义一个实现了 <code>IQProvider</code> 接口的 IQ 提供者。
     *
     * @param elementName 提供者解析的元素名称。
     * @param namespace 提供者解析的命名空间。
     * @param iqProvider 提供者的实现。
     */
    public IQProviderInfo(elementName: String, namespace: String, iqProvider: IqProvider<IQ>) {
        super(elementName, namespace, iqProvider)
    }
}

/**
 * 定义了在使用 {@link ProviderLoader} 时向 {@link ProviderManager} 注册一个节扩展提供者所需的信息。
 */
public class ExtensionProviderInfo <: AbstractProviderInfo {

    /**
     * 定义一个实现了 <code>ExtensionElementProvider</code> 接口的扩展提供者。
     *
     * @param elementName 提供者解析的元素名称。
     * @param namespace 提供者解析的命名空间。
     * @param extProvider 提供者的实现。
     */
    public ExtensionProviderInfo(
        elementName: String,
        namespace: String,
        extProvider: ExtensionElementProvider<ExtensionElement>
    ) {
        super(elementName, namespace, extProvider)
    }
}

public class StreamFeatureProviderInfo <: AbstractProviderInfo {

    /**
     * 定义一个实现了 <code>StreamFeatureProvider</code> 接口的扩展提供者。
     *
     * @param elementName 提供者解析的元素名称。
     * @param namespace 提供者解析的命名空间。
     * @param extProvider 提供者的实现。
     */
    public StreamFeatureProviderInfo(
        elementName: String,
        namespace: String,
        extProvider: ExtensionElementProvider<ExtensionElement>
    ) {
        super(elementName, namespace, extProvider)
    }
}
