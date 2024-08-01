/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

internal import encoding.hex.{toHexString}
internal import encoding.url.{URL}
internal import net.tls.*
internal import std.collection.*
internal import std.collection.concurrent.{ConcurrentHashMap, NonBlockingQueue}
internal import std.convert.*
internal import std.io.{ByteArrayStream, InputStream, IOException, OutputStream, StringReader, ChainedInputStream}
internal import std.log.*
internal import std.regex.{MatchData, Regex}
internal import std.socket.*
internal import std.sort.*
internal import std.sync.{AtomicInt64, Monitor, ReentrantMutex, Timer, Semaphore, sleep}
internal import std.time.*
internal import std.unicode.{UnicodeExtension}

extend<T> Option<T> {
    operator func ()(): T {
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
