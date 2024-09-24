/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Interface to receive parsing exceptions.
 * <p>
 * If this class is used as callback, then Xmpp will silently ignore the stanza that caused the parsing exception and
 * place the parser after the faulty stanza.
 * </p>
 * <p>
 * Xmpp provides 2 predefined ParsingExceptionCallback's: {@link ExceptionLoggingCallback} and {@link ExceptionThrowingCallback}.
 * </p>
 */
public interface ParsingExceptionCallback {
    /**
     * Called when parsing a stanza caused an exception.
     *
     * @param stanzaData the raw stanza data that caused the exception
     * @throws IOException if an I/O error occurred.
     */
    func handleUnparsableStanza(stanzaData: UnparseableStanza): Unit
}
