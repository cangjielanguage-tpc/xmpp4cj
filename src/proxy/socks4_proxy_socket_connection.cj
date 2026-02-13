/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.proxy

/**
 * socks4代理的套接字工厂。
 */
public class Socks4ProxySocketConnection <: ProxySocketConnection {
    private var proxyAddress: String // 代理地址

    private var proxyPort: UInt16 = 0 // 代理端口

    private var proxyUsername: String // 代理用户名

    private var proxyPassword: String // 代理密码

    init(pHost: String, pPort: UInt16, pUser: String, pPass: String) {
        this.proxyAddress = pHost
        this.proxyPort = pPort
        this.proxyUsername = pUser
        this.proxyPassword = pPass
    }

    public override func connect(socket: StreamingSocket, host: String, port: UInt16, timeout: Duration): StreamingSocket {
        let tcpSocket: TcpSocket = TcpSocket(proxyAddress, proxyPort)
        tcpSocket.connect(timeout: timeout)

        // 向代理服务器发送数据
        let buf: ByteBuffer = ByteBuffer()
        buf.write(4)
        buf.write(1)
        buf.write(UInt8(port >> 8))
        buf.write(UInt8(port & 0xff))
        let iplist: Array<IPAddress> = IPAddress.resolve(proxyAddress)
        let byteAddress = iplist[0].getAddressBytes()
        buf.write(byteAddress)
        buf.write(proxyUsername.toArray())
        buf.write(0)
        tcpSocket.write(buf.bytes())

        // 接收代理服务器发送的数据
        let arr: Array<Byte> = Array<Byte>(6, repeat: 0)
        tcpSocket.read(arr)
        if (arr[0] != 0) {
            throw ProxyException(ProxyInfoProxyType.SOCKS4, "server returns VN ${arr[0]}")
        }
        if (arr[1] != 90) {
            throw ProxyException(ProxyInfoProxyType.SOCKS4, "ProxySOCKS4: server returns CD ${arr[1]}")
        }

        // 接收代理服务器发送的数据
        let arr2: Array<Byte> = Array<Byte>(2, repeat: 0)
        tcpSocket.read(arr2)

        return tcpSocket
    }
}
