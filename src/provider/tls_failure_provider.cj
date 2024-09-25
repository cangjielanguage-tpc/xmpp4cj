/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public class TlsFailureProvider <: NonzaProvider<TlsProceed> {
    public static let INSTANCE = TlsFailureProvider()

    private init() {
        super()
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): TlsProceed {
        return TlsProceed.INSTANCE
    }
}
