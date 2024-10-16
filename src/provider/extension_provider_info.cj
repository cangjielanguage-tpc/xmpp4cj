/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 * 定义了在使用 {@link ProviderLoader} 时向 {@link ProviderManager} 注册一个节扩展提供者所需的信息。
 */
public class ExtensionProviderInfo <: AbstractProviderInfo {
    let extProvider: ExtensionElementProvider<ExtensionElement>
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
        this.extProvider = extProvider
    }
    public override func getProvider(): ExtensionElementProvider<ExtensionElement> {
        return extProvider
    }
}
