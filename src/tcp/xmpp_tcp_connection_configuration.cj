/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.tcp

/**
 * 默认连接超时时间。预初始化为30秒。如果更改此值，新的Builder实例将使用新值作为默认值。
 */
public let DEFAULT_CONNECT_TIMEOUT: Duration = Duration.second * 30

/**
 * 通过TCP的XMPP连接的连接配置（常见情况）。
 * <p>
 * 您可以使用{@link#builder（）}获取配置生成器的实例，并使用{@link builder#build（）}构建最终的不可变连接配置。
 * </p>
 * <pre>
 * {@code
 * let conf = XMPPTCPConnectionConfiguration.builder()
 *     .setXmppDomain("example.org")
 *     .setUsernameAndPassword("user", "password")
 *     .setCompressionEnabled(false)
 *     .build()
 * let connection: XMPPTCPConnection = XMPPTCPConnection(conf)
 * }
 * </pre>
 */
public class XMPPTCPConnectionConfiguration <: ConnectionConfiguration {
    /**
     * 套接字将等待多长时间才能建立TCP连接。
     */
    private let connectTimeout: Duration

    /**
     * 通过 XMPPTCPConnectionConfigurationBuilder 构建 XMPPTCPConnectionConfiguration。
     *
     * @param builder XMPPTCPConnectionConfigurationBuilder
     */
    init(builder: XMPPTCPConnectionConfigurationBuilder) {
        // TODO
        super(builder)
        connectTimeout = builder.connectTimeout
    }

    /**
     * 套接字将等待多长时间才能建立TCP连接（以毫秒为单位）。默认为{@link#DEFAULT_CONNECT_TIMEOUT}。
     *
     * @return 超时值
     */
    public func getConnectTimeout(): Duration {
        return connectTimeout
    }

    /**
     * 创建 XMPPTCPConnectionConfigurationBuilder 对象。
     *
     * @return XMPPTCPConnectionConfigurationBuilder对象
     */
    public static func builder(): XMPPTCPConnectionConfigurationBuilder {
        return XMPPTCPConnectionConfigurationBuilder()
    }
}

/**
 * 用于通过TCP进行XMPP连接的配置生成器。使用{@link XMPPTCPConnectionConfiguration#builder（）}获取新实例，并使用{@link#build}构建配置。
 */
public class XMPPTCPConnectionConfigurationBuilder <: ConnectionConfigurationBuilder {
    var connectTimeout: Duration = DEFAULT_CONNECT_TIMEOUT

    init() {
        super()
    }

    public func setConnectTimeout(connectTimeout: Duration): XMPPTCPConnectionConfigurationBuilder {
        this.connectTimeout = connectTimeout
        return this
    }

    public override func build(): XMPPTCPConnectionConfiguration {
        return XMPPTCPConnectionConfiguration(this)
    }
}
