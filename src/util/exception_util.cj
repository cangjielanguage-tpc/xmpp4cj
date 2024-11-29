/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * 异常工具类
 */
public class ExceptionUtil {
    /**
     * 打印报错的堆栈信息。
     *
     * @param throwable 异常。
     * @return 打印的堆栈信息。
     */
    public static func getStackTrace(throwable: Exception): String {
        let sb = StringBuilder(throwable.toString())
        throwable.getStackTrace() |>
            fold<StackTraceElement, StringBuilder>(sb) {
            sb, element =>
            sb.append(
                """

    at ${element.declaringClass}.${element.methodName} ${element.fileName}:${element.lineNumber}"""
            )
            sb
        }
        match (throwable) {
            case e: ExceptionExt => sb.append(e.getCauseStackTrace())
            case _ => ()
        }
        sb.toString()
    }
}

/* 针对Exception无法继承cause堆栈 定义一个ExceptionExt作为需要cause信息的父类 */
public abstract class ExceptionExt <: Exception {
    protected var cause: ?Exception = None
    protected init() {}
    protected init(cause: ?Exception) {
        this.cause = cause
    }
    protected init(message: String, cause: ?Exception) {
        super(message)
        this.cause = cause
    }
    /* 获取原始异常 */
    public open func getCause(): ?Exception {
        return this.cause
    }
    /* 获取原始异常的堆栈信息 */
    public func getCauseStackTrace(): String {
        if (let Some(e) <- cause) {
            "cause by: " + ExceptionUtil.getStackTrace(e)
        } else {
            ""
        }
    }
}

public class InterruptedException <: ExceptionExt {
    public init() {}
    public init(cause: ?Exception) {
        super(cause)
    }
    public init(message: String, cause: ?Exception) {
        super(message, cause)
    }
    public override func getClassName(): String {
        "InterruptedException"
    }
}
