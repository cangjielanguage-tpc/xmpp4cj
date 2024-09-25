/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Simple parsing exception callback that only logs the encountered parsing exception to java util logging.
 */
public class ExceptionLoggingCallback <: ParsingExceptionCallback {
    private static let LOGGER = getGlobalLogger(("name", "ExceptionLoggingCallback"))

    public override func handleUnparsableStanza(unparsed: UnparseableStanza): Unit {
        LOGGER.log(LogLevel.FATAL, "Xmpp message parsing exception. Content: \'" + (unparsed.getContent()) + "\'",
            ("Exception", unparsed.getParsingException()))
    }
}
