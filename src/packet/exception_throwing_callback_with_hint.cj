/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 类似于{@link ExceptionThrowingCallback}，但还会记录一条警告消息。
 */
public class ExceptionThrowingCallbackWithHint <: ExceptionThrowingCallback {
    private static let LOGGER = getGlobalLogger(("name", "ExceptionThrowingCallbackWithHint"))

    /**
     * 空参构造方法
     */
    public init() {
        super()
    }

    public override func handleUnparsableStanza(packetData: UnparseableStanza): Unit {
        LOGGER.warn(
            "Parsing exception \"${packetData.getParsingException().message}\" encountered. This exception will be re-thrown, leading to a disconnect. You can change this behavior by setting a different ParsingExceptionCallback using setParsingExceptionCallback(). More information an be found in AbstractXMPPConnection\'s doc."
        )
        super.handleUnparsableStanza(packetData)
    }
}
