internal import cangjie_tpc::xmpp4cj.compress.*
internal import cangjie_tpc::xmpp4cj.compression.*
internal import cangjie_tpc::xmpp4cj.connection.*
internal import cangjie_tpc::xmpp4cj.feature.*
internal import cangjie_tpc::xmpp4cj.filter.*
internal import cangjie_tpc::xmpp4cj.jid.*
internal import cangjie_tpc::xmpp4cj.modular.*
internal import cangjie_tpc::xmpp4cj.packet.*
internal import cangjie_tpc::xmpp4cj.provider.*
internal import cangjie_tpc::xmpp4cj.proxy.*
internal import cangjie_tpc::xmpp4cj.sasl.*
internal import cangjie_tpc::xmpp4cj.stream.*
internal import cangjie_tpc::xmpp4cj.tcp.*
internal import cangjie_tpc::xmpp4cj.util.*
internal import cangjie_tpc::xmpp4cj.xml.*
internal import std.sync.SyncCounter
internal import std.sync.*
internal import std.regex.*
internal import std.time.*
internal import std.collection.*
internal import std.net.*
internal import std.random.*
internal import stdx.net.tls.*
internal import stdx.net.tls.common.*
internal import std.io.*

let XmppTestServerHostName = "xmpp.testserver"

public class StanzaListener1 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    public var logContent: StringBuilder= StringBuilder()
    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }

    public override func processStanza(packet: Stanza) {
        logContent.append(packet.toXML())
        logContent.append("\n")
    }
}
public class StanzaListener2 <: StanzaListener {
    var syncCounter: SyncCounter
    var conn: XMPPTCPConnection
    public var logContent: StringBuilder= StringBuilder()
    public init(syncCounter: SyncCounter, conn: XMPPTCPConnection) {
        this.syncCounter = syncCounter
        this.conn = conn
    }

    public override func processStanza(packet: Stanza) {
        logContent.append(packet.toXML())
        logContent.append("\n")
    }
}
//定义查询当前用户删除联系人
public class ElementUnRegister <: Stanza {
   public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
       return '<iq xmlns="jabber:client" type="set"><query xmlns="jabber:iq:register"><remove /></query></iq>'
   }

   public override func toString(): String {
       return toXML().toString()
   }

   public override func getElementName(): String {
       return "iq"
   }
}
public func getStanzaCollectorByFilter():StanzaCollector{
    let syncCounter: SyncCounter = SyncCounter(2)
    // 接收消息
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    var stanzaCollector=conn1.createStanzaCollector(StanzaTypeFilter<IQ>("IQ"))
    conn1.connect() // 连接
    conn1.login() // 登录

    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
    return stanzaCollector
}
public func getStanzaCollectorBynewConfiguration():StanzaCollector{
    let syncCounter: SyncCounter = SyncCounter(2)
    // 接收消息
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
    var stanzaCollector=conn1.createStanzaCollector(StanzaCollector.newConfiguration())
    conn1.connect() // 连接
    conn1.login() // 登录

    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
    return stanzaCollector
}


public class MyReconnectionListener  <: ReconnectionListener{
    public var logContent=StringBuilder()
    public let val_connection: XMPPConnection

    init(val_connection: XMPPConnection) {
        this.val_connection = val_connection
    }

    public override func reconnectionFailed(e: Exception): Unit {
        logContent.append("Reconnection failed due to an exception (${val_connection})\n")
    }

    public override func reconnectingIn(seconds: Duration): Unit {
        logContent.append("Reconnection failed due to an exception (${val_connection})\n")
    }
}

public class PingRequestHandler <: AbstractIqRequestHandler {
    init() {
        super("ping", "urn:xmpp:ping", IQType.get, IQRequestHandlerMode.async)
    }
    public func handleIQRequest(iqRequest: IQ): ?IQ {
        var reply = IQ.createResultIQ(iqRequest)
        return None
    }
}
public class StanzaAllFilter <: StanzaFilter{
    public func accept(stanza: Stanza): Bool {
       return true
    }
    public func toString(): String {
       return "StanzaAllFilter"
    }
}
public class MyBundleAndDeferCallback <: BundleAndDeferCallback {
    public override func getBundleAndDeferMillis(bundleAndDefer:BundleAndDefer):Duration {
        return Duration.second*0;
    }
}
public func getStaxXmlPullParser(xmppXmlString:String):XmlPullParser{
    let ByteBuffer:ByteBuffer = ByteBuffer()
    ByteBuffer.write(xmppXmlString.toArray())
    var staxXmlPullParserFactory =StaxXmlPullParserFactory()
    return staxXmlPullParserFactory.newXmlPullParser(ByteBuffer)
}
public func getStanzaMessageSetFrom(jid:?String):Stanza{
    var stanza= StanzaBuilder.buildMessage().build()
    if(!jid.isNone()){
        stanza.setFrom(JidCreate.froms(jid.getOrThrow()))
    }
    return  stanza;
}
public func getStanzaMessageSetTo(jid:?String):Stanza{
    var stanza= StanzaBuilder.buildMessage().build()
    if(!jid.isNone()){
        stanza.setTo(JidCreate.froms(jid.getOrThrow()))
    }
    return  stanza;
}
public func getStanzaUnparsedIQaddExtension(extensionElement:?ExtensionElement):Stanza{
    var stanza=UnparsedIQ("UnparsedIQelement","UnparsedIQnamespace","UnparsedIQcontent")
    if(!extensionElement.isNone()){
        stanza.addExtension(extensionElement.getOrThrow())
    }
    return  stanza;
}
public func getStanzaUnparsedIQSetType(iqType:?IQType) :Stanza {
    var stanza=UnparsedIQ("UnparsedIQelement","UnparsedIQnamespace","UnparsedIQcontent");
    if(!iqType.isNone()){
        stanza.setType(iqType.getOrThrow());
    }
    return  stanza;
}

