/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 过滤特定类型的消息数据包（例如：CHAT）。
 *
 * @see MessageType
 */
public class MessageTypeFilter <: FlexibleStanzaTypeFilter<Message> {
    /**
     * 表示消息的类型。（默认）用于类似电子邮件界面的普通文本消息。
     */
    public static let NORMAL: StanzaFilter = MessageTypeFilter(MessageType.normal)

    /**
     * 表示消息的类型。用于逐行聊天界面的通常较短的文本消息。
     */
    public static let CHAT: StanzaFilter = MessageTypeFilter(MessageType.chat)

    /**
     * 表示消息的类型。发送到群聊服务器的群聊消息。
     */
    public static let GROUPCHAT: StanzaFilter = MessageTypeFilter(MessageType.groupchat)

    /**
     * 表示消息的类型。用于滚动字幕显示的文本消息。
     */
    public static let HEADLINE: StanzaFilter = MessageTypeFilter(MessageType.headline)

    /**
     * 表示消息的类型。表示消息错误。
     */
    public static let ERROR: StanzaFilter = MessageTypeFilter(MessageType.error)

    /**
     * 表示消息的类型。NORMAL、CHAT数组
     */
    public static let NORMAL_OR_CHAT: StanzaFilter = OrFilter([NORMAL, CHAT])

    /**
     * 表示消息的类型。NORMAL、HEADLINE数组
     */
    public static let NORMAL_OR_HEADLINE: StanzaFilter = OrFilter([NORMAL, HEADLINE])

    /**
     * 表示消息的类型。NORMAL_OR_CHAT、HEADLINE数组
     */
    public static let NORMAL_OR_CHAT_OR_HEADLINE: StanzaFilter = OrFilter([NORMAL_OR_CHAT, HEADLINE])

    private let messageType: MessageType // 存储消息类型  

    /**  
     * 使用指定的消息类型创建一个新的消息类型过滤器。
     *
     * @param type 消息类型。
     */
    private init(messageType: MessageType) {
        super("Message")
        this.messageType = messageType
    }

    /**  
     * 检查指定的消息是否匹配当前的消息类型。
     *
     * @param message 要检查的消息对象。
     * @return 如果消息的类型与当前过滤器的类型相同，则返回 true；否则返回 false。
     */
    protected override func acceptSpecific(message: Message): Bool {
        return message.getType() == messageType
    }

    public override func toString(): String {
        return "MessageTypeFilter: type=${messageType.toString()}" // 返回类名和消息类型的字符串表示  
    }
}
