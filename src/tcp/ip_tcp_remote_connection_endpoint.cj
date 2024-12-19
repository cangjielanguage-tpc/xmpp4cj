/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public class IpTcpRemoteConnectionEndpoint <: Rfc6120TcpRemoteConnectionEndpoint & SingleAddressRemoteConnectionEndpoint {
    private let host: String

    private let port: UInt16

    private let internetAddressResourceRecord: IPAddress

    public init(host: String, port: UInt16, internetAddressResourceRecord: IPAddress) {
        this.host = host
        this.port = port
        this.internetAddressResourceRecord = internetAddressResourceRecord
    }

    public static func comefrom(host: String, port: UInt16, inetAddress: IPAddress): IpTcpRemoteConnectionEndpoint {
        return IpTcpRemoteConnectionEndpoint(host, port, inetAddress)
    }

    public override func getHost(): String {
        return host
    }

    public override func getPort(): UInt16 {
        return port
    }

    public override func getInetAddress(): IPSocketAddress {
        IPSocketAddress(internetAddressResourceRecord, port)
    }

    public override func getDescription(): String {
        return "RFC 6120 A/AAAA Endpoint + [${host}:${port}]"
    }
}
