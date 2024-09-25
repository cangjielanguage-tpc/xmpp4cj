/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public class TlsProceedProvider <: NonzaProvider<TlsFailure> {
    public static let INSTANCE = TlsProceedProvider()

    private init() {
        super()
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): TlsFailure {
        return TlsFailure.INSTANCE
    }
}
