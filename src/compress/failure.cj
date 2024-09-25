/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.compress

public class Failure <: Nonza {
    public static let ELEMENT: String = "failure"
    public static let NAMESPACE: String = Compress.NAMESPACE
    public static let QNAME: QName = QName(NAMESPACE, ELEMENT)

    private let compressFailureError: FailureCompressFailureError
    private let stanzaError: ?StanzaError

    public init(compressFailureError: ?FailureCompressFailureError) {
        this(compressFailureError, None)
    }

    public init(compressFailureError: ?FailureCompressFailureError, stanzaError: ?StanzaError) {
        this.compressFailureError = Objects.requireNonNull(compressFailureError)
        this.stanzaError = stanzaError
    }

    public override func getElementName(): String {
        return ELEMENT
    }

    public override func getNamespace(): String {
        return NAMESPACE
    }

    public func getFailureCompressFailureError(): FailureCompressFailureError {
        return compressFailureError
    }

    public func getStanzaError(): ?StanzaError {
        return stanzaError
    }

    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml: XmlStringBuilder = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()

        xml.emptyElement(compressFailureError)
        xml.optElement(stanzaError ?? None)

        xml.closeElement(this)
        return xml
    }
}

public enum FailureCompressFailureError <: ToString {
    setup_failed
    | processing_failed
    | unsupported_method

    public override func toString(): String {
        return match (this) {
            case setup_failed => "setup-failed"
            case processing_failed => "processing-failed"
            case unsupported_method => "unsupported-method"
        }
    }

    public static func fromString(s: String): ?FailureCompressFailureError {
        match (s) {
            case "setup_failed" => setup_failed
            case "processing_failed" => processing_failed
            case "unsupported_method" => unsupported_method
            case _ => None
        }
    }
}
