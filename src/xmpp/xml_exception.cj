/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

public abstract class InvalidXmlException <: Exception {
    private let unexpectedChar: Rune

    private let xml: String

    protected init(message: String, unexpectedChar: Rune, xml: String) {
        super(message)
        this.unexpectedChar = unexpectedChar
        this.xml = xml
    }

    public func getUnexpectedChar(): Rune {
        return unexpectedChar
    }

    public func getParsedXmlSoFar(): String {
        return xml
    }
}

public class InvalidXmlException_InvalidEmptyTagException <: InvalidXmlException {
    private init(message: String, c: Rune, xml: String) {
        super(message, c, xml)
    }

    public static func create(c: Rune, xml: String): InvalidXmlException_InvalidEmptyTagException {
        let message = "Invalid empty tag, expected '>', but got '${c}'. Parsed xml so far: ${xml}"
        return InvalidXmlException_InvalidEmptyTagException(message, c, xml)
    }
}

public class InvalidXmlException_InvalidAttributeDeclarationException <: InvalidXmlException {
    private init(message: String, c: Rune, xml: String) {
        super(message, c, xml)
    }

    public static func create(c: Rune, xml: String): InvalidXmlException_InvalidAttributeDeclarationException {
        let message = "Invalid attribute declaration, expected ''' or '\"', but got '${c}'. Parsed xml so far: ${xml}"
        return InvalidXmlException_InvalidAttributeDeclarationException(message, c, xml)
    }
}
