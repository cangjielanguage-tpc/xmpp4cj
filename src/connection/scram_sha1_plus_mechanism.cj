/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

public open class ScramSha1PlusMechanism <: ScramPlusMechanism {
    public static let NAME: String = ScramSha1PlusMechanism().getName()

    public init() {
        super(SCRAMSHA1Mechanism.SHA_1_SCRAM_HMAC)
    }

    public open override func getPriority(): Int {
        return SCRAMSHA1Mechanism.PRIORITY - 10
    }

    protected open override func newInstance(): SASLMechanism {
        return ScramSha1PlusMechanism()
    }
}
