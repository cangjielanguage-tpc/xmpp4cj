/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.packet

/**
 * Builder 类用于构建 AbstractError 实例
 *
 * @param <B> Builder 类型的子类
 */
public abstract class AbstractErrorBuilder {
    /**
     * 文本命名空间。
     */
    protected var textNamespace: ?String = None

    /**
     * 描述性文本映射。
     */
    protected var descriptiveTexts: ?Map<String, String> = None

    /**
     * 扩展元素列表。
     */
    protected var extensions: ?ArrayList<ExtensionElement> = None

    /**  
     * 设置描述性文本
     *
     * @param descriptiveTexts 描述性文本映射
     * @return Builder 的子类实例
     */
    public func setDescriptiveTexts(descriptiveTexts: ?Map<String, String>): This {
        if (let Some(v) <- descriptiveTexts) {
            if (let Some(w) <- this.descriptiveTexts) {
                w.putAll(v)
            } else {
                this.descriptiveTexts = v
            }
        } else {
            this.descriptiveTexts = None
        }
        return this
    }

    /**  
     * 设置英语的描述性文本。
     *
     * @param descriptiveEnText 英语描述性文本
     * @return Builder 的子类实例
     */
    public func setDescriptiveEnText(descriptiveEnText: String): This {
        if (descriptiveTexts.isNone()) {
            descriptiveTexts = HashMap<String, String>()
        }
        descriptiveTexts?.put("en", descriptiveEnText)
        return this
    }

    /**  
     * 设置英语的描述性文本，并附加异常堆栈信息。
     *
     * @param descriptiveEnText 英语描述性文本
     * @param exception 附加的异常
     * @return Builder 的子类实例
     */
    public func setDescriptiveEnText(descriptiveEnText: String, exception: Exception): This {
        var sb: StringBuilder = StringBuilder(512)
        sb.append(descriptiveEnText)
        sb.append('\n')
        let stacktrace: String = ExceptionUtil.getStackTrace(exception)
        sb.append(stacktrace)
        return setDescriptiveEnText(sb.toString())
    }

    /**  
     * 设置文本命名空间。
     *
     * @param textNamespace 文本命名空间
     * @return Builder 的子类实例
     */
    public func setTextNamespace(textNamespace: ?String): This {
        this.textNamespace = textNamespace
        return this
    }

    /**  
     * 设置扩展元素列表。
     *
     * @param extensions 扩展元素列表
     * @return Builder 的子类实例
     */
    public func setExtensions(extensions: Collection<ExtensionElement>): This {
        if (let Some(v) <- this.extensions) {
            v.appendAll(extensions)
        } else {
            this.extensions = ArrayList<ExtensionElement>(extensions)
        }
        return this
    }

    /**  
     * 添加扩展元素。
     *
     * @param extensions 扩展元素
     * @return Builder 的子类实例
     */
    public func addExtension(extension: ExtensionElement): This {
        if (extensions.isNone()) {
            extensions = ArrayList<ExtensionElement>()
        }
        extensions?.append(extension)
        return this
    }
}
