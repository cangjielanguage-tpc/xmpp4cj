/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.provider

/**  
 * {@link TlsFailureProvider} 是一个提供程序，用于处理 TLS 协议中的失败事件。
 * 它扩展了 {@link NonzaProvider} 类，并提供解析 TLS 续授权的信息。
 */
public class TlsFailureProvider <: NonzaProvider<TlsProceed> {
    /**  
     * 单例实例，用于访问 {@link TlsFailureProvider}
     */
    public static let INSTANCE = TlsFailureProvider()

    /**  
     * 私有构造函数，防止外部实例化。
     */
    private init() {
        super("TlsProceed")
    }

    /**  
     * 解析 XML 中的 TLS 失败信息并返回 {@link TlsProceed} 实例。
     *
     * @param _ 用于解析 XML 的 {@link XmlPullParser}
     * @param _ 初始深度，用于跟踪 XML 解析的层级
     * @param _ 当前 XML 环境的上下文
     * @return 返回 {@link TlsProceed} 的实例，表示 TLS 续授权的信息
     */
    public override func parse(_: XmlPullParser, _: Int, _: ?XmlEnvironment): TlsProceed {
        return TlsProceed.INSTANCE
    }
}
