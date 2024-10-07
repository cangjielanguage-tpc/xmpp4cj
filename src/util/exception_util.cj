/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
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
                "\n\t at ${element.declaringClass}.${element.methodName}(${element.fileName}:${element.lineNumber}")
            sb
        }
        sb.toString()
    }
}
