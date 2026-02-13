/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.filter

/**
 * 过滤器类，用于根据扩展元素类型过滤 STANZA。
 */
public class ExtensionElementFilter<E> <: StanzaFilter where E <: ExtensionElement {
    private let extensionElementClass: ClassId // 存储扩展元素类的 Class 对象

    private let extensionElementQName: QName // 存储扩展元素的 QName（定 QName）

    /**
     * 构造函数，根据给定的扩展元素类创建过滤器。
     *
     * @param extensionElementClass 要过滤的扩展元素类，不能为空。
     */
    protected init(extensionElementClass: ClassId) {
        this.extensionElementClass = extensionElementClass
        extensionElementQName = XmppElementUtil.getQNameFor(extensionElementClass)
    }

    /**
     * 检查给定的 STANZA 数据包是否被接受。如果 STANZA 中包含指定的扩展元素，则返回 true。
     *
     * @param stanza 要检查的 STANZA 数据包。
     * @return 如果数据包包含扩展元素并且符合过滤条件，则返回 true；否则返回 false。
     */
    public override func accept(stanza: Stanza): Bool {
        let extensionElement: ?ExtensionElement = stanza.getExtension(extensionElementQName)
        if (let Some(v) <- extensionElement) {
            if (extensionElementClass != "ExtensionElement") {
                return false
            }
        } else {
            return false
        }
        return true
    }

    /**
     * 默认接受方法，可以在子类中重写以实现特定的过滤逻辑。
     *
     * @param extensionElement 要检查的特定扩展元素。
     * @return 如果特定扩展元素符合过滤条件，则返回 true；默认为 true。
     */
    public func accept(extensionElement: E): Bool {
        return true
    }

    public override func toString(): String {
        return "ExtensionElementFilter"
    }
}
