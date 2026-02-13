public class ErrStanza <: Stanza {
    let msg: Message = StanzaBuilder.buildMessage().build();

    public func toString(): String {
        return msg.toString();
    }

    public func getElementName(): String {
        return msg.getElementName();
    }

    public func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        throw Exception("stop")
    }
}

public class ReconnectionListener1 <: ReconnectionListener {
    public var logContent=StringBuilder()
    let latch = SyncCounter(1)
    public override func reconnectingIn(seconds: Duration): Unit {
        logContent.append("Reconnecting in ${seconds.toSeconds()} seconds")
        logContent.append("\n")
    }
    public override func reconnectionFailed(e: Exception): Unit {
        logContent.append("reconnectionFailed in ${e}")
        logContent.append("\n")
    }
}