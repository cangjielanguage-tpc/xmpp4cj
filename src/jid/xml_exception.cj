/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

/**  
 * 抽象类，表示无效的 XML 异常，继承自 Exception
 */
public abstract class InvalidXmlException <: Exception {
    private let unexpectedChar: Rune // 意外字符 

    private let xml: String // 解析到目前为止的 XML 内容  

    /**  
     * 构造函数
     *
     * @param message        异常消息
     * @param unexpectedChar 意外字符
     * @param xml           解析到目前为止的 XML 内容
     */
    protected init(message: String, unexpectedChar: Rune, xml: String) {
        super(message)
        this.unexpectedChar = unexpectedChar
        this.xml = xml
    }

    /**  
     * 获取意外字符
     *
     * @return 意外字符
     */
    public func getUnexpectedChar(): Rune {
        return unexpectedChar
    }

    /**  
     * 获取解析到目前为止的 XML 内容
     *
     * @return 解析到目前为止的 XML
     */
    public func getParsedXmlSoFar(): String {
        return xml
    }

    /**  
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected open override func getClassName(): String {
        "InvalidXmlException"
    }
}

/**  
 * 表示无效的空标签异常，继承自 InvalidXmlException
 */
public class InvalidEmptyTagException <: InvalidXmlException {
    /**  
     * 构造函数
     *
     * @param message 异常消息
     * @param c      意外字符
     * @param xml    解析到目前为止的 XML 内容
     */
    private init(message: String, c: Rune, xml: String) {
        super(message, c, xml)
    }

    /**  
     * 静态工厂方法，用于创建 InvalidEmptyTagException 的实例
     *
     * @param c   意外字符
     * @param xml 解析到目前为止的 XML 内容
     * @return InvalidEmptyTagException 实例
     */
    public static func create(c: Rune, xml: String): InvalidEmptyTagException {
        let message = "Invalid empty tag, expected '>', but got '${c}'. Parsed xml so far: ${xml}"
        return InvalidEmptyTagException(message, c, xml)
    }

    /**  
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "InvalidEmptyTagException"
    }
}

/**  
 * 表示无效的属性声明异常，继承自 InvalidXmlException
 */
public class InvalidAttributeDeclarationException <: InvalidXmlException {
    /**  
     * 构造函数
     *
     * @param message 异常消息
     * @param c      意外字符
     * @param xml    解析到目前为止的 XML 内容
     */
    private init(message: String, c: Rune, xml: String) {
        super(message, c, xml)
    }

    /**  
     * 静态工厂方法，用于创建 InvalidAttributeDeclarationException 的实例
     *
     * @param c   意外字符
     * @param xml 解析到目前为止的 XML 内容
     * @return InvalidAttributeDeclarationException 实例
     */
    public static func create(c: Rune, xml: String): InvalidAttributeDeclarationException {
        let message = "Invalid attribute declaration, expected ''' or '\"', but got '${c}'. Parsed xml so far: ${xml}"
        return InvalidAttributeDeclarationException(message, c, xml)
    }

    /**  
     * 获得类名，用字符串表示。
     *
     * @return 类名。
     */
    protected override func getClassName(): String {
        "InvalidAttributeDeclarationException"
    }
}
