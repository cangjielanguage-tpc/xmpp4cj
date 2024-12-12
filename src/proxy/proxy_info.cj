/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.proxy

/**  
 * 存储代理信息的类，例如代理类型、主机、端口、身份验证等。
 */
public class ProxyInfo {
    private var proxyAddress: String // 代理地址  

    private var proxyPort: UInt16 = 0 // 代理端口

    private var proxyUsername: String // 代理用户名  

    private var proxyPassword: String // 代理密码  

    private var proxyType: ProxyInfoProxyType // 代理类型  

    private let proxySocketConnection: ProxySocketConnection // 代理 socket 连接

    /**  
     * 构造 ProxyInfo 对象。
     *
     * @param pType 代理类型
     * @param pHost 代理主机
     * @param pPort 代理端口
     * @param pUser 代理用户名
     * @param pPass 代理密码
     */
    public init(pType: ProxyInfoProxyType, pHost: String, pPort: UInt16, pUser: String, pPass: String) {
        this.proxyType = pType
        this.proxyAddress = pHost
        this.proxyPort = pPort
        this.proxyUsername = pUser
        this.proxyPassword = pPass
        this.proxySocketConnection = ProxySocketConnection.forProxyType(proxyType, proxyAddress, proxyPort,
            proxyUsername, proxyPassword)
    }

    /**  
     * 创建一个 HTTP 代理的 ProxyInfo 实例。
     *
     * @param pHost 代理主机
     * @param pPort 代理端口
     * @param pUser 代理用户名
     * @param pPass 代理密码
     * @return ProxyInfo 实例
     */
    public static func forHttpProxy(pHost: String, pPort: UInt16, pUser: String, pPass: String): ProxyInfo {
        return ProxyInfo(ProxyInfoProxyType.HTTP, pHost, pPort, pUser, pPass)
    }

    /**  
     * 创建一个 SOCKS4 代理的 ProxyInfo 实例。
     *
     * @param pHost 代理主机
     * @param pPort 代理端口
     * @param pUser 代理用户名
     * @param pPass 代理密码
     * @return ProxyInfo 实例
     */
    public static func forSocks4Proxy(pHost: String, pPort: UInt16, pUser: String, pPass: String): ProxyInfo {
        return ProxyInfo(ProxyInfoProxyType.SOCKS4, pHost, pPort, pUser, pPass)
    }

    /**  
     * 创建一个 SOCKS5 代理的 ProxyInfo 实例。
     *
     * @param pHost 代理主机
     * @param pPort 代理端口
     * @param pUser 代理用户名
     * @param pPass 代理密码
     * @return ProxyInfo 实例
     */
    public static func forSocks5Proxy(pHost: String, pPort: UInt16, pUser: String, pPass: String): ProxyInfo {
        return ProxyInfo(ProxyInfoProxyType.SOCKS5, pHost, pPort, pUser, pPass)
    }

    /**  
     * 获取代理类型。
     *
     * @return 代理类型
     */
    public func getProxyType(): ProxyInfoProxyType {
        return proxyType
    }

    /**  
     * 获取代理地址。
     *
     * @return 代理地址
     */
    public func getProxyAddress(): String {
        return proxyAddress
    }

    /**  
     *  获取代理端口。
     *
     * @return 代理端口
     */
    public func getProxyPort(): UInt16 {
        return proxyPort
    }

    /**  
     * 获取代理用户名。
     *
     * @return 代理用户名
     */
    public func getProxyUsername(): String {
        return proxyUsername
    }

    /**  
     * 获取代理密码。
     *
     * @return 代理密码
     */
    public func getProxyPassword(): String {
        return proxyPassword
    }

    /**  
     * 获取代理 socket 连接。
     *
     * @return 代理 socket 连接
     */
    public func getProxySocketConnection(): ProxySocketConnection {
        return proxySocketConnection
    }
}

/**  
 * 代理类型的枚举类。
 */
public enum ProxyInfoProxyType <: ToString & Equatable<ProxyInfoProxyType> {
    /**  
     * HTTP 代理类型。
     */
    | HTTP
    /**  
     * SOCKS4 代理类型。
     */
    | SOCKS4
    /**  
     * SOCKS5 代理类型。
     */
    | SOCKS5

    public override func toString(): String {
        return match (this) {
            case HTTP => "HTTP"
            case SOCKS4 => "SOCKS4"
            case SOCKS5 => "SOCKS5"
        }
    }

    public operator func ==(that: ProxyInfoProxyType): Bool {
        return match ((this, that)) {
            case (HTTP, HTTP) => true
            case (SOCKS4, SOCKS4) => true
            case (SOCKS5, SOCKS5) => true
            case _ => false
        }
    }
}

/**
 * 表示代理类型。
 */
public enum ProxyType <: ToString & Equatable<ProxyType> {
    /**
     * 表示直接连接或不存在代理。
     */
    | DIRECT
    /**
     * 表示HTTP或FTP等高级协议的代理。
     */
    | HTTP
    /**
     * 表示SOCKS（V4或V5）代理。
     */
    | SOCKS

    public override func toString(): String {
        return match (this) {
            case DIRECT => "DIRECT"
            case HTTP => "HTTP"
            case SOCKS => "SOCKS"
        }
    }

    public operator func ==(that: ProxyType): Bool {
        return match ((this, that)) {
            case (DIRECT, DIRECT) => true
            case (HTTP, HTTP) => true
            case (SOCKS, SOCKS) => true
            case _ => false
        }
    }
}
