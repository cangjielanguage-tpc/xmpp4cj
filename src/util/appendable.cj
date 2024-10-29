/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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
}
