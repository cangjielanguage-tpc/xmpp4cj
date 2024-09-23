/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.xml

struct Status <: Equatable<Status> & ToString {
    private static const CONST_INIT = 0x1u64
    private static const CONST_DECL = 0x1u64 << 1
    private static const CONST_COMMENT = 0x1u64 << 2
    private static const CONST_PROC_INST = 0x1u64 << 3
    private static const CONST_DTD = 0x1u64 << 4
    private static const CONST_ELEMENT_START = 0x1u64 << 5
    private static const CONST_ELEMENT_END = 0x1u64 << 6
    private static const CONST_ELEMENT_EMPTY = 0x1u64 << 7
    private static const CONST_ATTRIBUTE = 0x1u64 << 8
    private static const CONST_NAMESPACE = 0x1u64 << 9
    private static const CONST_TEXT = 0x1u64 << 10
    private static const CONST_CDATA = 0x1u64 << 11
    private static const CONST_ENTITY_REF = 0x1u64 << 12
    private static const CONST_MARKUP_END = 0x1u64 << 13
    private static const CONST_EOF = 0x1u64 << 63

    public static let Init = Status(CONST_INIT)
    public static let Decl = Status(CONST_DECL)
    public static let Comment = Status(CONST_COMMENT)
    public static let ProcInst = Status(CONST_PROC_INST)
    public static let DTD = Status(CONST_DTD)
    public static let ElementStart = Status(CONST_ELEMENT_START)
    public static let ElementEnd = Status(CONST_ELEMENT_END)
    public static let ElementEmpty = Status(CONST_ELEMENT_EMPTY)
    public static let Attribute = Status(CONST_ATTRIBUTE)
    public static let Namespace = Status(CONST_NAMESPACE)
    public static let Text = Status(CONST_TEXT)
    public static let CData = Status(CONST_CDATA)
    public static let EntityRef = Status(CONST_ENTITY_REF)
    public static let MarkupClose = Status(CONST_MARKUP_END)
    public static let EOF = Status(CONST_EOF)

    private Status(private let v: UInt64) {}

    public operator func |(other: Status): Status {
        return Status(this.v | other.v)
    }

    public operator func ==(other: Status): Bool {
        return this.v == other.v
    }

    public func toString(): String {
        var addPrefix = false
        let sb = StringBuilder()
        addPrefix = checkAndAppend(Init, "Init", sb, addPrefix)
        addPrefix = checkAndAppend(Decl, "Decl", sb, addPrefix)
        addPrefix = checkAndAppend(Comment, "Comment", sb, addPrefix)
        addPrefix = checkAndAppend(ProcInst, "ProcInst", sb, addPrefix)
        addPrefix = checkAndAppend(DTD, "DTD", sb, addPrefix)
        addPrefix = checkAndAppend(ElementStart, "ElementStart", sb, addPrefix)
        addPrefix = checkAndAppend(ElementEnd, "ElementEnd", sb, addPrefix)
        addPrefix = checkAndAppend(ElementEmpty, "ElementEmpty", sb, addPrefix)
        addPrefix = checkAndAppend(Attribute, "Attribute", sb, addPrefix)
        addPrefix = checkAndAppend(Namespace, "Namespace", sb, addPrefix)
        addPrefix = checkAndAppend(Text, "Text", sb, addPrefix)
        addPrefix = checkAndAppend(CData, "CData", sb, addPrefix)
        addPrefix = checkAndAppend(EntityRef, "EntityRef", sb, addPrefix)
        addPrefix = checkAndAppend(MarkupClose, "MarkupClose", sb, addPrefix)
        addPrefix = checkAndAppend(EOF, "EOF", sb, addPrefix)
        return sb.toString()
    }

    private func checkAndAppend(expect: Status, name: String, sb: StringBuilder, addPrefix: Bool): Bool {
        if ((this.v & expect.v) != 0) {
            if (addPrefix) {
                sb.append(" | ")
            }
            sb.append(name)
            return true
        }
        return false
    }

    public func assert(expect: Status): Unit {
        if (!check(expect)) {
            throw XmlStatusException("Expect `${expect}`, but get `${this}`")
        }
    }

    public func check(expect: Status): Bool {
        return (this.v & expect.v) != 0
    }

    public func toEvent(): XmlEvent {
        return match (v) {
            case 0x0002u64 => XmlEvent.Decl
            case 0x0004u64 => XmlEvent.Comment
            case 0x0008u64 => XmlEvent.ProcInst
            case 0x0010u64 => XmlEvent.DTD
            case 0x0020u64 => XmlEvent.ElementStart
            case 0x0040u64 => XmlEvent.ElementEnd // '</'
            case 0x0080u64 => XmlEvent.ElementEnd // '/>' 
            case 0x0100u64 => XmlEvent.Attribute
            case 0x0200u64 => XmlEvent.Namespace
            case 0x0400u64 => XmlEvent.Text
            case 0x0800u64 => XmlEvent.CData
            case 0x1000u64 => XmlEvent.EntityRef
            // The status `MarkupClose` should be ignored by processor, should not convert to any `XmlEvent`.
            case _ => throw XmlStatusException("Failed to convert status `${this}` to XmlEvent")
        }
    }
}

class BytesInputStream {
    protected let buffer = Array<Byte>(4096, repeat: 0)
    protected var window = Array<Byte>() // the slice of data buffer, for fast path

    public BytesInputStream(private let rawInput: InputStream) {}

    public prop size: Int64 {
        get() {
            window.size
        }
    }

    public operator func [](idx: Int64): Byte {
        if (idx < window.size) {
            return window[idx]
        }

        if (!tryFill(idx)) {
            throw XmlException("Failed to read data, idx: ${idx} out of size: ${size}.")
        }
        return window[idx]
    }

    public func strcmp(idx: Int64, dst: Array<Byte>): Bool {
        if (this.size < dst.size) {
            if (!tryFill(dst.size) || this.size < dst.size) {
                return false
            }
        }
        // used for xml token cmp, no need use memcmp 
        for (i in 0..dst.size where this[idx + i] != dst[i]) {
            return false
        }
        return true
    }

    public func skipBytes(condition: (Byte) -> Bool): Unit {
        var idx = 0
        while (idx < window.size && condition(this[idx])) {
            idx++
        }
        window = window.slice(idx, window.size - idx)
    }

    public func skipIndex(condition: (Int64) -> Bool): Unit {
        var idx = 0
        while (idx < window.size && condition(idx)) {
            idx++
        }
        window = window.slice(idx, window.size - idx)
    }

    public func skip(num: Int64): Unit {
        window = window.slice(num, window.size - num)
    }

    public func read(count: Int64): String {
        let str = unsafe { String.fromUtf8Unchecked(window[..count]) }
        window = window[count..]
        str
    }

    public func readUntil(b: Byte): String {
        return readUntil {c, _ => c == b}
    }

    public func readUntil(condition: (Byte, Int64) -> Bool): String {
        var idx = 0
        while (idx < window.size && !condition(this[idx], idx)) {
            idx++
        }
        if (idx >= window.size) {
            throw XmlException("Failed to readUntil from `${this}`.")
        }

        let readData = window.slice(0, idx) // read data
        window = window.slice(idx, window.size - idx) // remain data
        return String.fromUtf8(readData)
    }

    private func tryFill(minSize: Int64): Bool {
        if (window.size > 0) { // align window to buffer start
            let dataSize = window.size
            for (i in 0..dataSize) { // as window is a slice of buffer, we should copy one by one here
                buffer[i] = window[i]
            }
            window = buffer.slice(0, dataSize)
        }

        while (fill() && window.size < minSize) {}
        return window.size >= minSize
    }

    private func fill(): Bool {
        let idx = window.size // write index
        let capacity = buffer.size - idx // write capacity
        if (capacity == 0) { // buffer is full
            return false
        }

        let readLen = rawInput.read(buffer.slice(idx, capacity))
        if (readLen > 0) {
            window = buffer.slice(0, idx + readLen)
            return true
        }
        return false
    }
}

extend String {
    public func toAsciiLowerCompare(asciiLower: String): Bool {
        let src = unsafe { this.rawData() }
        let dst = unsafe { asciiLower.rawData() }
        if (src.size != dst.size) {
            return false
        }
        for (i in 0..src.size where toAsciiLower(src[i]) != dst[i]) {
            return false
        }
        return true
    }
}

func toAsciiLower(b: Byte): Byte {
    const diff = b'a' - b'A'
    return match (b >= b'A' && b <= b'Z') {
        case true => b + diff
        case false => b
    }
}

public class Stack<T> {
    private var buff = Array<T>(16, repeat: unsafe { zeroValue<T>() })
    private var idx = 0

    public prop size: Int64 {
        get() {
            idx
        }
    }

    public func pop(): T {
        if (isEmpty()) {
            throw XmlException("Failed to pop, stack is empty!")
        }
        idx--
        return buff[idx]
    }

    public func peek(): T {
        if (isEmpty()) {
            throw XmlException("Failed to peek, stack is empty!")
        }
        return buff[idx - 1]
    }

    public func push(v: T): Unit {
        if (isFull()) {
            let newSize = buff.size + (buff.size >> 1)
            let newBuff = Array<T>(newSize, repeat: unsafe { zeroValue<T>() })
            buff.copyTo(newBuff, 0, 0, idx)
            buff = newBuff
        }
        buff[idx] = v
        idx++
    }

    public func isEmpty(): Bool {
        return idx == 0
    }

    public func isFull(): Bool {
        return idx == buff.size
    }
}
