/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class RandomUtil {
    static let SECURE_RANDOM: Random = Random()

    /**
     * Pseudo-random number generator object for use with randomString().
     * The Random class is not considered to be cryptographically secure, so
     * only use these random Strings for low to medium security applications.
     */
    static let RANDOM: Random = Random()

    public static func nextSecureRandomInt(bound: Int64): Int64 {
        return SECURE_RANDOM.nextInt64(bound)
    }

    public static func nextSecureRandomInt(): Int64 {
        return SECURE_RANDOM.nextInt64()
    }

    public static func fillWithSecureRandom(bytes: Array<Byte>): Unit {
        SECURE_RANDOM.nextUInt8s(bytes)
    }
}
