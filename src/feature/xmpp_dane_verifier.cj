/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/**
 * Implementations of this interface define a class that is capable of enabling DANE on a connection.
 */
// TODO
public interface XmppDaneVerifier {
    // throws KeyManagementException
    // func initself(context: TlsSessionContext, km: Array<KeyManager>, tm: X509TrustManager, random: SecureRandom): Unit

    // throws CertificateException
    func finish(sslSession: TlsSession): Unit
}
