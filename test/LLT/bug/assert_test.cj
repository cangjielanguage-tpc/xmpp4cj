// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func assertTest(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setXmppAddressAndPassword("1@xmpp.testserver", "123456") //           "test@xmpp.testserver", "123456"
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .performSaslAnonymousAuthentication()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)

    let connection = XMPPTCPConnection(configBuilder.build())

    connection.connect()

    connection.login()
    println("${connection.isConnected()} ${connection.isAuthenticated()}")
}
