/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * stanza id 资源
 */
public interface StanzaIdSource {
    /**
     * 创建stanza id。
     *
     * @return stanza id。
     */
    func getNewStanzaId(): ?String
}

/**
 * stanza id 资源工厂类
 */
public interface StanzaIdSourceFactory {
    /**
     * 构建StanzaId源
     *
     * @return StanzaId源
     */
    func constructStanzaIdSource(): StanzaIdSource
}

/**
 * 随机 stanza id 资源
 */
public class UuidStanzaIdSource <: StanzaIdSource {
    /**
     * 默认的UuidStanzaIdSource对象
     */
    public static let INSTANCE = UuidStanzaIdSource()

    /**
     * 构造方法
     */
    private init() {}

    /**
     * 创建随机数ID。
     *
     * @return 随机数ID。
     */
    public override func getNewStanzaId(): ?String {
        return UUID.randomUUID().toString()
    }
}

/**
 * 随机 stanza id 资源工厂类
 */
public class UuidStanzaIdSourceFactory <: StanzaIdSourceFactory {
    public override func constructStanzaIdSource(): UuidStanzaIdSource {
        return UuidStanzaIdSource.INSTANCE
    }
}

/**
 * 随机 stanza id 资源
 */
public class RandomStringStanzaIdSource <: StanzaIdSource {
    /**
     * 构造方法。
     */
    public RandomStringStanzaIdSource(let newStanzaId: () -> ?String) {}

    /**
     * 创建stanza id。
     *
     * @return stanza id。
     */
    public override func getNewStanzaId(): ?String {
        return newStanzaId()
    }
}

public class RandomStringStanzaIdSourceFactory <: StanzaIdSourceFactory {
    private let REQUIRED_MIN_LENGTH: Int64 = 10

    private let length: Int64

    private let verySecure: Bool

    /**
     * 构造方法
     *
     * @param length 长度。
     * @param verySecure 是否安全。
     * @return 工厂类实例
     */
    public init(length: Int64, verySecure: Bool) {
        if (length < REQUIRED_MIN_LENGTH) {
            throw IllegalArgumentException("Insufficient length ${length}, must be at least ${REQUIRED_MIN_LENGTH}")
        }
        this.length = length
        this.verySecure = verySecure
    }

    public override func constructStanzaIdSource(): StanzaIdSource {
        if (verySecure) {
            RandomStringStanzaIdSource {=> StringUtils.randomString(length)}
        } else {
            RandomStringStanzaIdSource {=> StringUtils.insecureRandomString(length)}
        }
    }
}

public class StandardStanzaIdSource <: StanzaIdSource {
    /**
     * 默认实例对象
     */
    public static let DEFAULT: StandardStanzaIdSource = StandardStanzaIdSource()

    /**
     * 前缀有助于确保ID在多个实例中是唯一的。
     */
    private let prefix: String = "${StringUtils.randomString(5)}-"

    /**
     * 跟踪当前增量，该增量将附加到论坛的前缀上一个唯一的ID。
     */
    private let id: AtomicInt64 = AtomicInt64(0)

    public override func getNewStanzaId(): ?String {
        id.fetchAdd(1)
        return "${prefix}${id.load()}"
    }
}

public class StandardStanzaIdSourceFactory <: StanzaIdSourceFactory {
    public override func constructStanzaIdSource(): StandardStanzaIdSource {
        return StandardStanzaIdSource()
    }
}
