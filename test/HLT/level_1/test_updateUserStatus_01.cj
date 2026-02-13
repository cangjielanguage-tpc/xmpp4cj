// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.sasl.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.packet.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestUser{
    //只是建立连接,不登录
    @TestCase
    func test_updateUserStatus01_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config)
        var listner01= StanzaListener1(syncCounter,conn1)
        conn1.addSyncStanzaListener(listner01,  StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn1.connect() // 连接
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var iq01="<iq xmlns='jabber:client' to='xmpp.testserver/.*' id='.*-1' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>user1@xmpp.testserver/.*</jid></bind></iq>"
        var matcherCur01 = Regex(iq01).matcher(listner01.logContent.toString())
        @Assert(matcherCur01.allCount(),0)
        var presenceRegex01="<presence xmlns='jabber:client' xml:lang='zh-CN' to='user1@xmpp.testserver/.*' from='user1@xmpp.testserver/.*' id='.*'/>"
        var matcherCur02 = Regex(presenceRegex01).matcher(listner01.logContent.toString())
        @Assert(matcherCur02.allCount(),0)
        var presenceRegex02="<presence xmlns='jabber:client' xml:lang='zh-CN' to='user1@xmpp.testserver/.*' from='user1@xmpp.testserver/.* id=.*' type='unavailable'/>"
        var matcherCur03 = Regex(presenceRegex02).matcher(listner01.logContent.toString())
        @Assert(matcherCur03.allCount(),0)
    }
    //建立连接,实名登录
    @TestCase
    func test_updateUserStatus01_02(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config)
        var listner01= StanzaListener1(syncCounter,conn1)
        conn1.addSyncStanzaListener(listner01,  StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn1.connect() // 连接
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        conn1.login("testuser1","123456") // 登录
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.sendStanza(iq02)
        conn1.disconnect() // 从服务器断开连接
        verifyFuncLoginWithName("testuser1",listner01.logContent)
    }
    //建立连接,匿名登录

    @TestCase
    func test_updateUserStatus01_03(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .performSaslAnonymousAuthentication()
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config)
        var listner01= StanzaListener1(syncCounter,conn1)
        conn1.addSyncStanzaListener(listner01,  StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
        conn1.connect() // 连接
        conn1.login() // 登录
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        verifyFuncLoginNoName(listner01.logContent)
    }

    //建立连接,不存在的用户登录
    @TestCase
    func test_updateUserStatus01_04(): Unit {
        let syncCounter: SyncCounter = SyncCounter(1)
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config)
        var listner01= StanzaListener1(syncCounter,conn1)
        conn1.addSyncStanzaListener(listner01, StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口  //StanzaTypeFilter<Message>.MESSAGE   StanzaTypeFilter<Element>("Element")
        conn1.connect() // 连接
        let e:SASLErrorException=@AssertThrows[SASLErrorException](conn1.login("error01","error01"))
        @Assert(e.toString(),"SASLErrorException: SASLError using SCRAM-SHA-1: Some(not-authorized)")
        @Assert(e.message,"SASLError using SCRAM-SHA-1: Some(not-authorized)")
        
        var iq01="<iq xmlns='jabber:client' to='xmpp.testserver/.*' id='.*-1' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>error01@xmpp.testserver/.*</jid></bind></iq>"
        var matcherCur01 = Regex(iq01).matcher(listner01.logContent.toString())
        @Assert(matcherCur01.allCount(),0)
        var presenceRegex01="<presence xmlns='jabber:client' xml:lang='zh-CN' to='error01@xmpp.testserver/.*' from='error01@xmpp.testserver/.*' id='.*'/>"
        var matcherCur02 = Regex(presenceRegex01).matcher(listner01.logContent.toString())
        @Assert(matcherCur02.allCount(),0)
        var presenceRegex02="<presence xmlns='jabber:client' xml:lang='zh-CN' to='error01@xmpp.testserver/.*' from='error01@xmpp.testserver/.* id=.*' type='unavailable'/>"
        var matcherCur03 = Regex(presenceRegex02).matcher(listner01.logContent.toString())
        @Assert(matcherCur03.allCount(),0)
    }
}
//定义查询当前用户添加联系人
class ElementRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>testuser1</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
func verifyFuncLoginWithName(name:String,logContent:StringBuilder){
    var iq01="<iq xmlns='jabber:client' to='xmpp.testserver/.*' id='.*' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>${name}@xmpp.testserver/.*</jid></bind></iq>"
    var matcherCur01 = Regex(iq01).matcher(logContent.toString())
    @Assert(matcherCur01.allCount(),1)

    var presenceRegex01="<presence xmlns='jabber:client' xml:lang='zh-CN' to='${name}@xmpp.testserver/.*' from='${name}@xmpp.testserver/.*' id='.*1'/>"
    var matcherCur02 = Regex(presenceRegex01).matcher(logContent.toString())
    @Assert(matcherCur02.allCount(),1)

    var presenceRegex02="<presence xmlns='jabber:client' xml:lang='zh-CN' to='${name}@xmpp.testserver/.*' from='${name}@xmpp.testserver/.* id=.*2' type='unavailable'/>"
    var matcherCur03 = Regex(presenceRegex02).matcher(logContent.toString())
    @Assert(matcherCur03.allCount(),0)
}
func verifyFuncLoginNoName(logContent:StringBuilder){
    var iq01="<iq xmlns='jabber:client' to='xmpp.testserver/.*' id='.*' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>.*@xmpp.testserver/.*</jid></bind></iq>"
    var matcherCur01 = Regex(iq01).matcher(logContent.toString())
    @Assert(matcherCur01.allCount(),1)

    var presenceRegex01="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.*' id='.*1'/>"
    var matcherCur02 = Regex(presenceRegex01).matcher(logContent.toString())
    @Assert(matcherCur02.allCount(),1)

    var presenceRegex02="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.* id=.*2' type='unavailable'/>"
    var matcherCur03 = Regex(presenceRegex02).matcher(logContent.toString())
    @Assert(matcherCur03.allCount(),1)
}

