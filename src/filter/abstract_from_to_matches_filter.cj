/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

public abstract class AbstractFromToMatchesFilter <: StanzaFilter {
    /**
     * 过滤器所匹配的 JID 地址
     */
    let address: ?Jid

    /**
     * 指示是针对裸JID地址还是完整JID进行检查的标志。
     */
    let ignoreResourcepart: Bool

    /**
     * 在｛@link#getAddressToCompare（Stanza）｝返回的地址上创建匹配的筛选器。地址必须与筛选器地址相同。第二个参数指定是比较完整地址还是裸地址。
     *
     * @param address 要筛选的地址。如果给定<code>None</code>，那么{@link#getAddressToCompare（Stanza）}也必须返回<code>空</code]进行匹配。
     * @param ignoreResourcepart Bool
     */
    protected init(address: ?Jid, ignoreResourcepart: Bool) {
        if (let Some(v) <- address.filter {_ => ignoreResourcepart}) {
            this.address = v.asBareJid()
        } else {
            this.address = address
        }
        this.ignoreResourcepart = ignoreResourcepart
    }

    /**  
     * 测试指定的 Stanza 是否应该通过过滤器。
     *
     * @param stanza 要测试的 Stanza。
     * @return 如果且仅如果 <code>stanza</code> 通过过滤器，则返回 true。
     */
    public override func accept(stanza: Stanza): Bool {
        var stanzaAddress: ?Jid = getAddressToCompare(stanza)
        if (stanzaAddress.isNone()) {
            return address == None
        }
        if (let Some(v) <- stanzaAddress.filter {_ => ignoreResourcepart}) {
            stanzaAddress = v.asBareJid()
        }
        return stanzaAddress == address
    }

    /**
     * 抽象方法，从 Stanza 中获取要比较的地址
     *
     * @param stanza Stanza
     */
    protected func getAddressToCompare(stanza: Stanza): ?Jid

    public open override func toString(): String {
        let matchMode: String = if (ignoreResourcepart) {
            "ignoreResourcepart"
        } else {
            "full"
        }
        return if (let Some(v) <- address) {
            "AbstractFromToMatchesFilter (${matchMode}): ${v}"
        } else {
            "AbstractFromToMatchesFilter (${matchMode}): None"
        }
    }
}
