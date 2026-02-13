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
    func test_AllGet_02(): Unit {
        var tmp=getConnection()
        var conn=tmp[0]
        var connectionConfiguration=tmp[1]
        conn.connect()
        conn.login()
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
        @Assert(connectionConfiguration.isEnabledSaslMechanism("CRAM-MD5"),false)
        var EnabledSaslMechanisms=connectionConfiguration.getEnabledSaslMechanisms().getOrThrow()
        @Assert(EnabledSaslMechanisms.size,1)
        @Assert(EnabledSaslMechanisms.contains("ANONYMOUS"),true)
        @Assert(connectionConfiguration.constructStanzaIdSource().getNewStanzaId().getOrThrow().isEmpty(),false)
        @Assert(connectionConfiguration.getXmlLang(),"zh-CN") 
        conn.disconnect()
    }
    func getConnection():(XMPPTCPConnection,XMPPTCPConnectionConfiguration){
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        return  (conn1,config1)
    }
}

