// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXMPPConnection{
    @TestCase
    func test_nextResultBlockForever_01(): Unit {
        let res:Future<Int64>=spawn{  =>
            var stanzaCollector=getStanzaCollectorByFilterForClose()
            var flag=0
            stanzaCollector.nextResultBlockForever()
            flag=1
            return flag
        }
        let e:Exception=@AssertThrows[Exception](res.get(Duration.second*15))

        @Assert(e.toString(),"TimeoutException")
    }
    @TestCase
    func test_nextResultBlockForever_02(): Unit {
        let res:Future<Int64>=spawn{  =>
            var stanzaCollector=getStanzaCollectorBynewConfigurationForClose()
            var flag=0
            stanzaCollector.nextResultBlockForever()
            flag=1
            return flag
        }
        let e:Exception=@AssertThrows[Exception](res.get(Duration.second*15))
        @Assert(e.toString(),"TimeoutException")
    }
    @TestCase
    func test_nextResultBlockForever_03(): Unit {
        let res:Future<Int64>=spawn{  =>
            var stanzaCollector=getStanzaCollectorByFilter()
            var flag=0
            stanzaCollector.nextResultBlockForever()
            flag=1
            return flag
        }
        @Assert(res.get(Duration.second*3),1)
    }
    @TestCase
    func test_nextResultBlockForever_04(): Unit {
        let res:Future<Int64>=spawn{  =>
            var stanzaCollector=getStanzaCollectorBynewConfiguration()
            var flag=0
            stanzaCollector.nextResultBlockForever()
            flag=1
            return flag
        }
        @Assert(res.get(Duration.second*3),1)
    }


    func getStanzaCollectorByFilterForClose():StanzaCollector{
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
        conn1.login() // 登录

        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var stanzaCollector=conn1.createStanzaCollector(StanzaCollector.newConfiguration())
        return stanzaCollector
    }
    func getStanzaCollectorBynewConfigurationForClose():StanzaCollector{
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
        conn1.login() // 登录

        syncCounter.waitUntilZero(timeout: Duration.second * 2)
        conn1.disconnect() // 从服务器断开连接
        var stanzaCollector=conn1.createStanzaCollector(StanzaCollector.newConfiguration())
        return stanzaCollector
    }
}

