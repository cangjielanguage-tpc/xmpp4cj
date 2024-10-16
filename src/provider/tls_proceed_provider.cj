/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**  
 * {@link TlsProceedProvider} 是一个提供程序，用于处理 TLS 协议的续授权。
 * 它扩展了 {@link NonzaProvider} 类，并提供解析 TLS 失败的功能。
 */
public class TlsProceedProvider <: NonzaProvider<TlsFailure> {
    /**  
     * 单例实例，用于访问 {@link TlsProceedProvider}
     */
    public static let INSTANCE = TlsProceedProvider()

    /**  
     * 私有构造函数，防止外部实例化。
     */
    private init() {
        super("TlsFailure")
    }

    /**  
     * 解析 XML 中的 TLS 续授权信息并返回 {@link TlsFailure} 实例。
     *
     * @param _ 用于解析 XML 的 {@link XmlPullParser}
     * @param _ 初始深度，用于跟踪 XML 解析的层级
     * @param _ 当前 XML 环境的上下文
     * @return 返回 {@link TlsFailure} 的实例，表示 TLS 续授权的信息
     */
    public override func parse(_: XmlPullParser, _: Int, _: ?XmlEnvironment): TlsFailure {
        return TlsFailure.INSTANCE
    }
}
