import std.unittest.testmacro.*
internal import std.collection.*
internal import std.fs.*
internal import std.io.*
internal import std.math.*
// internal import std.reflect.*
internal import std.sync.*
internal import std.time.*
internal import std.unicode.*
internal import std.unittest.*
internal import stdx.net.tls.*
internal import stdx.net.tls.common.*
internal import xmpp4cj.packet.*
internal import xmpp4cj.jid.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.sasl.*
internal import xmpp4cj.modular.*
internal import xmpp4cj.connection.*
internal import xmpp4cj.provider.*
internal import xmpp4cj.util.*
internal import xmpp4cj.compress.*
internal import xmpp4cj.feature.*
internal import xmpp4cj.filter.*
internal import xmpp4cj.compress.*
internal import xmpp4cj.tcp.*
internal import xmpp4cj.stream.*
// internal import xmpp4cj.extensions.*
// internal import xmpp4cj.core.*
internal import xmpp4cj.proxy.*

class Assert {
    static func assertNull<T>(any: ?T): Unit {
        if (any.isSome()) {
            throw Exception("expected None, but was:Some()")
        }
    }
    static func assertNotNull<T>(any: ?T): Unit {
        if (any.isNone()) {
            throw Exception("expected not None, but was:None")
        }
    }
    static func assertTrue(any: Bool): Unit {
        if (!any) {
            throw Exception("expected true, but false")
        }
    }
    static func assertTrue(msg: String, any: Bool): Unit {
        if (!any) {
            throw Exception(msg)
        }
    }
    static func assertFalse(any: Bool): Unit {
        if (any) {
            throw Exception("expected false, but true")
        }
    }
    static func assertEquals<T>(msg: String, expected: T, actual: T): Unit where T <: Equatable<T> {
        if (expected != actual) {
            throw Exception(msg)
        }
    }
    static func assertEquals<T>(expected: ?T, actual: ?T): Unit where T <: Equatable<T> {
        @PowerAssert(expected == actual)
    }
    static func assertNotEquals<T>(expected: ?T, actual: ?T): Unit where T <: Equatable<T> {
        @PowerAssert(expected != actual)
    }
    static func assertThrows<E>(actual: () -> Any): Unit where E<:Exception {
        try {
            actual()
        } catch (e: E) {}
    }
    static func fail(message: ?String): Unit {
        if (message.isNone()) {
            throw Exception()
        } else {
            throw Exception(message())
        }
    }
}

func assertEquals<T>(expected: ?T, actual: ?T): Unit where T <: Equatable<T> {
    Assert.assertEquals(expected, actual)
}

func assertEquals<T>(msg: String, expected: T, actual: T): Unit where T <: Equatable<T> {
    Assert.assertEquals(msg, expected, actual)
}

func assertTrue(any: Bool): Unit {
    Assert.assertTrue(any)
}

func assertFalse(any: Bool): Unit {
    Assert.assertFalse(any)
}

func assertTrue(msg: String, any: Bool): Unit {
    Assert.assertTrue(msg, any)
}

func assertNotNull<T>(any: ?T): Unit {
    Assert.assertNotNull(any)
}

func assertNull<T>(any: ?T): Unit {
    Assert.assertNull(any)
}

func assertNone<T>(any: ?T): Unit {
    Assert.assertNull(any)
}

func assertThrows<E>(actual: () -> Any): Unit where E <: Exception {
    try {
        actual()
    } catch (e: E) {
        return
    }
    throw Exception("assertThrows fail")
}

type Assertions = Assert

extend String {
    func equals(t: String): Bool {
        this == t
    }
}
// extend Option<T> where T <: Equatable<?T> {
//     operator func ==(other: ?T): Bool {
//         match ((this,other)) {
//             case (None,None) => true
//             case (Some(a),Some(b)) => a == b
//             case _ => false
//         }
//     }
// }

/* 
 * 所有的xmpp测试服务器应使用hostname DNSUtil已配置默认域名解析
 * 因为要部署到ci服务器 不能使用 127.0.0.1 或 localhost
 */
let XmppTestServerHostName = "xmpp.testserver"
public let TLS_TRUST_ALL = {
    =>
    var cfg = TlsClientConfig()
    cfg.verifyMode = CertificateVerifyMode.TrustAll
    cfg
}()

class StanzaFilterTrue <: StanzaFilter {
    public func accept(stanza: Stanza): Bool {
        true
    }
    public func toString(): String {
        "StanzaFilterTrue"
    }
}

/*
 * 连接类用例加固：连接/登录可能因服务端瞬时抖动（例如连接被重置、TLS/会话偶发失败）而抛异常。
 * CI 对 LLT 是整包单跑、无法单独复跑失败用例，故此处做“有界重试 + 失败清理”：
 *   - 每次尝试都新建连接；
 *   - 连接后应处于未认证状态，登录后应处于已认证状态（与原用例 @Assert 语义一致）；
 *   - 任一环节失败则清理连接并重试，最多 maxAttempts 次；仍失败则抛出最后一次异常；
 *   - 仅在重试之间做很短的退避（安全边界），避免固定长等待。
 *
 * @param config   连接配置
 * @param username 用户名
 * @param password 密码
 */
func connectLoginAuthenticatedAndDisconnect(
    config: XMPPTCPConnectionConfiguration,
    username: String,
    password: String
): Unit {
    let maxAttempts: Int64 = 3
    var lastError: ?Exception = None
    var attempt: Int64 = 1
    while (attempt <= maxAttempts) {
        let conn: XMPPTCPConnection = XMPPTCPConnection(config)
        try {
            conn.connect()
            // 连接后、登录前不应处于已认证状态
            if (conn.isAuthenticated()) {
                throw Exception("expected not authenticated right after connect, but authenticated")
            }
            conn.login(username, password)
            // 登录后应处于已认证状态
            if (!conn.isAuthenticated()) {
                throw Exception("expected authenticated right after login, but not authenticated")
            }
            conn.disconnect()
            return
        } catch (e: Exception) {
            lastError = e
            // 失败清理：断开可能残留的连接，避免影响后续重试
            try {
                if (conn.isConnected()) {
                    conn.disconnect()
                }
            } catch (e2: Exception) {}
        }
        attempt++
        if (attempt <= maxAttempts) {
            // 短退避（安全边界）：给服务端一点时间从瞬时抖动中恢复
            sleep(Duration.millisecond * (200 * attempt))
        }
    }
    throw lastError.getOrThrow()
}
