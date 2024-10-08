/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

/**
 * 表示 XML 环境的类，用于存储命名空间和语言信息。
 * <p>
 * 此类支持链式结构，可以通过 `next` 引用来表示更高层次的 XML 环境。
 * </p>
 */
public class XmlEnvironment {
    /**
     * 空的 XML 环境实例
     */
    public static let EMPTY: XmlEnvironment = XmlEnvironment(None)

    private var namespace: ?String = None // 命名空间

    private var language: ?String = None // 语言

    private var next: ?XmlEnvironment = None // 下一个 XML 环境

    private var effectiveNamespaceDetermined: Bool = false // 标记有效命名空间是否已确定

    private var effectiveLanguageDetermined: Bool = false // 标记有效语言是否已确定

    private var effectiveNamespace: ?String = None // 有效命名空间

    private var effectiveLanguage: ?String = None // 有效语言

    private var toStringCache: ?String = None // 字符串缓存

    /**
     * 构造一个 XML 环境，只有命名空间。
     *
     * @param namespace 命名空间
     */
    public init(namespace: ?String) {
        this(namespace, None)
    }

    /**
     * 构造一个 XML 环境，包含命名空间和语言。
     *
     * @param namespace 命名空间
     * @param language  语言
     */
    public init(namespace: ?String, language: ?String) {
        this(namespace, language, None)
    }

    /**
     * 使用构建器构造 XML 环境。
     *
     * @param builder 构建器
     */
    init(builder: XmlEnvironmentBuilder) {
        this(builder.namespace, builder.language, builder.next)
    }

    /**
     * 构造一个 XML 环境，包含命名空间、语言和下一个环境。
     *
     * @param namespace 命名空间
     * @param language  语言
     * @param next     下一个 XML 环境
     */
    public init(namespace: ?String, language: ?String, next: ?XmlEnvironment) {
        this.namespace = namespace
        this.language = language
        this.next = next
    }

    /**
     * 获取命名空间。
     *
     * @return 命名空间
     */
    public func getNamespace(): ?String {
        return namespace
    }

    /**
     * 获取有效的命名空间。如果当前命名空间为空，则递归查找下一个环境的命名空间。
     *
     * @return 有效的命名空间
     */
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

    /**
     * 获取有效命名空间，如果有效命名空间为空则使用提供的默认命名空间。
     *
     * @param namespace 默认命名空间
     * @return 有效命名空间
     */
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

    /**
     * 检查有效命名空间是否与提供的命名空间相等。
     *
     * @param namespace 要比较的命名空间
     * @return 如果有效命名空间相等则返回 true，否则返回 false
     */
    public func effectiveNamespaceEquals(namespace: String): Bool {
        var effectiveNamespace: ?String = getEffectiveNamespace()
        return if (let Some(v) <- effectiveNamespace) {
            v == namespace
        } else {
            false
        }
    }

    /**
     * 获取语言。
     *
     * @return 语言
     */
    public func getLanguage(): ?String {
        return language
    }

    /**
     * 如果当前语言为空，则递归查找下一个环境的语言。
     *
     * @return 有效的语言
     */
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

    /**
     * 检查有效语言是否与提供的语言相等。
     *
     * @param language 要比较的语言
     * @return 如果有效语言相等则返回 true，否则返回 false
     */
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

    /**
     * 从 XML 解析器创建 XML 环境。
     *
     * @param parser XML 解析器
     * @return XML 环境
     */
    public static func froms(parser: XmlPullParser): XmlEnvironment {
        return froms(parser, None)
    }

    /**
     * 从 XML 解析器创建 XML 环境，支持外部 XML 环境。
     *     * @param parser              XML 解析器
     * @param outerXmlEnvironment 外部 XML 环境
     * @return XML 环境
     */
    public static func froms(parser: XmlPullParser, outerXmlEnvironment: ?XmlEnvironment): XmlEnvironment {
        var namespace = parser.getDefaultNamespace()
        var xmlLang = ParserUtils.getXmlLang(parser)
        return XmlEnvironment(namespace, xmlLang, outerXmlEnvironment)
    }

    /**
     * 创建 XML 环境的构建器。
     *
     * @return XML 环境的构建器
     */
    public static func builder(): XmlEnvironmentBuilder {
        return XmlEnvironmentBuilder()
    }
}
/**
 * XML 环境的构建器类。
 */
public class XmlEnvironmentBuilder {
    var namespace: ?String = None // 命名空间

    var language: ?String = None // 语言

    var next: ?XmlEnvironment = None // 下一个 XML 环境

    /**
     * 设置命名空间。
     *
     * @param namespace 命名空间
     * @return 当前构建器
     */
    public func withNamespace(namespace: String): XmlEnvironmentBuilder {
        this.namespace = namespace
        return this
    }

    /**
     * 设置语言。
     *
     * @param language 语言
     * @return 当前构建器
     */
    public func withLanguage(language: ?String): XmlEnvironmentBuilder {
        this.language = language
        return this
    }

    /**
     * 设置下一个 XML 环境。
     *
     * @param next 下一个 XML 环境
     * @return 当前构建器
     */
    public func withNext(next: ?XmlEnvironment): XmlEnvironmentBuilder {
        this.next = next
        return this
    }

    /**
     * 从 StreamOpen 对象设置命名空间和语言。
     *
     * @param streamOpen StreamOpen 对象
     * @return 当前构建器
     */
    public func withs(streamOpen: StreamOpen): XmlEnvironmentBuilder {
        withNamespace(streamOpen.getNamespace())
        withLanguage(streamOpen.getLanguage())
        return this
    }

    /**
     * 构建 XML 环境实例。
     *
     * @return XML 环境实例
     */
    public func build(): XmlEnvironment {
        return XmlEnvironment(this)
    }
}
