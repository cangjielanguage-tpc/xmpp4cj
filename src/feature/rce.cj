/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

public interface RemoteConnectionEndpoint {
    func getHost(): String

    func getPort(): UInt16

    func getInetAddresses(): Collection<SocketAddress>

    func getDescription(): String
}

public class InetSocketAddressCoupling<RCE> <: ToString where RCE <: RemoteConnectionEndpoint {
    private let connectionEndpoint: RCE

    private let inetSocketAddress: SocketAddress

    public init(connectionEndpoint: RCE, inetAddress: SocketAddress) {
        this.connectionEndpoint = connectionEndpoint
        let port = connectionEndpoint.getPort()
        inetSocketAddress = inetAddress
    }

    public func getRemoteConnectionEndpoint(): RCE {
        return connectionEndpoint
    }

    public func getSocketAddress(): SocketAddress {
        return inetSocketAddress
    }

    public override func toString(): String {
        return "${connectionEndpoint.getDescription()} (${inetSocketAddress})"
    }
}

public abstract class RemoteConnectionEndpointLookupFailure <: ToString {
    private let description: String

    private let exception: Exception

    public init(description: String, exception: Exception) {
        this.description = description
        this.exception = exception
    }

    public func getDescription(): String {
        return description
    }

    public func getException(): Exception {
        return exception
    }

    public func getErrorMessage(): String {
        return "${description} because: ${exception}"
    }

    private var toStringCache: String = ""

    public override func toString(): String {
        if (toStringCache.isEmpty()) {
            toStringCache = ToStringUtil.builderFor("RemoteConnectionEndpointLookupFailure").addValue("description",
                description).addValue("exception", exception).build()
        }
        return toStringCache
    }
}

/* TODO */
public interface DnsName <: ToString {}

public class DnsLookupFailure <: RemoteConnectionEndpointLookupFailure {
    private let dnsName: DnsName

    public init(dnsName: DnsName, exception: Exception) {
        super("DNS lookup exception for ${dnsName}", exception)
        this.dnsName = dnsName
    }

    public func getDnsName(): DnsName {
        return dnsName
    }
}

public class RemoteConnectionException<RCE> <: ToString where RCE <: RemoteConnectionEndpoint {
    private let address: InetSocketAddressCoupling<RCE>

    private let exception: Exception

    public init(remoteConnectionEndpoint: RCE, inetAddress: SocketAddress, exception: Exception) {
        this(InetSocketAddressCoupling<RCE>(remoteConnectionEndpoint, inetAddress), exception)
    }

    public init(address: InetSocketAddressCoupling<RCE>, exception: Exception) {
        this.address = address
        this.exception = exception
    }

    public func getAddress(): InetSocketAddressCoupling<RCE> {
        return address
    }

    public func getException(): Exception {
        return exception
    }

    public func getErrorMessage(): String {
        return "'${address}' failed because: ${exception}"
    }

    private var toStringCache: String = ""

    public override func toString(): String {
        if (toStringCache.isEmpty()) {
            toStringCache = ToStringUtil.builderFor("RemoteConnectionException<Any>").addValue("address", address).
                addValue("exception", exception).build()
        }
        return toStringCache
    }

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

public interface SingleAddressRemoteConnectionEndpoint <: RemoteConnectionEndpoint {
    func getInetAddress(): SocketAddress

    func getInetAddresses(): Collection<SocketAddress> {
        return [getInetAddress()] // TODO Collections.singletonList(getInetAddress())
    }
}
