/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class StreamManagementModuleDescriptor <: ModuleDescriptor {
    static let INSTANCE = StreamManagementModuleDescriptor()

    protected override func getStateDescriptors(): Set<StateDescriptor> {
        let res: Set<StateDescriptor> = HashSet<StateDescriptor>()
        res.put(EnableStreamManagementStateDescriptor())
        res.put(ResumeStreamStateDescriptor())
        return res
    }

    protected override func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): C2sConnectionModule {
        return StreamManagementModule(this, connectionInternal)
    }

    public override func getClass(): ClassId {
        "StreamManagementModuleDescriptor"
    }
}

public class StreamManagementModuleDescriptorBuilder <: ModuleDescriptorBuilder {
    protected init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        super(connectionConfigurationBuilder)
    }

    protected override func build(): StreamManagementModuleDescriptor {
        return StreamManagementModuleDescriptor.INSTANCE
    }
}
