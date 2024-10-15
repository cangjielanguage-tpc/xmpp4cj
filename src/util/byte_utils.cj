/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

public class ByteUtils {
    /**
     * Concatenate two byte arrays.
     *
     * @param arrayOne the first input array.
     * @param arrayTwo the second input array
     * @return the concatenation of the first and second input array.
     *
     */
    public static func concat(arrayOne: Array<UInt8>, arrayTwo: Array<UInt8>): Array<UInt8> {
        arrayOne |> concat(arrayTwo) |> collectArray
    }
}
