/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

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
