// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main 
import std.sync.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.tcp.*

@Test
func account(): Unit {
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain("xmpp.testserver") // 替换为有效的XmppDomain
        .setHost("xmpp.testserver") // 替换为有效的Xmpp服务器域名或ip
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()

    /*当前无完整的用户模块 仅用报文模拟注册注销*/

    // 注册用户
    var reg = Register()
    conn.sendStanza(reg)
    // 登录
    conn.login("user00001", "123456")
    // 注销用户
    var unreg = UnRegister()
    conn.sendStanza(unreg)

    conn.disconnect() // 从服务器断开连接
}

// 注册账户
class Register <: Stanza {
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

// 注销账户
class UnRegister <: Stanza {
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