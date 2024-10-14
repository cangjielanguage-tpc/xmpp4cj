import std.unittest.testmacro.*
internal import std.collection.*
internal import std.fs.*
internal import std.io.*
internal import std.math.*
internal import std.reflect.*
internal import std.sync.*
internal import std.time.*
internal import std.unicode.UnicodeExtension
internal import std.unittest.*
internal import xmpp4cj.packet.*
internal import xmpp4cj.jid.*
internal import xmpp4cj.xml.*
internal import xmpp4cj.provider.*
internal import xmpp4cj.util.*
internal import xmpp4cj.compress.*
internal import xmpp4cj.feature.*
internal import xmpp4cj.filter.*
internal import xmpp4cj.compress.*

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
    static func assertThrows(expected: TypeInfo, actual: () -> Any): Unit {
        var actualType = expected
        try {
            actual()
        } catch (e: Exception) {
            actualType = TypeInfo.of(e)
            if (expected == actualType) {
                return
            }
        }
        throw Exception("expected ${expected}, but ${actualType}")
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
