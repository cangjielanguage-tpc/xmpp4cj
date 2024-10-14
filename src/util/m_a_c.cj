/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public class MAC {
    public static func hmacsha1(key: Array<Byte>, input: Array<UInt8>): Array<UInt8> {
        let HMAC_SHA1 = HMAC(key, HashType.SHA1)
        HMAC_SHA1.write(input)
        return HMAC_SHA1.finish()
    }
}
