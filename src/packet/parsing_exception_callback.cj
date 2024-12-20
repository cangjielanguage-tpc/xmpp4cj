/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 用于接收解析异常的接口。
 * 如果将此类用作回调，则Xmpp将默默地忽略导致解析异常的节，并且
 * 将解析器放在错误节之后。
 * Xmpp提供了两个预定义的解析异常回调：{@link ExceptionLoggingCallback}和{@link Exception ThrowingCallback}。
 */
public interface ParsingExceptionCallback {
    /**
     * 当解析一个节导致异常时调用。
     *
     * @param stanzaData 导致异常的原始节数据
     * @throws IOException 如果发生I/O错误，会抛出IOException。
     */
    func handleUnparsableStanza(stanzaData: UnparseableStanza): Unit
}
