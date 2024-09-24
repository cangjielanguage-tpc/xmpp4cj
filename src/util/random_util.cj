/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public class RandomUtil {
    static let SECURE_RANDOM: Random = SecureRandomWrapper()

    /**
     * Pseudo-random number generator object for use with randomString().
     * The Random class is not considered to be cryptographically secure, so
     * only use these random Strings for low to medium security applications.
     */
    static let RANDOM: Random = RandomWrapper()

    public static func nextSecureRandomInt(bound: Int64): Int64 {
        return SECURE_RANDOM.nextInt64(bound)
    }

    public static func nextSecureRandomInt(): Int64 {
        return SECURE_RANDOM.nextInt64()
    }

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
