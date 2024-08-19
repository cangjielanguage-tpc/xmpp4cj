/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp
/**
 * A context with describes the configuration used by XMPP.
 */
public class XmppContext {
    private static var defaultContext: ?XmppContext = None

    /**
     * Get the default context.
     *
     * @return the default context.
     */
    public static func getDefaultContext(): XmppContext {
        return defaultContext()
    }

    private static var defaultXmppStringprep: ?XmppStringprep = None

    /**
     * Set the default XmppStringprep interface.
     *
     * @param defaultXmppStringprep the default XmppStringprep interface.
     */
    public static func setDefaultXmppStringprep(defaultXmppStringprep: XmppStringprep): Unit {
        XmppContext.defaultXmppStringprep = defaultXmppStringprep
        updateDefaultContext()
    }

    private static func updateDefaultContext(): Unit {
        defaultContext = builder().enableCaching().withXmppStringprep(defaultXmppStringprep()).build()
    }

    private let cachingEnabled: Bool

    public let xmppStringprep: XmppStringprep

    XmppContext(builder: XmppContextBuilder) {
        cachingEnabled = builder.cachingEnabled
        xmppStringprep = builder.xmppStringprep.getOrThrow {
            => IllegalArgumentException("Argument 'xmppStringprep' must not be None")
        }
    }

    /**
     * Returns true if String, Part and Jid caching is enabled.
     *
     * @return true if caching is enabled.
     */
    public func isCachingEnabled(): Bool {
        return cachingEnabled
    }

    /**
     * Construct and retrieve a new builder.
     *
     * @return a new builder.
     */
    public static func builder(): XmppContextBuilder {
        return XmppContextBuilder()
    }
}

public class XmppContextBuilder {
    var cachingEnabled: Bool = false

    var xmppStringprep: ?XmppStringprep = None

    /**
     * Enable String, Part and Jid caching.
     *
     * @return a reference to this builder.
     */
    public func enableCaching(): XmppContextBuilder {
        cachingEnabled = true
        return this
    }

    /**
     * Set the used XmppStringprep.
     *
     * @param xmppStringprep the XmppStringprep to use.
     * @return a reference to this builder.
     */
    public func withXmppStringprep(xmppStringprep: XmppStringprep): XmppContextBuilder {
        this.xmppStringprep = xmppStringprep
        return this
    }

    /**
     * Build a XmppContext.
     *
     * @return a newly build XmppContext.
     */
    public func build(): XmppContext {
        return XmppContext(this)
    }
}

public enum XmppAddressParttype {
    | localpart
    | domainpart
    | resourcepart

    /**
     * Get the capitalized name of this XMPP address part.
     *
     * @return the capitalized name of this part.
     */
    public func getCapitalizedName(): String {
        return match (this) {
            case localpart => "Localpart"
            case domainpart => "Domainpart"
            case resourcepart => "Resourcepart"
        }
    }
}
