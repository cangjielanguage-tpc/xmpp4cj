/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * xmpp异常类。
 */
public open class XmppParsingException <: ExceptionExt {
    /**
     * 通过异常类构造当前对象。
     *
     * @param exception Exception。
     */
    protected init(exception: Exception) {
        super(exception.toString(), exception)
    }

    /**
     * 通过异常信息构造当前对象。
     *
     * @param message 异常信息。
     */
    public init(message: String) {
        super(message, None)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "XmppParsingException"
    }
}

/**
 * xmpp异常类。
 */
public class XmppTextParseException <: XmppParsingException {
    /**
     * 通过异常类构造当前对象。
     *
     * @param exception Exception。
     */
    public init(parsingException: Exception) {
        super(parsingException)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XmppTextParseException"
    }
}

/**
 * xmpp异常类。
 */
public class XmppUriSyntaxParsingException <: XmppParsingException {
    /**
     * 通过异常类构造当前对象。
     *
     * @param uriSyntaxException Exception。
     */
    public init(uriSyntaxException: Exception) {
        super(uriSyntaxException)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XmppUriSyntaxParsingException"
    }
}

/**
 * xmpp异常类。
 */
public open class XmppRequiredValueMissingException <: XmppParsingException {
    /**
     * 通过异常信息构造当前对象。
     *
     * @param message 异常信息。
     */
    public init(message: String) {
        super(message)
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "XmppRequiredValueMissingException"
    }
}

/**
 * xmpp异常类。
 */
public class XmppRequiredAttributeMissingException <: XmppRequiredValueMissingException {
    /**
     * 通过属性名称构造当前对象。
     *
     * @param attributeName 属性名称
     */
    public init(attributeName: String) {
        super("The required attribute \'${attributeName}" + "\' is missing (or has the empty String as value)")
    }

    /**
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "XmppRequiredAttributeMissingException"
    }
}
