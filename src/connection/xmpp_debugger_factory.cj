/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**  
 * SmackDebugger 工厂接口，用于创建 SmackDebugger 实例。
 */
public interface XmppDebuggerFactory {
    /**  
     * 初始化新的 SmackDebugger 实例。
     *
     * @param connection 将要附加到的 XMPP 连接。
     * @return 返回创建的 SmackDebugger 实例。
     * @throws IllegalArgumentException 如果无法加载 SmackDebugger，则抛出此异常。
     */
    func create(connection: XMPPConnection): XmppDebugger
}
