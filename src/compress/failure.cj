/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.compress

/**
 * Failure 类表示 XMPP 协议中的失败（Failure）非自定义数据（Nonza）元素。
 * <p>
 * 此类封装了失败相关的信息，包括压缩失败错误类型和可选的额外失败细节（StanzaError）。
 * </p>
 */
public class Failure <: Nonza {
    /**
     * 该元素的名称。
     */
    public static let ELEMENT: String = "failure"

    /**
     * 此元素所属的命名空间，引用了 Compress 类的命名空间。
     */
    public static let NAMESPACE: String = Compress.NAMESPACE

    /**
     * 此元素的 QNAME，包含命名空间和元素名称。
     */
    public static let QNAME: QName = QName(NAMESPACE, ELEMENT)

    static init() {
        ELEMENT_MAPPING.put("Failure", ELEMENT)
        NAMESPACE_MAPPING.put("Failure", NAMESPACE)
        QNAME_MAPPING.put("Failure", QNAME)
    }

    private let compressFailureError: FailureCompressFailureError // 压缩失败错误  

    private let stanzaError: ?StanzaError // 可选的 StanzaError  

    /**
     * 构造函数，仅使用压缩失败错误来创建 Failure 实例。
     *
     * @param compressFailureError 表示压缩失败的错误类型。
     */
    public init(compressFailureError: ?FailureCompressFailureError) {
        this(compressFailureError, None)
    }

    /**
     * 构造函数，同时使用压缩失败错误和可选的 StanzaError 来创建 Failure 实例。
     *
     * @param compressFailureError 表示压缩失败的错误类型。
     * @param stanzaError         可选的 StanzaError 实例，表示附带的错误信息。
     */
    public init(compressFailureError: ?FailureCompressFailureError, stanzaError: ?StanzaError) {
        this.compressFailureError = Objects.requireNonNull(compressFailureError)
        this.stanzaError = stanzaError
    }

    /**
     * 获取该元素的名称。
     *
     * @return 返回元素名称 "failure"。
     */
    public override func getElementName(): String {
        return ELEMENT
    }

    /**
     * 获取该元素所属的命名空间。
     *
     * @return 返回命名空间字符串。
     */
    public override func getNamespace(): String {
        return NAMESPACE
    }

    /**
     * 获取压缩失败错误类型。
     *
     * @return 返回 CompressFailureError 枚举值。
     */
    public func getFailureCompressFailureError(): FailureCompressFailureError {
        return compressFailureError
    }

    /**
     * 获取可选的 StanzaError 信息。
     *
     * @return 返回 StanzaError，可能为 null。
     */
    public func getStanzaError(): ?StanzaError {
        return stanzaError
    }

    /**
     * 将该元素转换为 XML 字符串表示。
     *
     * @param enclosingNamespace 包含此元素的 XML 环境。
     * @return 返回表示此失败元素的 XML 字符串。
     */
    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml: XmlStringBuilder = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()

        xml.emptyElement(compressFailureError)
        xml.optElement(stanzaError ?? None)

        xml.closeElement(this)
        return xml
    }
}

/**
 * CompressFailureError 枚举表示可用的压缩失败错误类型。
 */
public enum FailureCompressFailureError <: ToString & Equatable<FailureCompressFailureError> {
    /**
     * 安装失败。
     */
    setup_failed
    /**
     * 处理失败。
     */
    | processing_failed
    /**
     * 不支持的方法。
     */
    | unsupported_method

    public override func toString(): String {
        return match (this) {
            case setup_failed => "setup-failed"
            case processing_failed => "processing-failed"
            case unsupported_method => "unsupported-method"
        }
    }

    /**
     * 通过获取枚举。
     *
     * @return FailureCompressFailureError。
     */
    public static func fromString(s: String): ?FailureCompressFailureError {
        match (s) {
            case "setup_failed" => setup_failed
            case "processing_failed" => processing_failed
            case "unsupported_method" => unsupported_method
            case _ => None
        }
    }

    public operator override func ==(other: FailureCompressFailureError): Bool {
        match ((this, other)) {
            case (setup_failed, setup_failed) => true
            case (processing_failed, processing_failed) => true
            case (unsupported_method, unsupported_method) => true
            case _ => false
        }
    }
}
