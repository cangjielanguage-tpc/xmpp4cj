/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * Form Field Types as defined in XEP-4 § 3.3.
 *
 * @see <a href="xmpp/org/extensions/xep-0004.html#protocol-fieldtypes">XEP-4 § 3.3 Field Types</a>
 */
public enum FormFieldType <: ToString & Equatable<FormFieldType> {
    /**
     * Boolean type. Can be 0 or 1, true or false, yes or no. Default value is 0.
     * <p>
     * Note that in XEP-4 this type is called 'boolean'.
     * </p>
     */
    boolean
    /**
     * Fixed for putting in text to show sections, or just advertise your web site in the middle of the form.
     */
    | fixed
    /**
     * Is not given to the user at all, but returned with the questionnaire.
     */
    | hidden
    /**
     * multiple entries for JIDs.
     */
    | jid_multi
    /**
     * Jabber ID - choosing a JID from your roster, and entering one based on the rules for a JID.
     */
    | jid_single
    /**
     * Given a list of choices, pick one or more.
     */
    | list_multi
    /**
     * Given a list of choices, pick one.
     */
    | list_single
    /**
     * Multiple lines of text entry.
     */
    | text_multi
    /**
     * Instead of showing the user what they typed, you show ***** to protect it.
     */
    | text_private
    /**
     * Single line or word of text.
     */
    | text_single

    /**
     * Get a form field type from the given string. If <code>string</code> is None, then None will be returned.
     *
     * @param string the string to transform or None.
     * @return the type or None.
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

    public operator func !=(that: FormFieldType): Bool {
        return !(this == that)
    }
}
