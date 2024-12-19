/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * 一个 Nonza，即如 RFC 6120 8 所定义的<b>不是节</b>的所有内容。节是 {@link Message}、{@link Presence} 和 {@link IQ}。其他所有内容都应该继承这个类而不是 {@link Stanza}。
 * <p>
 * 清楚地区分节和非节非常重要。例如，普通的流元素不计入 XEP-198 流管理的节计数中。
 * </p>
 *
 * @see <a href="xmpp/org/extensions/xep-0360.html">XEP-0360: Nonzas (are not Stanzas)</a>
 */
public interface Nonza <: TopLevelStreamElement {}
