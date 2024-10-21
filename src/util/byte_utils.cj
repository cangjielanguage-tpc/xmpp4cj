/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public class ByteUtils {
    /**
     * 连接两个字节数组。
     *
     * @param arrayOne 第一个输入数组。
     * @param arrayTwo 第二个输入数组。
     * @return 第一个和第二个输入数组的连接。
     */
    public static func concat(arrayOne: Array<UInt8>, arrayTwo: Array<UInt8>): Array<UInt8> {
        arrayOne |> concat(arrayTwo) |> collectArray
    }
}
