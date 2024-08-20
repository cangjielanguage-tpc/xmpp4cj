/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class MessageBuilder <: MessageOrPresenceBuilder & MessageView {
    static let EMPTY = MessageBuilder(RandomStringStanzaIdSource {=> None})

    var typ: MessageType = MessageType.normal

    init(message: Message, stanzaId: ?String) {
        super(message, stanzaId)
        copyFromMessage(message)
    }

    init(message: Message, stanzaIdSource: StanzaIdSource) {
        super(message, stanzaIdSource)
        copyFromMessage(message)
    }

    init(stanzaIdSource: StanzaIdSource) {
        super(stanzaIdSource)
    }

    init(stanzaId: ?String) {
        super(stanzaId)
    }

    private func copyFromMessage(message: Message): Unit {
        typ = message.getType()
    }

    protected override func addStanzaSpecificAttributes(builder: ToStringUtilBuilder): Unit {
        builder.addValue("type", typ)
    }

    public func ofType(typ: MessageType): MessageBuilder {
        this.typ = typ
        return getThis()
    }

    public func setThread(thread: String): MessageBuilder {
        return setThread(thread, None)
    }

    public func setThread(thread: String, parent: ?String): MessageBuilder {
        addExtension(MessageThread(thread, parent))
        return getThis()
    }

    /**
     * Sets the subject of the message.
     * The subject is a short description of message contents.
     *
     * @param subject the subject of the message.
     * @return a reference to this builder.
     */
    public func setSubject(subject: String): MessageBuilder {
        return addSubject(None, subject)
    }

    /**
     * Adds a subject with a corresponding language.
     *
     * @param language the language of the subject being added.
     * @param subject the subject being added to the message.
     * @return a reference to this builder.
     */
    public func addSubject(languageStr: ?String, subject: String): MessageBuilder {
        let language = StringUtils.requireNullOrNotEmpty(languageStr, "language must be None or not empty")
        for (currentSubject in getExtensions(MessageSubject.getClassId())) {
            if (StringUtils.nullSafeCharSequenceEquals(language, currentSubject.getLanguage())) {
                throw IllegalArgumentException("Subject with the language ${language} already exists")
            }
        }
        let messageSubject = MessageSubject(language, subject)
        addExtension(messageSubject)
        return this
    }

    /**
     * Sets the body of the message.
     *
     * @param body the body of the message.
     * @return a reference to this builder.
     * @see #setBody(String)
     */
    public func setBody(body: String): MessageBuilder {
        return addBody(None, body)
    }

    /**
     * Adds a body with a corresponding language.
     *
     * @param language the language of the body being added.
     * @param body the body being added to the message.
     * @return a reference to this builder.
     */
    public func addBody(languageStr: ?String, body: String): MessageBuilder {
        let language = StringUtils.requireNullOrNotEmpty(languageStr, "language must be None or not empty")
        for (currentBody in getExtensions(MessageBody.getClassId())) {
            if (StringUtils.nullSafeCharSequenceEquals(language, currentBody.getLanguage())) {
                throw IllegalArgumentException("Body with the language ${language} already exists")
            }
        }
        let messageBody = MessageBody(language, body)
        addExtension(messageBody)
        return this
    }

    public override func getThis(): MessageBuilder {
        return this
    }

    public override func build(): Message {
        return Message(this)
    }

    public override func getType(): MessageType {
        return typ
    }
}
