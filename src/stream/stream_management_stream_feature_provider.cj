/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class StreamManagementStreamFeatureProvider <: ExtensionElementProvider<StreamManagementFeature> {
    public init() {
        super("StreamManagementFeature")
    }
    public func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): StreamManagementFeature {
        return StreamManagementFeature.INSTANCE
    }
}
