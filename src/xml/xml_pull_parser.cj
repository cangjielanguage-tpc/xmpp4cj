/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xml

/**
 * XMPP 的 XML 拉式解析器接口。
 *
 * <p>
 * 与 StAX 的 XMLStreamReader 的区别：
 * </p>
 * <ul>
 *   <li>{@link #getName()} 和 {@link #getAttributeName(int)} 返回本地名称，有 {@link #getQName()} 和 {@link #getAttributeQName(int)} 用于检索限定名称（{@link QName}）。</li>
 *   <li>{@link #nextText()} 替代了 {@code XMLStreamReader.getElementText()}。
 * </ul>
 * <p>
 * 与 XPP3 的 XmlPullParser 的区别：
 * </p>
 * <ul>
 *   <li>像 {@link #getAttributeName(int)} 这样带有属性索引的方法，如果给定索引不存在属性，则返回 <code>None</code>，而不是抛出异常。</li>
 * </ul>
 *
 * <h2>开发者信息</h2>
 * <p>
 * 下面的表格展示了 XMPP 的 XmlPullParser 事件与 StAX 和 XPP3 事件的映射：
 * </p>
 * <table>
 * <caption>XmlPullParser 事件映射</caption>
 * <tr><th>XMPP 的 {@link XmlPullParserEvent}</th><th>StAX 事件</th><th>XPP3 事件</th></tr>
 * <tr><td>{@link XmlPullParserEvent#START_DOCUMENT}</td><td>START_DOCUMENT (7)</td><td>START_DOCUMENT (0)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#END_DOCUMENT}</td><td>END_DOCUMENT (8)</td><td>END_DOCUMENT (1)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#START_ELEMENT}</td><td>START_ELEMENT (1)</td><td>START_TAG (2)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#END_ELEMENT}</td><td>END_ELEMENT (2)</td><td>END_TAG (3)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#TEXT_CHARACTERS}</td><td>CHARACTERS (4)</td><td>TEXT (4)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#PROCESSING_INSTRUCTION}</td><td>PROCESSING_INSTRUCTION (3)</td><td>PROCESSING_INSTRUCTION (8)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#COMMENT}</td><td>COMMENT (5)</td><td>COMMENT (9)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#IGNORABLE_WHITESPACE}</td><td>SPACE (6)</td><td>IGNORABLE_WHITESPACE (7)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#ENTITY_REFERENCE}</td><td>ENTITY_REFERENCE (9)</td><td>ENTITY_REF (6)</td></tr>
 * <tr><td>{@link XmlPullParserEvent#OTHER}</td><td>ENTITY_REFERENCE (9)</td><td>ENTITY_REF (6)</td></tr>
 * </table>
 * <p>{@link XmlPullParserEvent#OTHER} 在 StAX 的情况下包括：ATTRIBUTE (10)、DTD (11)、CDATA (12)、NAMESPACE (13)、NOTATION_DECLARATION (14) 和 ENTITY_DECLRATION (15)，在 XPP3 的情况下包括：CDSECT (5)、DOCDECL (10)。</p>
 *
 */
public interface XmlPullParser {
    /**
     * 获取指定名称的属性。
     *
     * @param name 属性名称。
     * @return 属性值对象。
     */
    func getProperty(name: String): Object

    /**
     * 获取输入编码。
     *
     * @return 输入编码字符串。
     */
    func getInputEncoding(): String

    /**
     * 获取命名空间数量。
     *
     * @return 命名空间数量。
     */
    func getNamespaceCount(): Int64

    /**
     * 获取指定位置的命名空间前缀。
     *
     * @param pos 位置索引。
     * @return 命名空间前缀字符串。
     */
    func getNamespacePrefix(pos: Int64): String

    /**
     * 获取指定位置的命名空间 URI。
     *
     * @param pos 位置索引。
     * @return 命名空间 URI 字符串。
     */
    func getNamespaceUri(pos: Int64): String

    /**
     * 根据前缀获取命名空间。
     *
     * @param prefix 命名空间前缀。
     * @return 命名空间字符串或 None。
     */
    func getNamespace(prefix: ?String): ?String

    /**
     * 获取默认命名空间。
     *
     * @return 默认命名空间字符串或 None。
     */
    func getDefaultNamespace(): ?String {
        return getNamespace(None)
    }

    /**
     * 获取当前深度。
     *
     * @return 当前深度值。
     */
    func getDepth(): Int64

    /**
     * 获取位置描述。
     *
     * @return 位置描述字符串。
     */
    func getPositionDescription(): String

    /**
     * 获取当前行号。
     *
     * @return 行号。
     */
    func getLineNumber(): Int64

    /**
     * 获取当前列号。
     *
     * @return 列号。
     */
    func getColumnNumber(): Int64

    /**
     * 判断是否为空白字符。
     *
     * @return 如果是空白字符则为 true，否则为 false。
     */
    func isWhiteSpace(): Bool

    /**
     * 获取文本内容。
     *
     * @return 文本内容字符串。
     */
    func getText(): String

    /**
     * 获取命名空间。
     *
     * @return 命名空间字符串。
     */
    func getNamespace(): String

    /**
     * 返回当前 START_ELEMENT 或 END_ELEMENT 事件的名称。
     * 只有在当前事件是 START_ELEMENT 或 END_ELEMENT 时才能调用此方法。
     *
     * @return 当前 START_ELEMETN 或 END_ELEMENT 事件的名称。
     */
    func getName(): String

    /**
     * 获取限定名称。
     *
     * @return 限定名称对象。
     */
    func getQName(): QName

    /**
     * 获取前缀。
     *
     * @return 前缀字符串。
     */
    func getPrefix(): String

    /**
     * 获取属性数量。
     *
     * @return 属性数量。
     */
    func getAttributeCount(): Int64

    /**
     * 获取指定索引的属性的命名空间。
     *
     * @param index 属性索引。
     * @return 属性命名空间字符串。
     */
    func getAttributeNamespace(index: Int64): String

    /**
     * 返回属性名称的本地部分，或者如果索引不指向属性则返回 <code>None</code>。
     *
     * @param index 属性索引。
     * @return 属性名称的本地部分或 <code>None</code>。
     */
    func getAttributeName(index: Int64): String

    /**
     * 获取指定索引的属性的限定名称。
     *
     * @param index 属性索引。
     * @return 限定名称对象。
     */
    func getAttributeQName(index: Int64): QName

    /**
     * 获取指定索引的属性的前缀。
     *
     * @param index 属性索引。
     * @return 属性前缀字符串。
     */
    func getAttributePrefix(index: Int64): String

    /**
     * 获取指定索引的属性的类型。
     *
     * @param index 属性索引。
     * @return 属性类型字符串。
     */
    func getAttributeType(index: Int64): String

    /**
     * 获取指定索引的属性的值。
     *
     * @param index 属性索引。
     * @return 属性值字符串。
     */
    func getAttributeValue(index: Int64): String

    /**
     * 根据命名空间和名称获取属性值。
     *
     * @param namespace 命名空间字符串或 None。
     * @param name 属性名称。
     * @return 属性值字符串或 None。
     */
    func getAttributeValue(namespace: ?String, name: String): ?String

    /**
     * 根据名称获取属性值。
     *
     * @param name 属性名称。
     * @return 属性值字符串或 None。
     */
    func getAttributeValue(name: String): ?String {
        return getAttributeValue(None, name)
    }

    /**
     * 获取当前事件类型。
     *
     * @return 当前事件类型对象。
     */
    func getEventType(): XmlPullParserEvent

    /**
     * 移动到下一个事件。
     *
     * @return 下一个事件类型对象。
     */
    func next(): XmlPullParserEvent

    /**
     * 读取仅包含文本的元素的内容，如果这不是仅包含文本的元素，则抛出异常。
     * <ul>
     *   <li>前置条件：当前事件是 START_ELEMENT。</li>
     *   <li>后置条件：当前事件是对应的 END_ELEMENT。</li>
     * </ul>
     *
     * @return 当前元素的文本内容。
     * @throws IOException 如果发生 IO 错误。
     * @throws XmlPullParserException 如果发生 XML 拉式解析器错误。
     */
    func nextText(): String

    /**
     * 移动到下一个标签事件。
     *
     * @return 下一个标签事件类型对象。
     */
    func nextTag(): XmlPullParserTagEvent

    /**
     * 判断是否支持往返操作。
     *
     * @return 如果支持往返操作则为 true，否则为 false。
     */
    func supportsRoundtrip(): Bool
}

public enum XmlPullParserTagEvent {
    START_ELEMENT
    | END_ELEMENT
}

public enum XmlPullParserEvent <: Equatable<XmlPullParserEvent> & ToString {
    START_DOCUMENT
    | END_DOCUMENT
    | START_ELEMENT
    | END_ELEMENT
    /**
     * Replaces TEXT from XPP3.
     */
    | TEXT_CHARACTERS
    | PROCESSING_INSTRUCTION
    | COMMENT
    | IGNORABLE_WHITESPACE
    | ENTITY_REFERENCE
    | OTHER

    public operator func ==(other: XmlPullParserEvent): Bool {
        this.toString() == other.toString()
    }
    public func toString(): String {
        match (this) {
            case START_DOCUMENT => "START_DOCUMENT"
            case END_DOCUMENT => "END_DOCUMENT"
            case START_ELEMENT => "START_ELEMENT"
            case END_ELEMENT => "END_ELEMENT"
            case TEXT_CHARACTERS => "TEXT_CHARACTERS"
            case PROCESSING_INSTRUCTION => "PROCESSING_INSTRUCTION"
            case COMMENT => "COMMENT"
            case IGNORABLE_WHITESPACE => "IGNORABLE_WHITESPACE"
            case ENTITY_REFERENCE => "ENTITY_REFERENCE"
            case OTHER => "OTHER"
        }
    }
}

public interface XmlPullParserFactory {
    func newXmlPullParser(reader: InputStream): XmlPullParser
}

public class XmlPullParserException <: Exception {
    public init(wrapped: Exception) {
        super(wrapped.toString())
    }

    public init(message: String) {
        super(message)
    }
}
