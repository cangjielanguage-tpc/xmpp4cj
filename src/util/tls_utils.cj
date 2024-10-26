/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public type HostnameVerifier = (String, TlsSession) -> Bool

public class TLSUtils {
    private static let LOGGER = getGlobalLogger("TLSUtils")

    public static let SSL = "SSL"
    public static let TLS = "TLS"
    public static let PROTO_SSL3: String = SSL + "v3"
    public static let PROTO_TLSV1: String = TLS + "v1"
    public static let PROTO_TLSV1_1: String = TLS + "v1.1"
    public static let PROTO_TLSV1_2: String = TLS + "v1.2"
    public static let PROTO_TLSV1_3: String = TLS + "v1.3"

    /**
     * Enable the recommended TLS protocols.
     *
     * @param builder the configuration builder to apply this setting to
     * @param <B> Type of the ConnectionConfiguration builder.
     *
     * @return the given builder
     */
    // public static func setEnabledTlsProtocolsToRecommended<B>(builder: B): B where B <: ConnectionConfiguration_Builder<B,
    // ConnectionConfiguration> {
    //     builder.setEnabledSSLProtocols([PROTO_TLSV1_3, PROTO_TLSV1_2])
    //     return builder
    // }

    /**
     * Accept all TLS certificates.
     * <p>
     * <b>Warning:</b> Use with care. This method make the Connection use {@link AcceptAllTrustManager} and essentially
     * <b>invalidates all security guarantees provided by TLS</b>. Only use this method if you understand the
     * implications.
     * </p>
     *
     * @param builder a connection configuration builder.
     * @param <B> Type of the ConnectionConfiguration builder.
     * @return the given builder.
     */
    // public static func acceptAllCertificates<B>(builder: B): B where B <: ConnectionConfiguration_Builder<B,
    // ConnectionConfiguration> {
    //     builder.setCustomX509TrustManager(TLSUtils_AcceptAllTrustManager())
    //     return builder
    // }

    /**
     * Disable the hostname verification of TLS certificates.
     * <p>
     * <b>Warning:</b> Use with care. This disables hostname verification of TLS certificates and essentially
     * <b>invalidates all security guarantees provided by TLS</b>. Only use this method if you understand the
     * implications.
     * </p>
     *
     * @param builder a connection configuration builder.
     * @param <B> Type of the ConnectionConfiguration builder.
     * @return the given builder.
     */
    // public static func disableHostnameVerificationForTlsCertificates<B>(builder: B): B where B <: ConnectionConfiguration_Builder<B,
    // ConnectionConfiguration> {
    //     builder.setHostnameVerifier(TLSUtils_1())
    //     return builder
    // }

    public static func setEnabledProtocolsAndCiphers(tlsSocket: TlsSocket, enabledProtocols: Array<String>,
        enabledCiphers: Array<String>): Unit {
        // var tempenabledProtocols = enabledProtocols
        // var tempenabledCiphers = enabledCiphers
        // if (tempenabledProtocols.isSome()) {
        //     let enabledProtocolsSet: Set<String> = HashSet<String>(tempenabledProtocols)
        //     let supportedProtocolsSet: Set<String> = HashSet<String>(TlsSocket.getSupportedProtocols())
        //     let protocolsIntersection: Set<String> = HashSet<String>(supportedProtocolsSet)
        //     protocolsIntersection.retainAll(SetCollectionView<String>(enabledProtocolsSet))
        //     if (protocolsIntersection.isEmpty()) {
        //         throw XmppException_SecurityNotPossibleException(
        //             "Request to enable SSL/TLS protocols '" + (StringUtils.collectionToString(
        //             enabledProtocolsSet as Collection<Object>)) + "', but only '" + (StringUtils.collectionToString(
        //             supportedProtocolsSet as Collection<Object>)) + "' are supported.")
        //     }
        //     tempenabledProtocols = Array<String>(protocolsIntersection.size)
        //     tempenabledProtocols = protocolsIntersection.toArray()
        //     TlsSocket.setEnabledProtocols(tempenabledProtocols)
        // }
        // if (tempenabledCiphers.isSome()) {
        //     let enabledCiphersSet: Set<String> = HashSet<String>(tempenabledCiphers)
        //     let supportedCiphersSet: Set<String> = HashSet<String>(TlsSocket.getEnabledCipherSuites())
        //     let ciphersIntersection: Set<String> = HashSet<String>(supportedCiphersSet)
        //     ciphersIntersection.retainAll(SetCollectionView<String>(enabledCiphersSet))
        //     if (ciphersIntersection.isEmpty()) {
        //         throw XmppException_SecurityNotPossibleException(
        //             "Request to enable SSL/TLS ciphers '" + (StringUtils.collectionToString(
        //             enabledCiphersSet as Collection<Object>)) + "', but only '" + (StringUtils.collectionToString(
        //             supportedCiphersSet as Collection<Object>)) + "' are supported.")
        //     }
        //     tempenabledCiphers = Array<String>(ciphersIntersection.size)
        //     tempenabledCiphers = ciphersIntersection.toArray()
        //     TlsSocket.setEnabledCipherSuites(tempenabledCiphers)
        // }
        throw Exception("TODO")
    }

    /**
     * Get the channel binding data for the 'tls-server-end-point' channel binding type. This channel binding type is
     * defined in RFC 5929 § 4.
     *
     * @param TlsSession the SSL/TLS session from which the data should be retrieved.
     * @return the channel binding data.
     * @throws SSLPeerUnverifiedException if we TLS peer could not be verified.
     * @throws CertificateEncodingException if there was an encoding error with the certificate.
     * @throws NoSuchAlgorithmException if no such algorithm is available.
     * @see <a href="https/tools/ietf/org/html/rfc5929#section-4">RFC 5929 § 4.</a>
     */
    public static func getChannelBindingTlsServerEndPoint(tlsSession: TlsSession): Array<UInt8> {
        // let peerCertificates = tlsSession.getPeerCertificates()
        // let certificate = peerCertificates[0]
        // let certificateAlgorithm = certificate.getPublicKey().getAlgorithm()
        // let algorithm: String
        // match (certificateAlgorithm) {
        //     case "MD5" | "SHA-1" => algorithm = "SHA-256"
        //     case _ => algorithm = certificateAlgorithm
        // }
        // let messageDigest = MessageDigest.getInstance(algorithm)
        // let certificateDerEncoded = certificate.getEncoded()
        // messageDigest.update(certificateDerEncoded)
        // return messageDigest.digest()
        throw Exception("TODO")
    }

    // private static let DEFAULT_TRUSTSTORE_PATH: File

    // public static func getDefaultTruststoreStreamIfPossible(): FileInputStream {
    //     try {
    //         return FileInputStream(DEFAULT_TRUSTSTORE_PATH)
    //     } catch (e: FileNotFoundException) {
    //         LOGGER.log(LogLevel.WARN, "Could not open default truststore at " + stringValueOf(DEFAULT_TRUSTSTORE_PATH),
    //             e)
    //         return None
    //     }
    // }

    private static let JKS_MAGIC = 0xfeedfeed

    private static let JKS_VERSION_1 = 1

    private static let JKS_VERSION_2 = 2

    public static func getDefaultTruststoreType(): TLSUtils_DefaultTrustStoreType {
        // do {
        //     let inputStream = getDefaultTruststoreStreamIfPossible()
        //     try {
        //         if (inputStream.isNone()) {
        //             return TLSUtils_DefaultTrustStoreType.no_default
        //         }
        //         let dis = DataInputStream(inputStream)
        //         let magic = dis.readInt()
        //         let version = dis.readInt()
        //         if (magic == JKS_MAGIC && (version == JKS_VERSION_1 || version == JKS_VERSION_2)) {
        //             return TLSUtils_DefaultTrustStoreType.jks
        //         }
        //     } catch (t_: Exception) {
        //         if (inputStream.isSome()) {
        //             try {
        //             } catch (x2: Exception) {
        //                 t_.addSuppressed(x2)
        //             }
        //         }
        //         throw t_
        //     } finally {
        //         if (inputStream.isSome()) {
        //         }
        //     }
        // } while (false)
        // return TLSUtils_DefaultTrustStoreType.unknown
        throw Exception("TODO")
    }

    /**
     * Tries to determine if the default truststore type is of type jks and sets the trustStoreType system
     * property to 'JKS' if so.
     */
    public static func setDefaultTrustStoreTypeToJksIfRequired(): Unit {
        // let defaultTrustStoreType: TLSUtils_DefaultTrustStoreType
        // try {
        //     defaultTrustStoreType = getDefaultTruststoreType()
        // } catch (e: IOException) {
        //     LOGGER.log(LogLevel.WARN, "Could not set keystore type to jks if required", e)
        //     return
        // }
        // if (defaultTrustStoreType == TLSUtils_DefaultTrustStoreType.jks) {
        //     System.setProperty("javax.net.ssl.trustStoreType", "JKS")
        // }
        throw Exception("TODO")
    }
}

/**
 *  A {@link X509TrustManager} that <b>doesn't validate</b> X.509 certificates.
 * <p>
 * Connections that use this TrustManager will just be encrypted, without any guarantee that the
 * counter part is actually the intended one. Man-in-the-Middle attacks will be possible, since
 * any certificate presented by the attacker will be considered valid.
 * </p>
 */
// public open class TLSUtils_AcceptAllTrustManager <: X509TrustManager {
//     public open override func checkClientTrusted(arg0: Array<X509Certificate>, arg1: String): Unit {
//     }

//     public open override func checkServerTrusted(arg0: Array<X509Certificate>, arg1: String): Unit {
//     }

//     public open override func getAcceptedIssuers(): Array<X509Certificate> {
//         return Array<X509Certificate>(0)
//     }
// }

public enum TLSUtils_DefaultTrustStoreType <: Equatable<TLSUtils_DefaultTrustStoreType> {
    | jks
    | unknown
    | no_default

    public operator override func ==(that: TLSUtils_DefaultTrustStoreType) {
        match ((this, that)) {
            case (jks, jks) => true
            case (unknown, unknown) => true
            case (no_default, no_default) => true
            case _ => false
        }
    }
}
