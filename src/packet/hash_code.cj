/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class HashCode {
    static let MULTIPLIERVALUE = 37

    public static func builder(): HashCodeBuilder {
        return HashCodeBuilder()
    }
}

public class HashCodeCache {
    private var calculated: Bool = false
    private var hashcode: Int = 0

    public func getHashCode(hashCodeCalculator: HashCodeCalculator): Int {
        if (calculated) {
            return hashcode
        }
        let hashCodeBuilder = HashCodeBuilder()
        hashCodeCalculator(hashCodeBuilder)
        calculated = true
        hashcode = hashCodeBuilder.hashcode
        return hashcode
    }
}

public type HashCodeCalculator = (HashCodeBuilder) -> Unit

public class HashCodeBuilder {
    var hashcode = 17

    private func applyHash(): Unit {
        applyHash(0)
    }

    @OverflowWrapping
    private func applyHash(hash: Int): Unit {
        hashcode = HashCode.MULTIPLIERVALUE * hashcode + hash
    }

    public func append<T>(object: ?T): HashCodeBuilder where T <: Hashable {
        let hashcode = if (let Some(v) <- object) {
            v.hashCode()
        } else {
            applyHash()
            return this
        }
        applyHash(hashcode)
        return this
    }

    public func append<T>(object: Iterable<T>): HashCodeBuilder where T <: Hashable {
        for (element in object) {
            applyHash(element.hashCode())
        }
        return this
    }

    public func append(value: Bool): HashCodeBuilder {
        applyHash(if (value) {
            0
        } else {
            1
        })
        return this
    }

    public func append(value: UInt8): HashCodeBuilder {
        applyHash(Int64(value))
        return this
    }

    public func append(value: Rune): HashCodeBuilder {
        applyHash(Int64(UInt32(value)))
        return this
    }

    @OverflowWrapping
    public func append(value: Float64): HashCodeBuilder {
        applyHash(Int64(value.toBits()))
        return this
    }

    public func append(value: Int64): HashCodeBuilder {
        applyHash(value)
        return this
    }

    public func build(): Int {
        return hashcode
    }
}
