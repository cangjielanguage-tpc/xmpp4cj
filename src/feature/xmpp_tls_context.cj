/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

// TODO
public class XmppTlsContext {
    public let sslContext: TlsSessionContext

    public let daneVerifier: ?XmppDaneVerifier

    public init(sslContext: TlsSessionContext, daneVerifier: XmppDaneVerifier) {
        this.sslContext = sslContext
        this.daneVerifier = daneVerifier
    }
}
