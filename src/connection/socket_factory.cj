/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

public open class SocketFactory {
    public static let DEFAULT = SocketFactory()
    public open func createSocket(addr: IPSocketAddress): TcpSocket {
        TcpSocket(addr)
    }
    public open func createSocket(host: String, port: UInt16): TcpSocket {
        TcpSocket(host, port)
    }
}

/**
 * public type WebSocketFactory = () -> WebSocket
 */
public type WebSocketFactory = () -> WebSocket
