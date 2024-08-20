/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public interface StanzaIdSource {
    func getNewStanzaId(): ?String
}

public interface StanzaIdSourceFactory {
    func constructStanzaIdSource(): StanzaIdSource
}

public class UuidStanzaIdSource <: StanzaIdSource {
    public static let INSTANCE = UuidStanzaIdSource()

    private init() {}

    public override func getNewStanzaId(): ?String {
        return UUID.randomUUID().toString()
    }
}

public class UuidStanzaIdSourceFactory <: StanzaIdSourceFactory {
    public override func constructStanzaIdSource(): UuidStanzaIdSource {
        return UuidStanzaIdSource.INSTANCE
    }
}

public class RandomStringStanzaIdSource <: StanzaIdSource {
    public RandomStringStanzaIdSource(let newStanzaId: () -> ?String) {}
    public override func getNewStanzaId(): ?String {
        return newStanzaId()
    }
}

public class RandomStringStanzaIdSourceFactory <: StanzaIdSourceFactory {
    private let REQUIRED_MIN_LENGTH: Int64 = 10
    private let length: Int64
    private let verySecure: Bool

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
    public static let DEFAULT: StandardStanzaIdSource = StandardStanzaIdSource()
    /**
     * A prefix helps to make sure that ID's are unique across multiple instances.
     */
    private let prefix: String = StringUtils.randomString(5) + "-"

    /**
     * Keeps track of the current increment, which is appended to the prefix to forum a unique ID.
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
