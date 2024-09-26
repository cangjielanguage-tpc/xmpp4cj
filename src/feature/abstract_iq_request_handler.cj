/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.feature

/**
 * Convenience class to create IQ requests handlers.
 */
public abstract class AbstractIqRequestHandler <: IQRequestHandler {
    private let element: String
    private let namespace: String
    private let Type: IQType
    private let mode: IQRequestHandlerMode

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

    public override func handleIQRequest(iqRequest: IQ): IQ

    public override func getMode(): IQRequestHandlerMode {
        return mode
    }

    public override func getType(): IQType {
        return Type
    }

    public override func getElement(): String {
        return element
    }

    public override func getNamespace(): String {
        return namespace
    }
}
