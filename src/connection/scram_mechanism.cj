/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

import stdx.crypto.crypto.SecureRandom
import stdx.crypto.digest.CryptoException

/**
 * public abstract class ScramMechanism <: SASLMechanism
 *
 */
public abstract class ScramMechanism <: SASLMechanism {
    private static let RANDOM_ASCII_BYTE_COUNT = 32
    private static let CLIENT_KEY_BYTES = toBytes("Client Key")
    private static let SERVER_KEY_BYTES = toBytes("Server Key")
    private static let ONE: Array<UInt8> = [0, 0, 0, 1]

    private static let _SECURE_RANDOM = ThreadLocal<SecureRandom>()
    private static prop SECURE_RANDOM: ThreadLocal<SecureRandom> {
        get() {
            _SECURE_RANDOM.get() ?? {
                =>
                let random = SecureRandom()
                _SECURE_RANDOM.set(random)
                random
            }()
            _SECURE_RANDOM
        }
    }

    private static let CACHE: Cache<String, ScramMechanismKeys> = LruCache(10)

    private let scramHmac: ScramHmac

    protected init(scramHmac: ScramHmac) {
        this.scramHmac = scramHmac
    }

    /**
     * The state of the this instance of SASL SCRAM-SHA1 authentication.
     */
    private var state: ScramMechanismState = ScramMechanismState.INITIAL

    /**
     * The client's random ASCII which is used as nonce
     */
    private var clientRandomAscii: ?String = None
    private var clientFirstMessageBare: ?String = None
    private var serverSignature: ?Array<UInt8> = None

    protected open override func authenticateInternal(_: ?CallbackHandler): Unit {
        throw UnsupportedException("CallbackHandler not (yet) supported")
    }

    protected open override func getAuthenticationText(): ?Array<UInt8> {
        clientRandomAscii = getRandomAscii()
        let saslPrepedAuthcId = saslPrep(authenticationId())
        clientFirstMessageBare = "n=${escape(saslPrepedAuthcId)},r=${clientRandomAscii()}"
        let clientFirstMessage: String = getGS2Header() + clientFirstMessageBare()
        state = ScramMechanismState.AUTH_TEXT_SENT
        return toBytes(clientFirstMessage)
    }

    public open override func getName(): String {
        return "SCRAM-${scramHmac.getHmacName()}"
    }

    public open override func checkIfSuccessfulOrThrow(): Unit {
        if (state != ScramMechanismState.VALID_SERVER_RESPONSE) {
            throw XmppSaslException("SCRAM-SHA1 is missing valid server response")
        }
    }

    public open override func authzidSupported(): Bool {
        return true
    }

    protected open override func evaluateChallenge(challenge: Array<UInt8>): ?Array<UInt8> {
        let challengeString = String.fromUtf8(challenge)
        match (state) {
            case AUTH_TEXT_SENT =>
                let serverFirstMessage = challengeString
                let attributes = parseAttributes(challengeString)

                // Handle server random ASCII (nonce)
                let rvalue = attributes.get(b'r') ?? throw XmppSaslException("Server random ASCII is null")
                if (rvalue.size <= clientRandomAscii().size) {
                    throw XmppSaslException("Server random ASCII is shorter then client random ASCII")
                }
                let receivedClientRandomAscii = rvalue[..clientRandomAscii().size]
                if (clientRandomAscii != receivedClientRandomAscii) {
                    throw XmppSaslException("Received client random ASCII does not match client random ASCII")
                }

                // Handle iterations
                var iterations = 0
                let iterationsString = attributes.get(b'i') ?? throw XmppSaslException("Iterations attribute not set")
                try {
                    iterations = Int64.parse(iterationsString)
                } catch (e: Exception) {
                    throw XmppSaslException("Exception parsing iterations", e)
                }

                // Handle salt
                let salt = attributes.get(b's') ?? throw XmppSaslException("SALT not send")

                // Parsing and error checking is done, we can now begin to calculate the values

                // First the client-final-message-without-proof
                let channelBinding = "c=" + toBase64String(getCBindInput())
                let clientFinalMessageWithoutProof = channelBinding + ",r=" + rvalue

                // AuthMessage := client-first-message-bare + "," + server-first-message + "," +
                // client-final-message-without-proof
                let authMessage = toBytes(
                    clientFirstMessageBare() + ',' + serverFirstMessage + ',' + clientFinalMessageWithoutProof)

                // RFC 5802 § 5.1 "Note that a client implementation MAY cache ClientKey&ServerKey … for later reauthentication …
                // as it is likely that the server is going to advertise the same salt value upon reauthentication."
                // Note that we also mangle the mechanism's name into the cache key, since the cache is used by multiple
                // mechanisms.
                let cacheKey = password() + ',' + salt + ',' + getName()
                let serverKey: Array<Byte>
                let clientKey: Array<Byte>
                if (let Some(keys) <- CACHE.lookup(cacheKey)) {
                    serverKey = keys.serverKey
                    clientKey = keys.clientKey
                } else {
                    // SaltedPassword := Hi(Normalize(password), salt, i)
                    let saltedPassword = hi(saslPrep(password()), fromBase64String(salt)(), iterations)

                    // ServerKey := HMAC(SaltedPassword, "Server Key")
                    serverKey = hmac(saltedPassword, SERVER_KEY_BYTES)

                    // ClientKey := HMAC(SaltedPassword, "Client Key")
                    clientKey = hmac(saltedPassword, CLIENT_KEY_BYTES)

                    let keys = ScramMechanismKeys(clientKey, serverKey)
                    CACHE.put(cacheKey, keys)
                }

                // ServerSignature := HMAC(ServerKey, AuthMessage)
                serverSignature = hmac(serverKey, authMessage)

                // StoredKey := H(ClientKey)
                let storedKey = SHA1Util.bytes(clientKey)

                // ClientSignature := HMAC(StoredKey, AuthMessage)
                let clientSignature = hmac(storedKey, authMessage)

                // ClientProof := ClientKey XOR ClientSignature
                let clientProof = Array<Byte>(clientKey.size, repeat: 0)
                for (i in 0..clientProof.size) {
                    clientProof[i] = clientKey[i] ^ clientSignature[i]
                }

                let clientFinalMessage = clientFinalMessageWithoutProof + ",p=" + toBase64String(clientProof)
                state = ScramMechanismState.RESPONSE_SENT
                return toBytes(clientFinalMessage)
            case RESPONSE_SENT =>
                let clientCalculatedServerFinalMessage = "v=" + toBase64String(serverSignature())
                if (clientCalculatedServerFinalMessage != challengeString) {
                    throw XmppSaslException("Server final message does not match calculated one")
                }
                state = ScramMechanismState.VALID_SERVER_RESPONSE
            case _ => throw XmppSaslException("Invalid state")
        }

        return None
    }

    private func getGS2Header(): String {
        var authzidPortion: String = ""
        if (let Some(v) <- authorizationId) {
            authzidPortion = "a=${v}"
        }
        let cbName = getGs2CbindFlag()
        assert(StringUtils.isNotEmpty(cbName))

        return "${cbName},${authzidPortion},"
    }

    private func getCBindInput(): Array<UInt8> {
        let cbindData = getChannelBindingData()
        let gs2Header = toBytes(getGS2Header())
        if (let Some(v) <- cbindData) {
            return ByteUtils.concat(gs2Header, v)
        } else {
            return gs2Header
        }
    }

    /**
     * Get the SCRAM GSS-API Channel Binding Flag value.
     *
     * @return the gs2-cbind-flag value.
     * @see <a href="https/tools/ietf/org/html/rfc5802#section-6">RFC 5802 § 6.</a>
     */
    protected open func getGs2CbindFlag(): String {
        // Check if we are using TLS and if a "-PLUS" variant of this mechanism is enabled. Assuming that the "-PLUS"
        // variants always have precedence before the non-"-PLUS" variants this means that the server did not announce
        // the "-PLUS" variant, as otherwise we would have tried it.
        if (sslSession.isSome() && connectionConfiguration().isEnabledSaslMechanism("${getName()}-PLUS")) {
            // Announce that we support Channel Binding, i.e., the '-PLUS' flavor of this SASL mechanism, but that we
            // believe the server does not.
            return "y"
        }
        return "n"
    }

    /**
     *
     * @return the Channel Binding data.
     * @throws XmppSaslException if a SASL specific error occurred.
     */
    protected open func getChannelBindingData(): ?Array<UInt8> {
        return None
    }

    private static func parseAttributes(string: String): Map<Byte, String> {
        if (string.size == 0) {
            return HashMap()
        }
        let keyValuePairs = string.split(",")
        let res: Map<Byte, String> = HashMap(keyValuePairs.size)
        for (keyValuePair in keyValuePairs) {
            if (keyValuePair.size < 3) {
                throw XmppSaslException("Invalid Key-Value pair: ${keyValuePair}")
            }
            let key = keyValuePair[0]
            if (keyValuePair[1] != b'=') {
                throw XmppSaslException("Invalid Key-Value pair: ${keyValuePair}")
            }
            let value: String = keyValuePair[2..]
            res.add(key, value)
        }
        return res
    }

    /**
     * Generate random ASCII.
     * <p>
     * This method is non-static and package-private for unit testing purposes.
     * </p>
     * @return A String of 32 random printable ASCII characters.
     */
    public open func getRandomAscii(): String {
        var count = 0
        let randomAscii = Array<Rune>(RANDOM_ASCII_BYTE_COUNT) {_ => r'\u{0000}'}
        let random = SECURE_RANDOM.get()()
        while (count < RANDOM_ASCII_BYTE_COUNT) {
            let r = random.nextUInt8(128)
            let c = Rune(r)
            // RFC 5802 § 5.1 specifies 'r:' to exclude the ',' character and to be only printable ASCII characters
            if (!isPrintableNonCommaAsciiChar(c)) {
                continue
            }
            randomAscii[count] = c
            count++
        }
        return String(randomAscii)
    }

    private static func isPrintableNonCommaAsciiChar(c: Rune): Bool {
        if (c == r',') {
            return false
        }
        // RFC 5802 § 7. 'printable': Contains all chars within 0x21 (33d) to 0x2b (43d) and 0x2d (45d) to 0x7e (126)
        // aka. "Printable ASCII except ','". Since we already filter the ASCII ',' (0x2c, 44d) above, we only have to
        // ensure that c is within [33, 126].
        return UInt32(c) > 32 && UInt32(c) < 127
    }

    /**
     * Escapes usernames or passwords for SASL SCRAM-SHA1.
     * <p>
     * According to RFC 5802 § 5.1 'n:'
     * "The characters ',' or '=' in usernames are sent as '=2C' and '=3D' respectively."
     * </p>
     *
     * @param string
     * @return the escaped string
     */
    private static func escape(string: String): String {
        let sb = ArrayList<Byte>(Int64(Float64(string.size) * 1.1))
        for (i in 0..string.size) {
            let c = string[i]
            match (c) {
                case b',' => sb.add(all: unsafe { "=2C".rawData() })
                case b'=' => sb.add(all: unsafe { "=3D".rawData() })
                case _ => sb.add(c)
            }
        }
        return byteList2String(sb)
    }

    /**
     * RFC 5802 § 2.2 HMAC(key, str)
     *
     * @param key
     * @param str
     * @return the HMAC-SHA1 value of the input.
     * @throws XmppException if Xmpp detected an exceptional situation.
     */
    private func hmac(key: Array<UInt8>, str: Array<UInt8>): Array<UInt8> {
        try {
            return scramHmac.hmac(key, str)
        } catch (e: CryptoException) {
            throw XmppSaslException("${getName()} Exception", e)
        }
    }

    /**
     * RFC 5802 § 2.2 Hi(str, salt, i)
     * <p>
     * Hi() is, essentially, PBKDF2 [RFC2898] with HMAC() as the pseudorandom function
     * (PRF) and with dkLen == output length of HMAC() == output length of H().
     * </p>
     *
     * @param normalizedPassword the normalized password.
     * @param salt
     * @param iterations
     * @return the result of the Hi function.
     * @throws XmppSaslException if a SASL related error occurs.
     */
    private func hi(normalizedPassword: String, salt: Array<UInt8>, iterations: Int64): Array<UInt8> {
        let key = normalizedPassword.toArray()
        var u = hmac(key, ByteUtils.concat(salt, ONE))
        let res: Array<UInt8> = u.clone()
        for (i in 1..iterations) {
            u = hmac(key, u)
            for (j in 0..u.size) {
                res[j] ^= u[j]
            }
        }
        return res
    }
}

enum ScramMechanismState <: Equatable<ScramMechanismState> {
    | INITIAL
    | AUTH_TEXT_SENT
    | RESPONSE_SENT
    | VALID_SERVER_RESPONSE

    public operator override func ==(that: ScramMechanismState): Bool {
        match ((this, that)) {
            case (INITIAL, INITIAL) => true
            case (AUTH_TEXT_SENT, AUTH_TEXT_SENT) => true
            case (RESPONSE_SENT, RESPONSE_SENT) => true
            case (VALID_SERVER_RESPONSE, VALID_SERVER_RESPONSE) => true
            case _ => false
        }
    }
}

class ScramMechanismKeys <: Equatable<ScramMechanismKeys> {
    ScramMechanismKeys(let clientKey: Array<UInt8>, let serverKey: Array<UInt8>) {}
    public operator func ==(that: ScramMechanismKeys): Bool {
        return refEq(this, that)
    }
}
