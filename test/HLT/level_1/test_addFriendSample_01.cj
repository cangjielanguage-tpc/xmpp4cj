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
    @TestCase
    func test_addFriend_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)

        var conn1= getConn()
        var conn2= getConn()
        conn1.connect() // 连接
        conn2.connect() // 连接
        //注册friend01
        var iqregister01=ElementRegister01()
        conn1.sendStanza(iqregister01)
        //注册friend02
        var iqregister02=ElementRegister02()
        conn2.sendStanza(iqregister02)

        conn1.login("friend01", "123456")
        conn2.login("friend02", "123456")
        var lisener01=StanzaListener1(syncCounter, conn1)
        var lisener02=StanzaListener1(syncCounter, conn1)
        conn1.addSyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))
        conn2.addSyncStanzaListener(lisener02, StanzaTypeFilter<Stanza>("Stanza"))
        //friend01添加好友 friend02
        var iq01=ElementAddFriend()
        conn1.sendStanza(iq01)
        //friend01添加成功后查询
        var iq03=ElementListFriend()
        conn1.sendStanza(iq03)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        //friend01查询成功后删除好友
        var iq02=ElementRemoveFriend()
        conn1.sendStanza(iq02)
        //friend01删除成功后查询
        conn1.sendStanza(iq03)
        syncCounter.waitUntilZero(timeout: Duration.second * 2)

        var iqremove=ElementUnRegister()
        conn1.sendStanza(iqremove)
        conn2.sendStanza(iqremove)
        conn1.disconnect() // 从服务器断开连接
        conn2.disconnect() // 从服务器断开连接
        verifySendContent(lisener01.logContent,"friend01","friend02")
    }
    func getConn():XMPPTCPConnection{
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
            .setPort(5222) // 设置端口号
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return conn1
    }
    func verifySendContent(listener:StringBuilder,curUser:String,addUser:String){
        //添加成功消息响应
        //删除好友成功的响应相同,故这里断言两条
        var msgRegex01="<iq xmlns='jabber:client' to='${curUser}@xmpp.testserver/.*' from='${curUser}@xmpp.testserver' type='result'></iq>"
        var matcherMag01 = Regex(msgRegex01).matcher(listener.toString())
        @Assert(matcherMag01.allCount(),3)
        //添加后查询到好友响应
        //<iq xmlns='jabber:client' to='friend01@xmpp.testserver/08b04c5c-1c3e-4f8a-b7e1-4858a0e520b7' type='result'><query xmlns='jabber:iq:roster'>&lt;query xmlns=&apos;jabber:iq:roster&apos; ver=&apos;2136287787&apos;&gt;&lt;item jid=&apos;friend02@xmpp.testserver&apos; subscription=&apos;none&apos;/&gt;&lt;/query&gt;</query></iq>
        var msgRegex02="<iq xmlns='jabber:client' to='${curUser}@xmpp.testserver/.*' type='result'><query xmlns='jabber:iq:roster'>&lt;query xmlns=&apos;jabber:iq:roster&apos; ver=.*item jid=&apos;${addUser}@xmpp.testserver.*</iq>"
        var matcherMag02 = Regex(msgRegex02).matcher(listener.toString())
        @Assert(matcherMag02.allCount(),1)
        //删除后查询到好友响应 ,只能同时匹配到两条查询回执，正则精确匹配不了
        var msgRegex03="<iq xmlns='jabber:client' to='${curUser}@xmpp.testserver/.*' type='result'><query xmlns='jabber:iq:roster'>&lt;query xmlns=&apos;jabber:iq:roster&apos; ver=.*</query></iq>"
        var matcherMag03 = Regex(msgRegex03).matcher(listener.toString())
        var res=matcherMag03.findAll().getOrThrow()
        @Assert(res.size,2)
        @Assert(res[0].matchString().contains("${addUser}@xmpp.testserver"),true)
        @Assert(res[1].matchString().contains("${addUser}@xmpp.testserver"),false)
    }

}

//注册
class ElementRegister01 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>friend01</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
class ElementRegister02 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>friend02</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}


//用户添加联系人
class ElementAddFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return '<iq xmlns="jabber:client"  type="set"><query xmlns="jabber:iq:roster"><item jid="friend02@xmpp.testserver"></item></query></iq>'
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
//删除联系人
class ElementRemoveFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return '<iq xmlns="jabber:client" type="set"><query xmlns="jabber:iq:roster"><item jid="friend02@xmpp.testserver" subscription="remove" /></query></iq>'
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}
//查询联系人列表
class ElementListFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' type='get'><query xmlns='jabber:iq:roster'/></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}

