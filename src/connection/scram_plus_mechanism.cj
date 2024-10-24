/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

/**
 * SCRAM-X-PLUS implementation. Due limitations of the Java API, this mechanism only supports the 'tls-server-end-point'
 * channel binding type. But on the other hand, the other relevant channel binding type 'tls-unique' has some flaws (see
 * 3SHAKE, RFC 7627).
 */
public abstract class ScramPlusMechanism <: ScramMechanism {
    protected init(scramHmac: ScramHmac) {
        super(scramHmac)
    }

    public open override func getName(): String {
        return "${super.getName()}-PLUS"
    }

    protected open override func getGs2CbindFlag(): String {
        return "p=tls-server-end-point"
    }

    protected open override func getChannelBindingData(): ?Array<UInt8> {
        let cbData: Array<UInt8>
        try {
            cbData = TLSUtils.getChannelBindingTlsServerEndPoint(sslSession())
        } catch (e: Exception) {
            throw XmppSaslException(e)
        }
        return cbData
    }
}
