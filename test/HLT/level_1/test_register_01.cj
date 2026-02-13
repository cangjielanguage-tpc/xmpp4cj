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
    //建立链接，注册用户，登录用户，注销用户
    @TestCase
    func test_Register_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect() // 连接
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口      //StanzaTypeFilter<Message>.MESSAGE
        
        //注册用户
        var iq01=ElementRegister()
        conn1.sendStanza(iq01)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        verifyRegister(lisener01.logContent)
        //登录
        conn1.login("user00001", "123456")
        verifyLogin(lisener01.logContent,"user00001")
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        //注销用户
        var iq02=ElementUnRegister()
        conn1.sendStanza(iq02)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        verifyUnregister(lisener01.logContent,"user00001")
        conn1.disconnect() // 从服务器断开连接
    }
    func verifyRegister(listener:StringBuilder){
        //注册成功的响应
        var msgRegex01="<iq xmlns='jabber:client' to='xmpp.testserver/.*' from='xmpp.testserver' type='result'></iq>"
        var matcherMag01 = Regex(msgRegex01).matcher(listener.toString())
        @Assert(matcherMag01.allCount(),1)
    }

    func verifyLogin(listener:StringBuilder,curUser:String){
        //登录成功的报文
        //<iq xmlns='jabber:client' to='xmpp.testserver/0633fc1a-a8df-4c0a-a227-60cc81c64b44' id='6H8YF-3' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>user00001@xmpp.testserver/0633fc1a-a8df-4c0a-a227-60cc81c64b44</jid></bind></iq>
        var msgRegex02="<iq xmlns='jabber:client' to='xmpp.testserver/.*' id='.*' type='result'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><jid>${curUser}@xmpp.testserver/.*</jid></bind></iq>"
        var matcherMag02 = Regex(msgRegex02).matcher(listener.toString())
        @Assert(matcherMag02.allCount(),1)
    }

    func verifyUnregister(listener:StringBuilder,curUser:String){
        //注销成功
        //<iq xmlns='jabber:client' to='user00001@xmpp.testserver/8460739e-f721-4d62-a247-7a3d566541ba' from='user00001@xmpp.testserver' type='result'></iq>
        var msgRegex03="<iq xmlns='jabber:client' to='${curUser}@xmpp.testserver/.*' from='${curUser}@xmpp.testserver' type='result'></iq>"
        var matcherMag03 = Regex(msgRegex03).matcher(listener.toString())
        @Assert(matcherMag03.allCount(),1)
    }
}

//定义查询当前用户添加联系人
class ElementRegister <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>user00001</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}


