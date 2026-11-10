// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// DEPENDENCE: ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj xml_test_utils.cj --test
// EXEC: ./main 
//--filter=*.setPresenceModeTest

@Test
public class MessageTest {
    @TestCase
    public func setMessageTypeTest(): Unit {
        let typ: MessageType = MessageType.chat
        let type2: MessageType = MessageType.headline

        var controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<message")
        controlBuilder.append(" type=\"")
        controlBuilder.append(typ)
        controlBuilder.append("\">")
        controlBuilder.append("</message>")
        var control: String = controlBuilder.toString()

        var messageBuildWithBuilder: Message = StanzaBuilder.buildMessage().ofType(MessageType.chat).build()

        assertEquals(typ, messageBuildWithBuilder.getType())
        assertXmlSimilar(control, messageBuildWithBuilder.toXML(StreamOpen.CLIENT_NAMESPACE).toString())

        controlBuilder = StringBuilder()
        controlBuilder.append("<message")
        controlBuilder.append(" type=\"")
        controlBuilder.append(type2)
        controlBuilder.append("\">")
        controlBuilder.append("</message>")
        control = controlBuilder.toString()

        var messageTypeSet: Message = StanzaBuilder.buildMessage().ofType(type2).build()
        assertEquals(type2, messageTypeSet.getType())
        assertXmlSimilar(control, messageTypeSet.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase()
    public func setNullMessageBodyTest(): Unit {
        @AssertThrows(StanzaBuilder.buildMessage().addBody("", "None").build())
    }

    @TestCase
    public func setMessageSubjectTest(): Unit {
        let messageSubject: String = "This is a test of the emergency broadcast system."

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<message>")
        controlBuilder.append("<subject>")
        controlBuilder.append(messageSubject)
        controlBuilder.append("</subject>")
        controlBuilder.append("</message>")
        let control: String = controlBuilder.toString()

        let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
        assertEquals(messageSubject, message.getSubject())
        assertXmlSimilar(control, message.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase
    public func oneMessageBodyTest(): Unit {
        let messageBody: String = "This is a test of the emergency broadcast system."

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<message>")
        controlBuilder.append("<body>")
        controlBuilder.append(messageBody)
        controlBuilder.append("</body>")
        controlBuilder.append("</message>")
        let control: String = controlBuilder.toString()

        let message: Message = StanzaBuilder.buildMessage().setBody(messageBody).build()
        assertEquals(messageBody, message.getBody())
        assertXmlSimilar(control, message.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase
    public func multipleMessageBodiesTest(): Unit {
        let messageBody1: String = "This is a test of the emergency broadcast system, 1."
        let lang2: String = "ru"
        let messageBody2: String = "This is a test of the emergency broadcast system, 2."
        let lang3: String = "sp"
        let messageBody3: String = "This is a test of the emergency broadcast system, 3."

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<message>")
        controlBuilder.append("<body>")
        controlBuilder.append(messageBody1)
        controlBuilder.append("</body>")
        controlBuilder.append("<body xml:lang=\"")
        controlBuilder.append(lang2)
        controlBuilder.append("\">")
        controlBuilder.append(messageBody2)
        controlBuilder.append("</body>")
        controlBuilder.append("<body xml:lang=\"")
        controlBuilder.append(lang3)
        controlBuilder.append("\">")
        controlBuilder.append(messageBody3)
        controlBuilder.append("</body>")
        controlBuilder.append("</message>")
        let control: String = controlBuilder.toString()

        let message: Message = StanzaBuilder
            .buildMessage()
            .addBody(None, messageBody1)
            .addBody(lang2, messageBody2)
            .addBody(lang3, messageBody3)
            .build()
        assertXmlSimilar(control, message.toXML(StreamOpen.CLIENT_NAMESPACE))

        let languages: HashSet<String> = message.getBodyLanguages() |> filter {v => v.isSome()} |> map {v => v()} |>
            collectHashSet
        let controlLanguages: ArrayList<String> = ArrayList<String>()
        controlLanguages.add(lang2)
        controlLanguages.add(lang3)
        println("controlLanguages0: ${controlLanguages} ${languages}")
        controlLanguages.removeIf {c => languages.contains(c)}
        println("controlLanguages1: ${controlLanguages}")
        assertTrue(controlLanguages.size == 0)
    }

    @TestCase
    public func simpleMessageBodyTest(): Unit {
        var message: Message = StanzaBuilder.buildMessage().setBody("test").build()
        assertTrue(message.getBodies().size == 1)

        message = StanzaBuilder.buildMessage().build()
        assertTrue(message.getBodies().size == 0)

        message = StanzaBuilder.buildMessage().addBody("es", "test").build()
        assertTrue(message.getBodies().size == 1)
    }

    @TestCase
    public func setMessageThreadTest(): Unit {
        let messageThread: String = "1234"

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<message>")
        controlBuilder.append("<thread>")
        controlBuilder.append(messageThread)
        controlBuilder.append("</thread>")
        controlBuilder.append("</message>")
        let control: String = controlBuilder.toString()

        let message: Message = StanzaBuilder.buildMessage().setThread(messageThread).build()

        for (ext in message.getExtensionsByType("MessageThread")) {
            println("ext: ${ext.getNamespace()} ${ext.getQName()} ${ext.getLanguage()}")
        }
        assertEquals(messageThread, message.getThread())
        assertXmlSimilar(control, message.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase
    public func messageXmlLangTest(): Unit {
        let lang: String = "sp"

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<message")
        controlBuilder.append(" xml:lang=\"")
        controlBuilder.append(lang)
        controlBuilder.append("\">")
        controlBuilder.append("</message>")
        let control: String = controlBuilder.toString()

        let message: Message = StanzaBuilder.buildMessage().setLanguage(lang).build()

        assertXmlSimilar(control, message.toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    /**
     * Tests that only required characters are XML escaped in body.
     *
     * @see <a href="https://issues.igniterealtime.org/browse/SMACK-892">SMACK-892</a>
     */
    @TestCase
    public func escapeInBodyTest(): Unit {
        let theFive: String = "\"'<>&"
        let body: MessageBody = MessageBody(None, theFive)

        assertEquals("<body xmlns='jabber:client'>\"'&lt;>&amp;</body>", body.toXML().toString())
    }
}
