/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

public open class SocketFactory {
    public static let DEFAULT = SocketFactory()
    public open func createSocket(addr: IPSocketAddress): TcpSocket {
        let socket = TcpSocket(addr)
        socket.noDelay = false
        socket
    }
    public open func createSocket(host: String, port: UInt16): TcpSocket {
        let socket = TcpSocket(host, port)
        socket.noDelay = false
        socket
    }
}

/**
 * public type WebSocketFactory = () -> WebSocket
 */
public type WebSocketFactory = () -> WebSocket
