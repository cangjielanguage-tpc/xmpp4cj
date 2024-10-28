/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**  
 * 实现 SASL ANONYMOUS 机制。
 *
 * <p>
 * SASL ANONYMOUS 机制允许客户端以匿名身份进行身份验证。
 * </p>
 */
public class SASLAnonymous <: SASLMechanism {
    /** 
     * ANONYMOUS 机制的名称
     */
    public static let NAME = "ANONYMOUS"

    /**  
     * 获取此机制的名称。
     *
     * @return 此 SASL 机制的名称，即 "ANONYMOUS"
     */
    public override func getName(): String {
        return NAME
    }

    /**  
     * 获取此机制的优先级。
     *
     * @return 此机制的优先级，为 500
     */
    public override func getPriority(): Int {
        return 500
    }

    /**  
     * 执行内部身份验证。对于 ANONYMOUS 机制，此方法不需要执行任何操作。
     *
     * @param _ 回调处理程序，用于处理身份验证过程中的回调
     */
    protected override func authenticateInternal(_: ?CallbackHandler): Unit {
        //此处无需执行任何操作
    }

    /**  
     * 获取身份验证文本。ANONYMOUS 机制没有初始响应，因此返回 None
     *
     * @return 此机制的身份验证文本，总是返回 None
     */
    protected override func getAuthenticationText(): ?Array<UInt8> {
        // ANONYMOUS 机制没有初始响应，返回 None
        return None
    }

    /**  
     * 创建并返回此机制的新实例。
     *
     * @return SASLAnonymous 的新实例
     */
    public override func newInstance(): SASLAnonymous {
        return SASLAnonymous()
    }

    /**  
     * 检查身份验证是否成功或抛出异常。对于 SASL ANONYMOUS 机制，该身份验证总是成功。
     */
    public override func checkIfSuccessfulOrThrow(): Unit {
        // SASL Anonymous 始终成功 :)  
    }

    /**  
     * 指示此机制是否需要密码。
     *
     * @return 如果此机制不需要密码，则返回 false
     */
    public override func requiresPassword(): Bool {
        return false
    }
}
