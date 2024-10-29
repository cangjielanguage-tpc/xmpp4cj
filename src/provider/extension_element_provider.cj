/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.provider

/**
 * 一个用于解析自定义扩展元素的抽象类。每个 ExtensionElementProvider 都必须在 ProviderManager 类中注册才能被使用。
 * 这个抽象类的每个实现<b>必须</b>有一个公共的无参构造函数。
 */
public abstract class ExtensionElementProvider<EE> <: Provider<EE> where EE <: Element {
    public init(elementClass: ClassId) {
        super(elementClass)
    }
}

type ExtensionElementProviderParse3 = (XmlPullParser, Int, ?XmlEnvironment) -> ExtensionElement

class ExtensionElementProviderWrapper <: ExtensionElementProvider<ExtensionElement> {
    public ExtensionElementProviderWrapper(elementClass: ClassId, let parse3: ExtensionElementProviderParse3) {
        super(elementClass)
    }
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): ExtensionElement {
        parse3(parser, initialDepth, xmlEnvironment)
    }
}
