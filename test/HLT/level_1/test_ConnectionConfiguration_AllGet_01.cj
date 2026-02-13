// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import cangjie_tpc::xmpp4cj.feature.*
import std.time.*
import std.net.*
import stdx.net.tls.*
import std.fs.*
import std.io.*
import stdx.log.*
import std.sync.SyncCounter
var caseNum=0
@Test
public class TestConnectionConfiguration{
    let XmppTestServerHostName="xmpp.testserver"
    @TestCase
    func test_AllGet_connectLoginByNameWithPassword_01(): Unit {
        var tmp=getConnection()
        var conn=tmp[0]
        var connectionConfiguration=tmp[1]
        @Assert(connectionConfiguration.getHostString(),XmppTestServerHostName)
        @Assert(connectionConfiguration.getHost().isNone(),true)
        @Assert(connectionConfiguration.getHostAddress().isNone(),true)
        @Assert(connectionConfiguration.getPort(),UInt16(5222))
        @Assert(connectionConfiguration.getXMPPServiceDomain(),JidCreate.domainBareFrom(XmppTestServerHostName))
        @Assert(connectionConfiguration.getXmppServiceDomainAsDnsNameIfPossible(),XmppTestServerHostName)
        @Assert(connectionConfiguration.getSecurityMode(),ConnectionConfigurationSecurityMode.disabled)
        @Assert(connectionConfiguration.getDnssecMode(),DnssecMode.disabled)
        @Assert(connectionConfiguration.getTlsClientConfig().isNone(),true)
        @Assert(connectionConfiguration.getDebuggerFactory().isNone(),true)
        @Assert(connectionConfiguration.getSocketFactory().isNone(),true)
        @Assert(connectionConfiguration.getCallbackHandler().isNone(),true)
        @Assert(connectionConfiguration.getProxyInfo().isNone(),true)
        @Assert(connectionConfiguration.getUsername().isNone(),true)
        @Assert(connectionConfiguration.getPassword().isNone(),true)
        @Assert(connectionConfiguration.getResource().isNone(),true)
        @Assert(connectionConfiguration.getLanguage(),"zh_CN")
        @Assert(connectionConfiguration.getAuthzid().isNone(),true)
        @Assert(connectionConfiguration.isSendPresence(),true)
        @Assert(connectionConfiguration.isCompressionEnabled(),false)
        @Assert(connectionConfiguration.isEnabledSaslMechanism("CRAM-MD5"),true)
        @Assert(connectionConfiguration.getEnabledSaslMechanisms().isNone(),true)
        @Assert(connectionConfiguration.constructStanzaIdSource().getNewStanzaId().getOrThrow().isEmpty(),false)
        @Assert(connectionConfiguration.getXmlLang(),"zh-CN")
        conn.disconnect()
    }
    @TestCase
    func test_AllGet_connectLoginByNameWithPassword_03(): Unit {
        var tmp=getConnection()
        var conn=tmp[0]
        var connectionConfiguration=tmp[1]
        conn.connect()
        var iq01=ElementRegister1()
        conn.sendStanza(iq01)
        conn.login("test1","123456")
        @Assert(connectionConfiguration.getHostString(),XmppTestServerHostName)
        @Assert(connectionConfiguration.getHost().isNone(),true)
        @Assert(connectionConfiguration.getHostAddress().isNone(),true)
        @Assert(connectionConfiguration.getPort(),UInt16(5222))
        @Assert(connectionConfiguration.getXMPPServiceDomain(),JidCreate.domainBareFrom(XmppTestServerHostName))
        @Assert(connectionConfiguration.getXmppServiceDomainAsDnsNameIfPossible(),XmppTestServerHostName)
        @Assert(connectionConfiguration.getSecurityMode(),ConnectionConfigurationSecurityMode.disabled)
        @Assert(connectionConfiguration.getDnssecMode(),DnssecMode.disabled)
        @Assert(connectionConfiguration.getTlsClientConfig().isNone(),true)
        @Assert(connectionConfiguration.getDebuggerFactory().isNone(),true)
        @Assert(connectionConfiguration.getSocketFactory().isNone(),true)
        @Assert(connectionConfiguration.getCallbackHandler().isNone(),true)
        @Assert(connectionConfiguration.getProxyInfo().isNone(),true)
        @Assert(connectionConfiguration.getUsername().isNone(),true)
        @Assert(connectionConfiguration.getPassword().isNone(),true)
        @Assert(connectionConfiguration.getResource().isNone(),true)
        @Assert(connectionConfiguration.getLanguage(),"zh_CN")
        @Assert(connectionConfiguration.getAuthzid().isNone(),true)
        @Assert(connectionConfiguration.isSendPresence(),true)
        @Assert(connectionConfiguration.isCompressionEnabled(),false)
        @Assert(connectionConfiguration.isEnabledSaslMechanism("CRAM-MD5"),true)
        @Assert(connectionConfiguration.getEnabledSaslMechanisms().isNone(),true)
        @Assert(connectionConfiguration.constructStanzaIdSource().getNewStanzaId().getOrThrow().isEmpty(),false)
        @Assert(connectionConfiguration.getXmlLang(),"zh-CN") 
        var iq02=ElementUnRegister()
        conn.sendStanza(iq02)
        conn.disconnect()
    }
    func getConnection():(XMPPTCPConnection,XMPPTCPConnectionConfiguration){
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return  (conn1,config1)
    }
}
//定义查询当前用户添加联系人
class ElementRegister1 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq type='set'><query xmlns='jabber:iq:register'><username>test1</username><password>123456</password></query></iq>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}


