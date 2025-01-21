/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public class ConnectionAttemptState {
    private let connectionInternal: C2sConnectionInternal
    private let discoveredEndpoints: DiscoveredTcpEndpoints
    private let establishingTcpConnectionState: EstablishingTcpConnectionState

    let socketChannel: SocketChannel

    let connectionExceptions: ArrayList<RemoteConnectionException<RemoteConnectionEndpoint>>

    var connectionException: ?EndpointConnectionException = None
    var connected: Bool = false
    var deadline: Duration = Duration.Zero

    let connectionEndpointIterator: ListIterator<Rfc6120TcpRemoteConnectionEndpoint>
    /** The current connection endpoint we are trying */
    var connectionEndpoint: ?Rfc6120TcpRemoteConnectionEndpoint = None
    var inetAddressIterator: ?ListIterator<IPSocketAddress> = None

    private let lock = Monitor()

    init(
        connectionInternal: C2sConnectionInternal,
        discoveredEndpoints: DiscoveredTcpEndpoints,
        establishingTcpConnectionState: EstablishingTcpConnectionState
    ) {
        this.connectionInternal = connectionInternal
        this.discoveredEndpoints = discoveredEndpoints
        this.establishingTcpConnectionState = establishingTcpConnectionState
        this.socketChannel = SocketChannel.open()

        let endpoints = discoveredEndpoints.result.discoveredRemoteConnectionEndpoints
        connectionEndpointIterator = ListIterator(endpoints.iterator())
        connectionExceptions = ArrayList<RemoteConnectionException<RemoteConnectionEndpoint>>(endpoints.size)
    }

    public func establishTcpConnection(): ?StateTransitionResultFailure {
        let address = nextAddress().getOrThrow()
        establishTcpConnection(address)
        synchronized(lock) {
            while (!connected && connectionException.isNone()) {
                let now = DateTime.now().toUnixTimeStamp()
                if (now >= deadline) {
                    return FailureCausedByTimeout("Timeout waiting to establish connection")
                }
                lock.wait(timeout: deadline - now)
            }
        }
        if (connected) {
            assert(connectionException.isNone())
            return None
        }
        return FailureCausedByException<Exception>(connectionException())
    }

    private func establishTcpConnection(address: InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint>): Unit {
        let connectingToHostEvent = TcpHostEventConnectingToHostEvent(establishingTcpConnectionState, address)
        connectionInternal.invokeConnectionStateMachineListener(connectingToHostEvent)
        let inetSocketAddress = address.getInetSocketAddress()
        deadline = DateTime.now().toUnixTimeStamp() + connectionInternal.connection.getReplyTimeout()
        try {
            connected = socketChannel.connect(inetSocketAddress(), connectionInternal.connection.getReplyTimeout())
        } catch (e: SocketTimeoutException) {
            onIOExceptionWhenEstablishingTcpConnection(e, address)
            return
        }
        if (connected) {
            let connectedToHostEvent = ConnectedToHostEvent(establishingTcpConnectionState, address, true)
            connectionInternal.invokeConnectionStateMachineListener(connectedToHostEvent)
            synchronized(lock) {
                lock.notifyAll()
            }
            return
        }
        try {
            connectionInternal.registerWithSelector(
                socketChannel,
                SelectionKey.OP_CONNECT,
                {_, _ => ()}
            )
        } catch (e: ClosedChannelException) {
            onIOExceptionWhenEstablishingTcpConnection(IOException(e.toString()), address)
        }
    }

    private func onIOExceptionWhenEstablishingTcpConnection(
        exception: Exception,
        failedAddress: InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint>
    ): Unit {
        let nextInetSocketAddress = nextAddress() ?? match (0) {
            case _ =>
                connectionException = EndpointConnectionException.comefrom(discoveredEndpoints.result.lookupFailures,
                    connectionExceptions)
                synchronized(lock) {
                    lock.notifyAll()
                }
                return
        }

        let coup = InetSocketAddressCoupling<RemoteConnectionEndpoint>(failedAddress.getRemoteConnectionEndpoint(),
            failedAddress.getInetSocketAddress())
        let rce = RemoteConnectionException<RemoteConnectionEndpoint>(coup, exception)
        connectionExceptions.add(rce)
        let connectionToHostFailedEvent = ConnectionToHostFailedEvent(establishingTcpConnectionState,
            nextInetSocketAddress, exception)
        connectionInternal.invokeConnectionStateMachineListener(connectionToHostFailedEvent)
        establishTcpConnection(nextInetSocketAddress)
    }

    private func nextAddress(): ?InetSocketAddressCoupling<Rfc6120TcpRemoteConnectionEndpoint> {
        if (inetAddressIterator.isNone() || !inetAddressIterator().hasNext()) {
            if (!connectionEndpointIterator.hasNext()) {
                return None
            }
            connectionEndpoint = connectionEndpointIterator.next()
            inetAddressIterator = ListIterator(connectionEndpoint().getInetAddresses().iterator())
            assert(inetAddressIterator?.hasNext() ?? false)
        }
        let inetAddress = inetAddressIterator().next()()
        return InetSocketAddressCoupling(connectionEndpoint(), inetAddress)
    }
}
