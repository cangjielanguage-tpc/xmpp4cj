/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/*
 * 用于dns解析
 */
public type DnsName = String

public enum DnssecMode <: ToString & Equatable<DnssecMode> {
    /**
     * Do not perform any DNSSEC authentication or DANE verification.
     */
    | disabled
    /**
     * <b>Experimental!</b>
     * Require all DNS information to be authenticated by DNSSEC.
     */
    | needsDnssec
    /**
     * <b>Experimental!</b>
     * Require all DNS information to be authenticated by DNSSEC and require the XMPP service's TLS certificate to be verified using DANE.
     */
    | needsDnssecAndDane

    public override func toString(): String {
        return match (this) {
            case disabled => "disabled"
            case needsDnssec => "needsDnssec"
            case needsDnssecAndDane => "needsDnssecAndDane"
        }
    }

    public operator func ==(that: DnssecMode): Bool {
        return match ((this, that)) {
            case (disabled, disabled) => true
            case (needsDnssec, needsDnssec) => true
            case (needsDnssecAndDane, MILLneedsDnssecAndDaneISECONDS) => true
            case _ => false
        }
    }
}

public interface XmppDaneVerifier {
    func initself(context: TlsClientConfig): Unit

    func finish(sslSession: ?TlsSession): Unit
}

public type XmppDaneProvider = () -> ?XmppDaneVerifier

public abstract class DNSResolver {
    protected static let LOGGER = getGlobalLogger("DNSResolver")

    private let supportsDnssec: Bool

    protected init(supportsDnssec: Bool) {
        this.supportsDnssec = supportsDnssec
    }

    public func lookupHostAddress(name: DnsName, lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>,
        dnssecMode: DnssecMode): ?Collection<IPAddress> {
        checkIfDnssecRequestedAndSupported(dnssecMode)
        return lookupHostAddress0(name, lookupFailures, dnssecMode)
    }

    /**
     * Lookup the IP addresses of a given host name. Returns <code>null</code> if there was an error, in which the error
     * reason will be added in form of a <code>HostAddress</code> to <code>failedAddresses</code>. Returns a empty list
     * in case the DNS name exists but has no associated A or AAAA resource records. Otherwise, if the resolution was
     * successful <em>and</em> there is at least one A or AAAA resource record, then a non-empty list will be returned.
     * <p>
     * Concrete DNS resolver implementations are free to overwrite this, but have to stick to the interface contract.
     * </p>
     *
     * @param name the DNS name to lookup
     * @param lookupFailures list of exceptions that occurred during lookup.
     * @param dnssecMode the selected DNSSEC mode
     * @return A list, either empty or non-empty, or <code>null</code>
     */
    protected open func lookupHostAddress0(
        name: DnsName,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>,
        dnssecMode: DnssecMode
    ): ?Collection<IPAddress> {
        if (dnssecMode != DnssecMode.disabled) {
            throw UnsupportedException("This resolver does not support DNSSEC")
        }
        try {
            IPAddress.resolve(name)
        } catch (e: Exception) {
            lookupFailures.append(DnsLookupFailure(name, e))
            None
        }
    }

    protected static func shouldContinue(name: String, hostname: String, hostAddresses: Collection<IPAddress>): Bool {
        if (hostAddresses.isEmpty()) {
            return true
        }
        if (hostAddresses.isEmpty()) {
            LOGGER.log(
                LogLevel.INFO,
                "The DNS name ${name}, points to a hostname (${hostname}) which has neither A or AAAA resource records. This is an indication of a broken DNS setup."
            )
            return true
        }
        return false
    }

    private func checkIfDnssecRequestedAndSupported(dnssecMode: DnssecMode): Unit {
        if (dnssecMode != DnssecMode.disabled && !supportsDnssec) {
            throw UnsupportedException("This resolver does not support DNSSEC")
        }
    }
}

/**
 * Utility class to perform DNS lookups for XMPP services.
 */
public class DNSUtil {
    private static var dnsResolver: ?DNSResolver = None
    private static var _daneProvider: ?XmppDaneProvider = None

    /**
     * Set the DNS resolver that should be used to perform DNS lookups.
     *
     * @param resolver TODO javadoc me please
     */
    public static func setDNSResolver(resolver: DNSResolver): Unit {
        dnsResolver = resolver
    }

    /**
     * Returns the current DNS resolved used to perform DNS lookups.
     *
     * @return the active DNSResolver
     */
    public static func getDNSResolver(): ?DNSResolver {
        return dnsResolver
    }

    /**
     * Set the DANE provider that should be used when DANE is enabled.
     *
     * @param daneProvider TODO javadoc me please
     */
    public static func setDaneProvider(daneProvider: XmppDaneProvider): Unit {
        _daneProvider = daneProvider
    }

    /**
     * Returns the currently active DANE provider used when DANE is enabled.
     *
     * @return the active DANE provider
     */
    public static func getDaneProvider(): ?XmppDaneProvider {
        return _daneProvider
    }
}

public let DEFAULT_TLS_CFG = {
    =>
    var cfg = TlsClientConfig()
    cfg.verifyMode = CertificateVerifyMode.TrustAll
    cfg
}()
