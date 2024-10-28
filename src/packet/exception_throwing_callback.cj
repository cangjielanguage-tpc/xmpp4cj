/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 解析异常回调类，它只是抛出遇到的解析异常。这通常会导致
 * ｛@link ConnectionListener#connectionClosedOnError（异常）｝并断开连接。
 */
public open class ExceptionThrowingCallback <: ParsingExceptionCallback {
    /**
     * 当解析一个节导致异常时调用。
     *
     * @param _ 导致异常的原始节数据
     * @throws IOException 如果发生I/O错误，会抛出IOException。
     */
    public open override func handleUnparsableStanza(_: UnparseableStanza): Unit {
        throw IOException()
    }
}
