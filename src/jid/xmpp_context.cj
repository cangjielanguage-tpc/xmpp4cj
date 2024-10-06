/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

/**
 * 一个描述 XMPP 所使用配置的上下文。
 */
public class XmppContext {
    private static var defaultContext: ?XmppContext = None

    /**
     * 获取默认上下文。
     *
     * @return 默认上下文。
     */
    public static func getDefaultContext(): XmppContext {
        return defaultContext()
    }

    private static var defaultXmppStringprep: ?XmppStringprep = None

    /**
     * 设置默认的 XmppStringprep 接口。
     *
     * @param defaultXmppStringprep 默认的 XmppStringprep 接口。
     */
    public static func setDefaultXmppStringprep(defaultXmppStringprep: XmppStringprep): Unit {
        XmppContext.defaultXmppStringprep = defaultXmppStringprep
        updateDefaultContext()
    }

    private static func updateDefaultContext(): Unit {
        defaultContext = builder().enableCaching().withXmppStringprep(defaultXmppStringprep()).build()
    }

    private let cachingEnabled: Bool

    /**
     * XmppStringprep对象
     */
    public let xmppStringprep: XmppStringprep

    XmppContext(builder: XmppContextBuilder) {
        cachingEnabled = builder.cachingEnabled
        xmppStringprep = builder.xmppStringprep.getOrThrow {
            => IllegalArgumentException("Argument 'xmppStringprep' must not be None")
        }
    }

    /**
     * 如果启用了字符串、部分和 JID 缓存，则返回 true。
     *
     * @return 如果缓存已启用，则返回 true。
     */
    public func isCachingEnabled(): Bool {
        return cachingEnabled
    }

    /**
     * 构造并检索一个新的构建器。
     *
     * @return 一个新的构建器。
     */
    public static func builder(): XmppContextBuilder {
        return XmppContextBuilder()
    }
}

public class XmppContextBuilder {
    var cachingEnabled: Bool = false

    var xmppStringprep: ?XmppStringprep = None

    /**
     * 启用字符串、部分和 JID 缓存。
     *
     * @return 对这个构建器的引用。
     */
    public func enableCaching(): XmppContextBuilder {
        cachingEnabled = true
        return this
    }

    /**
     * 设置要使用的 XmppStringprep。
     *
     * @param xmppStringprep 要使用的 XmppStringprep。
     * @return 对这个构建器的引用。
     */
    public func withXmppStringprep(xmppStringprep: XmppStringprep): XmppContextBuilder {
        this.xmppStringprep = xmppStringprep
        return this
    }

    /**
     * 构建一个 XmppContext。
     *
     * @return 一个新构建的 XmppContext。
     */
    public func build(): XmppContext {
        return XmppContext(this)
    }
}

public enum XmppAddressParttype <: ToString {
    /**
     * 本地域。
     */
    | localpart
    /**
     * 部分域。
     */
    | domainpart
    /**
     * 域资源部分。
     */
    | resourcepart

    /**
     * 获取此 XMPP 地址部分的大写名称。
     *
     * @return 此部分的大写名称。
     */
    public func getCapitalizedName(): String {
        return match (this) {
            case localpart => "Localpart"
            case domainpart => "Domainpart"
            case resourcepart => "Resourcepart"
        }
    }

    public override func toString(): String {
        return match (this) {
            case localpart => "localpart"
            case domainpart => "domainpart"
            case resourcepart => "resourcepart"
        }
    }
}
