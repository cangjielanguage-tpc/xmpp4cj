/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public open class ConnectionStateMachineListener {
    public ConnectionStateMachineListener(let f: (ConnectionStateEvent, C2sConnection) -> Unit) {}
    public func onConnectionStateEvent(connectionStateEvent: ConnectionStateEvent, connection: C2sConnection): Unit {
        f(connectionStateEvent, connection)
    }
}
