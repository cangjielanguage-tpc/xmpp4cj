/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public class XmppTcpTransportModuleDescriptor <: ModuleDescriptor {
    private let startTls: Bool
    private let directTls: Bool

    public init(builder: XmppTcpTransportModuleDescriptorBuilder) {
        startTls = builder.startTls
        directTls = builder.directTls
    }
    public init(startTls: Bool, directTls: Bool) {
        this.startTls = startTls
        this.directTls = directTls
    }

    protected func getStateDescriptors(): Set<StateDescriptor> {
        var res: Set<StateDescriptor> = HashSet()
        res.put(EstablishingTcpConnectionStateDescriptor())
        if (startTls) {
            res.put(EstablishTlsStateDescriptor())
        }
        if (directTls) {
            throw IllegalArgumentException("DirectTLS is not implemented yet")
        }
        return res
    }

    protected override func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): C2sConnectionModule {
        XmppTcpTransportModule(this, connectionInternal)
    }

    public func isStartTlsEnabled(): Bool {
        return startTls
    }

    public func isDirectTlsEnabled(): Bool {
        return directTls
    }

    public override func getClass(): ClassId {
        return "XmppTcpTransportModuleDescriptor"
    }
}

public class XmppTcpTransportModuleDescriptorBuilder <: ModuleDescriptorBuilder {
    var startTls: Bool = true

    var directTls: Bool = false

    private init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        super(connectionConfigurationBuilder)
    }

    public func disableDirectTls(): XmppTcpTransportModuleDescriptorBuilder {
        directTls = false
        return this
    }

    public func disableStartTls(): XmppTcpTransportModuleDescriptorBuilder {
        startTls = false
        return this
    }

    protected func build(): XmppTcpTransportModuleDescriptor {
        return XmppTcpTransportModuleDescriptor(this)
    }
}
