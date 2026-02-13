/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.sasl

/**
 * ScramHmac 类用于计算 HMAC 值，符合 RFC 5802 中定义的方法。
 */
public open class ScramHmac {
    /**
     * 构造函数。
     *
     * @param hmacName HMAC 的名称
     * @param hmacFunc 计算 HMAC 的函数，接受两个 byte 数组作为参数并返回 HMAC 结果
     */
    public ScramHmac(let hmacName: String, let hmacFunc: (Array<UInt8>, Array<UInt8>) -> Array<UInt8>) {}

    /**
     * 获取 HMAC 名称。
     *
     * @return HMAC 的名称
     */
    public open func getHmacName(): String {
        hmacName
    }

    /**
     *  RFC 5802 § 2.2 HMAC(key, str).
     *
     * @param key 用于计算 HMAC 的密钥，类型为 byte 数组
     * @param str 用于计算 HMAC 的输入字符串，类型为 byte 数组
     * @return the HMAC-SHA1 value of the input.
     */
    public open func hmac(key: Array<UInt8>, str: Array<UInt8>): Array<UInt8> {
        hmacFunc(key, str)
    }
}
