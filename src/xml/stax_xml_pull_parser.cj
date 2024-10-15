/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xml

/**
 * 使用Stax接口的XML拉取解析器。
 */
public class StaxXmlPullParser <: XmlPullParser {
    let reader: XmlReader

    private var xmlNode: ?XmlNode = None

    /**
     * 初始化对象。
     *
     * @param input 数据流。
     */
    public init(input: InputStream) {
        this.reader = XmlReader(input)
    }

    /**
     * 获取指定名称的属性。(不支持)
     *
     * @param _ 属性名称。
     * @return 属性值对象。
     * @throws UnsupportedException 不支持的接口抛UnsupportedException异常。
     */
    public override func getProperty(_: String): Object {
        throw UnsupportedException()
    }

    public override func getInputEncoding(): String {
        "UTF-8"
    }

    public override func getNamespaceCount(): Int64 {
        nss.size
    }

    public override func getNamespacePrefix(pos: Int64): String {
        nss[pos][0]
    }

    public override func getNamespaceUri(pos: Int64): String {
        nss[pos][1]
    }

    public override func getNamespace(prefix: ?String): ?String {
        nss.get(prefix ?? "")
    }

    public override func getDepth(): Int64 {
        depth
    }

    /**
     * 获取位置描述。（不支持）
     *
     * @return 位置描述字符串。
     * @throws UnsupportedException 不支持的接口抛UnsupportedException异常。
     */
    public override func getPositionDescription(): String {
        throw UnsupportedException()
    }

    /**
     * 获取当前行号。（不支持）
     *
     * @return 行号。
     * @throws UnsupportedException 不支持的接口抛UnsupportedException异常。
     */
    public override func getLineNumber(): Int64 {
        throw UnsupportedException()
    }

    /**
     * 获取当前列号。（不支持）
     *
     * @return 列号。
     * @throws UnsupportedException 不支持的接口抛UnsupportedException异常。
     */
    public override func getColumnNumber(): Int64 {
        throw UnsupportedException()
    }

    /**
     * 判断是否为空白字符。（不支持）
     *
     * @return 如果是空白字符则为 true，否则为 false。
     * @throws UnsupportedException 不支持的接口抛UnsupportedException异常。
     */
    public override func isWhiteSpace(): Bool {
        throw UnsupportedException()
    }

    public override func getText(): String {
        text
    }

    public override func getNamespace(): String {
        qname.getOrThrow().namespace
    }

    public override func getName(): String {
        let qname: QName = getQName()
        return qname.local
    }

    public override func getQName(): QName {
        qname.getOrThrow()
    }

    public override func getPrefix(): String {
        qname.getOrThrow().prefix
    }

    public override func getAttributeCount(): Int64 {
        attrs.size
    }

    public override func getAttributeNamespace(index: Int64): String {
        let prefix = attrs[index].qname.prefix
        if (prefix != "") {
            nss.get(prefix) ?? ""
        } else {
            ""
        }
    }

    public override func getAttributeName(index: Int64): String {
        attrs[index].qname.local
    }

    public override func getAttributeQName(index: Int64): QName {
        attrs[index].qname
    }

    public override func getAttributePrefix(index: Int64): String {
        attrs[index].qname.prefix
    }

    /**
     * 获取指定索引的属性的类型。
     *
     * @param index 属性索引。
     * @return 属性类型字符串。
     * @throws XmlPullParserException index越界的时候抛XmlPullParserException异常。
     */
    public override func getAttributeType(index: Int64): String {
        if (attrs.size > index) {
            "CDATA"
        } else {
            throw XmlPullParserException("No such attribute")
        }
    }

    public override func getAttributeValue(index: Int64): String {
        attrs[index].value
    }

    public override func getAttributeValue(namespace: ?String, name: String): ?String {
        for (attr in attrs) {
            if ((namespace ?? "") == attr.qname.namespace && name == attr.qname.local) {
                return attr.value
            }
        }
        None
    }

    public override func getEventType(): XmlPullParserEvent {
        eventType
    }

    var eventType: XmlPullParserEvent = XmlPullParserEvent.START_DOCUMENT
    var qname: ?QName = None
    var nss: LinkedHashMap<String, String> = LinkedHashMap<String, String>()
    var attrs: ArrayList<Attribute> = ArrayList<Attribute>()
    var text: String = ""
    var depth: Int = 0

    public override func next(): XmlPullParserEvent {
        if (eventType == XmlPullParserEvent.END_ELEMENT) {
            depth--
        }
        if (let Some(event) <- reader.peek()) {
            match (event) {
                case ElementStart =>
                    attrs.clear()
                    text = ""

                    let qnameTask = HashMap<String, (String) -> Unit>()
                    this.qname = reader.readElementStart()
                    while (let Some(e) <- reader.peek()) {
                        match (e) {
                            case XmlEvent.Namespace =>
                                let (prefix, uri) = reader.readNamespace()
                                nss.put(prefix, uri)
                            case XmlEvent.Attribute =>
                                let attr = reader.readAttribute()
                                attrs.append(attr)
                            case _ => break
                        }
                    }

                    // set namespace of qname
                    if (let Some(uri) <- nss.get(qname.getOrThrow().prefix)) {
                        qname.getOrThrow().namespace = uri
                    }
                    for (attr in attrs where attr.qname.prefix.size > 0 && attr.qname.namespace.size == 0) {
                        ifSome(nss.get(attr.qname.prefix)) {
                            uri => attr.qname.namespace = uri
                        }
                    }

                    depth++
                    this.eventType = XmlPullParserEvent.START_ELEMENT
                case Text | CData | EntityRef =>
                    let str = StringBuilder()
                    str.append(reader.readText())
                    while (true) {
                        match (reader.peek()) {
                            case Some(v) where v.isCharacter() => str.append(reader.readText())
                            case _ => break
                        }
                    }
                    text = str.toString()
                    this.eventType = XmlPullParserEvent.TEXT_CHARACTERS
                case ElementEnd =>
                    this.qname = reader.readElementEnd()
                    this.eventType = XmlPullParserEvent.END_ELEMENT
                case _ =>
                    reader.skip()
                    this.eventType = XmlPullParserEvent.OTHER
            }
        } else {
            this.eventType = XmlPullParserEvent.END_DOCUMENT
        }
        return this.eventType
    }

    public override func nextText(): String {
        if (eventType != XmlPullParserEvent.START_ELEMENT) {
            throw XmlPullParserException("parser must be on START_ELEMENT to read next text")
        }
        next()
        match (eventType) {
            case XmlPullParserEvent.TEXT_CHARACTERS => if (next() != XmlPullParserEvent.END_ELEMENT) {
                throw XmlPullParserException(
                    "elementGetText() function expects text only elment but START_ELEMENT was encountered.")
            }
            case XmlPullParserEvent.END_ELEMENT => return text
            case _ => throw XmlPullParserException("Unexpected event type ${eventType}")
        }
        return text
    }

    /**
     * 移动到下一个标签事件。
     *
     * @return 下一个标签事件类型对象。
     * @throws XmlPullParserException 当下个标签对象没有开始结束标签的时候抛XmlPullParserException异常。
     */
    public override func nextTag(): XmlPullParserTagEvent {
        while (next() != XmlPullParserEvent.END_DOCUMENT) {
            if (eventType == XmlPullParserEvent.START_ELEMENT) {
                return XmlPullParserTagEvent.START_ELEMENT
            }
            if (eventType == XmlPullParserEvent.END_ELEMENT) {
                return XmlPullParserTagEvent.END_ELEMENT
            }
        }
        throw XmlPullParserException("No start or end tag found")
    }

    public override func supportsRoundtrip(): Bool {
        false
    }
}

/**
 * 使用Stax接口的XML拉取解析器的工厂类
 */
public class StaxXmlPullParserFactory <: XmlPullParserFactory {
    /**
     * 新建一个XmlPullParser对象
     *
     * @param reader 数据流。
     * @return XmlPullParser对象。
     */
    public func newXmlPullParser(reader: InputStream): XmlPullParser {
        return StaxXmlPullParser(reader)
    }
}
