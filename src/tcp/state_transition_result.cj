/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.tcp

public class TcpSocketConnectedResult <: StateTransitionResultSuccess {
    private let remoteAddress: IPSocketAddress

    init(remoteAddress: IPSocketAddress) {
        super("TCP connection established to ${anyToString(remoteAddress)}")
        this.remoteAddress = remoteAddress
    }

    public func getRemoteAddress(): IPSocketAddress {
        return remoteAddress
    }
}

public class TlsEstablishedResult <: StateTransitionResultSuccess {
    init(sslEngine: SSLEngine) {
        super("TLS established: ${sslEngine}")
    }
}
