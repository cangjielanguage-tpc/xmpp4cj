/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

public interface RemoteConnectionEndpoint {
    /**  
     * 获取连接端点的主机名。
     *
     * @return 连接端点的主机名
     */
    func getHost(): String

    /**  
     * 获取连接端点的端口号。
     *
     * @return 连接端点的端口号
     */
    func getPort(): UInt16

    /**  
     * 获取与连接端点关联的 IP 地址集合。
     *
     * @return 连接端点的 IP 地址集合
     */
    func getInetAddresses(): Collection<IPSocketAddress>

    /**  
     * 获取连接端点的描述信息。
     *
     * @return 连接端点的描述
     */
    func getDescription(): String
}

/**  
 * 封装连接端点和相应的 InetSocketAddress 的类。
 *
 * @param <RCE> 连接端点的泛型类型
 */
public class InetSocketAddressCoupling<RCE> <: ToString where RCE <: RemoteConnectionEndpoint {
    private let connectionEndpoint: RCE // 连接端点

    private let inetSocketAddress: ?IPSocketAddress // InetSocketAddress 绑定  

    /**  
     * 构造一个新的 InetSocketAddressCoupling 实例。
     *
     * @param connectionEndpoint 连接端点
     * @param inetAddress 关联的 IP 地址
     */
    public init(connectionEndpoint: RCE, inetAddress: ?IPSocketAddress) {
        this.connectionEndpoint = connectionEndpoint
        let port = connectionEndpoint.getPort()
        inetSocketAddress = inetAddress
    }

    /**  
     * 获取关联的连接端点。
     *
     * @return 连接端点
     */
    public func getRemoteConnectionEndpoint(): RCE {
        return connectionEndpoint
    }

    /**  
     * 获取关联的 InetSocketAddress。
     *
     * @return InetSocketAddress 实例
     */
    public func getSocketAddress(): ?IPSocketAddress {
        return inetSocketAddress
    }

    public override func toString(): String {
        return "${connectionEndpoint.getDescription()} (${inetSocketAddress})"
    }
}

/**  
 * 表示远程连接端点查找失败的抽象类。
 */
public abstract class RemoteConnectionEndpointLookupFailure <: ToString {
    private let description: String // 描述信息

    private let exception: Exception // 产生的异常  

    /**  
     * 构造一个新的远程连接端点查找失败的实例。
     *
     * @param description 错误描述
     * @param exception 发生的异常
     */
    public init(description: String, exception: Exception) {
        this.description = description
        this.exception = exception
    }

    /**  
     * 获取错误描述信息。
     *
     * @return 错误描述
     */
    public func getDescription(): String {
        return description
    }

    /**  
     * 获取产生的异常。
     *
     * @return 发生的异常
     */
    public func getException(): Exception {
        return exception
    }

    /**  
     * 获取详细的错误信息，包括描述和异常信息。
     *
     * @return 完整的错误信息
     */
    public func getErrorMessage(): String {
        return "${description} because: ${exception}"
    }

    private var toStringCache: String = "" // 用于缓存字符串表示  

    public override func toString(): String {
        if (toStringCache.isEmpty()) {
            toStringCache = ToStringUtil.builderFor("RemoteConnectionEndpointLookupFailure").addValue("description",
                description).addValue("exception", exception).build()
        }
        return toStringCache
    }
}

/**  
 * 表示 DNS 查找失败的具体实现类。
 */
public class DnsLookupFailure <: RemoteConnectionEndpointLookupFailure {
    private let dnsName: DnsName // 发生 DNS 查找失败的域名 

    /**  
     * 构造一个新的 DNS 查找失败的实例。
     *
     * @param dnsName 导致失败的 DNS 名称
     * @param exception 发生的异常
     */
    public init(dnsName: DnsName, exception: Exception) {
        super("DNS lookup exception for ${dnsName}", exception)
        this.dnsName = dnsName
    }

    /**  
     * 获取导致查找失败的 DNS 名称。
     *
     * @return DNS 名称
     */
    public func getDnsName(): DnsName {
        return dnsName
    }
}

/**  
 * 表示远程连接异常的类。
 *
 * @param <RCE> 连接端点的泛型类型
 */
public class RemoteConnectionException<RCE> <: ToString where RCE <: RemoteConnectionEndpoint {
    private let address: InetSocketAddressCoupling<RCE> // 连接地址 

    private let exception: Exception // 发生的异常  

    /**  
     * 构造一个新的远程连接异常实例。
     *
     * @param remoteConnectionEndpoint 连接端点
     * @param inetAddress 关联的 IP 地址
     * @param exception 发生的异常
     */
    public init(remoteConnectionEndpoint: RCE, inetAddress: ?IPSocketAddress, exception: Exception) {
        this(InetSocketAddressCoupling<RCE>(remoteConnectionEndpoint, inetAddress), exception)
    }

    /**  
     * 构造一个新的远程连接异常实例。
     *
     * @param address 连接地址的封装
     * @param exception 发生的异常
     */
    public init(address: InetSocketAddressCoupling<RCE>, exception: Exception) {
        this.address = address
        this.exception = exception
    }

    /**  
     * 获取连接地址的封装。
     *
     * @return 连接地址的 InetSocketAddressCoupling 实例
     */
    public func getAddress(): InetSocketAddressCoupling<RCE> {
        return address
    }

    /**  
     * 获取发生的异常。
     *
     * @return 发生的异常
     */
    public func getException(): Exception {
        return exception
    }

    /**  
     * 获取详细的错误信息，包括地址和异常信息。
     *
     * @return 字符串形式的错误信息
     */
    public func getErrorMessage(): String {
        return "'${address}' failed because: ${exception}"
    }

    private var toStringCache: String = "" // 用于缓存字符串表示 

    public override func toString(): String {
        if (toStringCache.isEmpty()) {
            toStringCache = ToStringUtil.builderFor("RemoteConnectionException<Any>").addValue("address", address).
                addValue("exception", exception).build()
        }
        return toStringCache
    }

    /**  
     * 从指定的远程连接端点和异常中创建一个远程连接异常实例。
     *
     * @param <SARCE> 单地址连接端点的泛型类型
     * @param remoteConnectionEndpoint 单地址连接端点
     * @param exception 发生的异常
     * @return 创建的远程连接异常实例
     */
    public static func comefrom<SARCE>(
        remoteConnectionEndpoint: SARCE,
        exception: Exception
    ): RemoteConnectionException<SARCE> where SARCE <: SingleAddressRemoteConnectionEndpoint {
        return RemoteConnectionException<SARCE>(
            remoteConnectionEndpoint,
            remoteConnectionEndpoint.getInetAddress(),
            exception
        )
    }
}

/**  
 * 表示单地址远程连接端点的接口。
 * 该接口扩展了 {@link RemoteConnectionEndpoint} 并定义了获取单个 IP 地址的方法。
 */
public interface SingleAddressRemoteConnectionEndpoint <: RemoteConnectionEndpoint {
    /**  
     * 获取此远程连接端点的 IP 地址。
     *
     * @return 与此端点关联的 {@link InetAddress} 实例
     */
    func getInetAddress(): IPSocketAddress

    /**  
     * 获取与连接端点关联的 IP 地址集合。
     *
     * @return 连接端点的 IP 地址集合
     */
    override func getInetAddresses(): Collection<IPSocketAddress> {
        return [getInetAddress()]
    }
}
