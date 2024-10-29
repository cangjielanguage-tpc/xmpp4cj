/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.sasl

let SASLError_LOGGER = getGlobalLogger(("name", "SASLError"))

/**  
 * SASL 错误条件枚举。
 *
 * @see <a href="tools/ietf/org/html/rfc6120#section-6.5">RFC 6120 § 6.5, SASL Errors</a>
 */
public enum SASLError <: ToString {
    /**
     * 连接中止
     */
    aborted
    /**
     * 账户已禁用
     */
    | account_disabled
    /**
     * 凭据已过期
     */
    | credentials_expired
    /**
     *  需要加密
     */
    | encryption_required
    /**
     * 编码错误
     */
    | incorrect_encoding
    /**
     * 无效的授权 ID
     */
    | invalid_authzid
    /**
     * 无效的机制
     */
    | invalid_mechanism
    /**
     * 请求格式错误
     */
    | malformed_request
    /**
     * 机制过于弱
     */
    | mechanism_too_weak
    /**
     * 未经授权
     */
    | not_authorized
    /**
     * 临时身份验证失败
     */
    | temporary_auth_failure

    public override func toString(): String {
        match (this) {
            case aborted => "aborted"
            case account_disabled => "account-disabled"
            case credentials_expired => "credentials-expired"
            case encryption_required => "encryption-required"
            case incorrect_encoding => "incorrect-encoding"
            case invalid_authzid => "invalid-authzid"
            case invalid_mechanism => "invalid-mechanism"
            case malformed_request => "malformed-request"
            case mechanism_too_weak => "mechanism-too-weak"
            case not_authorized => "not-authorized"
            case temporary_auth_failure => "temporary-auth-failure"
        }
    }

    /**  
     * 从字符串转换为相应的 SASLError 枚举值。
     *
     * @param string 要转换的字符串
     * @return 转换后的 SASLError 枚举值，如果转换失败则返回 null
     */
    public static func fromString(string: ?String): ?SASLError {
        match (string?.replace('-', '_') ?? "") {
            case "aborted" => aborted
            case "account_disabled" => account_disabled
            case "credentials_expired" => credentials_expired
            case "encryption_required" => encryption_required
            case "incorrect_encoding" => incorrect_encoding
            case "invalid_authzid" => invalid_authzid
            case "invalid_mechanism" => invalid_mechanism
            case "malformed_request" => malformed_request
            case "mechanism_too_weak" => mechanism_too_weak
            case "not_authorized" => not_authorized
            case "temporary_auth_failure" => temporary_auth_failure
            case v =>
                SASLError_LOGGER.log(LogLevel.WARN, "Could not transform string '${v}' to SASLError")
                None
        }
    }
}
