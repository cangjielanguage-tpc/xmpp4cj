/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

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
