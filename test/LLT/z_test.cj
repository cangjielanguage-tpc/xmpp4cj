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
internal import cangjie_tpc::xmpp4cj.packet.*
internal import cangjie_tpc::xmpp4cj.jid.*
internal import cangjie_tpc::xmpp4cj.xml.*
internal import cangjie_tpc::xmpp4cj.sasl.*
internal import cangjie_tpc::xmpp4cj.modular.*
internal import cangjie_tpc::xmpp4cj.connection.*
internal import cangjie_tpc::xmpp4cj.provider.*
internal import cangjie_tpc::xmpp4cj.util.*
internal import cangjie_tpc::xmpp4cj.compress.*
internal import cangjie_tpc::xmpp4cj.feature.*
internal import cangjie_tpc::xmpp4cj.filter.*
internal import cangjie_tpc::xmpp4cj.compress.*
internal import cangjie_tpc::xmpp4cj.tcp.*
internal import cangjie_tpc::xmpp4cj.stream.*
// internal import cangjie_tpc::xmpp4cj.extensions.*
// internal import cangjie_tpc::xmpp4cj.core.*
internal import cangjie_tpc::xmpp4cj.proxy.*

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
