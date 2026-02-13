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
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .performSaslAnonymousAuthentication()
        // .enableDefaultDebugger()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connection = XMPPTCPConnection(configBuilder.build())
    connection.connect()
    connection.login()
    println("${connection.isConnected()} ${connection.isAuthenticated()}")
}
