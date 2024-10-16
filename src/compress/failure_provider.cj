/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.compress

/**  
 * FailureProvider 类是一个解析器，用于解析 XMPP 协议中的失败（Failure）非自定义数据（Nonza）元素。
 * <p>
 * 该类实现了 NonzaProvider 接口，专门用于创建和处理 Failure 实例。
 * </p>
 */
public class FailureProvider <: NonzaProvider<Failure> {
    /**  
     * Logger 实例，用于记录日志信息。
     */
    private static let LOGGER = getGlobalLogger(("name", "FailureProvider"))

    /**  
     * FailureProvider 的单例实例。
     */
    public static let INSTANCE = FailureProvider()

    /**  
     * 私有构造函数，防止外部创建实例。
     * <p>
     * 由于采用单例模式，只允许创建一个 FailureProvider 实例。
     * </p>
     */
    private init() {
        super("Failure")
    }

    /**  
     * 解析给定的 XML 拉解析器中的失败元素。
     *
     * @param parser        用于读取 XML 内容的 XmlPullParser。
     * @param initialDepth  初始的 XML 深度。
     * @param xmlEnvironment 与 XML 解析相关的环境信息。
     * @return 返回解析后的 Failure 实例，表示解析出的失败信息。
     * @throws XmlPullParserException 如果在解析过程中出现 XML 错误。
     * @throws IOException            如果在读入过程中发生 I/O 错误。
     * @throws XmppParsingException   如果在解析中发生 Xmpp 特定的错误。
     */
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
                            LOGGER.warn("Unknown element in ${Failure.NAMESPACE}: ${name}")
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
