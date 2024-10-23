/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.proxy

/**  
 * 代理 socket 连接的接口。
 */
public interface ProxySocketConnection {
    /**  
     * 初始化与给定主机和端口的连接。请注意，调用者需要负责在此方法抛出异常的情况下关闭 socket。
     *
     * @param socket 用于与代理建立连接的 socket。
     * @param host 要连接的主机。
     * @param port 要连接的端口。
     * @param timeout 超时时间（以毫秒为单位）。
     * @throws IOException 如果发生 I/O 错误。
     */
    func connect(socket: StreamingSocket, host: String, port: UInt16, timeout: Duration): Unit

    /**  
     * 根据代理类型返回对应的 ProxySocketConnection 实例的工厂方法。
     *
     * @param proxyType 代理类型
     * @return 返回一个 Function，用于创建 ProxyInfo 实例
     * @throws AssertionError 如果代理类型未知。
     */
    static func forProxyType(proxyType: ProxyInfoProxyType): ProxySocketConnection {
        // TODO
        match (proxyType) {
            case ProxyInfoProxyType.HTTP => throw Exception("TODO")
            case ProxyInfoProxyType.SOCKS4 => throw Exception("TODO")
            case ProxyInfoProxyType.SOCKS5 => throw Exception("TODO")
        }
    }
}
