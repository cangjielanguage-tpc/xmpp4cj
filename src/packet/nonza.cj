/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * A Nonza, i.e everything that is <b>not a stanza</b> as defined
 * RFC 6120 8. Stanzas are {@link Message}, {@link Presence} and {@link IQ}.
 * Everything else should sublcass this class instead of {@link Stanza}.
 * <p>
 * It is important to cleanly distinguish between stanzas and non-stanzas. For
 * example plain stream elements don't count into the stanza count of XEP-198
 * Stream Management.
 * </p>
 *
 * @see <a href="xmpp/org/extensions/xep-0360.html">XEP-0360: Nonzas (are not Stanzas)</a>
 */
public interface Nonza <: TopLevelStreamElement {}
