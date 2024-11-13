/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.xml

/**
 * xml反序列化接口。
 */
interface XmlDeserializable<T> {
    /**
     * 获取XML拉取解析器工厂类。
     *
     * @param xmlPullParserFactory XML拉取解析器工厂类。
     * @return XML拉取解析器工厂类。
     */
    static func fromXml(r: XmlReader): T
}

/**
 * xml读入解析器。
 */
class XmlReader {
    private var status = Status.Init
    private var readAfterLastPeek = false
    private let stack = Stack<QName>()

    private let buf: BytesInputStream

    /**
     * 初始化对象。
     *
     * @param input 数据流。
     */
    public init(input: InputStream) {
        buf = BytesInputStream(input)
    }

    /**
     * 读取XmlDeserializable对象。
     *
     * @return XmlDeserializable对象。
     */
    public func readObject<T>(): T where T <: XmlDeserializable<T> {
        // stash status
        let stashStatus = status
        let stashReadAfterLastPeek = readAfterLastPeek

        // init status before read new Xml Object
        status = Status.Init
        readAfterLastPeek = false
        let v = T.fromXml(this)

        // pop status
        status = stashStatus
        readAfterLastPeek = stashReadAfterLastPeek
        return v
    }

    /**
     * 获取XmlEvent。
     *
     * @return XmlEvent。
     */
    public func peek(): ?XmlEvent {
        if (status == Status.EOF) {
            return None
        }

        if (status != Status.Init && !readAfterLastPeek) {
            return status.toEvent()
        }

        readUntilEvent()
        if (buf.size == 0 && buf.tryFill(1) == false) {
            status = Status.EOF
            return None
        }
        status = match (buf[0]) {
            case b'<' => match (buf[1]) {
                case b'?' => match (buf.strcmp(2, BA_XML_S)) {
                    case true => Status.Decl
                    case false => Status.ProcInst
                }
                case b'!' => match {
                    case buf.strcmp(2, BA_DOCTYPE) => Status.DTD
                    case buf.strcmp(2, BA_CDATA_PRE) => Status.CData
                    case buf.strcmp(2, BA_DASH_DASH) => Status.Comment
                    case _ => throw XmlException("Unkonw xml token: ${buf}")
                }
                case b'/' => Status.ElementEnd
                case _ => Status.ElementStart
            }
            case b'&' => Status.EntityRef // TODO predefined entity: lt/gt/amp/apos/quot
            case _ => match (status.check(Status.ElementStart | Status.Attribute | Status.Namespace)) {
                case true => match {
                    case buf.strcmp(0, BA_EMPTY_TAG_END) => Status.ElementEmpty
                    case buf.strcmp(0, BA_XMLNS) => Status.Namespace
                    case _ => Status.Attribute
                }
                case false => Status.Text
            }
        }

        readAfterLastPeek = false
        return status.toEvent()
    }

    /**
     * 跳过数据。
     */
    public func skip(): Unit {
        match (status.toEvent()) {
            case ElementStart => readElementStart()
            case ElementEnd => readElementEnd()
            case Text => buf.skipBytes {b => b != b'<' && b != b'&'}
            case Attribute | Namespace =>
                buf.skipBytes {b => b != b'\'' && b != b'"'}
                let q = buf[0]
                buf.skip(1)
                buf.skipBytes {b => b != q}
                buf.skip(1)
            case Comment | Decl | ProcInst => buf.skipBytes {b => b != b'>'}
            case CData => buf.skipIndex {i => !buf.strcmp(i, BA_CDATA_SUF)} // skip '<![CDATA['
            case EntityRef =>
                buf.skipBytes {b => b != b';'}
                buf.skip(1) // skip ';'
            case DTD => readDTD()
        }
        readAfterLastPeek = true
    }

    public func readDecl(): (String, ?String, ?Bool) {
        peek()
        status.assert(Status.Decl)
        buf.skipBytes {b => b != b'v'}

        let version = readValue("version")
        if (version != "1.0") {
            throw XmlException("Unsupported XML version: `${version}`.")
        }

        skipWhitespace()
        let encoding: ?String = match (buf[0]) {
            case b'e' => readValue("encoding")
            case b's' | b'?' => None
            case _ => throw XmlException("Unsuppored XMLDecl expected `encoding or standalone` but found `${buf}`.")
        }
        if (let Some(v) <- encoding) {
            if (!v.toAsciiLowerCompare("utf-8")) {
                throw XmlException("Unsupported XML encoding: `${v}`.")
            }
        }

        skipWhitespace()
        var standalone: ?Bool = None
        let standaloneStr: ?String = match (buf[0]) {
            case b's' => readValue("standalone")
            case b'?' => None
            case _ => throw XmlException("Unsuppored XMLDecl expected `standalone` but found `${buf}`.")
        }
        if (let Some(v) <- standaloneStr) {
            match {
                case v == "yes" => standalone = true
                case v == "no" => standalone = false
                case _ => throw XmlException("Invalid value of `standalone`: `${v}`.")
            }
        }

        // skip '?>'
        skipWhitespace()
        readString("?>")

        readAfterLastPeek = true
        return (version, encoding, standalone)
    }

    // public func readElementText(name: String, namespace!: ?String = None): String {
    //     readElementStart(name, namespace: namespace)
    //     buf.skipBytes {b => b != b'>' && b != b'/'} // skip attributes
    //     let data = readText()
    //     readElementEnd(name, namespace: namespace)
    //     return data
    // }

    // public func readElementStart(name: String, namespace!: ?String = None): Unit {
    //     peek()
    //     status.assert(Status.ElementStart)
    //     buf.skip(1) // skip '<'
    //     readString(name)
    //     readAfterLastPeek = true
    //     stack.push(name)
    // }

    public func readElementEnd(name: String, namespace!: ?String = None): Unit {
        if (name != stack.peek().getFullName()) {
            throw XmlException("Element name should be `${stack.peek().getFullName()}`")
        }

        peek()

        // read empty element end tag
        if (status == Status.ElementEmpty) {
            buf.skip(2) // skip '/>'
            readAfterLastPeek = true
            stack.pop()
            return
        }

        // read EndTag
        status.assert(Status.ElementEnd)
        buf.skip(2) // skip '</'
        readString(name)
        skipWhitespace()
        readByte(b'>')
        readAfterLastPeek = true
        stack.pop()

        // EOF
        if (stack.isEmpty()) {
            status = Status.EOF
        }
    }

    public func readElementStart(): QName {
        peek()
        status.assert(Status.ElementStart)
        buf.skip(1) // skip '<'

        let name = buf.readName()
        let arr = name.split(":")
        let qname = if (arr.size == 2) {
            QName("", arr[1], arr[0])
        } else {
            QName(name)
        }

        readAfterLastPeek = true
        stack.push(qname)
        return qname
    }

    public func readElementEnd(): QName {
        peek()

        let qname = if (status == Status.ElementEmpty) {
            buf.skip(2) // skip '/>'
            readAfterLastPeek = true
            stack.pop()
        } else {
            status.assert(Status.ElementEnd)
            buf.skip(2) // skip '</'

            let qname = readQname()
            let qnamepeek = stack.peek()
            let equals = qname.prefix == qnamepeek.prefix && qname.local == qnamepeek.local
            if (!equals) {
                throw XmlException(
                    "Failed to read XML element end tag, expect name `${stack.peek().getFullName()}` but found `${qname.getFullName()}`."
                )
            }

            readAfterLastPeek = true
            stack.pop()
        }

        // EOF
        if (stack.isEmpty()) {
            status = Status.EOF
        }

        return qname
    }

    public func readText(): String {
        peek()
        if (status.check(Status.ElementEnd | Status.ElementEmpty)) {
            return ""
        }
        status.assert(Status.Text | Status.CData | Status.EntityRef)
        match {
            case status == Status.Text =>
                let txt = doReadText()
                readAfterLastPeek = true
                txt
            case status == Status.CData => readCData() + buf.readUntil {b, _ => !isWhitespace(b)}
            case _ => readEntityRef().decl.value + buf.readUntil {b, _ => !isWhitespace(b)}
        }
    }

    public func readCData(): String {
        peek()
        status.assert(Status.CData)
        buf.skip(9) // <![CDATA[

        let txt = buf.readUntil {b, i => b == b']' && buf.strcmp(i, BA_CDATA_SUF)}
        buf.skip(3) // ]]>

        readAfterLastPeek = true
        return txt
    }

    public func getCurrentPosition(): Position {
        throw UnsupportedException()
    }

    public func getCurrentNamespace(): ?Namespace {
        throw UnsupportedException()
    }

    public func readComment(): String {
        throw UnsupportedException()
    }

    public func readProcInst(): (String, ?String) {
        throw UnsupportedException()
    }

    /* 当前不支持 仅作ignore */
    public func readDTD(): DocTypeDecl {
        let str = buf.readUntil(b'>')
        DocTypeDecl("DOCTYPE", str)
    }

    public func readAttribute(): Attribute {
        let qname = readQname()
        buf.skip(1)
        let value = match (buf[0]) {
            case b'"' =>
                buf.skip(1)
                buf.readUntil(b'"')
            case b'\'' =>
                buf.skip(1)
                buf.readUntil(b'\'')
            case _ => throw XmlException("Failed to read Attribute ${qname.getFullName()}, `'` or `\"` was required.")
        }
        buf.skip(1)
        readAfterLastPeek = true
        Attribute(qname, value)
    }

    public func readAttribute(_: String, namespace!: ?String = None): String {
        throw UnsupportedException()
    }

    public func readNamespace(): (String, String) {
        readString("xmlns")
        if (buf[0] == b':') {
            buf.skip(1)
        }
        let prefix = buf.readUntil(b'=')
        readByte(b'=')
        let uri = match (buf[0]) {
            case b'"' =>
                buf.skip(1)
                buf.readUntil(b'"')
            case b'\'' =>
                buf.skip(1)
                buf.readUntil(b'\'')
            case _ => throw XmlException("Failed to read namespace ${prefix}, `'` or `\"` was required.")
        }
        buf.skip(1)
        readAfterLastPeek = true
        (prefix, uri)
    }

    public func readEntityRef(): EntityReference {
        let ref = "${buf.readUntil(b';')};"
        buf.skip(1)
        readAfterLastPeek = true
        EntityReference(ref, EntityDecl(ref, ESCAPE_MAPPING[ref]))
    }

    // TODO support xml:space="preserve"
    private func readUntilEvent(): Unit {
        skipWhitespace()
        if (buf[0] == b'>') {
            status = Status.MarkupClose
            buf.skip(1) // skip '>'
        }
        skipWhitespace()
    }

    private func skipWhitespace(): Unit {
        buf.skipBytes(isWhitespace)
    }

    private func readString(str: String): Unit {
        let bytes = unsafe { str.rawData() }
        if (!buf.strcmp(0, bytes)) {
            throw XmlException("Failed to read from `${buf}`, `${str}` was required.")
        }
        buf.skip(bytes.size)
    }

    private func readByte(b: Byte): Unit {
        if (buf[0] != b) {
            throw XmlException("Failed to read from `${buf}`, `${Rune(b)}` was required.")
        }
        buf.skip(1)
    }

    private func readValue(name: String): String {
        readString(name)
        readByte(b'=')

        let value = match (buf[0]) {
            case b'"' =>
                buf.skip(1)
                buf.readUntil(b'"')
            case b'\'' =>
                buf.skip(1)
                buf.readUntil(b'\'')
            case _ => throw XmlException("Failed to read value of `${name}` from `${buf}`, `'` or `\"` was required.")
        }
        buf.skip(1)
        return value
    }

    private func doReadText(): String {
        // TODO replace \r\n to \n， \r to \n
        return buf.readUntil {b, _ => b == b'<' || b == b'&'}
    }

    private func readQname(): QName {
        var i = 0
        var prefix: String = ""
        while (buf[i] != b'>' && buf[i] != b'=' && buf[i] != b' ' && buf[i] != b'\r' && buf[i] != b'\n' && buf[i] !=
                b'\t') {
            if (buf[i] == b':') {
                prefix = buf.read(i)
                buf.skip(1)
                i = 0
                continue
            }
            i++
        }
        let local = buf.read(i)
        let namespace = if (prefix == "xml") {
            W3_XML_NAMESPACE
        } else {
            ""
        }
        QName(namespace, local, prefix)
    }
}
