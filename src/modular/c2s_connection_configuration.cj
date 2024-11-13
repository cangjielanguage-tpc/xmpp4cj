/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class C2sConnectionConfiguration <: ConnectionConfiguration {
    let moduleDescriptors: Set<ModuleDescriptor>

    let initialStateDescriptorVertex: GraphVertex<StateDescriptor>

    init(builder: C2sConnectionConfigurationBuilder) {
        super(builder)
        moduleDescriptors = HashSet(builder.modulesDescriptors.values())
        let backwardEdgeStateDescriptors: Set<StateDescriptor> = HashSet()
        for (moduleDescriptor in moduleDescriptors) {
            let moduleStateDescriptors = moduleDescriptor.getStateDescriptors()
            backwardEdgeStateDescriptors.putAll(moduleStateDescriptors)
        }
        try {
            initialStateDescriptorVertex = StateDescriptorGraph.constructStateDescriptorGraph(
                backwardEdgeStateDescriptors)
        } catch (e: Exception) {
            DEBUGER.log(LogLevel.DEBUG, "1.1", e)
            throw IllegalStateException(e.toString())
        }
    }

    public func printStateGraphInDotFormat(pw: StringBuilder, breakStateName: Bool): Unit {
        StateDescriptorGraph.stateDescriptorGraphToDot([initialStateDescriptorVertex], pw, breakStateName)
    }

    public func getStateGraphInDotFormat(): String {
        let pw = StringBuilder()
        printStateGraphInDotFormat(pw, true)
        return pw.toString()
    }

    public static func builder(): C2sConnectionConfigurationBuilder {
        C2sConnectionConfigurationBuilder()
    }
}

public class C2sConnectionConfigurationBuilder <: ConnectionConfigurationBuilder {
    let modulesDescriptors: Map<ClassId, ModuleDescriptor> = HashMap()

    init() {
        C2sXmppConfiguration.addAllKnownModulesTo(this)
    }

    public override func build(): C2sConnectionConfiguration {
        return C2sConnectionConfiguration(this)
    }

    public func addModule(connectionModule: ModuleDescriptor): Unit {
        let moduleDescriptorClass: ClassId = connectionModule.getClass()
        if (modulesDescriptors.contains(moduleDescriptorClass)) {
            throw IllegalArgumentException("A connection module for ${moduleDescriptorClass} is already configured")
        }
        modulesDescriptors.put(moduleDescriptorClass, connectionModule)
    }

    public func addModule(
        moduleDescriptorBuilderCosntructor: (C2sConnectionConfigurationBuilder) -> ModuleDescriptorBuilder): C2sConnectionConfigurationBuilder {
        return moduleDescriptorBuilderCosntructor(this).buildModule()
    }

    public func removeModule(moduleClass: ClassId): C2sConnectionConfigurationBuilder {
        modulesDescriptors.remove(moduleClass)
        return getThis()
    }

    public func removeAllModules(): C2sConnectionConfigurationBuilder {
        modulesDescriptors.clear()
        return getThis()
    }

    protected override func getThis(): C2sConnectionConfigurationBuilder {
        return this
    }
}
