/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

public class MessageThreadElementProvider <: ExtensionElementProvider<MessageThread> {
    public init() {
        super()
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): MessageThread {
        let parent = parser.getAttributeValue(MessageThread.PARENT_ATTRIBUTE_NAME)
        let thread = parser.nextText()
        return MessageThread(thread, parent)
    }
}
