// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXMPPConnection{
    @TestCase
    func test_sendIqRequestAsync02_01(): Unit {
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        var lisener01=StanzaListener1(syncCounter, conn1)
        conn1.addAsyncStanzaListener(lisener01, StanzaTypeFilter<Stanza>("Stanza"))
        conn1.connect() // 连接
        conn1.login()
        var iqReply=conn1.sendIqRequestAsync(Session(),Duration.second*5)
        conn1.disconnect() // 从服务器断开连接
        try{
            var logContentCur=lisener01.logContent.toString()
            @Assert(logContentCur.contains(iqReply.get().toXML().toString()),true)
        }catch(e:IndexOutOfBoundsException) {}

    }
    @TestCase
    func test_sendIqRequestAsync02_02(): Unit { 
        let syncCounter: SyncCounter = SyncCounter(2)
        // 接收消息
        let config1: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
            .builder()
            .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
            .performSaslAnonymousAuthentication()
            .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
            .build()
        let conn1: XMPPTCPConnection = XMPPTCPConnection(config1)
        conn1.connect() // 连接
        conn1.login()
        var iqReply=conn1.sendIqRequestAsync(Session(),Duration.millisecond*0)
        let e:Exception=@AssertThrows[Exception](iqReply.get(Duration.second*0))
        @Assert(e.toString(),"TimeoutException")
        conn1.disconnect()
    }
}