/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public open class AbstractError {
    protected let textNamespace: ?String
    protected let descriptiveTexts: Map<String, String>
    protected let extensions: Collection<ExtensionElement>

    protected init(descriptiveTexts: ?Map<String, String>) {
        this(descriptiveTexts, None)
    }

    protected init(descriptiveTexts: ?Map<String, String>, extensions: ?Collection<ExtensionElement>) {
        this(descriptiveTexts, None, extensions)
    }

    protected init(
        descriptiveTexts: ?Map<String, String>,
        textNamespace: ?String,
        extensions: ?Collection<ExtensionElement>
    ) {
        this.descriptiveTexts = descriptiveTexts ?? Collections.EMPTY_STRING_MAP
        this.textNamespace = textNamespace
        this.extensions = extensions ?? Collections.EMPTY_EXTENSION_ELEMENT_COLLECTION
    }

    /**
     * Get the descriptive text of this SASLFailure.
     * <p>
     * Returns the descriptive text of this SASLFailure in the system default language if possible. May return None.
     * </p>
     *
     * @return the descriptive text or None.
     */
    public func getDescriptiveText(): ?String {
        if (descriptiveTexts.size == 0) {
            return None
        }
        // attempt to obtain the text in the user's locale, the English text, or the "" default
        let l: TimeZone = TimeZone.Local
        let tags: Array<String> = [
            l.toString(),
            "en",
            ""
        ]
        for (tag in tags) {
            let descriptiveText: ?String = getDescriptiveText(tag)
            if (let Some(v) <- descriptiveText) {
                return v
            }
        }
        return (descriptiveTexts |> take(1) |> map {kv => kv[1]}).next()
    }

    /**
     * Get the descriptive test of this SASLFailure.
     * <p>
     * Returns the descriptive text of this SASLFailure in the given language. May return None if not available.
     * </p>
     *
     * @param xmllang the language.
     * @return the descriptive text or None.
     */
    public func getDescriptiveText(xmllang: String): ?String {
        return descriptiveTexts.get(xmllang)
    }

    /**
     * Returns the first stanza extension that matches the specified element name and
     * namespace, or <code>None</code> if it doesn't exist.
     *
     * @param elementName the XML element name of the stanza extension.
     * @param namespace the XML element namespace of the stanza extension.
     * @return the extension, or <code>None</code> if it doesn't exist.
     */
    public func getExtension<PE>(elementName: String, namespace: String): ?ExtensionElement where PE <: ExtensionElement {
        return PacketUtil.extensionElementFrom(extensions, elementName, namespace)
    }

    protected func addDescriptiveTextsAndExtensions(xml: XmlStringBuilder) {
        for ((xmllang, text) in descriptiveTexts) {
            xml.halfOpenElement("text").xmlnsAttribute(textNamespace).optXmlLangAttribute(xmllang).rightAngleBracket().
                escape(text).closeElement("text")
        }
        xml.append(extensions |> map<ExtensionElement, Element> {e => e})
    }
}

public abstract class AbstractErrorBuilder<B> where B <: AbstractErrorBuilder<B> {
    protected var textNamespace: ?String = None
    protected var descriptiveTexts: ?Map<String, String> = None
    protected var extensions: ?ArrayList<ExtensionElement> = None

    public func setDescriptiveTexts(descriptiveTexts: ?Map<String, String>): B {
        if (let Some(v) <- descriptiveTexts) {
            if (let Some(w) <- this.descriptiveTexts) {
                w.putAll(v)
            } else {
                this.descriptiveTexts = v
            }
        } else {
            this.descriptiveTexts = None
        }
        return getThis()
    }

    public func setDescriptiveEnText(descriptiveEnText: String): B {
        if (descriptiveTexts.isNone()) {
            descriptiveTexts = HashMap<String, String>()
        }
        descriptiveTexts?.put("en", descriptiveEnText)
        return getThis()
    }

    public func setDescriptiveEnText(descriptiveEnText: String, exception: Exception): B {
        var sb: StringBuilder = StringBuilder(512)
        sb.append(descriptiveEnText)
        sb.append('\n')
        let stacktrace: String = ExceptionUtil.getStackTrace(exception)
        sb.append(stacktrace)
        return setDescriptiveEnText(sb.toString())
    }

    public func setTextNamespace(textNamespace: ?String): B {
        this.textNamespace = textNamespace
        return getThis()
    }

    public func setExtensions(extensions: Collection<ExtensionElement>): B {
        if (let Some(v) <- this.extensions) {
            v.appendAll(extensions)
        } else {
            this.extensions = ArrayList<ExtensionElement>(extensions)
        }
        return getThis()
    }

    public func addExtension(extension: ExtensionElement): B {
        if (extensions.isNone()) {
            extensions = ArrayList<ExtensionElement>()
        }
        extensions?.append(extension)
        return getThis()
    }

    protected func getThis(): B
}
