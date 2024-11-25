/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**  
 * 一个非常简单的调试器，打印发送和接收的 Stanza 到控制台（stdout）。
 * 使用此调试器时请谨慎，因为打印到控制台是一项昂贵的操作，可能会阻塞线程，
 * 因为一次只能有一个线程进行打印。
 * <p>
 * 可以打印原始的发送和接收 Stanza，也可以打印 Xmpp 解释的包。
 * 默认情况下，不会打印解释后的包。要启用此功能，只需将静态变量
 * <code>printInterpreted</code> 更改为 <code>true</code>。
 * </p>
 */
public class ConsoleDebugger <: AbstractDebugger {
    private let dateFormatter = DateTimeFormat.of("HH:mm:ss")

    private let dateFormatterLock = Monitor()

    /**  
     * 创建一个新的 ConsoleDebugger 实例。
     *
     * @param connection 关联的 XMPPConnection 对象
     */
    public init(connection: XMPPConnection) {
        super(connection)
        super.postInit()
    }

    /**  
     * 记录调试信息。
     *
     * @param logMessage 要记录的日志消息
     */
    protected override func log(logMessage: String): Unit {
        let formatedDate: String = synchronized(dateFormatterLock) {
            DateTime.now().toString(dateFormatter)
        }
        println('${formatedDate} ${logMessage}')
    }

    /**  
     * 记录调试信息及其相关的异常信息。
     *
     * @param logMessage 要记录的日志消息
     * @param throwable 相关的异常
     */
    protected override func log(logMessage: String, throwable: Exception): Unit {
        let stacktrace = ExceptionUtil.getStackTrace(throwable)
        log('${logMessage}\n${stacktrace}')
    }
}

/**  
 * ConsoleDebugger 的工厂类，用于创建 ConsoleDebugger 实例。
 */
public open class ConsoleDebuggerFactory <: XmppDebuggerFactory {
    /**  
     * XmppDebuggerFactory静态常量。
     */
    public static let INSTANCE: XmppDebuggerFactory = ConsoleDebuggerFactory()

    /**  
     * 创建一个新的 ConsoleDebugger 实例。
     *
     * @param connection 关联的 XMPPConnection 对象
     * @return 创建的 ConsoleDebugger 实例
     * @throws IllegalArgumentException 如果连接为 null
     */
    public open override func create(connection: XMPPConnection): XmppDebugger {
        return ConsoleDebugger(connection)
    }
}
