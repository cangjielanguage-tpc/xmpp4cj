// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj --test
// EXEC: ./main 
//--filter=*.*
import cangjie_tpc::xmpp4cj.connection.*
import cangjie_tpc::xmpp4cj.tcp.*

@Test
func conn_test1(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setUsernameAndPassword("user1", "user1")
        .setResource("cangjie")
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        // .setXmppDomain(XmppTestServerHostName)
        // .setHost("10.56.237.54")
        // .setXmppDomain("iss")
        // .setHost("172.23.160.1")
        .setPort(5222)
        .setConnectTimeout(Duration.second * 10)
        // .setDebuggerFactory(ConsoleDebugger.Factory.INSTANCE)
        // .setSendPresence(false)
        .setCompressionEnabled(true)
        // .setSslContextFactory(() -> { return context; })
        // .setCustomX509TrustManager(new SparkTrustManager())
        .enableDefaultDebugger()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connection = XMPPTCPConnection(configBuilder.build())
    connection.setReplyTimeout(Duration.second * 10)
    println("0.1 ${connection.isConnected()}, ${connection.isAuthenticated()}")
    connection.connect()
    println("0.2 ${connection.isConnected()}, ${connection.isAuthenticated()}")
    connection.login()
    println("0.3 ${connection.isConnected()}, ${connection.isAuthenticated()}")
    sleep(Duration.second * 10)
    connection.disconnect()
}
