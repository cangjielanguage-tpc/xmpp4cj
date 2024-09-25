/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

internal import encoding.url.{URL}
internal import std.collection.*
internal import std.convert.Parsable
internal import std.io.{ByteArrayStream, IOException, OutputStream, StringReader}
internal import std.regex.{Regex}
internal import std.sort.stableSort
internal import std.sync.{AtomicInt64, ReentrantMutex}
internal import std.time.{DateTime, DateTimeFormat, TimeParseException, TimeZone}
// internal import std.unicode.{UnicodeExtension}

type CharSequence = ToString

public interface OptionExt<T> {
    operator func ()(): T
}

extend<T> Option<T> <: OptionExt<T> {
    public operator func ()(): T {
        this.getOrThrow()
    }
}

func binarySearch<T>(arr: Array<T>, key: T): Int64 where T <: Comparable<T> {
    var low = 0
    var high = arr.size - 1
    while (low <= high) {
        var mid = (low + high) / 2
        let midVal = arr[mid]
        match (midVal.compare(key)) {
            case LT => low = mid + 1
            case GT => high = mid - 1
            case EQ => return mid // key found
        }
    }

    // key not found.
    return -(low + 1)
}

public let ETHERX_JABBER_STREAMS_NAMESPACE: String = "http://etherx.jabber.org/streams"
public let JABBER_PROTOCAL_NAMESPACE_PREFIX: String = "http://jabber.org/protocol"
