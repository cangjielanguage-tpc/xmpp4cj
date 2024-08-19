/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.packet

public class ToStringUtil {
    public static func builderFor(clazz: ClassId): ToStringUtilBuilder {
        let sb = StringBuilder()
        sb.append(clazz)
        sb.append('(')
        return ToStringUtilBuilder(sb)
    }
}

public class ToStringUtilBuilder {
    private let sb: StringBuilder

    init(sb: StringBuilder) {
        this.sb = sb
    }

    public func addValue(name: String, valueStr: ?ToString): ToStringUtilBuilder {
        let value = if (let Some(v) <- valueStr) {
            v.toString()
        } else {
            return this
        }
        if (sb.toString()[sb.size - 1] != b'(') {
            sb.append(' ')
        }
        sb.append("${name}='${value}'")
        return this
    }

    public func addValue(name: String, valueStr: ?String): ToStringUtilBuilder {
        let value = if (let Some(v) <- valueStr) {
            v.toString()
        } else {
            return this
        }
        if (sb.toString()[sb.size - 1] != b'(') {
            sb.append(' ')
        }
        sb.append("${name}='${value}'")
        return this
    }

    public func add(name: String, values: Iterator<ToString>): ToStringUtilBuilder {
        let str = values |> collectString(delimiter: ", ")

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

    public func build(): String {
        sb.append(')')
        return sb.toString()
    }
}
