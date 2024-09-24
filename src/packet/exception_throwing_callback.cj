/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Parsing exception callback class that simply throws the encountered parsing exception. This usually leads to an
 * {@link ConnectionListener#connectionClosedOnError(Exception)} and disconnect of the connection.
 */
public open class ExceptionThrowingCallback <: ParsingExceptionCallback {
    public open override func handleUnparsableStanza(packetData: UnparseableStanza): Unit {
        throw IOException()
    }
}
