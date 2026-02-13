// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main 
import std.sync.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.feature.*
import cangjie_tpc::xmpp4cj.filter.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.packet.*
import cangjie_tpc::xmpp4cj.tcp.*

func getConn(): XMPPTCPConnection {
    // Debugger立即打印报文
    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain('xmpp.testserver') // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .enableDefaultDebugger() // 打开debug 观察报文交互
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()
    conn.login("5","123456")
    conn
}

/*当前未实现roster模块 仅用报文模拟roster流程*/
@Test
func roster() {
    let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain('xmpp.testserver') // 替换为有效的XmppDomain
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .build()
    let conn = getConn()

    conn.sendStanza(ElementAddFriend()) // 添加联系人
    conn.sendStanza(ElementListFriend()) // 查询联系人
    conn.sendStanza(ElementRemoveFriend()) // 删除联系人
    conn.sendStanza(ElementListFriend()) // 查询联系人
    sleep(Duration.second) // 等待1s从debuger日志可以看到roster交互报文
}

//添加联系人
class ElementAddFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' id='1' type='set'><query xmlns='jabber:iq:roster'><item jid='asd@xmpp.testserver'></item></query></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return 'iq'
    }
}
//查询联系人列表
class ElementListFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' id='2' type='get'><query xmlns='jabber:iq:roster'/></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return 'iq'
    }
}
//删除联系人
class ElementRemoveFriend <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq xmlns='jabber:client' id='3' type='set'><query xmlns='jabber:iq:roster'><item jid='asd@xmpp.testserver' subscription='remove' /></query></iq>"
    }
    public override func toString(): String {
        return toXML().toString()
    }
    public override func getElementName(): String {
        return 'iq'
    }
}
