/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 用于过滤具有特定 Stanza ID 的 Stanzas 的过滤器。
 */
public class StanzaIdFilter <: StanzaFilter {
    /** 
     * 要过滤的 Stanza ID
     */
    private let stanzaId: ?String

    /**  
     * 使用指定 Stanza 的 ID 创建一个新的 Stanza ID 过滤器。
     *
     * @param stanza 要从中获取 ID 的 Stanza。
     */
    public init(stanza: Stanza) {
        this(stanza.getStanzaId())
    }

    /**  
     * 使用指定的 Stanza ID 创建一个新的 Stanza ID 过滤器。
     *
     * @param stanzaId 要过滤的 Stanza ID。
     */
    public init(stanzaId: ?String) {
        this.stanzaId = StringUtils.requireNotNullNorEmpty(stanzaId, "Stanza ID must not be null nor empty.")
    }

    /**  
     * 检查给定 Stanza 是否被该过滤器接受。
     *
     * @param stanza 要检查的 Stanza
     * @return 如果 Stanza 的 ID 与过滤器的 ID 匹配，则返回 true；否则返回 false。
     */
    public override func accept(stanza: Stanza): Bool {
        return stanzaId == stanza.getStanzaId()
    }

    /**  
     * 返回过滤器的字符串表示形式。
     *
     * @return 过滤器的字符串表示，包含类名和 Stanza ID。
     */
    public override func toString(): String {
        return if (let Some(v) <- stanzaId) {
            "StanzaIdFilter: id=${v}"
        } else {
            "StanzaIdFilter: id=None"
        }
    }
}
