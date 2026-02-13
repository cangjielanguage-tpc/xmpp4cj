// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// DEPENDENCE: ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj xml_test_utils.cj --test
// EXEC: ./main 
//--filter=*.setPresenceModeTest

@Test
public class PresenceTest {
    @TestCase
    public func setPresenceTypeTest(): Unit {
        let typ: PresenceType = PresenceType.unavailable
        let type2: PresenceType = PresenceType.subscribe

        var controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<presence")
        controlBuilder.append(" type=\"")
        controlBuilder.append(typ)
        controlBuilder.append("\">")
        controlBuilder.append("</presence>")
        var control: String = controlBuilder.toString()

        let presenceTypeInConstructor: Presence = StanzaBuilder.buildPresence().ofType(typ).build()
        assertEquals(typ, presenceTypeInConstructor.getType())
        assertXmlSimilar(control, presenceTypeInConstructor.toXML(StreamOpen.CLIENT_NAMESPACE).toString())

        controlBuilder = StringBuilder()
        controlBuilder.append("<presence")
        controlBuilder.append(" type=\"")
        controlBuilder.append(type2)
        controlBuilder.append("\">")
        controlBuilder.append("</presence>")
        control = controlBuilder.toString()

        let presenceTypeSet: PresenceBuilder = getNewPresence()
        presenceTypeSet.ofType(type2)
        assertEquals(type2, presenceTypeSet.getType())
        assertXmlSimilar(control, presenceTypeSet.build().toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase
    public func setNullPresenceTypeTest(): Unit {
        //     @AssertThrows[IllegalArgumentException](getNewPresence().ofType(None))
    }

    @TestCase
    public func isPresenceAvailableTest(): Unit {
        let presence: PresenceBuilder = getNewPresence()
        presence.ofType(PresenceType.available)
        assertTrue(presence.build().isAvailable())

        presence.ofType(PresenceType.unavailable)
        assertFalse(presence.build().isAvailable())
    }

    @TestCase
    public func setPresenceStatusTest(): Unit {
        let status: String = "This is a test of the emergency broadcast system."

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<presence>")
        controlBuilder.append("<status>")
        controlBuilder.append(status)
        controlBuilder.append("</status>")
        controlBuilder.append("</presence>")
        let control: String = controlBuilder.toString()

        let presence: PresenceBuilder = getNewPresence()
        presence.setStatus(status)

        assertEquals(status, presence.getStatus())
        assertXmlSimilar(control, presence.build().toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase
    public func setPresencePriorityTest(): Unit {
        let priority: UInt8 = 10

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<presence>")
        controlBuilder.append("<priority>")
        controlBuilder.append(priority)
        controlBuilder.append("</priority>")
        controlBuilder.append("</presence>")
        let control: String = controlBuilder.toString()

        let presence: PresenceBuilder = getNewPresence()
        presence.setPriority(priority)

        assertEquals(Int64(priority), presence.getPriority())
        assertXmlSimilar(control, presence.build().toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase
    public func setIllegalPriorityTest(): Unit {
        // @AssertThrows[IllegalArgumentException](getNewPresence().setPriority(Int64.Min))
    }

    @TestCase
    public func setPresenceModeTest(): Unit {
        let mode1: PresenceMode = PresenceMode.dnd
        let priority: UInt8 = 10
        let status: String = "This is a test of the emergency broadcast system."
        let mode2: PresenceMode = PresenceMode.chat

        var controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<presence>")
        controlBuilder.append("<status>")
        controlBuilder.append(status)
        controlBuilder.append("</status>")
        controlBuilder.append("<priority>")
        controlBuilder.append(priority)
        controlBuilder.append("</priority>")
        controlBuilder.append("<show>")
        controlBuilder.append(mode1)
        controlBuilder.append("</show>")
        controlBuilder.append("</presence>")
        var control: String = controlBuilder.toString()

        var presenceBuildWithBuilder: Presence = StanzaBuilder
            .buildPresence()
            .ofType(PresenceType.available)
            .setStatus(status)
            .setPriority(priority)
            .setMode(mode1)
            .build()
        assertEquals(mode1, presenceBuildWithBuilder.getMode())
        assertXmlSimilar(control, presenceBuildWithBuilder.toXML(StreamOpen.CLIENT_NAMESPACE).toString())

        controlBuilder = StringBuilder()
        controlBuilder.append("<presence>")
        controlBuilder.append("<show>")
        controlBuilder.append(mode2)
        controlBuilder.append("</show>")
        controlBuilder.append("</presence>")
        control = controlBuilder.toString()

        var presenceModeSet: PresenceBuilder = getNewPresence()
        presenceModeSet.setMode(mode2)
        assertEquals(mode2, presenceModeSet.getMode())
        assertXmlSimilar(control, presenceModeSet.build().toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    @TestCase
    public func isModeAwayTest(): Unit {
        let presence: PresenceBuilder = getNewPresence()
        presence.setMode(PresenceMode.away)
        assertTrue(presence.build().isAway())

        presence.setMode(PresenceMode.chat)
        assertFalse(presence.build().isAway())
    }

    @TestCase
    public func presenceXmlLangTest(): Unit {
        let lang: String = "sp"

        let controlBuilder: StringBuilder = StringBuilder()
        controlBuilder.append("<presence")
        controlBuilder.append(" xml:lang=\"")
        controlBuilder.append(lang)
        controlBuilder.append("\">")
        controlBuilder.append("</presence>")
        let control: String = controlBuilder.toString()

        let presence: PresenceBuilder = getNewPresence()
        presence.setLanguage(lang)

        assertXmlSimilar(control, presence.build().toXML(StreamOpen.CLIENT_NAMESPACE).toString())
    }

    private static func getNewPresence(): PresenceBuilder {
        let presence: PresenceBuilder = StanzaBuilder.buildPresence().ofType(PresenceType.available)
        return presence
    }
}
