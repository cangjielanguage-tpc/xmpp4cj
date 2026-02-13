/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.provider

/**
 * public abstract class NonzaProvider<N> <: Provider<N> where N <: Element
 *
 */
public abstract class NonzaProvider<N> <: Provider<N> where N <: Element {
    public init(elementClass: ClassId) {
        super(elementClass)
    }
}

type NonzaProviderParse3 = (XmlPullParser, Int, ?XmlEnvironment) -> Nonza

public class NonzaProviderWrapper <: NonzaProvider<Nonza> {
    public NonzaProviderWrapper(elementClass: ClassId, let parse3: NonzaProviderParse3) {
        super(elementClass)
    }
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): Nonza {
        parse3(parser, initialDepth, xmlEnvironment)
    }
}
