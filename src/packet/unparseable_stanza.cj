/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 无法解析的节点的表示。
 */
public class UnparseableStanza {
    private let content: String

    private let e: Exception

    /**
     * 构造方法
     *
     * @param content 节点内容。
     * @param e 异常。
     */
    public init(content: String, e: Exception) {
        this.content = content
        this.e = e
    }

    /**
     * 获取导致解析器失败的异常。
     *
     * @return 导致解析器失败的异常
     */
    public func getParsingException(): Exception {
        return e
    }

    /**
     * 检索原始节数据。
     *
     * @return 原始节数据
     */
    public func getContent(): String {
        return content
    }
}
