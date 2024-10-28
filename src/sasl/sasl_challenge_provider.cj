/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.sasl

/**  
 * 公共最终类 SaslChallengeProvider 继承自 NonzaProvider，专门处理 SASL 数据。
 */
public class SaslChallengeProvider <: NonzaProvider<SaslNonzaChallenge> {
    /**  
     * 单例实例
     */
    public static let INSTANCE = SaslChallengeProvider()

    /**  
     * 私有构造函数，防止外部实例化
     */
    private init() {
        super("SaslNonzaChallenge")
    }

    /**  
     * 解析 XML 拉取解析器中的 SASL 数据。
     *
     * @param parser          用于解析的 XmlPullParser 实例
     * @param _    初始深度
     * @param _  XML 环境
     * @return               返回一个 SaslNonza.Challenge 对象
     * @throws IOException                解析过程中可能发生的 IO 异常
     * @throws XmlPullParserException     解析过程中可能发生的 XML 解析异常
     */
    public override func parse(parser: XmlPullParser, _: Int, _: ?XmlEnvironment): SaslNonzaChallenge {
        let data = parser.nextText()
        return SaslNonzaChallenge(data)
    }
}
