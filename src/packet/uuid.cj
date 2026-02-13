/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.packet

class UUID <: ToString {
    private let bytes: Array<Byte> = Array(16, repeat: 0)

    public init(data: Array<Byte>) {
        if (data.size != 16) {
            throw IllegalArgumentException("data must be 16 bytes in length")
        }
        data.copyTo(bytes, 0, 0, bytes.size)
    }

    private init() {
        UUID(this.bytes)
    }

    /**
     * 00000000-0000-0000-0000-000000000000
     *
     * @return  A generated {@code UUID}
     */
    public static func nilUUID(): UUID {
        UUID()
    }

    /**
     * Static factory to retrieve a type 4 (pseudo randomly generated) UUID.
     * The {@code UUID} is generated using a cryptographically strong pseudo random number generator.
     *
     * @return  A randomly generated {@code UUID}
     */
    public static func randomUUID(): UUID {
        let ng: SecureRandom = SecureRandom(priv: false)
        let randomBytes = ng.nextBytes(16)
        randomBytes[6] &= 0x0f /* clear version        */
        randomBytes[6] |= 0x40 /* set to version 4     */
        randomBytes[8] &= 0x3f /* clear variant        */
        randomBytes[8] |= 0x80 /* set to IETF variant  */
        return UUID(randomBytes)
    }

    /**
     * Returns a {@code String} object representing this {@code UUID}.
     *
     * The UUID string representation is as described by this BNF:
     * {@code
     * UUID                   = <time_low> "-" <time_mid> "-"
     *                          <time_high_and_version> "-"
     *                          <variant_and_sequence> "-"
     *                          <node>
     * time_low               = 4*<hexOctet>
     * time_mid               = 2*<hexOctet>
     * time_high_and_version  = 2*<hexOctet>
     * variant_and_sequence   = 2*<hexOctet>
     * node                   = 6*<hexOctet>
     * hexOctet               = <hexDigit><hexDigit>
     * hexDigit               =
     *       "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
     *       | "a" | "b" | "c" | "d" | "e" | "f"
     *       | "A" | "B" | "C" | "D" | "E" | "F"
     * }
     *
     * @return A string representation of this {@code UUID}
     */
    public override func toString(): String {
        return (toHexString(this.bytes.slice(0, 4)) + "-" + toHexString(this.bytes.slice(4, 2)) + "-" + toHexString(
            this.bytes.slice(6, 2)) + "-" + toHexString(this.bytes.slice(8, 2)) + "-" + toHexString(
            this.bytes.slice(10, 6)))
    }
}
