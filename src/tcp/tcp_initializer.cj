/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public class TCPInitializer <: XmppInitializer {
    static init() {
        C2sXmppConfiguration.addModule(StreamManagementModuleDescriptor())
        C2sXmppConfiguration.addModule(XmppTcpTransportModuleDescriptor(true, false))

        ProviderManager.addStreamFeatureProvider("sm", "urn:xmpp:sm:3", StreamManagementStreamFeatureProvider())
    }
}
