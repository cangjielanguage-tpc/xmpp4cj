/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

public interface CompleteElementCallback {
    func onCompleteElement(completeElement: String): Unit
}

public interface DeclarationCallback {
    func onDeclaration(declaration: String): Unit
}

public interface XmppElementCallback <: CompleteElementCallback {
    func streamOpened(prefix: String, attributes: Map<String, String>): Unit

    func streamClosed(): Unit
}

public interface ProcessingInstructionCallback {
    func onProcessingInstruction(processingInstruction: String): Unit
}
