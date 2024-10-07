/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * HashCode工具类。
 */
public class HashCode {
    static let MULTIPLIERVALUE = 37

    /**
     * 返回HashCodeBuilder对象。
     *
     * @return HashCodeBuilder对象。
     */
    public static func builder(): HashCodeBuilder {
        return HashCodeBuilder()
    }
}

/**
 * HashCode缓存工具类。
 */
public class HashCodeCache {
    private var calculated: Bool = false
    private var hashcode: Int = 0

    /**
     * 通过hashCodeCalculator接口处理HashCode值。
     *
     * @param hashCodeCalculator HashCodeCalculator接口。
     * @return HashCode值。
     */
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

/**
 * HashCode工具类。
 */
public class HashCodeBuilder {
    var hashcode = 17

    private func applyHash(): Unit {
        applyHash(0)
    }

    @OverflowWrapping
    private func applyHash(hash: Int): Unit {
        hashcode = HashCode.MULTIPLIERVALUE * hashcode + hash
    }

    /**
     * 添加对象。
     *
     * @param object 添加的对象。
     * @return 当前对象。
     */
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

    /**
     * 添加迭代器。
     *
     * @param object 添加的迭代器。
     * @return 当前对象。
     */
    public func append<T>(object: Iterable<T>): HashCodeBuilder where T <: Hashable {
        for (element in object) {
            applyHash(element.hashCode())
        }
        return this
    }

    /**
     * 添加布尔值。
     *
     * @param value 添加的布尔值。
     * @return 当前对象。
     */
    public func append(value: Bool): HashCodeBuilder {
        applyHash(if (value) {
            0
        } else {
            1
        })
        return this
    }

    /**
     * 添加UInt8值。
     *
     * @param value 添加的UInt8值。
     * @return 当前对象。
     */
    public func append(value: UInt8): HashCodeBuilder {
        applyHash(Int64(value))
        return this
    }

    /**
     * 添加Char。
     *
     * @param value 添加的Char。
     * @return 当前对象。
     */
    public func append(value: Rune): HashCodeBuilder {
        applyHash(Int64(UInt32(value)))
        return this
    }

    /**
     * 添加Float64值。
     *
     * @param value 添加的Float64值。
     * @return 当前对象。
     */
    @OverflowWrapping
    public func append(value: Float64): HashCodeBuilder {
        applyHash(Int64(value.toBits()))
        return this
    }

    /**
     * 添加Int64值。
     *
     * @param value 添加的Int64值。
     * @return 当前对象。
     */
    public func append(value: Int64): HashCodeBuilder {
        applyHash(value)
        return this
    }

    /**
     * 返回计算之后的HashCode值。
     *
     * @return HashCode值。
     */
    public func build(): Int {
        return hashcode
    }
}
