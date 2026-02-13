/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.util

/**
 * public type ClassId = String
 *
 * 用于替代std.reflect.TypeInfo
 */
public type ClassId = String

/**
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

public func anyClassId(any: Any): ClassId {
    if (any is ClassIdentify) {
        (any as ClassIdentify).getOrThrow().getClass()
    } else {
        "NoClassInfo"
    }
}
