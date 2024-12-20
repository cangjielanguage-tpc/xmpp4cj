/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class StreamPredicate {
    public static func forMessagesOrAfter5Stanzas(): StanzaFilter {
        return ForMatchingPredicateOrAfterXStanzas(ForEveryMessage.INSTANCE, 5)
    }

    public static func after5Stanzas(): AfterXStanzas {
        return AfterXStanzas(5)
    }
}
