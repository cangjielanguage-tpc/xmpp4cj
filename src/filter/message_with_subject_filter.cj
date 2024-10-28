/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.filter

/**  
 * 过滤拥有至少一个主题的消息 Stanza。
 */
public class MessageWithSubjectFilter <: FlexibleStanzaTypeFilter<Message> {
    /**
     * 单例实例
     */
    public static let INSTANCE: StanzaFilter = MessageWithSubjectFilter()

    /**
     * 构造函数，初始化消息类型过滤器
     */
    private init() {
        super("Message")
    }

    /**  
     * 检查指定的消息是否具有主题信息。
     *
     * @param message 要检查的消息对象。
     * @return 如果消息的主题不为 null，则返回 true；否则返回 false。
     */
    protected override func acceptSpecific(message: Message): Bool {
        // 仅接受已设置主题的消息
        return message.getSubject().isSome()
    }

    public override func toString(): String {
        return "MessageWithSubjectFilter"
    }
}
