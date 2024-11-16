/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

// TODO
public abstract class SrvRemoteConnectionEndpoint <: RemoteConnectionEndpoint {
    // protected let srv: SRV

    protected let port: UInt16

    private let inetAddresses: ArrayList<IPSocketAddress>

    protected init(inetAddresses: ArrayList<IPSocketAddress>) {
        // protected init(srv: SRV, inetAddresses: ArrayList<IPSocketAddress>) {
        // this.srv = srv
        // this.port = srv.port
        this.port = 0
        this.inetAddresses = Objects.requireNonNull(inetAddresses)
    }

    public override func getHost(): String {
        return ""
        // return srv.target
    }

    public override func getPort(): UInt16 {
        return port
    }

    public override func getInetAddresses(): Collection<IPSocketAddress> {
        return inetAddresses
    }
}
