// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

import stdx.net.tls.*

@Test
public func test_ConnectionConfiguration1(): Unit {
    let connectionConfigurationSecurityMode1 = ConnectionConfigurationSecurityMode.required
    let connectionConfigurationSecurityMode2 = ConnectionConfigurationSecurityMode.ifpossible
    let connectionConfigurationSecurityMode3 = ConnectionConfigurationSecurityMode.disabled
    @Assert(true, connectionConfigurationSecurityMode1 == connectionConfigurationSecurityMode1)
    @Assert(true, connectionConfigurationSecurityMode2 == connectionConfigurationSecurityMode2)
    @Assert(true, connectionConfigurationSecurityMode3 == connectionConfigurationSecurityMode3)
    @Assert("required", connectionConfigurationSecurityMode1.toString())
    @Assert("ifpossible", connectionConfigurationSecurityMode2.toString())
    @Assert("disabled", connectionConfigurationSecurityMode3.toString())
    @Assert(false, connectionConfigurationSecurityMode1 == connectionConfigurationSecurityMode3)
}

class SASLMechanismExternal <: SASLMechanism {
    protected func authenticateInternal(cbh: ?CallbackHandler): Unit {
        throw Exception()
    }
    protected func getAuthenticationText(): ?Array<Byte> {
        throw Exception()
    }
    public func getName(): String {
        return SASLMechanism.EXTERNAL
    }
    public func getPriority(): Int {
        return 0
    }
    protected func checkIfSuccessfulOrThrow(): Unit {
    }
    protected func newInstance(): SASLMechanism {
        throw Exception()
    }
}

@Test
public func test2(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    config.getTlsClientConfig()
    config.getEnabledSaslMechanisms()
    XmppConfiguration.DEBUG = true
    let c1 = XMPPTCPConnectionConfiguration.builder()
    c1.setCallbackHandler({a => ()})
    c1.setTlsClientConfig(TlsClientConfig())
    c1.setSocketFactory(SocketFactory.DEFAULT)
    @AssertThrows[IllegalArgumentException](c1.performSaslExternalAuthentication(TlsClientConfig()))

    let mechanism = SASLMechanismExternal()
    SASLAuthentication.registerSASLMechanism(mechanism)
    c1.performSaslExternalAuthentication(TlsClientConfig())
}
