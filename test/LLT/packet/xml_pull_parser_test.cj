// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../xml_test_utils.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_test_utils.cj smack_test_util.cj --test
// EXEC: ./main 
//--filter=*.testAttributesNamespacedElementWithOneAttribute

@Test
public class XmlPullParserTest {

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testSimpleEmptyElement(parserKind: XmlPullParserKind): Unit {
        var reader = ByteBuffer()
        reader.write("<empty-element/>".toArray())
        let parser: XmlPullParser = parserKind.factory.newXmlPullParser(reader)

        assertEquals(XmlPullParserEvent.START_DOCUMENT, parser.getEventType())
        assertEquals(XmlPullParserEvent.START_ELEMENT, parser.next())
        var qname: QName = parser.getQName()
        assertEquals(qname.getLocalPart(), "empty-element")
        assertEquals(qname.getPrefix(), "")
        assertEquals(qname.getNamespaceURI(), "")
        assertEquals(XmlPullParserEvent.END_ELEMENT, parser.next())
        assertEquals(XmlPullParserEvent.END_DOCUMENT, parser.next())
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testQNameSimpleElement(parserKind: XmlPullParserKind): Unit {
        var simpleElement: String = "<outer-element xmlns='outer-namespace'><inner-element/></outer-element>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(simpleElement, parserKind)
        var qname: QName = parser.getQName()
        assertEquals("outer-element", qname.getLocalPart())
        assertEquals("outer-namespace", qname.getNamespaceURI())
        assertEquals(XmlPullParserEvent.START_ELEMENT, parser.next())
        qname = parser.getQName()
        assertEquals("inner-element", qname.getLocalPart())
        assertEquals("outer-namespace", qname.getNamespaceURI())
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testQNamePrefixElement(parserKind: XmlPullParserKind): Unit {
        var prefixElement: String = "<outer-element xmlns='outer-namespace' xmlns:inner-prefix='inner-namespace'><inner-prefix:inner-element></outer-element>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(prefixElement, parserKind)
        var qname: QName = parser.getQName()
        assertEquals("outer-element", qname.getLocalPart())
        assertEquals("outer-namespace", qname.getNamespaceURI())
        assertEquals(XmlPullParserEvent.START_ELEMENT, parser.next())
        qname = parser.getQName()
        assertEquals("inner-element", qname.getLocalPart())
        assertEquals("inner-namespace", qname.getNamespaceURI())
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testAttributesElementWithOneAttribute(parserKind: XmlPullParserKind): Unit {
        var elementWithOneAttribute: String = "<element attribute-one='attribute-one-value'/>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(elementWithOneAttribute, parserKind)
        assertAttributeHolds(parser, 0, "attribute-one", "", "")
        assertThrows<IndexOutOfBoundsException>({=> assertAttributeHolds(parser, 1, "attribute-one", "", "")})
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testAttributesNamespacedElementWithOneAttribute(parserKind: XmlPullParserKind): Unit {
        var namespacedElementWithOneAttribute: String = "<element xmlns='element-namespace' attribute-one='attribute-one-value'/>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(namespacedElementWithOneAttribute, parserKind)
        assertAttributeHolds(parser, 0, "attribute-one", "", "")
        // assertThrows<IndexOutOfBoundsException>({=> assertAttributeHolds(parser, 1, "attribute-one", "", "")})
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testAttributesNamespacedElementWithOneNamespacedAttribute(parserKind: XmlPullParserKind): Unit {
        var namespacedElementWithOneNamespacedAttribute: String = "<element xmlns='element-namespace' xmlns:attribute-namespace='attribute-namespace-value' attribute-namespace:attribute-one='attribute-one-value'/>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(namespacedElementWithOneNamespacedAttribute, parserKind)
        assertAttributeHolds(parser, 0, "attribute-one", "attribute-namespace", "attribute-namespace-value")
        assertThrows<IndexOutOfBoundsException>({=> assertAttributeHolds(parser, 1, "attribute-one", "", "")})
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testNamespacedAttributes(parserKind: XmlPullParserKind): Unit {
        var element: String = "<element xmlns:attr='attribute-namespace' attr:attributeOneName='attributeOneValue'/>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(element, parserKind)
        assertEquals(1, parser.getAttributeCount())

        assertEquals("attributeOneName", parser.getAttributeName(0))
        assertEquals("attr", parser.getAttributePrefix(0))
        assertEquals("attribute-namespace", parser.getAttributeNamespace(0))
        var attributeZeroQname: QName = parser.getAttributeQName(0)
        assertEquals("attributeOneName", attributeZeroQname.getLocalPart())
        assertEquals("attr", attributeZeroQname.getPrefix())
        assertEquals("attribute-namespace", attributeZeroQname.getNamespaceURI())

        // Test how parser handle non-existent attributes.
        @AssertThrows[IndexOutOfBoundsException](parser.getAttributeName(1))
        @AssertThrows[IndexOutOfBoundsException](parser.getAttributePrefix(1))
        @AssertThrows[IndexOutOfBoundsException](parser.getAttributeNamespace(1))
        @AssertThrows[IndexOutOfBoundsException](parser.getAttributeQName(1))
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testAttributeType(parserKind: XmlPullParserKind): Unit {
        var element: String = "<element xmlns:attr='attribute-namespace' attr:attributeOneName='attributeOneValue'/>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(element, parserKind)

        assertEquals("CDATA", parser.getAttributeType(0))

        @AssertThrows[XmlPullParserException](parser.getAttributeType(1))
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testNextText(parserKind: XmlPullParserKind): Unit {
        var parser: XmlPullParser

        var simpleElement: String = "<element>Element text</element>"
        parser = SmackTestUtil.getParserFor(simpleElement, parserKind)
        assertEquals("Element text", parser.nextText())

        var complexElement: String = "<outer-elment><element1>Element 1 &apos; text</element1><element2>Element 2 text</element2></outer-element>"
        parser = SmackTestUtil.getParserFor(complexElement, parserKind)
        assertEquals(XmlPullParserEvent.START_ELEMENT, parser.next())
        assertEquals("element1", parser.getName())
        assertEquals(0, parser.getAttributeCount())
        assertEquals("Element 1 ' text", parser.nextText())

        assertEquals(XmlPullParserEvent.START_ELEMENT, parser.next())
        assertEquals("element2", parser.getName())
        assertEquals(0, parser.getAttributeCount())
        assertEquals("Element 2 text", parser.nextText())
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testNextTextMixedContent(parserKind: XmlPullParserKind): Unit {
        var element: String = "<element>Mixed content element text<inner-element>Inner element text</inner-element></element>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(element, parserKind)
        @AssertThrows[XmlPullParserException](parser.nextText())
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testNextTextOnEndElement(parserKind: XmlPullParserKind): Unit {
        var element: String = "<element>Element text</element>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(element, parserKind)
        assertEquals(XmlPullParserEvent.START_ELEMENT, parser.getEventType())
        assertEquals(XmlPullParserEvent.TEXT_CHARACTERS, parser.next())
        assertEquals(XmlPullParserEvent.END_ELEMENT, parser.next())
        assertThrows<XmlPullParserException>({=> parser.nextText()})
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testNextTextOnEmptyElement(parserKind: XmlPullParserKind): Unit {
        let emptyElementStream: Array<String> = []
        for (emptyElement in emptyElementStream) {
            let parser: XmlPullParser = SmackTestUtil.getParserFor(emptyElement, parserKind)
            assertEquals(XmlPullParserEvent.START_ELEMENT, parser.getEventType())
            assertEquals("", parser.nextText())
        }
    }

    // XmlPullParserException:throws, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testGetNamespace(parserKind: XmlPullParserKind): Unit {
        var xml: String = "<foo:bar xmlns='namespace' xmlns:foo='foo-namespace'/>"
        let parser: XmlPullParser = SmackTestUtil.getParserFor(xml, parserKind)

        var parsedName: String = parser.getName()
        assertEquals("bar", parsedName)

        var parsedPrefix: String = parser.getPrefix()
        assertEquals("foo", parsedPrefix)

        var parsedPrefixNamespace: ?String = parser.getNamespace(parsedPrefix)
        println(parsedPrefixNamespace)
        assertEquals("foo-namespace", parsedPrefixNamespace)

        var parsedNamespace: ?String = parser.getNamespace()
        assertEquals("foo-namespace", parsedNamespace)

        let defaultNamespaceRetrievers = ArrayList<(XmlPullParser) -> ?String>()
        defaultNamespaceRetrievers.add({p => p.getNamespace(None)})
        defaultNamespaceRetrievers.add({p => p.getDefaultNamespace()})
        for (defaultNamespaceRetriever in defaultNamespaceRetrievers) {
            var defaultNamespace: ?String = defaultNamespaceRetriever(parser)
            assertEquals("namespace", defaultNamespace)
        }
    }

    private static func assertAttributeHolds(parser: XmlPullParser, attributeIndex: Int, expectedLocalpart: String,
        expectedPrefix: String, expectedNamespace: String): Unit {
        var qname: QName = parser.getAttributeQName(attributeIndex)
        var qnameNamespaceUri: String = qname.getNamespaceURI()

        assertEquals(expectedLocalpart, qname.getLocalPart())
        assertEquals(expectedPrefix, qname.getPrefix())
        assertEquals(expectedNamespace, qnameNamespaceUri)

        assertEquals(qname.getLocalPart(), parser.getAttributeName(attributeIndex))
        assertEquals(qname.getPrefix(), parser.getAttributePrefix(attributeIndex))

        let expectedGetAttributeNamespace: ?String
        if (qnameNamespaceUri.equals("")) {
            expectedGetAttributeNamespace = None
        } else {
            expectedGetAttributeNamespace = qnameNamespaceUri
        }
        assertEquals(qnameNamespaceUri, parser.getAttributeNamespace(attributeIndex))
    }
}

@Test
public class StaxParserTest {

    // throws XmlPullParserException, IOException 
    @TestCase
    public func factoryTest(): Unit {
        let staxXmlPullParserFactory = StaxXmlPullParserFactory()
        let input = ByteBuffer()
        input.write("<element/>".toArray())
        let parser = staxXmlPullParserFactory.newXmlPullParser(input)
        parser.next()
    }
}
