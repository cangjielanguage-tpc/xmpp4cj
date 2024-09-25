/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Like {@link ExceptionThrowingCallback} but additionally logs a warning message.
 */
public class ExceptionThrowingCallbackWithHint <: ExceptionThrowingCallback {
    public init() {
        super()
    }

    private static let LOGGER = getGlobalLogger(("name", "ExceptionThrowingCallbackWithHint"))

    public override func handleUnparsableStanza(packetData: UnparseableStanza): Unit {
        LOGGER.warn(
            "Parsing exception \"" + packetData.getParsingException().message +
            "\" encountered. This exception will be re-thrown, leading to a disconnect. You can change this behavior by setting a different ParsingExceptionCallback using setParsingExceptionCallback(). More information an be found in AbstractXMPPConnection\'s javadoc."
        )
        super.handleUnparsableStanza(packetData)
    }
}
