/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 * 用于将提供者加载到 {@link ProviderManager} 中。
 */
public interface ProviderLoader {
    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的 IQ 提供者的 IQ 提供者信息。
     * @return 要加载的 IQ 提供者信息。
     */
    func getIQProviderInfo(): Collection<IQProviderInfo>

    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的扩展提供者的扩展提供者信息。
     * @return 要加载的扩展提供者信息。
     */
    func getExtensionProviderInfo(): Collection<ExtensionProviderInfo>

    /**
     * 提供用于创建要添加到<code>ProviderManager</code>的流特征提供者的流特征提供者信息。
     *
     * @return 要加载的扩展提供者信息。
     */
    func getStreamFeatureProviderInfo(): Collection<StreamFeatureProviderInfo>
}
