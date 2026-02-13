/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.provider

/**
 * public abstract class AbstractProviderInfo
 *
 * 抽象类 AbstractProviderInfo 代表一个提供者信息的基类。
 * 它包含与提供者相关的元素名称、命名空间和提供者对象。
 */
public abstract class AbstractProviderInfo {
    private let element: String // 元素名称  
    private let ns: String // 命名空间  
    private let provider: Object // 提供者对象（可以是 IQ 或扩展提供者）

    /**
     * 构造函数，用于初始化 AbstractProviderInfo 的实例。
     *
     * @param elementName 元素名称
     * @param namespace 命名空间
     * @param iqOrExtProvider 提供者对象，可以是 IQ 或扩展提供者
     */
    public AbstractProviderInfo(elementName: String, namespace: String, iqOrExtProvider: Object) {
        element = elementName
        ns = namespace
        provider = iqOrExtProvider
    }

    /**
     * 获取元素名称。
     *
     * @return 元素名称
     */
    public func getElementName(): String {
        return element
    }

    /**
     * 获取命名空间。
     *
     * @return 命名空间
     */
    public func getNamespace(): String {
        return ns
    }

    /**
     * 获取提供者对象。
     *
     * @return 提供者对象
     */
    public open func getProvider(): Object {
        return provider
    }
}
