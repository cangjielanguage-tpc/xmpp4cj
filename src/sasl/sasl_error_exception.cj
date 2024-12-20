/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.sasl

/**
 * 表示 SASL 错误的异常类，继承自 XMPPException。
 */
public class SASLErrorException <: XMPPException {
    private let saslFailure: SaslNonzaSASLFailure // 表示 SASL 失败信息  
    private let mechanism: String // 使用的 SASL 机制 
    private let texts: Map<String, String> // 额外的文本信息  

    /**
     * 使用给定的机制和 SASL 失败信息构造 SASLErrorException。
     *
     * @param mechanism 使用的 SASL 机制
     * @param saslFailure SASL 失败信息
     */
    public init(mechanism: String, saslFailure: SaslNonzaSASLFailure) {
        this(mechanism, saslFailure, HashMap<String, String>())
    }

    /**
     * 使用给定的机制、SASL 失败信息和额外的文本信息构造 SASLErrorException。
     *
     * @param mechanism 使用的 SASL 机制
     * @param saslFailure SASL 失败信息
     * @param texts 额外的文本信息
     */
    public init(mechanism: String, saslFailure: SaslNonzaSASLFailure, texts: Map<String, String>) {
        super("SASLError using ${mechanism}: ${saslFailure.getSASLErrorString()}")
        this.mechanism = mechanism
        this.saslFailure = saslFailure
        this.texts = texts
    }

    /**
     * 获取 SASL 失败信息。
     *
     * @return 返回 SASLFailure 对象
     */
    public func getSASLFailure(): SaslNonzaSASLFailure {
        return saslFailure
    }

    /**
     * 获取使用的 SASL 机制。
     *
     * @return 返回 SASL 机制的名称
     */
    public func getMechanism(): String {
        return mechanism
    }

    /**
     * 获取额外的文本信息。
     *
     * @return 返回包含额外文本信息的 Map
     */
    public func getTexts(): Map<String, String> {
        return texts
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "SASLErrorException"
    }
}
