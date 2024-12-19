/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**
 * 实现 SASL X-OAUTH2 机制，如<a
 * href="https/developers/google/com/talk/jep_extensions/oauth">https/developers.google
 * .com/talk/jep_extensions/oauth</a> 中所述。
 * <p>
 * 提供的密码将用作 OAUTH 令牌。
 * </p>
 * <p>
 * 注意，X-OAUTH2 在 Xmpp 中是实验性的。这是因为 Google 除了
 * 定义了不良实践（XEP-134）之外，还为 'auth' stanza 添加了自定义属性，如下所示。
 * </p>
 *
 * <pre>
 * {@code
 * <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl" mechanism="X-OAUTH2"
 *    auth:service="chromiumsync" auth:allow-generated-jid="true"
 *    auth:client-uses-full-bind-result="true" xmlns:auth="http://www.google.com/talk/protocol/auth">
 * }
 * </pre>
 *
 * 来自 https/developers/google/com/cloud-print/docs/rawxmpp 和这里的内容
 *
 * <pre>
 * {@code
 * <auth xmlns="urn:ietf:params:xml:ns:xmpp-sasl"
 *   mechanism="X-OAUTH2"
 *   auth:service="oauth2"
 *   xmlns:auth="http://www.google.com/talk/protocol/auth">
 * base64("\0" + user_name + "\0" + oauth_token)
 * </auth>
 * }
 * </pre>
 *
 * 来自 https/developers/google/com/talk/jep_extensions/oauth
 * <p>
 * 这些属性扩展当前不受 Xmpp 支持，且尚不清楚它们如何影响授权以及它们的普及程度。
 * </p>
 */
public open class SASLXOauth2Mechanism <: SASLMechanism {
    /** 
     * X-OAUTH2 机制的名称
     */
    public static let NAME = "X-OAUTH2"

    /**
     * 执行内部身份验证。当前不支持 CallbackHandler，抛出 {@link UnsupportedOperationException}。
     *
     * @param _ 回调处理程序，用于处理身份验证过程中的回调
     */
    protected open override func authenticateInternal(_: ?CallbackHandler): Unit {
        throw UnsupportedException("CallbackHandler not (yet) supported")
    }

    /**
     * 获取身份验证文本。返回的字节序列将使用 BASE64 编码。
     *
     * @return 作为身份验证文本的字节数组
     */
    protected open override func getAuthenticationText(): ?Array<UInt8> {
        return toBytes("\u{0000}${authenticationId}\u{0000}${password}")
    }

    /**
     * 获取此机制的名称。
     *
     * @return 此 SASL 机制的名称，即 "X-OAUTH2"
     */
    public open override func getName(): String {
        return NAME
    }

    /**
     * 获取此机制的优先级。X-OAUTH2 的优先级与 SASL PLAIN 相同。
     *
     * @return 此机制的优先级
     */
    public open override func getPriority(): Int {
        //  权限与 SASL PLAIN 一致  
        return 410
    }

    /**
     * 创建并返回此机制的新实例。
     *
     * @return SASLXOauth2Mechanism 的新实例
     */
    public open override func newInstance(): SASLXOauth2Mechanism {
        return SASLXOauth2Mechanism()
    }

    /**
     * 检查身份验证是否成功或抛出异常。此机制不执行任何检查。
     */
    public open override func checkIfSuccessfulOrThrow(): Unit {
        // 不进行检查  
    }
}
