// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class FromMatchesFilterTest {
    private static let BASE_JID1: Jid = JidCreate.entityBareFrom("one@exampleOne.org")
    private static let FULL_JID1_R1: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceOne")
    private static let FULL_JID1_R2: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceTwo")
    private static let BASE_JID2: Jid = JidCreate.entityBareFrom("one@exampleTwo.org")
    private static let FULL_JID2: Jid = JidCreate.entityFullFrom("two@exampleTwo.org/resourceOne")
    private static let BASE_JID3: Jid = JidCreate.entityBareFrom("dummy@example.org")
    private static let SERVICE_JID1: Jid = JidCreate.domainBareFrom("muc.example.org")
    private static let SERVICE_JID2: Jid = JidCreate.domainBareFrom("pubsub.example.org")

    @TestCase
    public func autoCompareMatchingEntityFullJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.create(FULL_JID1_R1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(FULL_JID1_R1)
        assertTrue(filter.accept(packet))

        packet.setFrom(BASE_JID1)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID1_R2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func autoCompareMatchingBaseJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.create(BASE_JID1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(BASE_JID1)
        assertTrue(filter.accept(packet))

        packet.setFrom(FULL_JID1_R1)
        assertTrue(filter.accept(packet))

        packet.setFrom(FULL_JID1_R2)
        assertTrue(filter.accept(packet))

        packet.setFrom(BASE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func autoCompareMatchingServiceJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.create(SERVICE_JID1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(SERVICE_JID1)
        assertTrue(filter.accept(packet))

        packet.setFrom(SERVICE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID1)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID1_R1)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func bareCompareMatchingEntityFullJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.createBare(FULL_JID1_R1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(BASE_JID1)
        assertTrue(filter.accept(packet))

        packet.setFrom(FULL_JID1_R1)
        assertTrue(filter.accept(packet))

        packet.setFrom(FULL_JID1_R2)
        assertTrue(filter.accept(packet))

        packet.setFrom(BASE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func bareCompareMatchingBaseJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.createBare(BASE_JID1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(BASE_JID1)
        assertTrue(filter.accept(packet))

        packet.setFrom(FULL_JID1_R1)
        assertTrue(filter.accept(packet))

        packet.setFrom(FULL_JID1_R2)
        assertTrue(filter.accept(packet))

        packet.setFrom(BASE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func bareCompareMatchingServiceJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.createBare(SERVICE_JID1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(SERVICE_JID1)
        assertTrue(filter.accept(packet))

        packet.setFrom(SERVICE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID1)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID1_R1)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func fullCompareMatchingEntityFullJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.createFull(FULL_JID1_R1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(FULL_JID1_R1)
        assertTrue(filter.accept(packet))

        packet.setFrom(BASE_JID1)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID1_R2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func fullCompareMatchingBaseJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.createFull(BASE_JID1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(BASE_JID1)
        assertTrue(filter.accept(packet))

        packet.setFrom(FULL_JID1_R1)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID1_R2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }

    @TestCase
    func fullCompareMatchingServiceJid() {
        let filter: FromMatchesFilter = FromMatchesFilter.createFull(SERVICE_JID1)
        let packet: Stanza = StanzaBuilder.buildMessage().build()

        packet.setFrom(SERVICE_JID1)
        assertTrue(filter.accept(packet))

        packet.setFrom(SERVICE_JID2)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID1)
        assertFalse(filter.accept(packet))

        packet.setFrom(FULL_JID1_R1)
        assertFalse(filter.accept(packet))

        packet.setFrom(BASE_JID3)
        assertFalse(filter.accept(packet))
    }
}
