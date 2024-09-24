/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public open class XmppParsingException <: Exception {
    protected init(exception: Exception) {
        super()
    }

    public init(message: String) {
        super(message)
    }
}

public class XmppTextParseException <: XmppParsingException {
    public init(parsingException: Exception) {
        super(parsingException)
    }
}

public class XmppUriSyntaxParsingException <: XmppParsingException {
    public init(uriSyntaxException: Exception) {
        super(uriSyntaxException)
    }
}

public open class XmppRequiredValueMissingException <: XmppParsingException {
    public init(message: String) {
        super(message)
    }
}

public class XmppRequiredAttributeMissingException <: XmppRequiredValueMissingException {
    public init(attributeName: String) {
        super("The required attribute \'" + (attributeName) + "\' is missing (or has the empty String as value)")
    }
}
