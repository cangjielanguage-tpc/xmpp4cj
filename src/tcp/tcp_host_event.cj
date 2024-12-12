/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public abstract class TcpHostEvent <: ConnectionStateEventDetailedTransitionIntoInformation {
    protected let address: InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint>

    protected init(state: State, address: InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint>) {
        super(state)
        this.address = address
    }

    public func getAddress(): InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint> {
        return address
    }
}

public class TcpHostEventConnectingToHostEvent <: TcpHostEvent {
    init(state: State, address: InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint>) {
        super(state, address)
    }
}

public class ConnectedToHostEvent <: TcpHostEvent {
    private let connectionEstablishedImmediately: Bool

    init(state: State, address: InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint>, immediately: Bool) {
        super(state, address)
        this.connectionEstablishedImmediately = immediately
    }

    public override func toString(): String {
        if (connectionEstablishedImmediately) {
            "${super.toString()} connected immediately"
        } else {
            "${super.toString()} no connected immediately"
        }
    }
}

public class ConnectionToHostFailedEvent <: TcpHostEvent {
    private let ioException: Exception

    init(state: State, address: InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint>, ioException: Exception) {
        super(state, address)
        this.ioException = ioException
    }
}
