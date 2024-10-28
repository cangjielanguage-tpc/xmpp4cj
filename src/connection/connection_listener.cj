/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**  
 * 接口，允许实现类监听连接关闭和重新连接事件。监听器与 XMPPConnection 对象注册。
 *
 * @see XMPPConnection#addConnectionListener
 * @see XMPPConnection#removeConnectionListener
 */
public interface ConnectionListener {
    /**  
     * 通知连接正在进行中。
     * 当执行 {@link AbstractXMPPConnection#connect()} 时调用此方法。
     *
     * @param _ 正在连接的 XMPPConnection 对象
     */
    func connecting(_: XMPPConnection): Unit {}

    /**  
     * 通知连接已成功连接到远程端点（例如 XMPP 服务器）。
     * <p>
     * 注意，连接可能尚未经过身份验证，因此可能仅能进行有限的操作，例如注册账户。
     * </p>
     *
     * @param _ 成功连接到其端点的 XMPPConnection 对象
     */
    func connected(_: XMPPConnection): Unit {}

    /**  
     * 通知连接已通过身份验证。
     *
     * @param _ 成功通过身份验证的 XMPPConnection 对象
     * @param _ 如果是从之前的 XMPP 会话恢复的连接，则为 true
     */
    func authenticated(_: XMPPConnection, _: Bool): Unit {}

    /**  
     * 通知连接正常关闭。
     */
    func connectionClosed(): Unit {}

    /**  
     * 通知连接因异常而关闭。当连接被突然断开时，连接可能会尝试重新连接到服务器。
     *
     * @param _ 关闭连接时抛出的异常
     */
    func connectionClosedOnError(_: Exception): Unit {}
}

public class ConnectionListenerBuilder {
    var _connecting: (XMPPConnection) -> Unit = {_ =>}

    var _connected: (XMPPConnection) -> Unit = {_ =>}

    var _authenticated: (XMPPConnection, Bool) -> Unit = {_, _ =>}

    var _connectionClosed: () -> Unit = {=>}

    var _connectionClosedOnError: (Exception) -> Unit = {_ =>}

    /**  
     * 通知连接正在进行中。
     *
     * @param connecting 接口处理的回调
     */
    public func connecting(connecting: (XMPPConnection) -> Unit): ConnectionListenerBuilder {
        this._connecting = connecting
        this
    }

    /**  
     * 通知连接已成功连接到远程端点（例如 XMPP 服务器）。
     *
     * @param connected 接口处理的回调
     */
    public func connected(connected: (XMPPConnection) -> Unit): ConnectionListenerBuilder {
        this._connected = connected
        this
    }

    /**  
     * 通知连接已通过身份验证。
     *
     * @param authenticated 接口处理的回调
     */
    public func authenticated(authenticated: (XMPPConnection, Bool) -> Unit): ConnectionListenerBuilder {
        this._authenticated = authenticated
        this
    }

    /**  
     * 通知连接正常关闭。
     *
     * @param connectionClosed 接口处理的回调
     */
    public func connectionClosed(connectionClosed: () -> Unit): ConnectionListenerBuilder {
        this._connectionClosed = connectionClosed
        this
    }

    /**  
     * 通知连接因异常而关闭。当连接被突然断开时，连接可能会尝试重新连接到服务器。
     *
     * @param connectionClosedOnError 接口处理的回调
     */
    public func connectionClosedOnError(connectionClosedOnError: (Exception) -> Unit): ConnectionListenerBuilder {
        this._connectionClosedOnError = connectionClosedOnError
        this
    }

    /**  
     * 返回ConnectionListener对象。
     *
     * @return ConnectionListener
     */
    public func build(): ConnectionListener {
        return SimpleConnectionListener(this)
    }
}

class SimpleConnectionListener <: ConnectionListener {
    SimpleConnectionListener(let builder: ConnectionListenerBuilder) {}

    public override func connecting(connection: XMPPConnection): Unit {
        builder._connecting(connection)
    }

    public override func connected(connection: XMPPConnection): Unit {
        builder._connected(connection)
    }

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {
        builder._authenticated(connection, resumed)
    }

    public override func connectionClosed(): Unit {
        builder._connectionClosed()
    }

    public override func connectionClosedOnError(e: Exception): Unit {
        builder._connectionClosedOnError(e)
    }
}

/**  
 * 实现此接口的类将在新的 {@link XMPPConnection} 被创建时收到通知。
 * 新创建的连接尚未实际连接到服务器。使用
 * {@link XMPPConnectionRegistry#addConnectionCreationListener(ConnectionCreationListener)}
 * 来添加新的监听器。
 */
public open class ConnectionCreationListener <: Hashable & Equatable<ConnectionCreationListener> {
    private let hash: Int

    /**  
     * 通过func构建ConnectionCreationListener。
     *
     * @param callback 回调方法
     */
    public ConnectionCreationListener(let callback: (XMPPConnection) -> Unit) {
        hash = DateTime.now().hashCode()
    }

    /**  
     * 通知新连接已创建。新连接尚未连接到服务器。
     *
     * @param connection 新创建的 XMPPConnection 对象
     */
    public open func connectionCreated(connection: XMPPConnection): Unit {
        callback(connection)
    }

    public open override func hashCode(): Int {
        hash
    }

    public open operator override func ==(that: ConnectionCreationListener): Bool {
        refEq(this, that)
    }
}
