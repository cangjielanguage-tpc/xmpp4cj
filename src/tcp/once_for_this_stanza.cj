/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.tcp

public class OnceForThisStanza <: StanzaFilter {
    private let id: ?String
    private let connection: XMPPTCPConnection

    private init(connection: XMPPTCPConnection, packet: Stanza) {
        this.connection = connection
        this.id = packet.getStanzaId()
        if (StringUtils.isNullOrEmpty(id)) {
            throw IllegalArgumentException("Stanza ID must be set")
        }
    }

    public static func setup(connection: XMPPTCPConnection, packet: Stanza): Unit {
        let packetFilter: StanzaFilter = OnceForThisStanza(connection, packet)
        connection.addRequestAckPredicate(packetFilter)
    }

    public override func accept(packet: Stanza): Bool {
        var otherId: ?String = packet.getStanzaId()
        if (StringUtils.isNullOrEmpty(otherId)) {
            return false
        }
        if (id.toString() == otherId.toString()) {
            connection.removeRequestAckPredicate(this)
            return true
        }
        return false
    }

    public override func toString(): String {
        return "OnceForThisStanza ${id}"
    }
}
