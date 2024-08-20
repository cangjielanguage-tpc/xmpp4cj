/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public interface MessageView <: StanzaView {
    /**
     * Returns the type of the message.
     * If no type has been set this method will return {@link MessageType#normal}.
     *
     * @return the type of the message.
     */
    func getType(): MessageType

    /**
     * Returns the default subject of the message, or None if the subject has not been set.
     * The subject is a short description of message contents.
     * <p>
     * The default subject of a message is the subject that corresponds to the message's language.
     * (see {@link #getLanguage()}) or if no language is set to the applications default
     * language (see {@link Stanza#getDefaultLanguage()}).
     *
     * @return the subject of the message.
     */
    func getSubject(): ?String {
        return getSubject(None)
    }

    /**
     * Returns the subject corresponding to the language.
     * If the language is None, the method result will be the same as {@link #getSubject()}.
     * Null will be returned if the language does not have a corresponding subject.
     *
     * @param language the language of the subject to return.
     * @return the subject related to the passed in language.
     */
    func getSubject(language: ?String): ?String {
        let subject = getMessageSubject(language)
        return subject?.getSubject()
    }

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
     * Returns a set of all subjects in this Message,
     * including the default message subject accessible from {@link #getSubject()}.
     *
     * @return a collection of all subjects in this message.
     */
    func getSubjects(): Set<MessageSubject> {
        let subjectList = StanzaView.getExt<MessageSubject>(getExtensions(MessageSubject.getClassId()))
        let subjects: Set<MessageSubject> = HashSet<MessageSubject>(subjectList.size)
        subjects.putAll(subjectList)
        return subjects
    }

    /**
     * Returns all the languages being used for the subjects, not including the default subject.
     *
     * @return the languages being used for the subjects.
     */
    func getSubjectLanguages(): Collection<String> {
        let defaultSubject = getMessageSubject(None)
        let languages = ArrayList<String>()
        for (subject in StanzaView.getExt<MessageSubject>(getExtensions(MessageSubject.getClassId()))) {
            if (defaultSubject != subject) {
                languages.append(subject.getLanguage() ?? "None")
            }
        }
        return languages
    }

    /**
     * Returns the default body of the message, or None if the body has not been set. The body
     * is the main message contents.
     * <p>
     * The default body of a message is the body that corresponds to the message's language.
     * (see {@link #getLanguage()}) or if no language is set to the applications default
     * language (see {@link Stanza#getDefaultLanguage()}).
     *
     * @return the body of the message.
     */
    func getBody(): ?String {
        return getBody(getLanguage())
    }

    /**
     * Returns the body corresponding to the language.
     * If the language is None, the method result will be the same as {@link #getBody()}.
     * Null will be returned if the language does not have a corresponding body.
     *
     * @param language the language of the body to return.
     * @return the body related to the passed in language.
     */
    func getBody(language: ?String): ?String {
        let body = getMessageBody(language)
        return body?.getMessage() ?? None
    }

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
     * Returns a set of all bodies in this Message,
     * including the default message body accessible from {@link #getBody()}.
     *
     * @return a collection of all bodies in this Message.
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
     * Returns all the languages being used for the bodies, not including the default body.
     *
     * @return the languages being used for the bodies.
     */
    func getBodyLanguages(): ArrayList<String> {
        let defaultBody = getMessageBody(None)
        let languages = ArrayList<String>()
        for (body in getBodies()) {
            if (defaultBody != body) {
                languages.append(body.getLanguage().toString())
            }
        }
        return languages // TODO
    }

    /**
     * Returns the thread id of the message, which is a unique identifier for a sequence
     * of "chat" messages. If no thread id is set, <code>None</code> will be returned.
     *
     * @return the thread id of the message, or <code>None</code> if it doesn't exist.
     */
    func getThread(): ?String {
        let thread = StanzaView.getExt<MessageThread>(getExtension(MessageThread.getClassId()))
        return thread?.getThread() ?? None
    }
}
