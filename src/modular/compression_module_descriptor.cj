/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class CompressionModuleDescriptor <: ModuleDescriptor {
    static let INSTANCE = CompressionModuleDescriptor()

    protected override func getStateDescriptors(): Set<StateDescriptor> {
        return HashSet<StateDescriptor>([CompressionStateDescriptor()])
    }

    protected override func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): CompressionModule {
        return CompressionModule(this, connectionInternal)
    }

    public override func getClass(): String {
        "CompressionModuleDescriptor"
    }
}

public class CompressionModuleDescriptorBuilder <: ModuleDescriptorBuilder {
    private init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        super(connectionConfigurationBuilder)
    }

    protected override func build(): ModuleDescriptor {
        return CompressionModuleDescriptor.INSTANCE
    }
}
