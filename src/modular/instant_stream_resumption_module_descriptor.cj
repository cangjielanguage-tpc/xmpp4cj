/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class InstantStreamResumptionModuleDescriptor <: ModuleDescriptor {
    static let INSTANCE = InstantStreamResumptionModuleDescriptor()

    protected override func getStateDescriptors(): Set<StateDescriptor> {
        return HashSet<StateDescriptor>([InstantStreamResumptionStateDescriptor()])
    }

    protected override func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): InstantStreamResumptionModule {
        return InstantStreamResumptionModule(this, connectionInternal)
    }

    public override func getClass(): String {
        "InstantStreamResumptionModuleDescriptor"
    }
}

public class InstantStreamResumptionModuleDescriptorBuilder <: ModuleDescriptorBuilder {
    private init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        super(connectionConfigurationBuilder)
    }

    protected override func build(): ModuleDescriptor {
        return InstantStreamResumptionModuleDescriptor.INSTANCE
    }
}
