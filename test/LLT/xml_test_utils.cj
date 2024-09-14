import std.collection.*
import std.sort.*
import std.regex.*
import std.unittest.testmacro.*
import xmpp4cj.xml.*

public class XmlAttr <: ToString {
    var name: String
    var value: String
    init(name: String, value: String) {
        this.name = name
        this.value = value
    }
    public func toString(): String {
        "${name}='${value}'"
    }
}

public class XmlElement <: ToString {
    var parent: XmlElement = unsafe { zeroValue<XmlElement>() }
    let namespaces = ArrayList<QName>()
    let attributes = ArrayList<XmlAttr>()
    let childrenElements = ArrayList<XmlElement>()
    var name: String
    var content: String
    init(name: String, content: String) {
        this.name = name
        this.content = content
    }
    public func toXmlString(): String {
        let str = StringBuilder("<${name}")
        for (ns in namespaces) {
            if (ns.getPrefix() == "") {
                str.append(" xmlns='${ns.getNamespaceURI()}'")
            } else {
                str.append(" xmlns:${ns.getPrefix()}='${ns.getNamespaceURI()}'")
            }
        }
        for (attr in attributes) {
            str.append(" ${attr.name}='${attr.value}'")
        }
        str.append(">")
        for (child in childrenElements) {
            str.append(child.toXmlString())
        }
        str.append("</${name}>")
        str.toString()
    }
    public func toString(): String {
        toXmlString()
    }
    static func parse(xml: String): XmlElement {
        let input = ByteArrayStream()
        input.write(xml.toArray())
        let parser = XmppXmlParser.newXmlParser(input)

        // root 空节点
        let tag = QName("")
        var current: XmlElement = XmlElement("", "")

        while (!(parser.next() == XmlPullParserEvent.END_ELEMENT && parser.getQName() == tag)) {
            match (parser.getEventType()) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let element = XmlElement(parser.getQName().getFullName(), "")
                    // namespaces
                    for (i in 0..parser.getNamespaceCount()) {
                        let prefix = parser.getNamespacePrefix(i)
                        let nsuri = parser.getNamespaceUri(i)
                        let qname = QName(nsuri, "", prefix)
                        current.namespaces.append(qname)
                    }
                    // attributes
                    for (i in 0..parser.getAttributeCount()) {
                        let qname = parser.getAttributeQName(i)
                        let value = parser.getAttributeValue(i)
                        let attr = XmlAttr(qname.getFullName(), value)
                        current.attributes.append(attr)
                    }
                    current.childrenElements.append(element)
                    element.parent = current
                    current = element
                case XmlPullParserEvent.TEXT_CHARACTERS => current.content = parser.getText()
                case XmlPullParserEvent.END_ELEMENT => current = current.parent
                case v => break
            }
        }
        current.childrenElements[0]
    }
}

public class XMLBuilder {
    public static func create(name: String): XMLBuilder {
        let doc = XMLBuilder(name)
        doc
    }
    public static func create(name: String, namespace: String): XMLBuilder {
        let doc = XMLBuilder(name, namespace)
        doc
    }

    var namespaceURI: String = ""
    let ele: XmlElement
    let children = ArrayList<XMLBuilder>()
    var parent: ?XMLBuilder = None

    public init(name: String) {
        ele = XmlElement(name, "")
    }
    public init(name: String, namespaceURI: String) {
        ele = XmlElement(name, "")
        ele.attributes.append(XmlAttr("xmlns", namespaceURI))
        this.namespaceURI = namespaceURI
    }

    public func attribute(name: String, value: String): XMLBuilder {
        ele.attributes.append(XmlAttr(name, value))
        this
    }
    public func a(name: String, value: String): XMLBuilder {
        this.attribute(name, value)
    }

    public func text(value: String): XMLBuilder {
        ele.content = value
        this
    }
    public func t(value: String): XMLBuilder {
        this.text(value)
    }

    public func namespace(ns: String): XMLBuilder {
        this.attribute("xmlns", ns)
    }
    public func ns(ns: String): XMLBuilder {
        this.namespace(ns)
    }

    public func element(name: String): XMLBuilder {
        let child = XMLBuilder(name)
        child.parent = this
        children.append(child)
        ele.childrenElements.append(child.ele)
        child
    }
    public func e(name: String): XMLBuilder {
        this.element(name)
    }

    public func up(): XMLBuilder {
        this.parent.getOrThrow()
    }

    public func asString(property: Map<String, String>): String {
        if ((property.get("omit-xml-declaration") ?? "yes") == "yes") {
            getRoot().ele.toXmlString()
        } else {
            getRoot().ele.toXmlString()
        }
    }
    public func asString(): String {
        let e = getRoot().ele
        e.toString()
    }
    func getRoot(): XMLBuilder {
        var e = this
        while (let Some(v) <- e.parent) {
            e = v
        }
        e
    }
}

let WhiteSpaceReg = Regex("\\s+")

func xmlSimilarSimple(expected: ToString, actual: ToString): Bool {
    if (expected.toString() == actual.toString()) {
        return true
    }
    println("expected: ${expected}")
    println("  actual: ${actual}")

    let expectedArr = WhiteSpaceReg.matcher(expected.toString()).replaceAll(" ") |> collectArray
    expectedArr.sort()
    let actualArr = WhiteSpaceReg.matcher(actual.toString()).replaceAll(" ") |> collectArray
    actualArr.sort()

    println("expected: ${expectedArr}")
    println("actual: ${actualArr}")

    expectedArr == actualArr
}

func xmlSimilarParser(expected: ToString, actual: ToString): Bool {
    if (expected.toString() == actual.toString()) {
        return true
    }
    var expectedStr = WhiteSpaceReg.matcher(expected.toString()).replaceAll(" ")
    var actualStr = WhiteSpaceReg.matcher(actual.toString()).replaceAll(" ")
    println("expected: ${expectedStr}")
    println("  actual: ${actualStr}")

    expectedStr = XmlElement.parse(expectedStr).toXmlString()
    actualStr = XmlElement.parse(actualStr).toXmlString()

    expectedStr == actualStr
}

public class XmlAssertUtil {
    public static func assertXmlNotSimilar(xmlOne: CharSequence, xmlTwo: CharSequence): Unit {
        // normalizedCompare(xmlOne, xmlTwo).areNotSimilar()
        @Assert(false, xmlSimilarParser(xmlOne, xmlTwo))
    }

    public static func assertXmlSimilar(expected: CharSequence, actual: CharSequence): Unit {
        // normalizedCompare(expected, actual).areSimilar()
        @Assert(xmlSimilarParser(expected, actual))
    }

    private static func normalizedCompare(expectedCharSequence: CharSequence, actualCharSequence: CharSequence): Unit {
        // let expectedString:String = expectedCharSequence.toString()
        // let actualString:String = actualCharSequence.toString()

        // let expected:NormalizedSource = NormalizedSource( StreamSource( StringReader(expectedString)))
        // let actual:NormalizedSource = NormalizedSource( StreamSource( StringReader(actualString)))
        // return XmlAssert.assertThat(actual).and(expected)
        //                 .ignoreChildNodesOrder()
        //                 .withNodeMatcher(new DefaultNodeMatcher(ElementSelectors.byNameAndAllAttributes, ElementSelectors.byNameAndText))
        //                 .normalizeWhitespace()
    }
}

public func assertXmlNotSimilar(xmlOne: CharSequence, xmlTwo: CharSequence): Unit {
    XmlAssertUtil.assertXmlNotSimilar(xmlOne, xmlTwo)
}

public func assertXmlSimilar(expected: CharSequence, actual: CharSequence): Unit {
    XmlAssertUtil.assertXmlSimilar(expected, actual)
}

public class XmlAssert {
    var actual: String
    var expected: String
    var _ignoreChildNodesOrder = true
    var matcher: Iterable<NodeMatcher> = []
    var _normalizeWhitespace = false

    public init(actual: String, expected: String) {
        this.actual = actual
        this.expected = expected
    }

    public static func assertThat(actual: String): XmlAssert {
        XmlAssert(actual, "")
    }

    public func and(expected: String): XmlAssert {
        this.expected = expected
        this
    }
    public func ignoreChildNodesOrder(): XmlAssert {
        this._ignoreChildNodesOrder = true
        this
    }
    public func withNodeMatcher(nodeMatcher: Array<NodeMatcher>): XmlAssert {
        matcher = matcher |> concat(nodeMatcher)
        this
    }
    public func normalizeWhitespace(): XmlAssert {
        _normalizeWhitespace = true
        this
    }

    public func areSimilar(): Bool {
        false
    }
    public func areNotSimilar(): Bool {
        !areSimilar()
    }
}

public type NodeMatcher = (XmlElement, XmlElement) -> Bool

public let byName: NodeMatcher = {
    expected: XmlElement, actual: XmlElement => expected.name == actual.name
}
public let byNameAndAllAttributes: NodeMatcher = {
    expected: XmlElement, actual: XmlElement =>
    if (!byName(expected, actual) || expected.attributes.size != actual.attributes.size) {
        return false
    }

    let expectedArr = expected.attributes |> map {attr: XmlAttr => attr.toString()} |> collectArray<String>
    let expectedStr = expectedArr.sort().toString()
    let actualArr = actual.attributes |> map {attr: XmlAttr => attr.toString()} |> collectArray<String>
    let actualStr = actualArr.sort().toString()
    expectedStr == actualStr
}
public let byNameAndText: NodeMatcher = {
    expected: XmlElement, actual: XmlElement => expected.name == actual.name && expected.content == actual.content
}
