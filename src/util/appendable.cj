/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/**
 * 一个可以附加char序列和值的对象。
 */
public interface Appendable {
    /**
     * 将指定的字符序列附加到此｛@code Appendable｝。
     *
     * @param csq 要附加的字符序列。
     * @return 返回Appendable对象。
     */
    func append(csq: CharSequence): Appendable

    /**
     * Appends a subsequence of the specified character sequence to this {@code Appendable}.
     *
     * @param  csq
     *         The character sequence from which a subsequence will be
     *         appended.
     * @param  start
     *         The index of the first character in the subsequence
     * @param  end
     *         The index of the character following the last character in the
     *         subsequence
     *
     * @return  A reference to this {@code Appendable}
     */
    // func append(csq: CharSequence, start: Int64, end: Int64): Appendable

    /**
     * Appends the specified character to this {@code Appendable}.
     *
     * @param  c
     *         The character to append
     * @return  A reference to this {@code Appendable}
     */
    // func append(c: Rune): Appendable
}
