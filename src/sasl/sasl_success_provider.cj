/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.sasl

/**
 * 公共最终类 SaslSuccessProvider 继承自 NonzaProvider，专门处理 SASL 成功数据。
 */
public class SaslSuccessProvider <: NonzaProvider<SaslNonzaSuccess> {
    /**
     * 单例实例
     */
    public static let INSTANCE = SaslSuccessProvider()

    /**
     * 私有构造函数，防止外部实例化
     */
    private init() {
        super("SaslNonzaSuccess")
    }

    /**
     * 解析 XML 拉取解析器中的 SASL 成功数据。
     *
     * @param parser          用于解析的 XmlPullParser 实例
     * @param initialDepth    初始深度
     * @param xmlEnvironment  XML 环境
     * @return               返回一个 SaslNonza.Success 对象
     * @throws IOException                解析过程中可能发生的 IO 异常
     * @throws XmlPullParserException     解析过程中可能发生的 XML 解析异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): SaslNonzaSuccess {
        let data = parser.nextText()
        return SaslNonzaSuccess(data)
    }
}
