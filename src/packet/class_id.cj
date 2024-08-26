/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/*
 * 用于替代std.reflect.TypeInfo
 */
public type ClassId = String

/*
 * 用于获取ClassId
 */
public interface ClassIdentify {
    static func getClassId(): ClassId
    func getClass(): ClassId
}
