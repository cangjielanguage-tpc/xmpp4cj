/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.util

import stdx.crypto.digest.HMAC
import stdx.crypto.digest.HashType

public class MAC {
    /**
     * 使用字节数组形式的密钥和输入字节数组计算 HMAC-SHA1
     *
     * @param keyBytes 用于 HMAC 的密钥字节数组
     * @param input    输入数据
     * @return 计算得到的 HMAC-SHA1 值
     * @throws CryptoException 如果密钥无效
     */
    public static func hmacsha1(key: Array<Byte>, input: Array<UInt8>): Array<UInt8> {
        let HMAC_SHA1 = HMAC(key, HashType.SHA1)
        HMAC_SHA1.write(input)
        return HMAC_SHA1.finish()
    }
}
