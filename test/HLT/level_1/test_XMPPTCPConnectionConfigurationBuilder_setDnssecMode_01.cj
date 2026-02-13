// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import cangjie_tpc::xmpp4cj.jid.*
import std.time.*

@Test
public class TestXMPPTCPConnectionConfigurationBuilder{
    let XmppTestServerHostName = "xmpp.testserver"
    @TestCase
    func test_setDnssecMode_01(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setDnssecMode(DnssecMode.disabled)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),true)
        connection.disconnect()
    }
    @TestCase
    func test_setDnssecMode_02(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        var tlsConfig=TlsClientConfig()
        tlsConfig.verifyMode=CertificateVerifyMode.TrustAll
        configBuilder.setXmppDomain(XmppTestServerHostName)
                    .setDnssecMode(DnssecMode.disabled)
                    .setTlsClientConfig(tlsConfig)
                    .performSaslAnonymousAuthentication()
                    .setSecurityMode(ConnectionConfigurationSecurityMode.required)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),true)
        @Assert(connection.isSecureConnection(),true)
        connection.disconnect()
    }
    @TestCase
    func test_setDnssecMode_04(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        var tlsConfig=TlsClientConfig()
        tlsConfig.verifyMode=CertificateVerifyMode.TrustAll
        configBuilder.setXmppDomain(XmppTestServerHostName)
        .setDnssecMode(DnssecMode.disabled)
        .setTlsClientConfig(tlsConfig)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.ifpossible)
        let connection = XMPPTCPConnection(configBuilder.build())
        connection.connect()
        connection.login()
        @Assert(connection.isConnected(),true)
        @Assert(connection.isAuthenticated(),true)
        @Assert(connection.isSecureConnection(),true)
        connection.disconnect()
    }
    @Skip  //标准库bug
    @TestCase
    func test_setDnssecMode_03(): Unit {
        let configBuilder = XMPPTCPConnectionConfiguration.builder()
        configBuilder.setXmppDomain(XmppTestServerHostName)
                    .setDnssecMode(DnssecMode.disabled)
                    .performSaslAnonymousAuthentication()
                    .setSecurityMode(ConnectionConfigurationSecurityMode.required)
        let connection = XMPPTCPConnection(configBuilder.build())
        try{
            connection.connect()
            @Assert(false)
        }catch(e:XmppWrappedException){
            println(e.toString())
            if(e.toString().contains("XmppWrappedException: TLS handshake failed (client): certificate verify failed (134), TLS alert unknown CA(F)")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }catch(e:Xmpp4cjException){
            println(e.toString())
            if(e.toString().contains("Xmpp4cjException: No response received within reply timeout")){
                @Assert(true)
            }else{
                @Assert(false)
            }
        }
    }
}

