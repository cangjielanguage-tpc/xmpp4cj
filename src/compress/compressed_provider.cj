/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.compress

public class CompressedProvider <: NonzaProvider<Compressed> {
    public static let INSTANCE = CompressedProvider()

    private init() {
        super()
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): Compressed {
        return Compressed.INSTANCE
    }
}
