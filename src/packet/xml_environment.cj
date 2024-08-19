/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class XmlEnvironment {
    public static let EMPTY: XmlEnvironment = XmlEnvironment(None)

    private var namespace: ?String = None
    private var language: ?String = None

    private var next: ?XmlEnvironment = None

    private var effectiveNamespaceDetermined: Bool = false
    private var effectiveLanguageDetermined: Bool = false

    private var effectiveNamespace: ?String = None
    private var effectiveLanguage: ?String = None
    private var toStringCache: ?String = None

    public init(namespace: ?String) {
        this(namespace, None)
    }

    public init(namespace: ?String, language: ?String) {
        this(namespace, language, None)
    }

    init(builder: XmlEnvironmentBuilder) {
        this(builder.namespace, builder.language, builder.next)
    }

    public init(namespace: ?String, language: ?String, next: ?XmlEnvironment) {
        this.namespace = namespace
        this.language = language
        this.next = next
    }

    public func getNamespace(): ?String {
        return namespace
    }

    public func getEffectiveNamespace(): ?String {
        if (effectiveNamespaceDetermined) {
            return effectiveNamespace
        }
        effectiveNamespace = if (StringUtils.isNotEmpty(namespace)) {
            namespace
        } else {
            next?.getEffectiveNamespace() ?? None
        }
        effectiveNamespaceDetermined = true
        return effectiveNamespace
    }

    public func getEffectiveNamespaceOrUse(namespace: String): ?String {
        var effectiveNamespace: ?String = getEffectiveNamespace()
        if (let Some(v) <- effectiveNamespace) {
            if (v.isEmpty()) {
                return namespace
            }
        } else {
            return namespace
        }
        return effectiveNamespace
    }

    public func effectiveNamespaceEquals(namespace: String): Bool {
        var effectiveNamespace: ?String = getEffectiveNamespace()
        return if (let Some(v) <- effectiveNamespace) {
            v == namespace
        } else {
            false
        }
    }

    public func getLanguage(): ?String {
        return language
    }

    public func getEffectiveLanguage(): ?String {
        if (effectiveLanguageDetermined) {
            return effectiveLanguage
        }
        effectiveLanguage = if (StringUtils.isNotEmpty(language)) {
            language
        } else {
            next?.getEffectiveLanguage() ?? None
        }
        effectiveLanguageDetermined = true
        return effectiveLanguage
    }

    public func effectiveLanguageEquals(language: ?String): Bool {
        let effectiveLanguage: ?String = getEffectiveLanguage()
        return if (let Some(v) <- effectiveLanguage) {
            language == v
        } else {
            false
        }
    }

    public func toString(): String {
        return if (let Some(v) <- toStringCache) {
            v
        } else {
            let str = "XmlEnvironment xmlns=${getEffectiveNamespace()} xmllang=${getEffectiveLanguage()} "
            toStringCache = str
            str
        }
    }

    public static func froms(parser: XmlPullParser): XmlEnvironment {
        return froms(parser, None)
    }

    public static func froms(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): XmlEnvironment {
        var namespace: String = parser.getDefaultNamespace()
        var xmlLang: String = ParserUtils.getXmlLang(parser)
        return XmlEnvironment(namespace, xmlLang, outerXmlEnvironment)
    }

    public static func builder(): XmlEnvironmentBuilder {
        return XmlEnvironmentBuilder()
    }
}

public class XmlEnvironmentBuilder {
    var namespace: ?String = None

    var language: ?String = None

    var next: ?XmlEnvironment = None

    public func withNamespace(namespace: String): XmlEnvironmentBuilder {
        this.namespace = namespace
        return this
    }

    public func withLanguage(language: ?String): XmlEnvironmentBuilder {
        this.language = language
        return this
    }

    public func withNext(next: ?XmlEnvironment): XmlEnvironmentBuilder {
        this.next = next
        return this
    }

    public func withs(streamOpen: StreamOpen): XmlEnvironmentBuilder {
        withNamespace(streamOpen.getNamespace())
        withLanguage(streamOpen.getLanguage())
        return this
    }

    public func build(): XmlEnvironment {
        return XmlEnvironment(this)
    }
}
