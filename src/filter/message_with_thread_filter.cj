/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**  
 * 过滤拥有至少一个线程的消息 Stanza。
 */
public class MessageWithThreadFilter <: FlexibleStanzaTypeFilter<Message> {
    /**
     * 单例实例
     */
    public static let INSTANCE: StanzaFilter = MessageWithThreadFilter()

    /**
     * 构造函数，初始化消息类型过滤器
     */
    private init() {
        super("Message")
    }

    /**  
     * 检查指定的消息是否具有线程信息。
     *
     * @param message 要检查的消息对象。
     * @return 如果消息的线程不为空，则返回 true；否则返回 false。
     */
    protected override func acceptSpecific(message: Message): Bool {
        return StringUtils.isNotEmpty(message.getThread())
    }

    public override func toString(): String {
        return "MessageWithThreadFilter"
    }
}
