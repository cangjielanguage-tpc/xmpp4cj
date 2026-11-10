// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../xml_test_utils.cj
// DEPENDENCE: ../smack_test_util.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj xml_test_utils.cj smack_test_util.cj --test
/// EXEC: ./main
/* TODO */
@Test
public class PacketParserUtilsTest {
    private static let outputProperties = HashMap<String, String>([("omit-xml-declaration", "yes")])

    // throws Exception 
    @TestCase[parserKind in [ StAX ]]
    public func singleMessageBodyTest(parserKind: XmlPullParserKind): Unit {
        let defaultLanguage: String = Stanza.getDefaultLanguage()
        let otherLanguage: String = determineNonDefaultLanguage()

        var control: String

        // message has default language, body has no language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", defaultLanguage)
            .e("body")
            .t(defaultLanguage)
            .asString(outputProperties)

        let message: Message = PacketParserUtils.parseMessage(SmackTestUtil.getParserFor(control, parserKind))

        assertEquals(defaultLanguage, message.getBody())
        assertTrue(message.getBodyLanguages().isEmpty())
        assertEquals(defaultLanguage, message.getBody(defaultLanguage))
        assertNull(message.getBody(otherLanguage))
        assertXmlSimilar(control, message.toXML().toString())

        // message has non-default language, body has no language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", otherLanguage)
            .e("body")
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(SmackTestUtil.getParserFor(control, parserKind))

        assertEquals(otherLanguage, message.getBody())
        assertTrue(message.getBodyLanguages().isEmpty())
        assertEquals(otherLanguage, message.getBody(otherLanguage))
        assertNull(message.getBody(defaultLanguage))
        assertXmlSimilar(control, message.toXML().toString())

        // message has no language, body has no language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("body")
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(SmackTestUtil.getParserFor(control, parserKind))

        assertEquals(defaultLanguage, message.getBody())
        assertTrue(message.getBodyLanguages().isEmpty())
        assertEquals(defaultLanguage, message.getBody(None))
        assertNull(message.getBody(otherLanguage))
        assertXmlSimilar(control, message.toXML().toString())

        // message has no language, body has default language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("body")
            .a("xml:lang", defaultLanguage)
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(SmackTestUtil.getParserFor(control, parserKind))

        assertNull(message.getBody())
        assertFalse(message.getBodyLanguages().isEmpty())
        assertEquals(defaultLanguage, message.getBody(defaultLanguage))
        assertNull(message.getBody(otherLanguage))

        assertXmlSimilar(control, message.toXML().toString())

        // message has no language, body has non-default language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("body")
            .a("xml:lang", otherLanguage)
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(SmackTestUtil.getParserFor(control, parserKind))

        assertNull(message.getBody())
        assertFalse(message.getBodyLanguages().isEmpty())
        assertTrue(message.getBodyLanguages().contains(otherLanguage))
        assertEquals(otherLanguage, message.getBody(otherLanguage))
        assertNull(message.getBody(defaultLanguage))
        assertXmlSimilar(control, message.toXML().toString())

        // message has default language, body has non-default language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", defaultLanguage)
            .e("body")
            .a("xml:lang", otherLanguage)
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(SmackTestUtil.getParserFor(control, parserKind))

        assertNull(message.getBody())
        assertFalse(message.getBodyLanguages().isEmpty())
        assertTrue(message.getBodyLanguages().contains(otherLanguage))
        assertEquals(otherLanguage, message.getBody(otherLanguage))
        assertNull(message.getBody(defaultLanguage))
        assertXmlSimilar(control, message.toXML().toString())

        // message has non-default language, body has default language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", otherLanguage)
            .e("body")
            .a("xml:lang", defaultLanguage)
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(SmackTestUtil.getParserFor(control, parserKind))

        assertNull(message.getBody())
        assertFalse(message.getBodyLanguages().isEmpty())
        assertTrue(message.getBodyLanguages().contains(defaultLanguage))
        assertEquals(defaultLanguage, message.getBody(defaultLanguage))
        assertNull(message.getBody(otherLanguage))
        assertXmlSimilar(control, message.toXML().toString())
    }

    // throws Exception 
    @TestCase
    public func singleMessageSubjectTest(): Unit {
        let defaultLanguage: String = Stanza.getDefaultLanguage()
        let otherLanguage: String = determineNonDefaultLanguage()

        var control: String

        // message has default language, subject has no language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", defaultLanguage)
            .e("subject")
            .t(defaultLanguage)
            .asString(outputProperties)

        let message: Message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getSubject())
        assertTrue(message.getSubjectLanguages().isEmpty())
        assertEquals(defaultLanguage, message.getSubject(defaultLanguage))
        assertNull(message.getSubject(otherLanguage))
        assertXmlSimilar(control, message.toXML())

        // message has non-default language, subject has no language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", otherLanguage)
            .e("subject")
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(otherLanguage, message.getSubject())
        assertTrue(message.getSubjectLanguages().isEmpty())
        assertEquals(otherLanguage, message.getSubject(otherLanguage))
        assertNull(message.getSubject(defaultLanguage))
        assertXmlSimilar(control, message.toXML())

        // message has no language, subject has no language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("subject")
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getSubject())
        assertTrue(message.getSubjectLanguages().isEmpty())
        assertEquals(defaultLanguage, message.getSubject(None))
        assertNull(message.getSubject(otherLanguage))
        assertXmlSimilar(control, message.toXML())

        // message has no language, subject has default language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("subject")
            .a("xml:lang", defaultLanguage)
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertFalse(message.getSubjectLanguages().isEmpty())
        assertEquals(defaultLanguage, message.getSubject(defaultLanguage))
        assertNull(message.getSubject(otherLanguage))

        assertXmlSimilar(control, message.toXML())

        // message has no language, subject has non-default language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("subject")
            .a("xml:lang", otherLanguage)
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertNull(message.getSubject())
        assertFalse(message.getSubjectLanguages().isEmpty())
        assertTrue(message.getSubjectLanguages().contains(otherLanguage))
        assertEquals(otherLanguage, message.getSubject(otherLanguage))
        assertNull(message.getSubject(defaultLanguage))
        assertXmlSimilar(control, message.toXML())

        // message has default language, subject has non-default language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", defaultLanguage)
            .e("subject")
            .a("xml:lang", otherLanguage)
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertNull(message.getSubject())
        assertFalse(message.getSubjectLanguages().isEmpty())
        assertTrue(message.getSubjectLanguages().contains(otherLanguage))
        assertEquals(otherLanguage, message.getSubject(otherLanguage))
        assertNull(message.getSubject(defaultLanguage))
        assertXmlSimilar(control, message.toXML())

        // message has non-default language, subject has default language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", otherLanguage)
            .e("subject")
            .a("xml:lang", defaultLanguage)
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertNull(message.getSubject())
        assertFalse(message.getSubjectLanguages().isEmpty())
        assertTrue(message.getSubjectLanguages().contains(defaultLanguage))
        assertEquals(defaultLanguage, message.getSubject(defaultLanguage))
        assertNull(message.getSubject(otherLanguage))
        assertXmlSimilar(control, message.toXML())
    }

    // throws Exception 
    @TestCase
    public func multipleMessageBodiesTest(): Unit {
        let defaultLanguage: String = Stanza.getDefaultLanguage()
        let otherLanguage: String = determineNonDefaultLanguage()

        var control: String
        var message: Message

        // message has default language, first body no language, second body other language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", defaultLanguage)
            .e("body")
            .t(defaultLanguage)
            .up()
            .e("body")
            .a("xml:lang", otherLanguage)
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getBody())
        assertEquals(otherLanguage, message.getBody(otherLanguage))
        assertEquals(2, message.getBodies().size())
        assertEquals(1, message.getBodyLanguages().size())
        assertTrue(message.getBodyLanguages().contains(otherLanguage))
        assertXmlSimilar(control, message.toXML().toString())

        // message has non-default language, first body no language, second body default language
        control = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", otherLanguage)
            .e("body")
            .t(otherLanguage)
            .up()
            .e("body")
            .a("xml:lang", defaultLanguage)
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(otherLanguage, message.getBody())
        assertEquals(defaultLanguage, message.getBody(defaultLanguage))
        assertEquals(2, message.getBodies().size())
        assertEquals(1, message.getBodyLanguages().size())
        assertTrue(message.getBodyLanguages().contains(defaultLanguage))
        assertXmlSimilar(control, message.toXML().toString())
    }

    // TODO: Re-enable once we throw an exception on duplicate body elements.
    // throws FactoryConfigurationError, XmlPullParserException, IOException, Exception 
    @Skip
    @TestCase
    public func duplicateMessageBodiesTest(): Unit {
        let defaultLanguage: String = Stanza.getDefaultLanguage()

        // message has default language, first body no language, second body default language
        let control: String = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", defaultLanguage)
            .e("body")
            .t(defaultLanguage)
            .up()
            .e("body")
            .a("xml:lang", defaultLanguage)
            .t(defaultLanguage + "2")
            .asString(outputProperties)

        let message: Message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getBody())
        assertEquals(defaultLanguage, message.getBody(defaultLanguage))
        assertEquals(1, message.getBodies().size())
        assertEquals(0, message.getBodyLanguages().size())
        assertXmlNotSimilar(control, message.toXML().toString())
    }

    // throws FactoryConfigurationError, XmlPullParserException, IOException, Exception 
    @Skip
    @TestCase
    public func duplicateMessageBodiesTest2(): Unit {
        let defaultLanguage: String = Stanza.getDefaultLanguage()
        let otherLanguage: String = determineNonDefaultLanguage()

        // message has no language, first body no language, second body no language
        let control: String = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("xml:lang", defaultLanguage)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("body")
            .t(defaultLanguage)
            .up()
            .e("body")
            .t(otherLanguage)
            .asString(outputProperties)

        PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))
    }

    // throws FactoryConfigurationError, XmlPullParserException, IOException, Exception 
    @TestCase
    public func messageNoLanguageFirstBodyNoLanguageSecondBodyOtherTest(): Unit {
        let defaultLanguage: String = Stanza.getDefaultLanguage()
        let otherLanguage: String = determineNonDefaultLanguage()

        // message has no language, first body no language, second body other language
        let control: String = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("body")
            // TODO change default language into something else
            .t(defaultLanguage)
            .up()
            .e("body")
            .a("xml:lang", otherLanguage)
            .t(otherLanguage)
            .asString(outputProperties)

        let message: Message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getBody())
        assertEquals(defaultLanguage, message.getBody(None))
        assertEquals(otherLanguage, message.getBody(otherLanguage))
        assertEquals(2, message.getBodies().size())
        assertEquals(1, message.getBodyLanguages().size())
        assertXmlSimilar(control, message.toXML().toString())
    }

    // throws Exception 
    @TestCase
    public func multipleMessageSubjectsTest(): Unit {
        let defaultLanguage: String = Stanza.getDefaultLanguage()
        let otherLanguage: String = determineNonDefaultLanguage()

        var control: String
        var message: Message

        // message has default language, first subject no language, second subject other language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", defaultLanguage)
            .e("subject")
            .t(defaultLanguage)
            .up()
            .e("subject")
            .a("xml:lang", otherLanguage)
            .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getSubject())
        assertEquals(otherLanguage, message.getSubject(otherLanguage))
        assertEquals(2, message.getSubjects().size())
        assertEquals(1, message.getSubjectLanguages().size())
        assertTrue(message.getSubjectLanguages().contains(otherLanguage))
        assertXmlSimilar(control, message.toXML())

        // message has non-default language, first subject no language, second subject default language
        control = XMLBuilder
            .create("message")
            .ns(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", otherLanguage)
            .e("subject")
            .t(otherLanguage)
            .up()
            .e("subject")
            .a("xml:lang", defaultLanguage)
            .t(defaultLanguage)
            .asString(outputProperties)

        message = PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(otherLanguage, message.getSubject())
        assertEquals(defaultLanguage, message.getSubject(defaultLanguage))
        assertEquals(2, message.getSubjects().size())
        assertEquals(1, message.getSubjectLanguages().size())
        assertTrue(message.getSubjectLanguages().contains(defaultLanguage))
        assertXmlSimilar(control, message.toXML())

        /*
        // message has no language, first subject no language, second subject default language
        control = XMLBuilder.create("message")
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("subject")
                .t(defaultLanguage)
            .up()
            .e("subject")
                .a("xml:lang", defaultLanguage)
                .t(defaultLanguage + "2")
            .asString(outputProperties)

        message = PacketParserUtils
                        .parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getSubject())
        assertEquals(defaultLanguage, message.getSubject(defaultLanguage))
        assertEquals(1, message.getSubjects().size())
        assertEquals(0, message.getSubjectLanguages().size())
        assertXMLNotEqual(control, message.toXML(StreamOpen.CLIENT_NAMESPACE).toString())

        // message has no language, first subject no language, second subject other language
        control = XMLBuilder.create("message")
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("subject")
                .t(defaultLanguage)
            .up()
            .e("subject")
                .a("xml:lang", otherLanguage)
                .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils
                        .parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getSubject())
        assertEquals(defaultLanguage, message.getSubject(defaultLanguage))
        assertEquals(otherLanguage, message.getSubject(otherLanguage))
        assertEquals(2, message.getSubjects().size())
        assertEquals(1, message.getSubjectLanguages().size())
        assertXmlSimilar(control, message.toXML(StreamOpen.CLIENT_NAMESPACE).toString())

        // message has no language, first subject no language, second subject no language
        control = XMLBuilder.create("message")
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .e("subject")
                .t(defaultLanguage)
            .up()
            .e("subject")
                .t(otherLanguage)
            .asString(outputProperties)

        message = PacketParserUtils
                        .parseMessage(PacketParserUtils.getParserFor(control))

        assertEquals(defaultLanguage, message.getSubject())
        assertEquals(defaultLanguage, message.getSubject(defaultLanguage))
        assertEquals(1, message.getSubjects().size())
        assertEquals(0, message.getSubjectLanguages().size())
        assertXMLNotEqual(control, message.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
         */
    }

    /**
     * RFC6121 5.2.3 explicitly disallows mixed content in <body/> elements. Make sure that we throw
     * an exception if we encounter such an element.
     *
     * @throws Exception if an exception occurs.
     */
    @TestCase
    public func invalidMessageBodyContainingTagTest(): Unit {
        let control: String = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", "en")
            .e("body")
            .a("xmlns", "http://www.w3.org/1999/xhtml")
            .e("span")
            .a("style", "font-weight: bold;")
            .t("Bad Message Body")
            .asString(outputProperties)

        @AssertThrows[XmlPullParserException](PacketParserUtils.parseMessage(TestUtils.getMessageParser(control)))
    }

    // throws Exception 
    @TestCase
    public func invalidXMLInMessageBody(): Unit {
        let validControl: String = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", "en")
            .e("body")
            .t("Good Message Body")
            .asString(outputProperties)

        @AssertThrows[XmlPullParserException]({=>
            let invalidControl:String = validControl.replace("Good Message Body", "Bad </span> Body")
            PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(invalidControl))
        }())

        @AssertThrows[XmlPullParserException]({=>
            let invalidControl:String = validControl.replace("Good Message Body", "Bad </body> Body")
            PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(invalidControl))
        }())

        @AssertThrows[XmlPullParserException]({=>
            let invalidControl:String = validControl.replace("Good Message Body", "Bad </message> Body")
            PacketParserUtils.parseMessage(PacketParserUtils.getParserFor(invalidControl))
        }())
    }

    // throws Exception 
    @TestCase
    public func multipleMessageBodiesParsingTest(): Unit {
        let control: String = XMLBuilder
            .create("message")
            .namespace(StreamOpen.CLIENT_NAMESPACE)
            .a("from", "romeo@montague.lit/orchard")
            .a("to", "juliet@capulet.lit/balcony")
            .a("id", "zid615d9")
            .a("type", "chat")
            .a("xml:lang", "en")
            .e("body")
            .t("This is a test of the emergency broadcast system, 1.")
            .up()
            .e("body")
            .a("xml:lang", "ru")
            .t("This is a test of the emergency broadcast system, 2.")
            .up()
            .e("body")
            .a("xml:lang", "sp")
            .t("This is a test of the emergency broadcast system, 3.")
            .asString(outputProperties)

        let message: Stanza = PacketParserUtils.parseStanza(control)
        assertXmlSimilar(control, message.toXML())
    }

    // throws Exception 
    @TestCase
    public func validateSimplePresence(): Unit {
        let stanza: String = "<presence from='juliet@example.com/balcony' to='romeo@example.net'/>"

        let presence: Presence = PacketParserUtils.parsePresence(PacketParserUtils.getParserFor(stanza))

        assertXmlSimilar(stanza, presence.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    // throws Exception 
    @TestCase
    public func validatePresenceProbe(): Unit {
        let stanza: String = "<presence from='mercutio@example.com' id='xv291f38' to='juliet@example.com' type='unsubscribed'/>"

        let presence: Presence = PacketParserUtils.parsePresence(PacketParserUtils.getParserFor(stanza))

        assertXmlSimilar(stanza, presence.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
        assertEquals(Presence.Type.unsubscribed, presence.getType())
    }

    // throws Exception 
    @TestCase
    public func validatePresenceOptionalElements(): Unit {
        let stanza: String = "<presence xml:lang='en' type='unsubscribed'>" + "<show>dnd</show>" +
            "<status>Wooing Juliet</status>" + "<priority>1</priority>" + "</presence>"

        let presence: Presence = PacketParserUtils.parsePresence(PacketParserUtils.getParserFor(stanza))
        assertXmlSimilar(stanza, presence.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
        assertEquals(Presence.Type.unsubscribed, presence.getType())
        assertEquals("dnd", presence.getMode().name())
        assertEquals("en", presence.getLanguage())
        assertEquals("Wooing Juliet", presence.getStatus())
        assertEquals(1, presence.getPriority())
    }

    // throws Exception 
    // @TestCase
    // public func parseContentDepthTest() :Unit{
    //      let stanza:String = "<iq type='result' to='foo@bar.com' from='baz.com' id='42'/>"
    //     let parser:XmlPullParser= TestUtils.getParser(stanza, "iq")
    //     let content:CharSequence= PacketParserUtils.parseContent(parser)
    //     assertEquals("", content.toString())
    // }

    // throws ParserConfigurationException,FactoryConfigurationError, XmlPullParserException,IOException, TransformerException, SAXException 
    @TestCase
    public func parseElementMultipleNamespace(): Unit {
        // @formatter:off
        let stanza: String = XMLBuilder
            .create("outer", "outerNamespace")
            .a("outerAttribute", "outerValue")
            .element("inner", "innerNamespace")
            .a("innerAttribute", "innerValue")
            .element("innermost")
            .t("some text")
            .asString()
        // @formatter:on
        let parser: XmlPullParser = TestUtils.getParser(stanza, "outer")
        let result: CharSequence = PacketParserUtils.parseElement(parser, true)
        assertXmlSimilar(stanza, result.toString())
    }

    private static func determineNonDefaultLanguage(): String {
        let otherLanguage: String = "jp"
        // let availableLocales:Array<Locale>  = Locale.getAvailableLocales()
        // for (int i = 0; i < availableLocales.length; i++) {
        //     if (availableLocales[i] != Locale.getDefault()) {
        //         otherLanguage = availableLocales[i].getLanguage().toLowerCase(Locale.US)
        //         // Check for empty strings as Java8 returns those here for certain Locales
        //         if (otherLanguage.length() > 0) {
        //             break
        //         }
        //     }
        // }
        return otherLanguage
    }

    // throws Exception 
    @TestCase
    public func descriptiveTextNullLangPassedMap(): Unit {
        let text: String = "Dummy descriptive text"
        let texts: Map<String, String> = HashMap<String, String>()
        texts.put(None, text)

        @AssertThrows[IllegalArgumentException](
            StanzaError
                .getBuilder(StanzaError.Condition.internal_server_error)
                .setDescriptiveTexts(texts)
                .build()
        )
    }

    // throws Exception 
    @TestCase
    public func ensureNoEmptyLangInDescriptiveText(): Unit {
        let text: String = "Dummy descriptive text"
        let texts: Map<String, String> = HashMap<String, String>()
        texts.put("", text)
        let error: StanzaError = StanzaError
            .getBuilder(StanzaError.Condition.internal_server_error)
            .setDescriptiveTexts(texts)
            .build()
        let errorXml: String = XMLBuilder
            .create(StanzaError.ERROR)
            .a("type", "cancel")
            .up()
            .element("internal-server-error", StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE)
            .up()
            .element("text", StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE)
            .t(text)
            .up()
            .asString()
        assertXmlSimilar(errorXml, error.toXML(StreamOpen.CLIENT_NAMESPACE))
    }

    // throws Exception 
    @TestCase
    public func ensureNoNullLangInParsedDescriptiveTexts(): Unit {
        let text: String = "Dummy descriptive text"
        let errorXml: String = XMLBuilder
            .create(StanzaError.ERROR)
            .a("type", "cancel")
            .up()
            .element("internal-server-error", StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE)
            .up()
            .element("text", StanzaError.ERROR_CONDITION_AND_TEXT_NAMESPACE)
            .t(text)
            .up()
            .asString()
        let parser: XmlPullParser = TestUtils.getParser(errorXml)
        let error: StanzaError = PacketParserUtils.parseError(parser)
        assertEquals(text, error.getDescriptiveText())
    }

    // throws TransformerException, ParserConfigurationException, FactoryConfigurationError, XmlPullParserException, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testParseElementSimple(parserKind: XmlPullParserKind): Unit {
        let unknownElement: String = XMLBuilder
            .create("unknown-element")
            .ns("https://example.org/non-existent")
            .e("inner")
            .t("test")
            .asString(outputProperties)

        let xmlPullParser: XmlPullParser = SmackTestUtil.getParserFor(unknownElement, parserKind)

        let unknownElementParsed: CharSequence = PacketParserUtils.parseElement(xmlPullParser)
        assertXmlSimilar(unknownElement, unknownElementParsed)
    }

    // throws TransformerException, ParserConfigurationException, FactoryConfigurationError, XmlPullParserException, IOException 
    @TestCase[parserKind in [ StAX ]]
    public func testParseElementExtended(parserKind: XmlPullParserKind): Unit {
        let unknownElement: String = XMLBuilder
            .create("unknown-element")
            .ns("https://example.org/non-existent")
            .a("attribute-outer", "foo")
            .e("inner")
            .a("attribute-inner", "bar")
            .a("attribute-inner-2", "baz")
            .t("test")
            .up()
            .e("empty-element")
            .up()
            .asString(outputProperties)

        let xmlPullParser: XmlPullParser = SmackTestUtil.getParserFor(unknownElement, parserKind)

        let unknownElementParsed: CharSequence = PacketParserUtils.parseElement(xmlPullParser)
        assertXmlSimilar(unknownElement, unknownElementParsed)
    }
}
