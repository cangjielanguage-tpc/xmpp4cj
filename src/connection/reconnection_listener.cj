/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.connection

/**
 * <p>监听器接口，用于接收来自 {@link ReconnectionManager} 的重连事件。
 * 通过 {@link ReconnectionManager#addReconnectionListener(ReconnectionListener)} 方法可以将新的监听器添加到重连管理器。</p>
 */
public interface ReconnectionListener {
    /**
     * 在指定的秒数后，将尝试重新连接。
     * <p>
     * 注意：此方法仅在 {@link ReconnectionManager#isAutomaticReconnectEnabled()} 返回 true 时调用，即
     * 只有在重连管理器对连接启用时才会调用此方法。
     * </p>
     *
     * @param seconds 剩余的秒数，在尝试重新连接之前
     */
    func reconnectingIn(seconds: Duration): Unit

    /**
     * 尝试连接到服务器失败。连接将继续尝试在一段时间后重新连接到服务器。
     * <p>
     * 注意：此方法仅在 {@link ReconnectionManager#isAutomaticReconnectEnabled()} 返回 true 时调用，即
     * 只有在重连管理器对连接启用时才会调用此方法。
     * </p>
     *
     * @param e 导致重连失败的异常
     */
    func reconnectionFailed(e: Exception): Unit
}
