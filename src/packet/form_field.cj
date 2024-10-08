/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * XEP-4§3.3中定义的表单字段类型。
 *
 * @see <a href="xmpp/org/extensions/xep-0004.html#protocol-fieldtypes">XEP-4 § 3.3 Field Types</a>
 */
public enum FormFieldType <: ToString & Equatable<FormFieldType> {
    /**
     * 布尔类型。可以是0或1，true或false，yes或no。默认值为0。
     * 请注意，在XEP-4中，这种类型被称为“boolean”。
     */
    boolean
    /**
     * 修正了在表格中间插入文本以显示部分或只是广告你的网站。
     */
    | fixed
    /**
     * 根本不给用户，而是随问卷一起返回。
     */
    | hidden
    /**
     * JID的多个条目。
     */
    | jid_multi
    /**
     * Jabber ID-从您的名单中选择一个JID，并根据JID的规则输入一个。
     */
    | jid_single
    /**
     * 给定一个选项列表，选择一个或多个。
     */
    | list_multi
    /**
     * 给定一个选项列表，选择一个。
     */
    | list_single
    /**
     * 多行文本输入。
     */
    | text_multi
    /**
     * 您显示*****以保护它，而不是向用户显示他们键入的内容。
     */
    | text_private
    /**
     * 单行或单词文本。
     */
    | text_single

    /**
     * 从给定的字符串中获取表单字段类型。如果<code>字符串</code>为None，则将返回None。
     *
     * @param string要转换的字符串或None。
     * @return type或None。
     */
    public static func fromString(string: String): ?FormFieldType {
        match (string.replace('-', '_')) {
            case "boolean" => boolean
            case "fixed" => fixed
            case "hidden" => hidden
            case "jid_multi" => jid_multi
            case "jid_single" => jid_single
            case "list_multi" => list_multi
            case "list_single" => list_single
            case "text_multi" => text_multi
            case "text_private" => text_private
            case "text_single" => text_single
            case _ => None
        }
    }

    public override func toString(): String {
        return match (this) {
            case boolean => "boolean"
            case fixed => "fixed"
            case hidden => "hidden"
            case jid_multi => "jid-multi"
            case jid_single => "jid-single"
            case list_multi => "list-multi"
            case list_single => "list-single"
            case text_multi => "text-multi"
            case text_private => "text-private"
            case text_single => "text-single"
        }
    }

    public operator func ==(that: FormFieldType): Bool {
        this.toString() == that.toString()
    }
}
