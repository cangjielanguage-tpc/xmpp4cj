/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

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
