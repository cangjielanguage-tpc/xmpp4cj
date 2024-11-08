/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.modular

public class ClassInfo<R> <: Hashable & Equatable<ClassInfo<R>> & ToString {
    public ClassInfo(let classId: ClassId, let constructor: (Array<Object>) -> R) {}
    public override func hashCode(): Int64 {
        classId.hashCode()
    }
    public override func toString(): String {
        classId.toString()
    }
    public operator func ==(that: ClassInfo<R>): Bool {
        classId == that.classId
    }
}
