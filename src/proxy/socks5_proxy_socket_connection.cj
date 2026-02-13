/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.proxy

/**
 * Socks5代理的套接字工厂。
 */
public class Socks5ProxySocketConnection <: ProxySocketConnection {
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
        buf.write(5)
        buf.write(2)
        buf.write(0)
        buf.write(2)
        tcpSocket.write(buf.bytes())

        // 接收代理服务器发送的数据
        let arr: Array<Byte> = Array<Byte>(2, repeat: 0)
        tcpSocket.read(arr)
        var check: Bool = false
        match (arr[1] & 0xff) {
            case 0 => check = true
            case 2 =>
                // 向代理服务器发送数据 - 用户名和密码
                let buf: ByteBuffer = ByteBuffer()
                buf.write(1)
                let userByte: Array<Byte> = proxyUsername.toArray()
                OutputStreamUtil.writeByteSafe(buf, userByte.size, "Username to long")
                buf.write(userByte)
                let passwordBytes: Array<Byte> = proxyPassword.toArray()
                OutputStreamUtil.writeByteSafe(buf, passwordBytes.size, "Password to long")
                buf.write(passwordBytes)
                tcpSocket.write(buf.bytes())

                // 接收代理服务器发送的数据
                let arr: Array<Byte> = Array<Byte>(2, repeat: 0)
                buf.read(arr)
                if (arr[1] == 0) {
                    check = true
                }
            case _ => ()
        }
        if (!check) {
            throw ProxyException(ProxyInfoProxyType.SOCKS5, "fail in SOCKS5 proxy")
        }

        // 向代理服务器发送数据
        let buf1: ByteBuffer = ByteBuffer()
        buf1.write(5)
        buf1.write(1)
        buf1.write(0)
        let hostb: Array<Byte> = host.toArray()
        let len: Int64 = hostb.size
        buf1.write(3)
        OutputStreamUtil.writeByteSafe(buf1, len, "Hostname to long")
        buf1.write(hostb)
        buf1.write(UInt8(port >> 8))
        buf1.write(UInt8(port & 0xff))
        tcpSocket.write(buf1.bytes())

        // 接收代理服务器发送的数据
        let arr1: Array<Byte> = Array<Byte>(4, repeat: 0)
        tcpSocket.read(arr1)
        if (arr1[1] != 0) {
            throw ProxyException(ProxyInfoProxyType.SOCKS5, "server returns ${arr1[1]}")
        }
        var addressBytes: Int64 = 0
        let atyp = arr1[3] & 0xff
        match (atyp) {
            case 1 => addressBytes = 4
            case 3 =>
                // 接收代理服务器发送的数据
                let arr: Array<Byte> = Array<Byte>(1, repeat: 0)
                tcpSocket.read(arr)
                addressBytes = Int64(arr[0] & 0xff)
            case 4 => addressBytes = 16
            case _ => throw IOException("Unknown ATYP value: ${atyp}")
        }

        // 接收代理服务器发送的数据
        let arr2: Array<Byte> = Array<Byte>(addressBytes + 2, repeat: 0)
        tcpSocket.read(arr2)

        return tcpSocket
    }
}
