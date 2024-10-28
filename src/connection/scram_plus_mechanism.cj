/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * SCRAM-X-PLUS实施。由于API的限制，此机制仅支持“tls-server-end-point”通道绑定类型。但另一方面，另一种相关的通道绑定类型“tls-unique”存在一些缺陷（参见3SHAKE，RFC 7627）。
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
