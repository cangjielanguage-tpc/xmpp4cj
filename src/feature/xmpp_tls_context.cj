package xmpp4cj.feature

// TODO
/**
 * 表示 Xmpp 的 TLS 上下文配置。
 * 此类封装了 SSL 上下文和 DANE 验证器的实例，
 * 用于处理安全的 XMPP 连接。
 */
public class XmppTlsContext {
    /** 
     * Config。
     */
    public let tlsCfg: TlsClientConfig

    /** 
     * DANE 验证器，用于进行 DANE（DNS-Based Authentication of Named Entities）验证。
     */
    public let daneVerifier: ?XmppDaneVerifier

    /**
     * 构造一个 XmppTlsContext 实例。
     *
     * @param tlsCfg Config
     * @param daneVerifier DANE 验证器的实例
     * @throws AssertionError 如果 sslContext 为 None
     */
    public init(tlsCfg: TlsClientConfig, daneVerifier: ?XmppDaneVerifier) {
        this.tlsCfg = tlsCfg
        this.daneVerifier = daneVerifier
    }

    /**
     * 设置TlsSocket参数。
     *
     * @param tcpSocket TcpSocket
     * @param connectTimeout 超时时间
     * @param session TlsSession
     * @return TlsSocket
     */
    public func tlsSocketFactory(
        tcpSocket: TcpSocket,
        // host: String,
        // port: UInt16,
        connectTimeout!: ?Duration = None,
        session!: ?TlsSession = None
    ): TlsSocket {
        var clientSession: ?TlsClientSession = None
        if (let Some(v: TlsClientSession) <- session) {
            v
        }
        let tls = TlsSocket.client(tcpSocket, clientConfig: tlsCfg, session: clientSession)
        tls
    }

    public func createSSLEngine(peerHost: String, peerPort: UInt16): SSLEngine {
        throw Exception("TODO")
    }
}

/**
 * 此异常表示各种证书问题之一。
 */
public class CertificateException <: Exception {
    /**
     * 构造一个 CertificateException 实例。
     *
     * @param msg 异常信息
     */
    public init(msg: String) {
        super(msg)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "CertificateException"
    }
}
