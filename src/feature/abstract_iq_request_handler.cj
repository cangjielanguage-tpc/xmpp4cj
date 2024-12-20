/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.feature

/**
 * public abstract class AbstractIqRequestHandler <: IQRequestHandler
 *
 * 抽象类，用于创建 IQ 请求处理器的便利类。
 * <p>
 * 该类用于处理 XMPP 中的 IQ 请求。只允许处理类型为“get”和“set”的请求。
 * </p>
 */
public abstract class AbstractIqRequestHandler <: IQRequestHandler {
    private let element: String // IQ 请求的元素名称  

    private let namespace: String // IQ 请求的命名空间  

    private let Type: IQType // IQ 请求的类型（get 或 set）  

    private let mode: IQRequestHandlerMode // IQ 请求的模式 

    /**
     * 构造函数，初始化 IQ 请求处理器的基本参数。
     *
     * @param element   IQ 请求的元素名称
     * @param namespace IQ 请求的命名空间
     * @param type      IQ 请求的类型，只允许 get 或 set
     * @param mode      IQ 请求的模式
     * @throws IllegalArgumentException 如果类型不是 get 或 set
     */
    protected init(element: String, namespace: String, Type: IQType, mode: IQRequestHandlerMode) {
        match (Type) {
            case IQType.set | IQType.get => ()
            case _ => throw IllegalArgumentException("Only get and set IQ type allowed")
        }
        this.element = element
        this.namespace = namespace
        this.Type = Type
        this.mode = mode
    }

    /**
     * 处理 IQ 请求的抽象方法。
     *
     * @param iqRequest 要处理的 IQ 请求
     * @return 处理后的 IQ 响应
     */
    public override func handleIQRequest(iqRequest: IQ): ?IQ

    /**
     * 获取请求的模式。
     *
     * @return IQ 请求的模式
     */
    public override func getMode(): IQRequestHandlerMode {
        return mode
    }

    /**
     * 获取请求的类型。
     *
     * @return IQ 请求的类型
     */
    public override func getType(): IQType {
        return Type
    }

    /**
     * 获取请求的元素名称。
     *
     * @return IQ 请求的元素名称
     */
    public override func getElement(): String {
        return element
    }

    /**
     * 获取请求的命名空间。
     *
     * @return IQ 请求的命名空间
     */
    public override func getNamespace(): String {
        return namespace
    }
}
