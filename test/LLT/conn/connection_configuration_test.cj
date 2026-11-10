// DEPENDENCE: ../z_test.cj ../jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main 

@Test
public class ConnectionConfigurationTest {
    @TestCase
    public func setIp() {
        let builder: DummyConnectionConfigurationBuilder = newUnitTestBuilder()
        let ip: String = "192.168.0.1"
        builder.setHost(ip)
        let connectionConfiguration: DummyConnectionConfiguration = builder.build()
        let str = connectionConfiguration.getHostAddress().getOrThrow().toString()
        println(str)
        // 对标库是"/${ip}",标准库和对标库解析不同导致的
        assertEquals("${ip}", str)
    }

    @TestCase
    public func setFqdn() {
        let builder: DummyConnectionConfigurationBuilder = newUnitTestBuilder()
        let fqdn: String = "foo.example.org"
        builder.setHost(fqdn)
        let connectionConfiguration: DummyConnectionConfiguration = builder.build()
        let str = connectionConfiguration.getHost().getOrThrow().toString()
        assertEquals(fqdn, str)
    }

    private static func newUnitTestBuilder(): DummyConnectionConfigurationBuilder {
        let builder: DummyConnectionConfigurationBuilder = DummyConnectionConfigurationBuilder()
        builder.setXmppDomain(JidTestUtil.DOMAIN_BARE_JID_1)
        return builder
    }
}

private class DummyConnectionConfiguration <: ConnectionConfiguration {
    protected init(builder: DummyConnectionConfigurationBuilder) {
        super(builder)
    }

    public static func builder(): DummyConnectionConfigurationBuilder {
        return DummyConnectionConfigurationBuilder()
    }
}

private class DummyConnectionConfigurationBuilder <: ConnectionConfigurationBuilder {
    public override func build(): DummyConnectionConfiguration {
        return DummyConnectionConfiguration(this)
    }

}
