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
 * Defines the information required to register an IQ Provider
 * with the {@link ProviderManager} when using the {@link ProviderLoader}.
 */
public class IQProviderInfo <: AbstractProviderInfo {
    /**
     * Defines an IQ provider which implements the <code>IQProvider</code> interface.
     *
     * @param elementName Element that provider parses.
     * @param namespace Namespace that provider parses.
     * @param iqProvider The provider implementation.
     */
    public IQProviderInfo(elementName: String, namespace: String, iqProvider: IqProvider<IQ>) {
        super(elementName, namespace, iqProvider)
    }
}

/**
 * Defines the information required to register a stanza extension Provider
 * with the {@link ProviderManager} when using the {@link ProviderLoader}.
 */
public class ExtensionProviderInfo <: AbstractProviderInfo {

    /**
     * Defines an extension provider which implements the <code>ExtensionElementProvider</code> interface.
     *
     * @param elementName Element that provider parses.
     * @param namespace Namespace that provider parses.
     * @param extProvider The provider implementation.
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
     * Defines an extension provider which implements the <code>StreamFeatureProvider</code> interface.
     *
     * @param elementName Element that provider parses.
     * @param namespace Namespace that provider parses.
     * @param extProvider The provider implementation.
     */
    public StreamFeatureProviderInfo(
        elementName: String,
        namespace: String,
        extProvider: ExtensionElementProvider<ExtensionElement>
    ) {
        super(elementName, namespace, extProvider)
    }
}
