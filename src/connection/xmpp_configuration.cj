/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

/**
 * Represents the configuration of Xmpp. The configuration is used for:
 * <ul>
 *      <li> Initializing classes by loading them at start-up.
 *      <li> Getting the current Xmpp version.
 *      <li> Getting and setting global library behavior, such as the period of time
 *          to wait for replies to packets from the server. Note: setting these values
 *          via the API will override settings in the configuration file.
 * </ul>
 *
 * Configuration settings are stored in xmpp_config_xml.
 */
public class XmppConfiguration {
    public static let XMPP_URL_STRING = "https://gitcode.com/Cangjie-TPC/xmpp4cj"

    private static var defaultPacketReplyTimeout = Duration.millisecond * 5000

    private static var packetCollectorSize = 5000

    private static var defaultMechs: ArrayList<String> = ArrayList<String>()

    static var disabledXmppClasses: Set<ClassId> = HashSet<ClassId>()

    static let compressionHandlers = ArrayList<XMPPInputOutputStream>(2)

    public static var xmppInitialized = false

    public static var DEBUG = false

    private static var DEFAULT_DEBUGGER_FACTORY: XmppDebuggerFactory = ReflectionDebuggerFactory.INSTANCE

    /**
     * The default parsing exception callback is {@link ExceptionThrowingCallback} which will
     * throw an exception and therefore disconnect the active connection.
     */
    private static var defaultCallback: ParsingExceptionCallback = ExceptionThrowingCallbackWithHint()

    private static let defaultConcurrencyLevelLimit: Int = 0

    /**
     * If enabled, causes {@link AbstractXMPPConnection} to create a thread for every asynchronous send operation. This
     * is meant to work-around a shortcoming of Xmpp, where certain send operations are not asynchronous even if
     * they should be. This is an expert setting, do not toggle if you do not understand the consequences or have been
     * told to do so. Note that it is expected that this will not be needed in future Xmpp versions.
     */
    public static var TRUELY_ASYNC_SENDS = false

    static let mtx: Monitor = Monitor()

    /**
     * Returns the number of milliseconds to wait for a response from
     * the server. The default value is 5000 ms.
     *
     * @return the milliseconds to wait for a response from the server
     */
    public static func getDefaultReplyTimeout(): Duration {
        if (defaultPacketReplyTimeout <= Duration.Zero) {
            defaultPacketReplyTimeout = Duration.millisecond * 5000
        }
        return defaultPacketReplyTimeout
    }

    /**
     * Sets the number of milliseconds to wait for a response from
     * the server.
     *
     * @param timeout the milliseconds to wait for a response from the server
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
     * Gets the default max size of a stanza collector before it will delete
     * the older packets.
     *
     * @return The number of packets to queue before deleting older packets.
     */
    public static func getStanzaCollectorSize(): Int64 {
        return packetCollectorSize
    }

    /**
     * Sets the default max size of a stanza collector before it will delete
     * the older packets.
     *
     * @param collectorSize the number of packets to queue before deleting older packets.
     */
    public static func setStanzaCollectorSize(collectorSize: Int64): Unit {
        packetCollectorSize = collectorSize
    }

    /**
     * Add a SASL mechanism to the list to be used.
     *
     * @param mech the SASL mechanism to be added
     */
    public static func addSaslMech(mech: String): Unit {
        if (!defaultMechs.contains(mech)) {
            defaultMechs.append(mech)
        }
    }

    /**
     * Add a Collection of SASL mechanisms to the list to be used.
     *
     * @param mechs the Collection of SASL mechanisms to be added
     */
    public static func addSaslMechs(mechs: Collection<String>): Unit {
        for (mech in mechs) {
            addSaslMech(mech)
        }
    }

    /**
     * Remove a SASL mechanism from the list to be used.
     *
     * @param mech the SASL mechanism to be removed
     */
    public static func removeSaslMech(mech: String): Unit {
        defaultMechs.remove(mech)
    }

    /**
     * Remove a Collection of SASL mechanisms to the list to be used.
     *
     * @param mechs the Collection of SASL mechanisms to be removed
     */
    public static func removeSaslMechs(mechs: Collection<String>): Unit {
        for (mech in mechs) {
            defaultMechs.remove(mech)
        }
    }

    /**
     * Returns the list of SASL mechanisms to be used. If a SASL mechanism is
     * listed here it does not guarantee it will be used. The server may not
     * support it, or it may not be implemented.
     *
     * @return the list of SASL mechanisms to be used.
     */
    public static func getSaslMechs(): ArrayList<String> {
        return defaultMechs
    }

    /**
     * Set the default parsing exception callback for all newly created connections.
     *
     * @param callback TODO javadoc me please
     * @see ParsingExceptionCallback
     */
    public static func setDefaultParsingExceptionCallback(callback: ParsingExceptionCallback): Unit {
        defaultCallback = callback
    }

    /**
     * Returns the default parsing exception callback.
     *
     * @return the default parsing exception callback
     * @see ParsingExceptionCallback
     */
    public static func getDefaultParsingExceptionCallback(): ParsingExceptionCallback {
        return defaultCallback
    }

    public static func addCompressionHandler(xmppInputOutputStream: XMPPInputOutputStream): Unit {
        compressionHandlers.append(xmppInputOutputStream)
    }

    /**
     * Get compression handlers.
     *
     * @return a list of compression handlers.
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
     * Convenience method for {@link #addDisabledXmppClass(String)}.
     *
     * @param clz the Xmpp class to disable
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
     * Check if Xmpp was successfully initialized.
     *
     * @return true if xmpp was initialized, false otherwise
     */
    public static func isXmppInitialized(): Bool {
        return xmppInitialized
    }

    private static var unknownIqRequestReplyMode: XmppConfigurationUnknownIqRequestReplyMode = XmppConfigurationUnknownIqRequestReplyMode.
        replyFeatureNotImplemented

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

    private static let KNOWN_MODULES: Set<ClassId> = HashSet<ClassId>()

    public static func addModule(moduleDescriptor: ClassId): Bool {
        synchronized(mtx) {
            return KNOWN_MODULES.put(moduleDescriptor)
        }
    }

    // public static func addAllKnownModulesTo(builder: ModularXmppClientToServerConnectionConfigurationBuilder): Unit {
    //         synchronized (getMonitorByObject((KNOWN_MODULES as Object))) {
    //             for (moduleDescriptor in KNOWN_MODULES) {
    //                 builder.addModule(moduleDescriptor)
    //             }
    //         }
    // }
}

public enum XmppConfigurationUnknownIqRequestReplyMode <: ToString & Equatable<XmppConfigurationUnknownIqRequestReplyMode> {
    | doNotReply
    | replyFeatureNotImplemented
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
