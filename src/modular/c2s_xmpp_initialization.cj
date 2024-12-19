/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

/**
 * 加载模块化配置
 */
public class C2sXmppInitialization {
    static init() {
        C2sXmppConfiguration.addModule(Bind2ModuleDescriptor())
        C2sXmppConfiguration.addModule(CompressionModuleDescriptor())
        C2sXmppConfiguration.addModule(InstantStreamResumptionModuleDescriptor())
    }
}
