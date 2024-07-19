/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj

public let INSTANCE: UuidStanzaIdSource = UuidStanzaIdSource()
public let VERY_SECURE: RandomStringStanzaIdSourceFactory = RandomStringStanzaIdSourceFactory(10, true)
public let MEDIUM_SECURE: RandomStringStanzaIdSourceFactory = RandomStringStanzaIdSourceFactory(10, false)

public interface StanzaIdSource {
    func getNewStanzaId(): String
}

public interface StanzaIdSourceFactory {
    func constructStanzaIdSource(): StanzaIdSource
}

public class UuidStanzaIdSource <: StanzaIdSource {
    init() {
    }

    public func getNewStanzaId(): String {
        ""
        // return UUID.randomUUID().toString()
    }
}

public class UuidStanzaIdSourceFactory <: StanzaIdSourceFactory {
    public func constructStanzaIdSource(): UuidStanzaIdSource {
        return INSTANCE
    }
}

public class RandomStringStanzaIdSource {}

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

    public func constructStanzaIdSource(): StanzaIdSource {
        var stanzaIdSource: StanzaIdSource
        if (verySecure) {
            stanzaIdSource = StanzaIdSource1(length)
        } else {
            stanzaIdSource = StanzaIdSource2(length)
        }
        return stanzaIdSource
    }
}

public class StanzaIdSource1 <: StanzaIdSource {
    var lengthInt64: Int64
    init(lengthInt64: Int64) {
        this.lengthInt64 = lengthInt64
    }
    public func getNewStanzaId(): String {
        ""
        // StringUtils.randomString(length)
    }
}

public class StanzaIdSource2 <: StanzaIdSource {
    var lengthInt64: Int64
    init(lengthInt64: Int64) {
        this.lengthInt64 = lengthInt64
    }
    public func getNewStanzaId(): String {
        ""
        // StringUtils.insecureRandomString(length)
    }
}

public let DEFAULT: StandardStanzaIdSource = StandardStanzaIdSource()

public class StandardStanzaIdSource <: StanzaIdSource {
    /**
     * A prefix helps to make sure that ID's are unique across multiple instances.
     */
    // private let prefix: String = StringUtils.randomString(5) + "-"
    private let prefix: String = ""

    /**
     * Keeps track of the current increment, which is appended to the prefix to
     * forum a unique ID.
     */
    private let id: AtomicInt64 = AtomicInt64(0)

    public func getNewStanzaId(): String {
        id.fetchAdd(1)
        return "${prefix}${id.load()}"
    }
}

public class StandardStanzaIdSourceFactory <: StanzaIdSourceFactory {
    public func constructStanzaIdSource(): StandardStanzaIdSource {
        return StandardStanzaIdSource()
    }
}
