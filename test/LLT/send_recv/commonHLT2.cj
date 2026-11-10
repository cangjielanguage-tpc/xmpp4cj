import std.time.*
import xmpp4cj.compress.*
import xmpp4cj.compression.*
import xmpp4cj.connection.*
import xmpp4cj.feature.*
import xmpp4cj.filter.*
import xmpp4cj.jid.*
import xmpp4cj.modular.*
import xmpp4cj.packet.*
import xmpp4cj.provider.*
import xmpp4cj.proxy.*
import xmpp4cj.sasl.*
import xmpp4cj.stream.*
import xmpp4cj.tcp.*
import xmpp4cj.util.*
import xmpp4cj.xml.*
import std.sync.SyncCounter
import std.regex.*

// let XmppTestServerHostName = "xmpp.testserver"

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
    }
}
//验证链接,登录,断开链接之间的报文发送回执情况---用户名密码登录
public func verifyFuncLoginWithName(name:String,logContent:StringBuilder){
    //login触发发送iq报文,用户名密码登录,用户名匹配
    var iq01="<iq xmlns='jabber:client' to='xmpp.testserver/.*' id='.*' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>${name}@xmpp.testserver/.*</jid></bind></iq>"
    var matcherCur01 = Regex(iq01).matcher(logContent.toString())
    @Assert(matcherCur01.allCount(),1)
    //login触发发送presence报文,用户名密码登录,用户名匹配
    var presenceRegex01="<presence xmlns='jabber:client' xml:lang='zh-CN' to='${name}@xmpp.testserver/.*' from='${name}@xmpp.testserver/.*' id='.*'/>"
    var matcherCur02 = Regex(presenceRegex01).matcher(logContent.toString())
    @Assert(matcherCur02.allCount(),1)
    //disconnect触发发送报文,用户名密码登录,用户名匹配
    var presenceRegex02="<presence xmlns='jabber:client' xml:lang='zh-CN' to='${name}@xmpp.testserver/.*' from='${name}@xmpp.testserver/.* id=.*' type='unavailable'/>"
    var matcherCur03 = Regex(presenceRegex02).matcher(logContent.toString())
    @Assert(matcherCur03.allCount(),1)
}
//验证链接,登录,断开链接之间的报文发送回执情况---匿名登录
public func verifyFuncLoginNoName(logContent:StringBuilder){
    //login触发发送iq报文,匿名登录,用户名随机分配,不匹配
    var iq01="<iq xmlns='jabber:client' to='xmpp.testserver/.*' id='.*' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>.*@xmpp.testserver/.*</jid></bind></iq>"
    var matcherCur01 = Regex(iq01).matcher(logContent.toString())
    @Assert(matcherCur01.allCount(),1)
    //login触发发送presence报文 ,匿名登录,用户名随机分配,不匹配
    var presenceRegex01="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.*' id='.*'/>"
    var matcherCur02 = Regex(presenceRegex01).matcher(logContent.toString())
    @Assert(matcherCur02.allCount(),1)
    //disconnect触发发送报文 ,匿名登录,用户名随机分配,不匹配
    var presenceRegex02="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.* id=.*' type='unavailable'/>"
    var matcherCur03 = Regex(presenceRegex02).matcher(logContent.toString())
    @Assert(matcherCur03.allCount(),1)
}