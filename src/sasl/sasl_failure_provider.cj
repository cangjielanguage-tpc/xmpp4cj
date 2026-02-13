/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.sasl

/**
 * 公共最终类 SaslFailureProvider 继承自 NonzaProvider，专门处理 SASL 失败数据。
 */
public class SaslFailureProvider <: NonzaProvider<SaslNonzaSASLFailure> {
    /**
     * 单例实例
     */
    public static let INSTANCE = SaslFailureProvider()

    /**
     * 私有构造函数，防止外部实例化
     */
    private init() {
        super("SaslNonzaSASLFailure")
    }

    /**
     * 解析 XML 拉取解析器中的 SASL 失败数据。
     *
     * @param parser          用于解析的 XmlPullParser 实例
     * @param initialDepth    初始深度
     * @param xmlEnvironment  XML 环境
     * @return               返回一个 SASLFailure 对象
     * @throws XmlPullParserException  解析过程中可能发生的 XML 解析异常
     * @throws IOException             解析过程中可能发生的 IO 异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): SaslNonzaSASLFailure {
        var condition: ?String = None
        var descriptiveTexts: ?Map<String, String> = None

        while (true) {
            let eventType = parser.nextTag()
            match (eventType) {
                case XmlPullParserTagEvent.START_ELEMENT =>
                    let name = parser.getName()
                    if (name == "text") {
                        descriptiveTexts = PacketParserUtils.parseDescriptiveTexts(parser, descriptiveTexts)
                    } else {
                        assert(condition.isNone())
                        condition = parser.getName()
                    }
                case XmlPullParserTagEvent.END_ELEMENT =>
                    if (parser.getDepth() == initialDepth) {
                        break
                    }
            }
        }
        return SaslNonzaSASLFailure(condition.getOrThrow(), descriptiveTexts)
    }
}
