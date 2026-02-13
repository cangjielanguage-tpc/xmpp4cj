/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package cangjie_tpc::xmpp4cj.filter

/**
 * 用于过滤具有特定线程值的消息数据包的过滤器。
 */
public class ThreadFilter <: FlexibleStanzaTypeFilter<Message> {
    /** 
     * 要过滤的线程值
     */
    private let thread: ?String

    /**
     * 使用指定的线程值创建一个新的线程过滤器。
     *
     * @param thread 要过滤的线程值。必须非空且非 null。
     */
    public init(thread: String) {
        super(thread)
        StringUtils.requireNotNullNorEmpty(thread, "Thread must not be null nor empty.")
        this.thread = thread
    }

    /**
     * 检查给定消息是否接受该线程过滤器。
     *
     * @param message 要检查的消息
     * @return 如果消息的线程值与过滤器的线程值匹配，则返回 true；否则返回 false。
     */
    protected override func acceptSpecific(message: Message): Bool {
        return thread == message.getThread()
    }

    /**
     * 返回过滤器的字符串表示形式。
     *
     * @return 过滤器的字符串表示，包含类名和线程值。
     */
    public override func toString(): String {
        return if (let Some(v) <- thread) {
            "ThreadFilter: thread=${v}"
        } else {
            "ThreadFilter: thread=None"
        }
    }
}
