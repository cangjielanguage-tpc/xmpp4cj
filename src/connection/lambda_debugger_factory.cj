/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

import std.process.Process

public type DebuggerSupplier = (XMPPConnection) -> XmppDebugger

/* 
 * 通过{@code type DebuggerSupplier = (XMPPConnection) -> XmppDebugger}构造XmppDebugger
 * 支持xmpp.debuggerClass环境变量指定默认
 * 支持{@link XmppConfiguration#addDisabledXmppClasses}排除规则
 */
public class LambdaDebuggerFactory <: XmppDebuggerFactory {
    private static let LOGGER = getGlobalLogger("LambdaDebuggerFactory")

    private static let DEBUGGER_CLASS_PROPERTY_NAME = "xmpp.debuggerClass"

    public static let INSTANCE = LambdaDebuggerFactory()

    private static let DEFAULT_DEBUGGERS: HashMap<ClassId, DebuggerSupplier> = HashMap(
        [("ConsoleDebugger", {cfg => ConsoleDebugger(cfg)})])

    /**
     * Sets custom debugger class to be created by this factory.
     * @param debuggerClass class to be used by this factory
     */
    public static func setDebuggerClass(debuggerClass: ?ClassId): Unit {
        if (let Some(v) <- debuggerClass) {
            Process.current.setEnv(DEBUGGER_CLASS_PROPERTY_NAME, v)
        } else {
            Process.current.removeEnv(DEBUGGER_CLASS_PROPERTY_NAME)
        }
    }

    public static func getDebuggerClass(): ?ClassId {
        let customDebuggerClassName = getCustomDebuggerClassName()
        if (let Some(v) <- customDebuggerClassName) {
            // 对标库设计: 通过反射校验class存在
            // 若异常: None
            return v
        } else {
            return getOneOfDefaultDebuggerClasses()
        }
        return None
    }

    public override func create(connection: XMPPConnection): XmppDebugger {
        let debuggerClass = getDebuggerClass()
        if (let Some(debuggerClass) <- debuggerClass) {
            if (let Some(v) <- DEFAULT_DEBUGGERS.get(debuggerClass)) {
                return v(connection)
            }
        }
        throw IllegalArgumentException("Can't initialize the configured debugger!")
    }

    private static func getCustomDebuggerClassName(): ?ClassId {
        return Process.current.getEnv(DEBUGGER_CLASS_PROPERTY_NAME)
    }

    private static func getOneOfDefaultDebuggerClasses(): ?ClassId {
        for (debugger in DEFAULT_DEBUGGERS) {
            if (XmppConfiguration.isDisabledXmppClass(debugger[0])) {
                continue
            }
            // 对标库设计: 通过反射校验class存在
            // 若异常: 根据异常类型记录日志 返回None
            return debugger[0]
        }
        return None
    }
}
