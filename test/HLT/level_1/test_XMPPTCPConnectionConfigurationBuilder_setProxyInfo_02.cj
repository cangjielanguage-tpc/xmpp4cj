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
    func test_setProxyInfo_03(): Unit {
        let port: UInt16 = 1082  //其他端口,非正常端口
        let proxyInfo: ProxyInfo = ProxyInfo.forSocks4Proxy("xmpp.testserver", port, "", "")
        let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName)
            .setProxyInfo(proxyInfo) // 设置代理
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
            .build()
        var connection: AbstractXMPPConnection = XMPPTCPConnection(config)
        let e:EndpointConnectionException=@AssertThrows[EndpointConnectionException](connection.connect())
        @Assert(e.toString().contains("The following addresses failed: 'RFC 6120 A/AAAA Endpoint"),true)
    }
}

