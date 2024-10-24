/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.connection

public class XMPPConnectionRegistry {
    /**
     * A set of listeners which will be invoked if a new connection is created.
     */
    private static let connectionEstablishedListeners: HashSet<ConnectionCreationListener> = HashSet()

    /**
     * Adds a new listener that will be notified when new Connections are created. Note
     * that newly created connections will not be actually connected to the server.
     *
     * @param connectionCreationListener a listener interested on new connections.
     */
    public static func addConnectionCreationListener(connectionCreationListener: ConnectionCreationListener): Unit {
        connectionEstablishedListeners.put(connectionCreationListener)
    }

    /**
     * Removes a listener that was interested in connection creation events.
     *
     * @param connectionCreationListener a listener interested on new connections.
     */
    public static func removeConnectionCreationListener(connectionCreationListener: ConnectionCreationListener): Unit {
        connectionEstablishedListeners.remove(connectionCreationListener)
    }

    /**
     * Get the collection of listeners that are interested in connection creation events.
     *
     * @return a collection of listeners interested on new connections.
     */
    protected static func getConnectionCreationListeners(): Collection<ConnectionCreationListener> {
        return connectionEstablishedListeners
    }
}
