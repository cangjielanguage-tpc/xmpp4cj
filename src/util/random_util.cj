/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

import crypto.crypto.SecureRandom

/**
 * 随机数工具类
 */
public class RandomUtil {
    static let SECURE_RANDOM: SecureRandomWrapper = SecureRandomWrapper()

    /**
     * 用于randomString（）的伪随机数生成器对象。
     * Random类不被认为是加密安全的，因此
     * 仅将这些随机字符串用于低到中等安全性的应用程序。
     */
    static let RANDOM: RandomWrapper = RandomWrapper()

    /**
     * 获取一个范围在 [0, bound) 的 Int64 类型的伪随机数。
     *
     * @param bound 范围。
     * @return 伪随机数。
     */
    public static func nextSecureRandomInt(bound: Int64): Int64 {
        return SECURE_RANDOM.nextInt64(bound)
    }

    /**
     * 获取一个 Int64 类型的伪随机数。
     *
     * @return 伪随机数。
     */
    public static func nextSecureRandomInt(): Int64 {
        return SECURE_RANDOM.nextInt64()
    }

    /**
     * 生成随机数替换入参数组中的每个元素。
     *
     * @param bytes 数组。
     * @return 替换过随机数的数组。
     */
    public static func fillWithSecureRandom(bytes: Array<Byte>): Array<Byte> {
        SECURE_RANDOM.nextUInt8s(bytes)
    }
}

class SecureRandomWrapper <: Random {
    let lock = ReentrantMutex()

    let random = SecureRandom()

    public override func nextInt64(upper: Int): Int64 {
        synchronized(lock) {
            return random.nextInt64(upper)
        }
    }

    public override func nextInt64(): Int64 {
        synchronized(lock) {
            return random.nextInt64()
        }
    }

    public override func nextUInt8s(bytes: Array<UInt8>): Array<UInt8> {
        synchronized(lock) {
            for (i in 0..bytes.size) {
                let byte = random.nextUInt8()
                bytes[i] = byte
            }
        }
        return bytes
    }
}

class RandomWrapper <: Random {
    let lock = ReentrantMutex()

    let random = Random()

    public override func nextInt64(upper: Int): Int64 {
        synchronized(lock) {
            return random.nextInt64(upper)
        }
    }
}
