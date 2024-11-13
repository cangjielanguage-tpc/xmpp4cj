/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.proxy

/**
 * HTTP代理套接字连接，使用HTTP代理连接套接字。
 */
class HTTPProxySocketConnection <: ProxySocketConnection {
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
        tcpSocket.connect()

        // 向代理服务器发送数据
        let hostport: String = "CONNECT ${host}:${port}"
        var proxyLine: String = "\r\nProxy-Authorization: Basic ${toBase64String("${proxyUsername}:${proxyPassword}".toArray())}"
        tcpSocket.write("${hostport} HTTP/1.1\r\nHost: ${host}:${port}${proxyLine}\r\n\r\n".toArray())

        // 接收代理服务器发送的数据
        let got: StringBuilder = StringBuilder(100)
        var nlchars: Int64 = 0
        let arr: Array<Byte> = Array<Byte>(1, repeat: 0)
        while (true) {
            tcpSocket.read(arr)
            got.append(arr[0])
            if (got.size > 1024) {
                throw ProxyException(ProxyInfoProxyType.HTTP,
                    "Received header of >1024 characters from ${proxyAddress}, cancelling connection")
            }
            if ((nlchars == 0 || nlchars == 2) && arr[0] == b'\r') {
                nlchars++
            } else if ((nlchars == 1 || nlchars == 3) && arr[0] == b'\n') {
                nlchars++
            } else {
                nlchars = 0
            }
            if (nlchars == 4) {
                break
            }
        }
        if (nlchars != 4) {
            throw ProxyException(ProxyInfoProxyType.HTTP,
                "Never received blank line from ${proxyAddress}, cancelling connection")
        }
        let gotstr: Iterator<String> = got.toString().lines()
        let response: String = gotstr.next().getOrThrow()
        let m: Matcher = RESPONSE_PATTERN.matcher(response)
        if (m.findAll().isNone()) {
            throw ProxyException(ProxyInfoProxyType.HTTP, "Unexpected proxy response from ${proxyAddress}:${response}")
        }
        let code: Int64 = Int64.parse(m.find(1).getOrThrow().matchStr())
        if (code != 200) {
            throw ProxyException(ProxyInfoProxyType.HTTP, "Error code in proxy response: ${code}");
        }

        return tcpSocket
    }

    private static let RESPONSE_PATTERN: Regex = Regex("HTTP/\\S+\\s(\\d+)\\s(.*)\\s*")
}
