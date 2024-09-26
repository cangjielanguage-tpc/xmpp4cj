/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.compress

public class FailureProvider <: NonzaProvider<Failure> {
    private static let LOGGER = getGlobalLogger(("name", "FailureProvider"))

    public static let INSTANCE = FailureProvider()

    private init() {
        super()
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): Failure {
        var compressFailureError: ?FailureCompressFailureError = None
        var stanzaError: ?StanzaError = None
        let failureXmlEnvironment = XmlEnvironment.froms(parser, xmlEnvironment)

        while (true) {
            let eventType = parser.next()
            match (eventType) {
                case XmlPullParserEvent.START_ELEMENT =>
                    let name = parser.getName()
                    let namespace = parser.getNamespace()
                    if (namespace == Failure.NAMESPACE) {
                        compressFailureError = FailureCompressFailureError.fromString(name.replace("-", "_"))
                        if (compressFailureError.isNone()) {
                            LOGGER.warn("Unknown element in " + Failure.NAMESPACE + ": " + (name))
                        }
                    } else if (namespace == StreamOpen.CLIENT_NAMESPACE || namespace == StreamOpen.SERVER_NAMESPACE) {
                        if (name == StanzaError.ERROR) {
                            stanzaError = PacketParserUtils.parseError(parser, failureXmlEnvironment)
                        } else {
                            LOGGER.warn("Unknown element in ${namespace}: ${name}")
                        }
                    }
                case XmlPullParserEvent.END_ELEMENT => if (parser.getDepth() == initialDepth) {
                    break
                }
                case _ => ()
            }
        }
        return Failure(compressFailureError, stanzaError)
    }
}
