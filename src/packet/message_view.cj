/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

public interface MessageView <: StanzaView {
    /**
     * 返回消息的类型。如果没有设置类型，此方法将返回 {@link MessageType#normal}。
     *
     * @return 消息的类型。
     */
    func getType(): ?MessageType

    /**
     * 返回消息的默认主题，如果主题未设置则返回 None。主题是消息内容的简短描述。
     * <p>
     * 消息的默认主题是与消息的语言相对应的主题（见 {@link #getLanguage()}），或者如果没有设置语言，则为应用程序的默认语言（见 {@link Stanza#getDefaultLanguage()}）。
     *
     * @return 消息的主题。
     */
    func getSubject(): ?String {
        return getSubject(None)
    }

    /**
     * 返回与给定语言相对应的主题。如果语言为 None，方法结果将与 {@link #getSubject()} 相同。如果语言没有相应的主题，则返回 null。
     *
     * @param language 要返回的主题的语言。
     * @return 与传入语言相关的主题。
     */
    func getSubject(language: ?String): ?String {
        let subject = getMessageSubject(language)
        return subject?.getSubject()
    }

    /**
     * 返回与给定语言相对应的主题。如果语言为 None，方法结果将与 {@link #getSubject()} 相同。如果语言没有相应的主题，则返回 null。
     *
     * @param language 要返回的主题的语言。
     * @return 与传入语言相关的主题。
     */
    func getMessageSubject(language: ?String): ?MessageSubject {
        let lan = Stanza.determineLanguage(this, language)
        for (subject in getSubjects()) {
            if (lan == subject.getLanguage() || (subject.getLanguage().isNone() && getLanguage() == lan)) {
                return subject
            }
        }
        return None
    }

    /**
     * 返回此消息中的所有主题集合，包括可从 {@link #getSubject()} 访问的默认消息主题。
     *
     * @return 此消息中的所有主题集合。
     */
    func getSubjects(): Set<MessageSubject> {
        let subjectList = StanzaView.castExt<MessageSubject>(getExtensionsByType(MessageSubject.getClassId()))
        let subjects: Set<MessageSubject> = HashSet<MessageSubject>(subjectList.size)
        subjects.putAll(subjectList)
        return subjects
    }

    /**
     * 返回所有用于主题的语言，不包括默认主题。
     *
     * @return 用于主题的语言集合。
     */
    func getSubjectLanguages(): Collection<String> {
        let defaultSubject = getMessageSubject(None)
        let languages = ArrayList<String>()
        for (subject in StanzaView.castExt<MessageSubject>(getExtensionsByType(MessageSubject.getClassId()))) {
            if (defaultSubject != subject) {
                languages.append(subject.getLanguage() ?? "null")
            }
        }
        return languages
    }

    /**
     * 返回消息的默认正文，如果正文未设置则返回 None。正文是消息的主要内容。
     * <p>
     * 消息的默认正文是与消息的语言相对应的正文（见 {@link #getLanguage()}），或者如果没有设置语言，则为应用程序的默认语言（见 {@link Stanza#getDefaultLanguage()}）。
     *
     * @return 消息的正文。
     */
    func getBody(): ?String {
        return getBody(getLanguage())
    }

    /**
     * 返回与给定语言相对应的正文。如果语言为 None，方法结果将与 {@link #getBody()} 相同。如果语言没有相应的正文，则返回 null。
     *
     * @param language 要返回的正文的语言。
     * @return 与传入语言相关的正文。
     */
    func getBody(language: ?String): ?String {
        let body = getMessageBody(language)
        return body?.getMessage() ?? None
    }

    /**
     * 返回与给定语言相对应的正文。如果语言为 None，方法结果将与 {@link #getBody()} 相同。如果语言没有相应的正文，则返回 null。
     *
     * @param language 要返回的正文的语言。
     * @return 与传入语言相关的正文。
     */
    func getMessageBody(language: ?String): ?MessageBody {
        var lan: ?String = language
        lan = Stanza.determineLanguage(this, lan)
        for (body in getBodies()) {
            if (lan == body.getLanguage() || (lan.isSome() && lan == getLanguage() && body.getLanguage().isNone())) {
                return body
            }
        }
        return None
    }

    /**
     * 返回此消息中的所有正文集合，包括可从 {@link #getBody()} 访问的默认消息正文。
     *
     * @return 此消息中的所有正文集合。
     */
    func getBodies(): Set<MessageBody> {
        let bodiesList = getExtensions(MessageBody.QNAME)
        let resultSet: Set<MessageBody> = HashSet<MessageBody>(bodiesList.size)
        for (extensionElement in bodiesList) {
            let body = (extensionElement as MessageBody).getOrThrow()
            resultSet.put(body)
        }
        return resultSet
    }

    /**
     * 返回所有用于正文的语言，不包括默认正文。
     *
     * @return 用于正文的语言集合。
     */
    func getBodyLanguages(): ArrayList<?String> {
        let defaultBody = getMessageBody(None)
        let languages = ArrayList<?String>()
        for (body in getBodies()) {
            if (defaultBody != body) {
                languages.append(body.getLanguage())
            }
        }
        return languages // TODO
    }

    /**
     * 返回消息的线程 ID，如果没有设置线程 ID，则返回 None。线程 ID 是一系列“聊天”消息的唯一标识符。
     *
     * @return 消息的线程 ID，或者如果不存在则返回 None。
     */
    func getThread(): ?String {
        let thread = StanzaView.castExt<MessageThread>(getExtensionByType(MessageThread.getClassId()))
        return thread?.getThread() ?? None
    }
}
