/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

public open class SCRAMSHA1Mechanism <: ScramMechanism {
    static let PRIORITY = 110

    public static let NAME: String
    static let SHA_1_SCRAM_HMAC: ScramHmac

    static init() {
        SHA_1_SCRAM_HMAC = ScramHmac(
            "SHA-1",
            {
                key, str => MAC.hmacsha1(key, str)
            }
        )
        NAME = SCRAMSHA1Mechanism().getName()
    }

    public init() {
        super(SHA_1_SCRAM_HMAC)
    }

    public open override func getPriority(): Int {
        return PRIORITY
    }

    protected open override func newInstance(): SASLMechanism {
        return SCRAMSHA1Mechanism()
    }
}
