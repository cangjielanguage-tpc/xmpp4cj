/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class Bind2ModuleDescriptor <: ModuleDescriptor {
    static let INSTANCE = Bind2ModuleDescriptor()

    protected override func getStateDescriptors(): Set<StateDescriptor> {
        return HashSet<StateDescriptor>([Bind2StateDescriptor()])
    }

    protected override func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): Bind2Module {
        return Bind2Module(this, connectionInternal)
    }

    public override func getClass(): String {
        "Bind2ModuleDescriptor"
    }
}

public class Bind2ModuleDescriptorBuilder <: ModuleDescriptorBuilder {
    protected init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        super(connectionConfigurationBuilder)
    }

    protected override func build(): Bind2ModuleDescriptor {
        return Bind2ModuleDescriptor.INSTANCE
    }
}
