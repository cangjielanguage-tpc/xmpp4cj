// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.filter.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter

@Test
public class TestUser{
    //双方变更状态交互：PresenceMode:chat/available/away/xa/dnd,验证报文的发送情况
    @TestCase
    func test_updateUserStatus02_01(): Unit {
        let listner01=testPresence(PresenceMode.away)
        verifyFuncLoginNoName(listner01)
        var presenceRegex03="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.*'><status>I&apos;ll be away for a while.</status><show>away</show></presence>"
        var matcherCur04 = Regex(presenceRegex03).matcher(listner01.toString())
        @Assert(matcherCur04.allCount(),1)
    }
    @TestCase
    func test_updateUserStatus02_02(): Unit {
        let listner01=testPresence(PresenceMode.chat)
        verifyFuncLoginNoName(listner01)
        var presenceRegex03="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.*'><status>I&apos;ll be away for a while.</status><show>chat</show></presence>"
        var matcherCur04 = Regex(presenceRegex03).matcher(listner01.toString())
        @Assert(matcherCur04.allCount(),1)
    }
    @TestCase
    func test_updateUserStatus02_03(): Unit {
        let listner01=testPresence(PresenceMode.available)
        verifyFuncLoginNoName(listner01)
        var presenceRegex03="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.*'><status>I&apos;ll be away for a while.</status></presence>"
        var matcherCur04 = Regex(presenceRegex03).matcher(listner01.toString())
        @Assert(matcherCur04.allCount(),1)
    }
    @TestCase
    func test_updateUserStatus02_04(): Unit {
        let listner01=testPresence(PresenceMode.xa)
        verifyFuncLoginNoName(listner01)
        var presenceRegex03="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.*'><status>I&apos;ll be away for a while.</status><show>xa</show></presence>"
        var matcherCur04 = Regex(presenceRegex03).matcher(listner01.toString())
        @Assert(matcherCur04.allCount(),1)
    }
    @TestCase
    func test_updateUserStatus02_05(): Unit {
        let listner01=testPresence(PresenceMode.dnd)
        verifyFuncLoginNoName(listner01)
        var presenceRegex03="<presence xmlns='jabber:client' xml:lang='zh-CN' to='.*@xmpp.testserver/.*' from='.*@xmpp.testserver/.*'><status>I&apos;ll be away for a while.</status><show>dnd</show></presence>"
        var matcherCur04 = Regex(presenceRegex03).matcher(listner01.toString())
        @Assert(matcherCur04.allCount(),1)
    }
}

func testPresence(mode:PresenceMode): StringBuilder{
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
    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(mode)
        .build()
    conn1.sendStanza(presence) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 2)
    conn1.disconnect() // 从服务器断开连接
    return listner01.logContent
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
