/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**  
 * 抽象类 AbstractProvider 用于提供元素类型的支持。
 *
 * @param <E> 元素类型，必须是 Element 的子类
 */
public open class AbstractProvider<E> where E <: Element {
    /**  
     * 存储元素类型的 Class 对象。
     */
    protected var elementClass: ClassId = ""

    /*
     * 构造函数
     * @param elementClass Element泛型的ClassId
     */
    public init(elementClass: ClassId) {
        this.elementClass = elementClass
    }

    /**  
     * 获取元素类型的 Class 对象。
     *
     * @return 元素类型的 Class 对象
     */
    public func getElementClass(): ClassId {
        return elementClass
    }
}
