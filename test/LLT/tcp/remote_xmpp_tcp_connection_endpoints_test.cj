/// DEPENDENCE: ../z_test.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj --test
/// EXEC: ./main 
/* TODO */

// RemoteXmppTcpConnectionEndpointsDomainType 枚举不是 public

@Test
public class RemoteXmppTcpConnectionEndpointsTest {
    @TestCase
    public func simpleDomainTypeTest() {
        let client: RemoteXmppTcpConnectionEndpointsDomainType = RemoteXmppTcpConnectionEndpointsDomainType.client
        assertEquals(RemoteXmppTcpConnectionEndpoints.XMPP_CLIENT_DNS_SRV_PREFIX, client.toString())

        let server: RemoteXmppTcpConnectionEndpointsDomainType = RemoteXmppTcpConnectionEndpointsDomainType.server
        assertEquals(RemoteXmppTcpConnectionEndpoints.XMPP_SERVER_DNS_SRV_PREFIX, server.toString())
    }
}
