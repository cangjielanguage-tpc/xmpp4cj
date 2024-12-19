/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

import std.runtime

/**
 * 表示Xmpp的配置。该配置用于：
 * <ul>
 *      <li> 通过在启动时加载类来初始化类。
 *      <li> 获取当前Xmpp版本。
 *      <li>获取和设置全局库行为，如时间段等待服务器对数据包的回复。注意：设置这些值通过API将覆盖配置文件中的设置。
 * </ul>
 *
 * *配置设置存储在xmpp_config_xml中。
 */
public open class XmppConfiguration {
    public static let XMPP_URL_STRING = "https://gitcode.com/Cangjie-TPC/xmpp4cj" // 将本项目的主页作为xmlns

    private static var defaultPacketReplyTimeout = Duration.millisecond * 5000

    private static var packetCollectorSize = 5000

    private static var defaultMechs: ArrayList<String> = ArrayList<String>()

    static var disabledXmppClasses: Set<ClassId> = HashSet<ClassId>()

    static let compressionHandlers = ArrayList<XMPPInputOutputStream>(2)

    public static var xmppInitialized = false

    public static var DEBUG = false

    private static var DEFAULT_DEBUGGER_FACTORY: XmppDebuggerFactory = LambdaDebuggerFactory.INSTANCE

    /**
     * 默认的解析异常回调是{@link ExceptionThrowingCallback}，它将抛出异常，从而断开活动连接。
     */
    private static var defaultCallback: ParsingExceptionCallback = ExceptionThrowingCallbackWithHint()

    private static var defaultConcurrencyLevelLimit: Int = 0

    /**
     * 如果启用，将导致{@link AbstractXMPPConnection}为每个异步发送操作创建一个线程。
     * 这是为了解决Xmpp的一个缺点，即某些发送操作即使应该异步，也不是异步的。
     * 这是一个专家设置，如果您不了解后果或被告知要这样做，请不要切换。请注意，预计在未来的Xmpp版本中不会需要这样做。
     */
    public static var TRUELY_ASYNC_SENDS = false

    /**
     * 返回等待服务器响应的毫秒数。默认值为5000毫秒。
     *
     * @return 返回等待服务器响应的毫秒数
     */
    public static func getDefaultReplyTimeout(): Duration {
        if (defaultPacketReplyTimeout <= Duration.Zero) {
            defaultPacketReplyTimeout = Duration.millisecond * 5000
        }
        return defaultPacketReplyTimeout
    }

    /**
     * 设置等待服务器响应的毫秒数。
     *
     * @param timeout 超时等待服务器响应的毫秒数
     */
    public static func setDefaultReplyTimeout(timeout: Duration): Unit {
        if (timeout <= Duration.Zero) {
            throw IllegalArgumentException()
        }
        defaultPacketReplyTimeout = timeout
    }

    public static func setDefaultXmppDebuggerFactory(debuggerFactory: XmppDebuggerFactory): Unit {
        DEFAULT_DEBUGGER_FACTORY = Objects.requireNonNull(debuggerFactory, "Debugger factory must not be null")
    }

    public static func getDefaultXmppDebuggerFactory(): XmppDebuggerFactory {
        return DEFAULT_DEBUGGER_FACTORY
    }

    /**
     * 获取节收集器在删除旧数据包之前的默认最大大小。
     *
     * @return 删除旧数据包之前要排队的数据包数。
     */
    public static func getStanzaCollectorSize(): Int64 {
        return packetCollectorSize
    }

    /**
     * 设置节收集器在删除旧数据包之前的默认最大大小。
     *
     * @param collectorSize 删除旧数据包之前要排队的数据包数量。
     */
    public static func setStanzaCollectorSize(collectorSize: Int64): Unit {
        packetCollectorSize = collectorSize
    }

    /**
     * 将SASL机制添加到要使用的列表中。
     *
     * @param mech 要添加的SASL机制
     */
    public static func addSaslMech(mech: String): Unit {
        if (!defaultMechs.contains(mech)) {
            defaultMechs.append(mech)
        }
    }

    /**
     * 将SASL机制的集合添加到要使用的列表中。
     *
     * @param mechs 要添加的SASL机制集合
     */
    public static func addSaslMechs(mechs: Collection<String>): Unit {
        for (mech in mechs) {
            addSaslMech(mech)
        }
    }

    /**
     * 从要使用的列表中删除SASL机制。
     *
     * @param mech 要删除的SASL机制
     */
    public static func removeSaslMech(mech: String): Unit {
        defaultMechs.removeValue(mech)
    }

    /**
     * 将SASL机制集合删除到要使用的列表中。
     *
     * @param mechs 要删除的SASL机制集合
     */
    public static func removeSaslMechs(mechs: Collection<String>): Unit {
        for (mech in mechs) {
            defaultMechs.removeValue(mech)
        }
    }

    /**
     * 返回要使用的SASL机制列表。如果此处列出了SASL机制，则不能保证它会被使用。服务器可能不支持它，或者它可能无法实现。
     *
     * @return 要使用的SASL机制列表。
     */
    public static func getSaslMechs(): ArrayList<String> {
        return defaultMechs
    }

    /**
     * 为所有新创建的连接设置默认的解析异常回调。
     *
     * @param callback 回调接口
     * @see ParsingExceptionCallback
     */
    public static func setDefaultParsingExceptionCallback(callback: ParsingExceptionCallback): Unit {
        defaultCallback = callback
    }

    /**
     * 返回默认的解析异常回调。
     *
     * @return 默认解析异常回调
     * @see ParsingExceptionCallback
     */
    public static func getDefaultParsingExceptionCallback(): ParsingExceptionCallback {
        return defaultCallback
    }

    public static func addCompressionHandler(xmppInputOutputStream: XMPPInputOutputStream): Unit {
        compressionHandlers.append(xmppInputOutputStream)
    }

    /**
     * 获取压缩处理程序。
     *
     * @return 压缩处理程序列表。
     */
    public static func getCompressionHandlers(): ArrayList<XMPPInputOutputStream> {
        let res = ArrayList<XMPPInputOutputStream>(compressionHandlers.size)
        for (ios in compressionHandlers) {
            if (ios.isSupported()) {
                res.append(ios)
            }
        }
        return res
    }

    /**
     * 方便的方法{@link #addDisabledXmppClass(String)}.
     *
     * @param clz 要禁用的Xmpp类
     */
    public static func addDisabledXmppClass(clz: ClassId): Unit {
        disabledXmppClasses.put(clz)
    }

    public static func addDisabledXmppClasses(classNames: Array<String>): Unit {
        for (className in classNames) {
            addDisabledXmppClass(className)
        }
    }

    public static func isDisabledXmppClass(className: String): Bool {
        for (disabledClassOrPackage in disabledXmppClasses) {
            if (disabledClassOrPackage == className) {
                return true
            }
            let lastDotIndex = disabledClassOrPackage.lastIndexOf(".") ?? -1
            // Security check to avoid NPEs if someone entered 'foo.bar.'
            if (disabledClassOrPackage.size > lastDotIndex &&
                // disabledClassOrPackage is not an Class
                !Rune(disabledClassOrPackage[lastDotIndex + 1]).isAsciiUpperCase() &&
                    // classToLoad startsWith the package disabledClassOrPackage disables
                    className.startsWith(
                disabledClassOrPackage)) {
                // Skip the class because the whole package was disabled
                return true
            }
        }
        return false
    }

    /**
     * 检查Xmpp是否已成功初始化。
     *
     * @return 如果xmpp已初始化，则为true，否则为false
     */
    public static func isXmppInitialized(): Bool {
        return xmppInitialized
    }

    private static var unknownIqRequestReplyMode: XmppConfigurationUnknownIqRequestReplyMode = XmppConfigurationUnknownIqRequestReplyMode
        .replyFeatureNotImplemented

    public static func getUnknownIqRequestReplyMode(): XmppConfigurationUnknownIqRequestReplyMode {
        return unknownIqRequestReplyMode
    }

    public static func setUnknownIqRequestReplyMode(
        unknownIqRequestReplyMode: XmppConfigurationUnknownIqRequestReplyMode): Unit {
        XmppConfiguration.unknownIqRequestReplyMode = Objects.requireNonNull(unknownIqRequestReplyMode, "Must set mode")
    }

    public static func getDefaultConcurrencyLevelLimit(): Int {
        return defaultConcurrencyLevelLimit
    }

    static init() {
        let availableProcessors = runtime.ProcessorInfo.processorCount
        if (availableProcessors < 8) {
            defaultConcurrencyLevelLimit = 8
        } else {
            defaultConcurrencyLevelLimit = Int64(Float64(availableProcessors) * 1.1)
        }
    }
}

/**
 * 表示对于未知的 IQ 请求的回复模式。
 */
public enum XmppConfigurationUnknownIqRequestReplyMode <: ToString & Equatable<XmppConfigurationUnknownIqRequestReplyMode> {
    /**
     * 不做回复。
     */
    | doNotReply
    /**
     * 回复功能未实现。
     */
    | replyFeatureNotImplemented
    /**
     * 回复服务不可用。
     */
    | replyServiceUnavailable

    public override func toString(): String {
        return match (this) {
            case doNotReply => "doNotReply"
            case replyFeatureNotImplemented => "replyFeatureNotImplemented"
            case replyServiceUnavailable => "replyServiceUnavailable"
        }
    }

    public operator func ==(that: XmppConfigurationUnknownIqRequestReplyMode): Bool {
        this.toString() == that.toString()
    }
}
