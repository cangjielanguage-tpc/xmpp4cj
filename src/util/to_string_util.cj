/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.util

/**
 * ToString工具类
 */
public class ToStringUtil {
    /**
     * 将ClassId对象处理成String。
     *
     * @param clazz ClassId对象。
     * @return ToStringUtilBuilder对象。
     */
    public static func builderFor(clazz: ClassId): ToStringUtilBuilder {
        let sb = StringBuilder()
        sb.append(clazz)
        sb.append('(')
        return ToStringUtilBuilder(sb)
    }
}

/**
 * ToString工具类
 */
public class ToStringUtilBuilder {
    private let sb: StringBuilder

    /**
     * 初始化。
     *
     * @param sb StringBuilder。
     */
    init(sb: StringBuilder) {
        this.sb = sb
    }

    /**
     * 添加Value name=value。
     *
     * @param name 名称。
     * @param valueStr 值。
     * @return 当前对象。
     */
    public func addValue<S>(name: String, valueStr: ?S): ToStringUtilBuilder where S <: ToString {
        let value = valueStr?.toString() ?? return this
        if (sb.toString()[sb.size - 1] != b'(') {
            sb.append(' ')
        }
        sb.append("${name}='${value}'")
        return this
    }

    /**
     * 添加Value name[value]。
     *
     * @param name 名称。
     * @param valueStr 值。
     * @return 当前对象。
     */
    public func add<S>(name: String, values: Iterable<S>): ToStringUtilBuilder where S <: ToString {
        let str = values |> map<S, ToString> {s => s} |> collectString(delimiter: ", ")

        if (str.size == 0) {
            return this
        }
        sb.append(' ')
        sb.append(name)
        sb.append('[')
        sb.append(str)
        sb.append(']')
        return this
    }

    /**
     * 打印toString。
     *
     * @return 打印文本。
     */
    public func build(): String {
        sb.append(')')
        return sb.toString()
    }
}

/**
 * public type CharSequence = ToString
 *
 * ToString别名CharSequence
 */
public type CharSequence = ToString
