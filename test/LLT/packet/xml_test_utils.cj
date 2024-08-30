import encoding.xml.*
import std.collection.*
import std.sort.*
import std.regex.*
import std.unittest.testmacro.*

public class XMLBuilder {
    public static func create(name: String): XMLBuilder {
        let doc = XMLBuilder(name)
        doc.parent = doc
        doc
    }

    var namespaceURI: String = ""
    let ele: XmlElement
    let children = ArrayList<XMLBuilder>()
    var parent: XMLBuilder = unsafe { zeroValue<XMLBuilder>() }

    public init(name: String) {
        ele = XmlElement(name, "")
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
        children.append(child)
        ele.childrenElements.append(child.ele)
        child
    }
    public func e(name: String): XMLBuilder {
        this.element(name)
    }

    public func up(): XMLBuilder {
        this.parent
    }

    public func asString(property: Map<String, String>): String {
        if ((property.get("omit-xml-declaration") ?? "yes") == "yes") {
            ele.toXmlString()
        } else {
            ele.toXmlString()
        }
    }
    public func asString(): String {
        ele.toXmlString()
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

let Xml_Parser: XmlParser = XmlParser()

func xmlSimilarParser(expected: ToString, actual: ToString): Bool {
    if (expected.toString() == actual.toString()) {
        return true
    }
    var expectedStr = WhiteSpaceReg.matcher(expected.toString()).replaceAll(" ")
    var actualStr = WhiteSpaceReg.matcher(actual.toString()).replaceAll(" ")
    println("expected: ${expectedStr}")
    println("  actual: ${actualStr}")

    expectedStr = Xml_Parser.parse(expectedStr).getOrThrow().toXmlString()
    actualStr = Xml_Parser.parse(actualStr).getOrThrow().toXmlString()

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
    var matcher: Iterator<NodeMatcher> = Array<NodeMatcher>([]).iterator()
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
