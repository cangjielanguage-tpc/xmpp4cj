/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.util

/*
 * 用于替代std.reflect.TypeInfo
 */
public type ClassId = String

/*
 * 用于获取ClassId
 */
public interface ClassIdentify {
    /**
     * 获取ClassId。
     *
     * @return ClassId。
     */
    static func getClassId(): ClassId

    /**
     * 获取ClassId。
     *
     * @return ClassId。
     */
    func getClass(): ClassId
}
