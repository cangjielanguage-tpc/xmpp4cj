/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Representation of an unparsable stanza.
 */
public class UnparseableStanza {
    private let content: String

    private let e: Exception

    public init(content: String, e: Exception) {
        this.content = content
        this.e = e
    }

    /**
     * Get the exception that caused the parser to fail.
     * @return the exception that caused the parser to fail
     */
    public func getParsingException(): Exception {
        return e
    }

    /**
     * Retrieve the raw stanza data.
     *
     * @return the raw stanza data
     */
    public func getContent(): String {
        return content
    }
}
