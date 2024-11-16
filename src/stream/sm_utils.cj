/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.stream

public class SMUtils {
    private static let MASK_32_BIT: Int = 0xFFFFFFFF

    /**
     * 增加 Stream Management height 计数器.
     *
     * 引用 XEP-198 4.:
     * “在不太可能的情况下，如果在流管理会话期间处理的节（stanza）数量超过 XML 模式第 2 部分[10]中指定的无符号整数数据类型所能表示的数字（即 2 的 32 次方），那么‘h’的值应从 2 的 32 次方减 1 重置回零，而不是递增到 2 的 32 次方。”
     *
     * @param height
     * @return 增加后的 height
     */
    public static func incrementHeight(height: Int64): Int64 {
        var tempheight = height
        return (height + 1) & MASK_32_BIT
    }

    /**
     * 计算最后已知的已处理节的数量和新报告的已处理节的数量之间的差值，同时考虑到新值可能在 2 的 32 次方减 1 之后回绕。
     *
     * @param reportedHandledCount 新报告的已处理节的数量
     * @param lastKnownHandledCount 已处理节的数量
     * @return 差值
     */
    public static func calculateDelta(reportedHandledCount: Int64, lastKnownHandledCount: Int64): Int64 {
        if (lastKnownHandledCount > reportedHandledCount) {
            throw IllegalStateException(
                "Illegal Stream Management State: Last known handled count (${lastKnownHandledCount}) is greater than reported handled count (${reportedHandledCount})"
            )
        }
        return (reportedHandledCount - lastKnownHandledCount) & MASK_32_BIT
    }
}
