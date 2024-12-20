/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

/**
 * public abstract class ModuleDescriptor <: ClassIdentify & Hashable & Equatable<ModuleDescriptor>
 *
 */
public abstract class ModuleDescriptor <: ClassIdentify & Hashable & Equatable<ModuleDescriptor> {
    protected func getStateDescriptors(): Set<StateDescriptor>

    protected func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): C2sConnectionModule

    public static func getClassId(): ClassId {
        "ModuleDescriptor"
    }
    public open override func hashCode(): Int64 {
        this.getClass().hashCode()
    }
    public open operator override func ==(that: ModuleDescriptor): Bool {
        this.getClass() == that.getClass()
    }
}

/**
 * public abstract class ModuleDescriptorBuilder
 *
 */
public abstract class ModuleDescriptorBuilder {
    private let connectionConfigurationBuilder: C2sConnectionConfigurationBuilder

    protected init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        this.connectionConfigurationBuilder = connectionConfigurationBuilder
    }

    protected func build(): ModuleDescriptor

    public func buildModule(): C2sConnectionConfigurationBuilder {
        let moduleDescriptor: ModuleDescriptor = build()
        connectionConfigurationBuilder.addModule(moduleDescriptor)
        return connectionConfigurationBuilder
    }
}
