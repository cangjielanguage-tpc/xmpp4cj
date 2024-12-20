/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.feature

/**
 * public type DnsName = String
 *
 * 用于dns解析
 */
public type DnsName = String

/**
 * 确定请求的 DNSSEC 安全模式。
 * <b>注意：Xmpp 对 DNSSEC/DANE 的支持仍然处于实验阶段！</b>
 * <p>
 * 默认选项 '{@link #disabled}' 表示不进行任何 DNSSEC 或 DANE 验证。如果使用 '{@link #needsDnssec}'，
 * 则如果用于连接 XMPP 服务的资源记录未通过 DNSSEC 认证，则无法建立连接。此外，如果使用
 * '{@link #needsDnssecAndDane}'，则会使用 DANE 验证 XMPP 服务的 TLS 证书。
 * </p>
 */
public enum DnssecMode <: ToString & Equatable<DnssecMode> {
    /**
     * 不进行任何 DNSSEC 认证或 DANE 验证。
     */
    | disabled
    /**
     * 要求所有 DNS 信息都需通过 DNSSEC 认证。
     */
    | needsDnssec
    /**
     * 要求所有 DNS 信息都需通过 DNSSEC 认证，并要求使用 DANE 验证 XMPP 服务的 TLS 证书。
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
            case (needsDnssecAndDane, needsDnssecAndDane) => true
            case _ => false
        }
    }
}

/**
 * 该接口的实现定义了一个能够在连接上启用 DANE 的类。
 * <p>
 * DANE（DNS-based Authentication of Named Entities）是一种可以使用 DNSSEC（DNS Security Extensions）来验证证书的机制。
 * 实现此接口的类需要提供初始化和结束 DANE 验证的功能。
 * </p>
 */
public interface XmppDaneVerifier {
    /**
     * 初始化 DANE 验证器。
     *
     * @param context SSL 上下文
     * @throws KeyManagementException 如果密钥管理出现问题
     */
    func initself(context: TlsClientConfig): Unit

    /**
     * 完成 DANE 验证过程。
     *
     * @param sslSession SSL 会话
     * @throws CertificateException 如果证书验证失败
     */
    func finish(sslSession: ?TlsSession): Unit
}

/**
 * public type XmppDaneProvider = () -> ?XmppDaneVerifier
 */
public type XmppDaneProvider = () -> ?XmppDaneVerifier

/**
 * public abstract class DNSResolver
 *
 * 该接口的实现定义了一个能够解析 DNS 地址的类。
 * <p>
 * 此抽象类提供了查找服务记录和主机地址的基本功能，并提供对 DNSSEC 的支持。
 * </p>
 */
public abstract class DNSResolver {
    protected static let LOGGER = getGlobalLogger("DNSResolver")

    private let supportsDnssec: Bool

    /**
     * 构造函数，初始化 DNSResolver 实例。
     *
     * @param supportsDnssec 表示是否支持 DNSSEC 的布尔值
     */
    protected init(supportsDnssec: Bool) {
        this.supportsDnssec = supportsDnssec
    }

    /**
     * 查找给定 DNS 名称的 IP 地址列表。
     *
     * @param name              要查找的 DNS 名称
     * @param lookupFailures    在查找期间发生的异常列表
     * @param dnssecMode       选择的 DNSSEC 模式
     * @return 一个列表，可能为空、非空或 <code>None</code>
     */
    public func lookupHostAddress(name: DnsName, lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>,
        dnssecMode: DnssecMode): ?Collection<IPAddress> {
        checkIfDnssecRequestedAndSupported(dnssecMode)
        return lookupHostAddress0(name, lookupFailures, dnssecMode)
    }

    /**
     * 在给定主机名称上查找 IP 地址。
     * <p>
     * 如果发生错误，将返回 <code>null</code>，并且错误原因将以 <code>HostAddress</code> 的形式添加到 <code>failedAddresses</code>。
     * 如果 DNS 名称存在但没有与之关联的 A 或 AAAA 资源记录，则返回空列表。
     * 否则，如果解析成功并且至少有一个 A 或 AAAA 资源记录，则返回非空列表。
     * </p>
     *
     * @param name              要查找的 DNS 名称
     * @param lookupFailures    在查找期间发生的异常列表
     * @param dnssecMode       选择的 DNSSEC 模式
     * @return 包含 IP 地址的列表
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

    /**
     * 判断是否应继续查询。
     *
     * @param name            DNS 名称
     * @param hostname        主机名
     * @param hostAddresses   主机地址列表
     * @return 如果应继续，则返回 true；否则返回 false
     */
    protected static func shouldContinue(name: String, hostname: String, hostAddresses: ?Collection<IPAddress>): Bool {
        if (hostAddresses.isNone()) {
            return true
        }
        if (hostAddresses.getOrThrow().isEmpty()) {
            LOGGER.log(
                LogLevel.INFO,
                "The DNS name ${name}, points to a hostname (${hostname}) which has neither A or AAAA resource records. This is an indication of a broken DNS setup."
            )
            return true
        }
        return false
    }

    /**
     * 检查是否请求并支持 DNSSEC。
     *
     * @param dnssecMode DNSSEC 模式
     * @throws UnsupportedOperationException 如果不支持 DNSSEC
     */
    private func checkIfDnssecRequestedAndSupported(dnssecMode: DnssecMode): Unit {
        if (dnssecMode != DnssecMode.disabled && !supportsDnssec) {
            throw UnsupportedException("This resolver does not support DNSSEC")
        }
    }
}

/**
 * 用于执行 XMPP 服务的 DNS 查找的工具类。
 * <p>
 * 此类提供了一些静态方法来设置和获取 DNS 解析器和 DANE 提供者。
 * </p>
 * @author Florian Schmaus
 */
public class DNSUtil {
    private static var dnsResolver: ?DNSResolver = StdDnsResolver() // 当前使用的 DNS 解析器  

    private static var _daneProvider: ?XmppDaneProvider = None // 当前使用的 DANE 提供者 

    /**
     * 设置用于执行 DNS 查找的 DNS 解析器。
     *
     * @param resolver 要设置的 DNS 解析器
     * @throws NullPointerException 如果提供的解析器为 null
     */
    public static func setDNSResolver(resolver: DNSResolver): Unit {
        dnsResolver = resolver
    }

    /**
     * 返回当前用于执行 DNS 查找的 DNS 解析器。
     *
     * @return 当前活动的 DNSResolver
     */
    public static func getDNSResolver(): ?DNSResolver {
        return dnsResolver
    }

    /**
     * 设置在启用 DANE 时应使用的 DANE 提供者。
     *
     * @param daneProvider 要设置的 DANE 提供者
     * @throws NullPointerException 如果提供的 DANE 提供者为 null
     */
    public static func setDaneProvider(daneProvider: XmppDaneProvider): Unit {
        _daneProvider = daneProvider
    }

    /**
     * 返回当前启用 DANE 时使用的活动 DANE 提供者。
     *
     * @return 当前活动的 DANE 提供者
     */
    public static func getDaneProvider(): ?XmppDaneProvider {
        return _daneProvider
    }
}

public let DEFAULT_TLS_CFG = {
    =>
    var cfg = TlsClientConfig()
    // cfg.verifyMode = CertificateVerifyMode.TrustAll
    cfg
}()

/**
 * 默认的 DNS 解析器, 忽略 DNSSEC 校验
 */
public class StdDnsResolver <: DNSResolver {
    public init() {
        super(true)
    }
    public override func lookupHostAddress0(
        name: DnsName,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>,
        dnssecMode: DnssecMode
    ): ?Collection<IPAddress> {
        let arr = super.lookupHostAddress0(name, lookupFailures, DnssecMode.disabled)
        match (arr) {
            case Some(arr) where arr.isEmpty() => lookupFailures.append(DnsLookupFailure(name, None))
            case _ => ()
        }
        arr
    }
}
