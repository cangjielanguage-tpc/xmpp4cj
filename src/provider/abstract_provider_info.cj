/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public abstract class AbstractProviderInfo {
    private let element: String
    private let ns: String
    private let provider: Object

    public AbstractProviderInfo(elementName: String, namespace: String, iqOrExtProvider: Object) {
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
