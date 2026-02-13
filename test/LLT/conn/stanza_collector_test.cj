// DEPENDENCE: ../z_test.cj ../jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main

@Test
public class StanzaCollectorTest {
    @TestCase
    public func verifyRollover() {
        // let conf: ConnectionConfiguration = XMPPTCPConnectionConfiguration.builder().setConnectTimeout(Duration.second).
        //     setUsernameAndPassword("user", "password").setCompressionEnabled(false).build()
        // let connection: XMPPTCPConnection = XMPPTCPConnection((conf as XMPPTCPConnectionConfiguration).getOrThrow())
        // let collector: StanzaCollector = createTestStanzaCollector(connection, OKEverything(), 5)
        // for (i in 0..6) {
        //     let testPacket: Stanza = TestPacket(i)
        //     collector.processStanza(testPacket)
        // }
        // Assert that '0' has rolled off
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.pollResult().getOrThrow().getStanzaId())
        // println(collector.pollResult())
        // assertEquals("1", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("2", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("3", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("4", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("5", collector.pollResult().getOrThrow().getStanzaId())
        // assertNull(collector.pollResult())
        // for (i in 10..15) {
        //     let testPacket: Stanza = TestPacket(i)
        //     collector.processStanza(testPacket)
        // }
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // println(collector.pollResult().getOrThrow().getStanzaId())
        // println(collector.pollResult())
        // println(collector.nextResult(Duration.second * 10))
        // assertEquals("10", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("11", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("12", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("13", collector.nextResultBlockForever().getOrThrow().getStanzaId())
        // assertEquals("14", collector.pollResult().getOrThrow().getStanzaId())
        // assertNull(collector.pollResult())
        // assertNull(collector.nextResult(Duration.second * 10))
    }

    /**
     * 然由于线程的性质，这并不能保证任何事情，但它可能会发现问题。
     *
     * @throws InterruptedException 如果被打断。
     */
    @TestCase
    public func verifyThreadSafety() {
        let insertCount: Int64 = 500
        // let collector: StanzaCollector = createTestStanzaCollector(None, OKEverything(), insertCount)
        // let consumer1Dequeued: AtomicInteger = AtomicInteger(0)
        // let consumer2Dequeued: AtomicInteger = AtomicInteger(0)
        // let consumer3Dequeued: AtomicInteger = AtomicInteger(0)

        // spawn {

        // }
    }
}

class OKEverything <: StanzaFilter {
    public override func accept(packet: Stanza): Bool {
        return true
    }

    public override func toString(): String {
        return ""
    }
}

// private func createTestStanzaCollector(connection: XMPPConnection, packetFilter: StanzaFilter, size: Int64): StanzaCollector {
//     return StanzaCollector(connection, StanzaCollector.newConfiguration().setStanzaFilter(packetFilter).setSize(size))
// }

class TestPacket <: Stanza {
    init(i: Int64) {
        setStanzaId("${i}")
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<packetId>${getStanzaId()}</packetId>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "packetId"
    }
}

class Element0 <: Stanza {
    public override func toXML(enclosingNamespace: ?XmlEnvironment): ToString {
        return "<iq/>"
    }

    public override func toString(): String {
        return toXML().toString()
    }

    public override func getElementName(): String {
        return "iq"
    }
}