/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.modular

/**
 * public abstract class C2sConnectionModule
 *
 */
public abstract class C2sConnectionModule {
    public let moduleDescriptor: ModuleDescriptor

    public let connectionInternal: C2sConnectionInternal

    protected init(
        moduleDescriptor: ModuleDescriptor,
        connectionInternal: C2sConnectionInternal
    ) {
        this.moduleDescriptor = moduleDescriptor
        this.connectionInternal = connectionInternal
    }

    public func getModuleDescriptor(): ModuleDescriptor {
        return moduleDescriptor
    }

    protected open func getTransport(): ?C2sTransport {
        return None
    }
}
