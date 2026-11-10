// DEPENDENCE: ../z_test.cj ../dummy_connection_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj dummy_connection_test.cj --test
// EXEC: ./main 

import stdx.encoding.base64.*

@Test
public class SCRAMSHA1MechanismTest {
    public static let USERNAME: String = "user"
    public static let PASSWORD: String = "pencil"
    public static let CLIENT_FIRST_MESSAGE: String = "n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL"
    public static let SERVER_FIRST_MESSAGE: String = "r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096"
    public static let CLIENT_FINAL_MESSAGE: String = "c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts="
    public static let SERVER_FINAL_MESSAGE: String = "v=rmF9pqV8S7suAoZWja4dJRkFsKQ="

    static init() {
        Xmpp.ensureInitialized()
    }

    @TestCase
    public func testScramSha1Mechanism() {
        let con: DummyConnection = DummyConnection()
        let mech: SCRAMSHA1Mechanism = SCRAMSHA1Mechanism1(con)
        mech.authenticate(USERNAME, "unusedFoo", JidCreate.domainBareFrom("exampleOne.org"), PASSWORD, None, None)
        let topLevelStreamElement0: ?TopLevelStreamElement = con.getSentPacket()
        let authMechanism: SaslNonzaAuthMechanism = (topLevelStreamElement0
            .getOrThrow() as SaslNonzaAuthMechanism)
            .getOrThrow()
        assertEquals(SCRAMSHA1Mechanism.NAME, authMechanism.getMechanism())
        assertEquals(CLIENT_FIRST_MESSAGE, saslLayerString(authMechanism.getAuthenticationText()))
        mech.challengeReceived(toBase64String(SERVER_FIRST_MESSAGE.toArray()), false)
        let topLevelStreamElement1: ?TopLevelStreamElement = con.getSentPacket()
        let response: SaslNonzaResponse = (topLevelStreamElement1.getOrThrow() as SaslNonzaResponse).getOrThrow()
        assertEquals(CLIENT_FINAL_MESSAGE, saslLayerString(response.getAuthenticationText().getOrThrow()))
        mech.challengeReceived(toBase64String(SERVER_FINAL_MESSAGE.toArray()), true)
        mech.checkIfSuccessfulOrThrow()
    }

    private static func saslLayerString(string: String): String {
        return String.fromUtf8(fromBase64String(string).getOrThrow())
    }
}

public class SCRAMSHA1Mechanism1 <: SCRAMSHA1Mechanism {
    var con: DummyConnection

    public init(con: DummyConnection) {
        super()
        this.con = con
    }

    public override func getRandomAscii(): String {
        this.connection = con
        return "fyko+d2lbbFgONRv9qkxdawL"
    }
}
