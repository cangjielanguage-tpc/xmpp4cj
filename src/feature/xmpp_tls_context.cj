/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

// TODO
public class XmppTlsContext {
    public let tlsCfg: TlsClientConfig

    public let daneVerifier: ?XmppDaneVerifier

    public init(tlsCfg: TlsClientConfig, daneVerifier: ?XmppDaneVerifier) {
        this.tlsCfg = tlsCfg
        this.daneVerifier = daneVerifier
    }

    public func tlsSocketFactory(
        tcpSocket: TcpSocket,
        // host: String,
        // port: UInt16,
        connectTimeout!: ?Duration = None,
        session!: ?TlsSession = None
    ): TlsSocket {
        tcpSocket.connect(timeout: connectTimeout)
        TlsSocket.client(tcpSocket, clientConfig: tlsCfg, session: session)
    }
}

public class CertificateException <: Exception {
    public init(msg: String) {
        super(msg)
    }
    protected override func getClassName(): String {
        "CertificateException"
    }
}
