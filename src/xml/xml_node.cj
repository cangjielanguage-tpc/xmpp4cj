/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xml

class XmlNode {
    /*
     * 父节点
     */
    let parentNode: ?XmlNode

    /*
     * 当前QName对象
     */
    let qName: QName

    /*
     * 当前属性列表
     */
    let attrs: ArrayList<Attribute>

    /*
     * 当前namespace列表
     */
    let namespaces: LinkedHashMap<String, QName>

    public init(parentNode: ?XmlNode, qName: QName, attrs: ArrayList<Attribute>, namespaces: LinkedHashMap<String, QName>) {
        this.parentNode = parentNode
        this.qName = qName
        this.attrs = attrs
        this.namespaces = namespaces
    }

    /*
     * 是否存在父节点
     */
    public func hasParent(): Bool {
        return parentNode.isSome()
    }
}
