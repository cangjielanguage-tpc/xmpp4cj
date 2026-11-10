// DEPENDENCE: ./commonHLT.cj ../log.cj ../z_test.cj
// EXEC: cjc %import-path %L %l %f log.cj z_test.cj commonHLT.cj --test
// EXEC: ./main 
//--filter=*.*
/// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
/// dependence: ../commonHLT.cj
/// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj

import xmpp4cj.connection.*
import xmpp4cj.tcp.*
import xmpp4cj.jid.*
import xmpp4cj.packet.*
import xmpp4cj.filter.*
import xmpp4cj.compression.*
import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter
import stdx.encoding.base64.*

@Test
public class TestUser {
    //双方变更状态，消息交互情况
    //发送对象在PresenceMode的各种情况下，是否能发送消息
    @TestCase
    func test_updateUserStatus04_01(): Unit {
        let tmp = testPresence(PresenceMode.away)
        let listner01 = tmp[0]
        let listner02 = tmp[1]
        var msgRegex01 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='12@xmpp.testserver' from='.*@xmpp.testserver/.*' type='chat'><body>message: userNoName@xmpp.testserver to 12@xmpp.testserver</body></message>"
        var matcherMag01 = Regex(msgRegex01).matcher(listner01.toString())
        @Assert(matcherMag01.allCount(),1)
        var msgRegex02 = "<message.*>"
        var matcherMag02 = Regex(msgRegex02).matcher(listner02.toString())
        @Assert(matcherMag02.allCount(),0)
    }
    @TestCase
    func test_updateUserStatus04_02(): Unit {
        let tmp = testPresence(PresenceMode.away)
        let listner01 = tmp[0]
        let listner02 = tmp[1]
        var msgRegex01 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='12@xmpp.testserver' from='.*@xmpp.testserver/.*' type='chat'><body>message: userNoName@xmpp.testserver to 12@xmpp.testserver</body></message>"
        var matcherMag01 = Regex(msgRegex01).matcher(listner01.toString())
        @Assert(matcherMag01.allCount(),1)
        var msgRegex02 = "<message.*>"
        var matcherMag02 = Regex(msgRegex02).matcher(listner02.toString())
        @Assert(matcherMag02.allCount(),0)
    }
    @TestCase
    func test_updateUserStatus04_03(): Unit {
        let tmp = testPresence(PresenceMode.available)
        let listner01 = tmp[0]
        let listner02 = tmp[1]
        var msgRegex01 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='12@xmpp.testserver' from='.*@xmpp.testserver/.*' type='chat'><body>message: userNoName@xmpp.testserver to 12@xmpp.testserver</body></message>"
        var matcherMag01 = Regex(msgRegex01).matcher(listner01.toString())
        @Assert(matcherMag01.allCount(),1)
        var msgRegex02 = "<message.*>"
        var matcherMag02 = Regex(msgRegex02).matcher(listner02.toString())
        @Assert(matcherMag02.allCount(),0)
    }
    @TestCase
    func test_updateUserStatus04_04(): Unit {
        let tmp = testPresence(PresenceMode.xa)
        let listner01 = tmp[0]
        let listner02 = tmp[1]
        var msgRegex01 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='12@xmpp.testserver' from='.*@xmpp.testserver/.*' type='chat'><body>message: userNoName@xmpp.testserver to 12@xmpp.testserver</body></message>"
        var matcherMag01 = Regex(msgRegex01).matcher(listner01.toString())
        @Assert(matcherMag01.allCount(),1)
        var msgRegex02 = "<message.*>"
        var matcherMag02 = Regex(msgRegex02).matcher(listner02.toString())
        @Assert(matcherMag02.allCount(),0)
    }
    @TestCase
    func test_updateUserStatus04_05(): Unit {
        let tmp = testPresence(PresenceMode.dnd)
        let listner01 = tmp[0]
        let listner02 = tmp[1]
        var msgRegex01 = "<message xmlns='jabber:client' xml:lang='zh-CN' to='12@xmpp.testserver' from='.*@xmpp.testserver/.*' type='chat'><body>message: userNoName@xmpp.testserver to 12@xmpp.testserver</body></message>"
        var matcherMag01 = Regex(msgRegex01).matcher(listner01.toString())
        @Assert(matcherMag01.allCount(),1)
        var msgRegex02 = "<message.*>"
        var matcherMag02 = Regex(msgRegex02).matcher(listner02.toString())
        @Assert(matcherMag02.allCount(),0)
    }
}
// 有限重试：connect+login 阶段可能因偶发网络抖动失败（读线程捕获连接错误后由 connect()/login() 同步抛出），
// 每次尝试新建连接确保状态干净，至多重试 3 次，间隔 1 秒
func connectAndLoginWithRetry(config: XMPPTCPConnectionConfiguration, username: String, password: String): XMPPTCPConnection {
    var lastError: Exception = Exception("connect failed")
    var retries = 0
    while (retries < 3) {
        let conn = XMPPTCPConnection(config)
        try {
            conn.connect() // 连接
            conn.login(username, password) // 登录
            return conn
        } catch (e: Exception) {
            lastError = e
            try {
                conn.disconnect() // 清理失败的连接
            } catch (_) {
                ()
            }
            sleep(Duration.second)
            retries = retries + 1
        }
    }
    throw lastError
}

// 动态等待：conn1 收到 Message 节时置零 SyncCounter，使 waitUntilZero 在消息到达瞬间返回（超时仅作兜底）
class MessageArrivedListener <: StanzaListener {
    var syncCounter: SyncCounter

    public init(syncCounter: SyncCounter) {
        this.syncCounter = syncCounter
    }

    public override func processStanza(packet: Stanza) {
        if (packet is Message) {
            syncCounter.dec()
        }
    }
}

//封装流程逻辑：只修改 PresenceMode
func testPresence0(mode: PresenceMode): (StringBuilder, StringBuilder) {
    let syncCounter: SyncCounter = SyncCounter(1)
    let config: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        .setCompressionEnabled(true)
        // .enableDefaultDebugger()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn1: XMPPTCPConnection = connectAndLoginWithRetry(config, "12", "123456") // 连接并登录（有限重试，避免偶发网络抖动）
    var listner01 = StanzaListener1(syncCounter, conn1)
    conn1.addSyncStanzaListener(listner01, StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口
    conn1.addSyncStanzaListener(MessageArrivedListener(syncCounter), StanzaTypeFilter<Stanza>("Stanza")) // 消息到达即置零计数器，实现动态等待

    let presence: Presence = PresenceBuilder
        .buildPresence()
        .setStatus("I'll be away for a while.")
        .setMode(mode)
        .build()
    conn1.sendStanza(presence) // 发送消息

    let config2: XMPPTCPConnectionConfiguration = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName) // 设置XMPP域
        // .performSaslAnonymousAuthentication()
        .setCompressionEnabled(true)
        // .enableDefaultDebugger()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled) // 设置建立连接时使用的TLS安全模式
        .build()
    let conn2: XMPPTCPConnection = connectAndLoginWithRetry(config2, "5", "123456") // 连接并登录（有限重试，避免偶发网络抖动）
    var listner02 = StanzaListener1(syncCounter, conn1)
    conn2.addSyncStanzaListener(listner02, StanzaTypeFilter<Stanza>("Stanza")) // 添加消息接收回调接口

    let entityBareJid2: EntityBareJid = JidCreate.entityBareFrom("12@xmpp.testserver")
    let message2: Message = MessageBuilder
        .buildMessage()
        .to(entityBareJid2) // 设置消息的接收方地址
        .ofType(MessageType.chat) // 设置消息类型
        .setBody("message: userNoName@xmpp.testserver to 12@xmpp.testserver") // 设置消息正文
        .build()

    conn2.trySendStanza(message2) // 发送消息
    syncCounter.waitUntilZero(timeout: Duration.second * 10)
    conn1.disconnect() // 从服务器断开连接
    conn2.disconnect() // 从服务器断开连接
    return (listner01.logContent, listner02.logContent)
}

func testPresence(mode: PresenceMode): (StringBuilder, StringBuilder) {
    try {
        testPresence0(mode)
    } catch (e: Exception) {
        throw e
    } finally {
        /* sleep(Duration.second * 2)
        for ((hash, byteBuffer) in xmlmap) {
            println(
                """
        2.1 ${hash} ->
        ${byteBuffer.bytes()}
        ${toBase64String(byteBuffer.bytes())}
        ${try {String.fromUtf8(byteBuffer.bytes())} catch (_) {""}}"""
            )
        } */
    }
}
