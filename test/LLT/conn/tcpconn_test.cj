// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*

@Test
func conn_test1(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setUsernameAndPassword("user1", "user1")
        // .setResource("jtest")
        .setXmppDomain(XmppTestServerHostName)
        // .setHost("10.56.237.54")
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        // .setConnectTimeout(1000)
        // .setDebuggerFactory(ConsoleDebugger.Factory.INSTANCE)
        // .setSendPresence(false)
        // .setCompressionEnabled(false)
        // .setSslContextFactory(() -> { return context; })
        // .setCustomX509TrustManager(new SparkTrustManager())
        // .enableDefaultDebugger()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connection = XMPPTCPConnection(configBuilder.build())
    connection.connect()
    // connection.login()
}
