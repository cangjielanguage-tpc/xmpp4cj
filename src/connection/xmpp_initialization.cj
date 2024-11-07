/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

import std.process.Process

public type StartUp = (String, () -> Object)

/**
 * 待加载XmppInitializer列表
 */
public let XMPP_CONFIG_STARTUP_CLASSES: ArrayList<StartUp> = ArrayList([
    // ("ReconnectionManager", {=>}), // ReconnectionManager静态资源会自动加载
    // ("VmArgInitializer", {=>}), // VmArgInitializer静态资源会自动加载
    ])

/**
 * 待加载XmppInitializer列表 加载失败会忽略
 */
public let XMPP_CONFIG_OPTIONAL_STARTUP_CLASSES: ArrayList<StartUp> = ArrayList([
    // ("DNSResolver",{=>}) // DNSResolver未实现
    // ("ExtensionsInitializer",{=>}) // ExtensionsInitializer未实现
    // ("ExperimentalInitializer",{=>}) // ExperimentalInitializer未实现
    // ("LegacyInitializer",{=>}) // LegacyInitializer未实现
    // ("TCPInitializer",{=>TCPInitializer()}) // TCPInitializer未实现
    // ("SASLProvidedXmppInitializer",{=>SASLProvidedXmppInitializer()}) // SASLProvidedXmppInitializer未实现
    // ("XmppImInitializer",{=>}) // XmppImInitializer未实现
    // ("OmemoInitializer",{=>}) // OmemoInitializer未实现
    // ("OpenPgpInitializer",{=>}) // OpenPgpInitializer未实现
    ])

/**  
 * Xmpp 初始化类，用于加载 Xmpp 的配置和类。
 * <p>
 * 该类负责从配置文件中读取设置，并根据需要初始化相关的类和属性。
 * <p>
 * 初始化过程涉及以下几个步骤：
 * <ol>
 * <li>加载一组类以执行其静态初始化块</li>
 * <li>检索并设置当前 Xmpp版本</li>
 * <li>设置调试模式</li>
 * </ol>
 */
public class XmppInitialization {
    /**
     * 当前 Xmpp 版本
     */
    static let XMPP_VERSION: String

    /**
     *  默认配置文件路径
     */
    private static let DEFAULT_CONFIG_FILE = "xmpp-config.xml"

    /**
     *  日志记录器
     */
    private static let LOGGER = getGlobalLogger("XmppInitialization")

    /**  
     * 静态初始化块，加载配置并执行初始化操作。
     * <p>
     * 该块将在类加载时运行，执行必要的静态初始化逻辑。
     * </p>
     */
    static init() {
        // 对标库逻辑是取version文件内容
        // 此处写死 表示客户端版本
        XMPP_VERSION = "0.0.1"

        let disabledClasses = Process.current.getEnv("xmpp.disabledClasses")
        if (let Some(v) <- disabledClasses) {
            let splitDisabledClasses = v.split(",")
            for (s in splitDisabledClasses) {
                XmppConfiguration.addDisabledXmppClass(s)
            }
        }

        // 对标库是取xmpp-config.xml文件内容 通过反射加载startupClasses和optionalStartupClasses
        // 改为读取XMPP_CONFIG_STARTUP_CLASSES/XMPP_CONFIG_OPTIONAL_STARTUP_CLASSES
        try {
            processConfigFile(None)
        } catch (e: Exception) {
            throw IllegalStateException("Could not parse Xmpp configuration ${e}")
        }

        XmppConfiguration.addCompressionHandler(ZlibInputOutputStream())

        XmppCompressionManager.registerXmppCompressionFactory(ZlibXmppCompressionFactory.INSTANCE)

        try {
            let debugEnabled = Process.current.getEnv("xmpp.debugEnabled")?.toAsciiLower() ?? ""
            if (debugEnabled == "true") {
                XmppConfiguration.DEBUG = true
            }
        } catch (_) {
            // ignore
        }

        SASLAuthentication.registerSASLMechanism(SCRAMSHA1Mechanism())
        SASLAuthentication.registerSASLMechanism(ScramSha1PlusMechanism())
        SASLAuthentication.registerSASLMechanism(SASLXOauth2Mechanism())
        SASLAuthentication.registerSASLMechanism(SASLAnonymous())

        ProviderManager.addIQProvider(Bind.ELEMENT, Bind.NAMESPACE, BindIQProvider())
        ProviderManager.addExtensionProvider(MessageBody.ELEMENT, MessageBody.NAMESPACE, BodyElementProvider())
        ProviderManager.addExtensionProvider(MessageThread.ELEMENT, MessageThread.NAMESPACE,
            MessageThreadElementProvider())
        ProviderManager.addExtensionProvider(MessageSubject.ELEMENT, MessageSubject.NAMESPACE,
            MessageSubjectElementProvider())

        ProviderManager.addNonzaProvider(SaslChallengeProvider.INSTANCE)
        ProviderManager.addNonzaProvider(SaslSuccessProvider.INSTANCE)
        ProviderManager.addNonzaProvider(SaslFailureProvider.INSTANCE)
        ProviderManager.addNonzaProvider(TlsProceedProvider.INSTANCE)
        ProviderManager.addNonzaProvider(TlsFailureProvider.INSTANCE)
        ProviderManager.addNonzaProvider(CompressedProvider.INSTANCE)
        ProviderManager.addNonzaProvider(FailureProvider.INSTANCE)

        XmppConfiguration.xmppInitialized = true
    }

    /**  
     * 处理配置文件，读取并执行所需的配置。
     *
     * @param cfgFileStream 配置文件的输入流
     * @param exceptions 存储在处理过程中出现的异常
     * @throws Exception 如果处理过程中发生错误
     */
    public static func processConfigFile(exceptions: ?ArrayList<Exception>): Unit {
        for (startupClasses in XMPP_CONFIG_STARTUP_CLASSES) {
            parseClassesToLoad(startupClasses, false, exceptions)
        }
        for (optionalStartupClasses in XMPP_CONFIG_OPTIONAL_STARTUP_CLASSES) {
            parseClassesToLoad(optionalStartupClasses, true, exceptions)
        }
    }

    /**  
     * 处理配置文件，读取并执行所需的配置。
     *
     * @param cfgFileStream 配置文件的输入流
     * @param exceptions 存储在处理过程中出现的异常
     * @param classLoader 类加载器
     * @throws Exception 如果处理过程中发生错误
     */
    private static func parseClassesToLoad(startup: StartUp, optional: Bool, exceptions: ?ArrayList<Exception>): Unit {
        let classToLoad = startup[0]
        if (XmppConfiguration.isDisabledXmppClass(classToLoad)) {
            return
        }
        try {
            loadXmppClass(startup, optional)
        } catch (e: Exception) {
            if (exceptions.isSome()) {
                exceptions?.append(e)
            } else {
                throw e
            }
        }
    }

    /**  
     * 解析要加载的类。
     *
     * @param parser XML解析器
     * @param optional 是否为可选加载
     * @param exceptions 存储在处理过程中出现的异常
     * @param classLoader 类加载器
     * @throws Exception 如果解析过程中发生错误
     */
    private static func loadXmppClass(startup: StartUp, optional: Bool): Unit {
        let className = startup[0]
        let initClass: Object
        try {
            initClass = startup[1]()
        } catch (cnfe: Exception) {
            let logLevel: LogLevel
            if (optional) {
                logLevel = LogLevel.TRACE
            } else {
                logLevel = LogLevel.WARN
            }
            LOGGER.log(logLevel, "A startup class '${className}' could not be loaded.")
            if (!optional) {
                throw cnfe
            } else {
                return
            }
        }
        if (let Some(initializer) <- (initClass as XmppInitializer)) {
            let exceptions = initializer.initialize()
            if (exceptions.isEmpty() || exceptions.size == 0) {
                LOGGER.log(LogLevel.TRACE, "Loaded XmppInitializer ${className}")
            } else {
                for (e in exceptions) {
                    LOGGER.log(LogLevel.TRACE, "Exception in loadXmppClass", e)
                }
            }
        } else {
            LOGGER.log(LogLevel.TRACE, "Loaded ${className}")
        }
    }
}
