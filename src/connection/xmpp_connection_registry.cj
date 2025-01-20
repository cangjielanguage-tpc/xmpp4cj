/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * XMPPConnection注册表
 */
public class XMPPConnectionRegistry {
    /**
     * 一组监听器，当新连接被创建时将被调用。
     */
    private static let connectionEstablishedListeners: HashSet<ConnectionCreationListener> = HashSet()

    /**
     * 添加一个新的监听器，当新连接被创建时，将通知该监听器。
     * 注意：新创建的连接尚未实际连接到服务器。
     *
     * @param connectionCreationListener 对新连接感兴趣的监听器。
     */
    public static func addConnectionCreationListener(connectionCreationListener: ConnectionCreationListener): Unit {
        connectionEstablishedListeners.add(connectionCreationListener)
    }

    /**
     * 移除一个曾对连接创建事件感兴趣的监听器。
     *
     * @param connectionCreationListener 对新连接感兴趣的监听器。
     */
    public static func removeConnectionCreationListener(connectionCreationListener: ConnectionCreationListener): Unit {
        connectionEstablishedListeners.remove(connectionCreationListener)
    }

    /**
     * 获取对连接创建事件感兴趣的监听器集合。
     *
     * @return 一个对新连接感兴趣的监听器的不可修改集合。
     */
    public static func getConnectionCreationListeners(): Collection<ConnectionCreationListener> {
        return connectionEstablishedListeners
    }
}
