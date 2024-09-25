/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public open class AbstractProvider<E> where E <: Element {
    protected var elementClass: ClassId = "" // need init in subclass

    public func getElementClass(): ClassId {
        return elementClass
    }
}
