/// DEPENDENCE: ../z_test.cj ../dummy_connection_test.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj dummy_connection_test.cj --test
/// EXEC: ./main 
/* TODO */

public open class AbstractSaslTest {
    protected let xmppConnection: DummyConnection = DummyConnection()

    protected let saslMechanism: SASLMechanism

    protected AbstractSaslTest(saslMechanism: SASLMechanism) {
        this.saslMechanism = saslMechanism.instanceForAuthentication(xmppConnection, xmppConnection.getConfiguration())
    }
}

public class DigestMd5SaslTest <: AbstractSaslTest {
    protected static let challenge: String = "realm=\"xmpp.org\",nonce=\"jgGgnz+cQcmyVaAs2n88kQ==\",qop=\"auth\",charset=utf-8,algorithm=md5-sess"

    protected static let challengeBytes: Array<Byte> = StringUtils.toUtf8Bytes(challenge)

    public init(saslMechanism: SASLMechanism) {
        super(saslMechanism)
    }

    protected func runTest(useAuthzid: Bool) {
        var authzid: ?EntityBareJid = None
        if (useAuthzid) {
            authzid = JidCreate.entityBareFrom("shazbat@xmpp.org")
        }
        saslMechanism.authenticate("florian", "irrelevant", JidCreate.domainBareFrom("xmpp.org"), "secret", authzid,
            None)
        // evaluateChallenge 方法非 public
        var response: ?Array<Byte> = saslMechanism.evaluateChallenge(challengeBytes)
        var responseString: String = String.fromUtf8(response.getOrThrow())
        var responseParts: Array<String> = responseString.split(",")
        var responsePairs: Map<String, String> = HashMap<String, String>()
        for (part in responseParts) {
            var keyValue: Array<String> = part.split("=", 2)
            var key: String = keyValue[0]
            var value: String = keyValue[1].replace("\"", "")
            responsePairs.put(key, value)
        }
        if (useAuthzid) {
            assertMapValue("authzid", "shazbat@xmpp.org", responsePairs)
        } else {
            assertTrue(!responsePairs.contains("authzid"))
        }
        assertMapValue("username", "florian", responsePairs)
        assertMapValue("realm", "xmpp.org", responsePairs)
        assertMapValue("digest-uri", "xmpp/xmpp.org", responsePairs)
        assertMapValue("qop", "auth", responsePairs)
    }

    private static func assertMapValue(key: String, value: String, map: Map<String, String>) {
        assertEquals(value, map.get(key))
    }
}
