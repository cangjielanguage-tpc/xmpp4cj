/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 简单的解析异常回调，仅将遇到的解析异常记录到java.util.日志中。
 */
public class ExceptionLoggingCallback <: ParsingExceptionCallback {
    private static let LOGGER = getGlobalLogger(("name", "ExceptionLoggingCallback"))

    public override func handleUnparsableStanza(unparsed: UnparseableStanza): Unit {
        LOGGER.log(LogLevel.ERROR, "Xmpp message parsing exception. Content: \'${unparsed.getContent()}\'",
            ("Exception", unparsed.getParsingException()))
    }
}
