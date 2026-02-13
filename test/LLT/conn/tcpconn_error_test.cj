// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 

import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*
import std.net.*

// 连接超时
@Test
func comm_test1(): Unit {
    let iplist: Array<IPAddress> = IPAddress.resolve(XmppTestServerHostName)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setConnectTimeout(Duration.nanosecond * 1)
        .setHost(XmppTestServerHostName) // 设置提供XMPP服务的主机的名称
        .setPort(8888) // 设置端口号
        .setSecurityMode(ConnectionConfigurationSecurityMode.required) // 设置建立连接时使用的TLS安全模式
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let conn: XMPPTCPConnection = XMPPTCPConnection(config)
    let e: EndpointConnectionException = @AssertThrows[EndpointConnectionException](conn.connect())
    // @Assert("SocketTimeoutException: Failed to connect: connect timeout.", e.toString())
}

