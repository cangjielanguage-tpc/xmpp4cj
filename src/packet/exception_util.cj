/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class ExceptionUtil {
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
