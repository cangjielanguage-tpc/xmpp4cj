/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

public type DebuggerSupplier = (XMPPConnection) -> XmppDebugger

// TODO
public class ReflectionDebuggerFactory <: XmppDebuggerFactory {
    // private static let LOGGER = getGlobalLogger(("name", "ReflectionDebuggerFactory"))

    private static let DEBUGGER_CLASS_PROPERTY_NAME = "xmpp.debuggerClass"

    public static let INSTANCE = ReflectionDebuggerFactory()

    private static let DEFAULT_DEBUGGERS: Array<DebuggerSupplier> = [{cfg => ConsoleDebugger(cfg)}]

    /**
     * Sets custom debugger class to be created by this factory.
     * @param debuggerClass class to be used by this factory
     */
    // public static func setDebuggerClass(debuggerClass: ClassTypeInfo): Unit {
    //     if (debuggerClass.isEmpty()) {
    //         System.clearProperty(DEBUGGER_CLASS_PROPERTY_NAME)
    //     } else {
    //         System.setProperty(DEBUGGER_CLASS_PROPERTY_NAME, debuggerClass.getCanonicalName())
    //     }
    // }

    // public static func getDebuggerClass(): ClassTypeInfo {
    //     let customDebuggerClassName = getCustomDebuggerClassName()
    //     if (customDebuggerClassName.isEmpty()) {
    //         return getOneOfDefaultDebuggerClasses()
    //     } else {
    //         try {
    //             return TypeInfo.get(customDebuggerClassName) as ClassTypeInfo
    //         } catch (e: Exception) {
    //             LOGGER.log(LogLevel.WARN, "Unable to instantiate debugger class ${customDebuggerClassName}", e)
    //         }
    //     }
    //     return None
    // }

    public override func create(connection: XMPPConnection): XmppDebugger {
        //     let debuggerClass = getDebuggerClass()
        //     if (debuggerClass.isEmpty() == false) {
        //         try {
        //             let constructor = debuggerClass.getConstructor([TypeInfo.of<XMPPConnection>() as ClassTypeInfo])
        //             return constructor.newInstance([connection)]).getOrThrow(
        //         } catch (e: Exception) {
        //             throw IllegalArgumentException("Can\'t initialize the configured debugger!")
        //         }
        //     }
        throw Exception("TODO")
    }

    // private static func getCustomDebuggerClassName(): String {
    //     try {
    //         return System.getProperty(DEBUGGER_CLASS_PROPERTY_NAME)
    //     } catch (t: Exception) {
    //         return None
    //     }
    // }

    // private static func getOneOfDefaultDebuggerClasses(): ClassTypeInfo {
    //     for (debugger in DEFAULT_DEBUGGERS) {
    //         if (XmppConfiguration.isDisabledXmppClass(debugger)) {
    //             continue
    //         }
    //         try {
    //             return TypeInfo.get(debugger) as ClassTypeInfo
    //         } catch (cnfe: ClassNotFoundException) {
    //             LOGGER.trace("Did not find debugger class \'${debugger}" + "\'")
    //         } catch (ex: ClassCastException) {
    //             LOGGER.warning("Found debugger class that does not appears to implement XmppDebugger interface")
    //         } catch (ex: Exception) {
    //             LOGGER.warning("Unable to instantiate either Xmpp debugger class")
    //         }
    //     }
    //     return None
    // }
}
