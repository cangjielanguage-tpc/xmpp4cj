/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

public class RemoteXmppTcpConnectionEndpoints {
    private static let LOGGER = getGlobalLogger(("name", "RemoteXmppTcpConnectionEndpoints"))

    public static let XMPP_CLIENT_DNS_SRV_PREFIX = "_xmpp-client._tcp"

    public static let XMPP_SERVER_DNS_SRV_PREFIX = "_xmpp-server._tcp"

    /**
     * Lookups remote connection endpoints on the server for XMPP connections over TCP taking A, AAAA and SRV resource
     * records into account. If no host address was configured and all lookups failed, for example with NX_DOMAIN, then
     * result will be populated with the empty list.
     *
     * @param config the connection configuration to lookup the endpoints for.
     * @return a lookup result.
     */
    public static func lookup(config: ConnectionConfiguration): RemoteXmppTcpConnectionEndpointsResult<Rfc6120TcpRemoteConnectionEndpoint> {
        let discoveredRemoteConnectionEndpoints: ArrayList<Rfc6120TcpRemoteConnectionEndpoint>
        let lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>

        let hostAddress = config.getHostAddress()
        let host = config.getHost()

        if (let Some(hostAddress) <- hostAddress) {
            lookupFailures = ArrayList(0)
            let connectionEndpoint = IpTcpRemoteConnectionEndpoint.comefrom(hostAddress.toString(), config.getPort(),
                hostAddress)
            discoveredRemoteConnectionEndpoints = ArrayList(1)
            discoveredRemoteConnectionEndpoints.append(connectionEndpoint)
        } else if (let Some(host) <- host) {
            lookupFailures = ArrayList<RemoteConnectionEndpointLookupFailure>(1)
            let hostAddresses = DNSUtil.getDNSResolver()?.lookupHostAddress(host, lookupFailures, config.getDnssecMode()
            )
            if (let Some(hostAddresses) <- hostAddresses.flatten()) {
                discoveredRemoteConnectionEndpoints = ArrayList<Rfc6120TcpRemoteConnectionEndpoint>(hostAddresses.size)
                let port = config.getPort()
                for (inetAddress in hostAddresses) {
                    let connectionEndpoint = IpTcpRemoteConnectionEndpoint.comefrom(host.toString(), port, inetAddress)
                    discoveredRemoteConnectionEndpoints.append(connectionEndpoint)
                }
            } else {
                discoveredRemoteConnectionEndpoints = ArrayList(0)
            }
        } else {
            lookupFailures = ArrayList(0)
            let dnsName = config.getXmppServiceDomainAsDnsNameIfPossible().getOrThrow {=> IllegalStateException()}
            discoveredRemoteConnectionEndpoints = resolveXmppServiceDomain(dnsName, lookupFailures,
                config.getDnssecMode())
        }

        assert(!discoveredRemoteConnectionEndpoints.isEmpty() || !lookupFailures.isEmpty())

        return RemoteXmppTcpConnectionEndpointsResult(discoveredRemoteConnectionEndpoints, lookupFailures)
    }

    /**
     * Returns a list of HostAddresses under which the specified XMPP server can be reached at for client-to-server
     * communication. A DNS lookup for a SRV record in the form "_xmpp-client._tcp.example.com" is attempted, according
     * to section 3.2.1 of RFC 6120. If that lookup fails, it's assumed that the XMPP server lives at the host resolved
     * by a DNS lookup at the specified domain on the default port of 5222.
     * <p>
     * As an example, a lookup for "example.com" may return "im.example.com:5269".
     * </p>
     *
     * @param domain the domain.
     * @param lookupFailures on optional list that will be populated with host addresses that failed to resolve.
     * @param dnssecMode DNSSec mode.
     * @return List of HostAddress, which encompasses the hostname and port that the
     *      XMPP server can be reached at for the specified domain.
     */
    public static func resolveXmppServiceDomain(domain: DnsName,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>, dnssecMode: DnssecMode): ArrayList<Rfc6120TcpRemoteConnectionEndpoint> {
        let dnsResolver = getDnsResolverOrThrow()
        return resolveDomain(domain, RemoteXmppTcpConnectionEndpointsDomainType.client, lookupFailures, dnssecMode,
            dnsResolver)
    }

    /**
     * Returns a list of HostAddresses under which the specified XMPP server can be reached at for server-to-server
     * communication. A DNS lookup for a SRV record in the form "_xmpp-server._tcp.example.com" is attempted, according
     * to section 3.2.1 of RFC 6120. If that lookup fails , it's assumed that the XMPP server lives at the host resolved
     * by a DNS lookup at the specified domain on the default port of 5269.
     * <p>
     * As an example, a lookup for "example.com" may return "im.example.com:5269".
     * </p>
     *
     * @param domain the domain.
     * @param lookupFailures a list that will be populated with host addresses that failed to resolve.
     * @param dnssecMode DNSSec mode.
     * @return List of HostAddress, which encompasses the hostname and port that the
     *      XMPP server can be reached at for the specified domain.
     */
    public static func resolveXmppServerDomain(domain: DnsName,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>, dnssecMode: DnssecMode): ArrayList<Rfc6120TcpRemoteConnectionEndpoint> {
        let dnsResolver = getDnsResolverOrThrow()
        return resolveDomain(domain, RemoteXmppTcpConnectionEndpointsDomainType.server, lookupFailures, dnssecMode,
            dnsResolver)
    }

    /**
     *
     * @param domain the domain.
     * @param domainType the XMPP domain type, server or client.
     * @param failedAddresses a list that will be populated with host addresses that failed to resolve.
     * @return a list of resolver host addresses for this domain.
     */
    private static func resolveDomain(
        domain: DnsName,
        domainType: RemoteXmppTcpConnectionEndpointsDomainType,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>,
        dnssecMode: DnssecMode,
        dnsResolver: DNSResolver
    ): ArrayList<Rfc6120TcpRemoteConnectionEndpoint> {
        let endpoints = ArrayList<Rfc6120TcpRemoteConnectionEndpoint>()

        let defaultPort: UInt16 = match (domainType) {
            case RemoteXmppTcpConnectionEndpointsDomainType.client => 5222
            case RemoteXmppTcpConnectionEndpointsDomainType.server => 5269
        }
        let hostAddresses = dnsResolver.lookupHostAddress(domain, lookupFailures, dnssecMode)
        if (let Some(hostAddresses) <- hostAddresses) {
            for (inetAddress in hostAddresses) {
                let endpoint = IpTcpRemoteConnectionEndpoint.comefrom(
                    domain,
                    defaultPort,
                    inetAddress
                )
                endpoints.append(endpoint)
            }
        }
        return endpoints
    }

    private static func getDnsResolverOrThrow(): DNSResolver {
        DNSUtil.getDNSResolver().getOrThrow {=> IllegalStateException("No DNS resolver configured in Xmpp")}
    }
}

public class RemoteXmppTcpConnectionEndpointsResult<RCE> where RCE <: RemoteConnectionEndpoint {
    public let discoveredRemoteConnectionEndpoints: ArrayList<RCE>

    public let lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>

    init(
        discoveredRemoteConnectionEndpoints: ArrayList<RCE>,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>
    ) {
        this.discoveredRemoteConnectionEndpoints = discoveredRemoteConnectionEndpoints
        this.lookupFailures = lookupFailures
    }
}

enum RemoteXmppTcpConnectionEndpointsDomainType <: ToString & Equatable<RemoteXmppTcpConnectionEndpointsDomainType> {
    | server
    | client

    public operator override func ==(that: RemoteXmppTcpConnectionEndpointsDomainType): Bool {
        match ((this, that)) {
            case (server, server) => true
            case (client, client) => true
            case _ => false
        }
    }

    public func fromString(): String {
        match (this) {
            case client => RemoteXmppTcpConnectionEndpoints.XMPP_CLIENT_DNS_SRV_PREFIX
            case server => RemoteXmppTcpConnectionEndpoints.XMPP_SERVER_DNS_SRV_PREFIX
        }
    }

    public override func toString(): String {
        match (this) {
            case server => "server"
            case client => "client"
        }
    }
}
