/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.jid

/**  
 * 回调接口，用于处理完成元素的回调
 */
public interface CompleteElementCallback {
    /**  
     * 当完成某个元素时调用
     *
     * @param completeElement 完成的元素
     */
    func onCompleteElement(completeElement: String): Unit
}

/**  
 * 回调接口，用于处理声明的回调
 */
public interface DeclarationCallback {
    /**  
     * 当出现声明时调用
     *
     * @param declaration 声明的内容
     */
    func onDeclaration(declaration: String): Unit
}

/**  
 * 回调接口，用于处理 XMPP 元素的回调，继承自 CompleteElementCallback
 */
public interface XmppElementCallback <: CompleteElementCallback {
    /**  
     * 当流打开时调用
     *
     * @param prefix     流的前缀
     * @param attributes 流的属性集合
     */
    func streamOpened(prefix: String, attributes: Map<String, String>): Unit

    /**  
     * 当流关闭时调用
     */
    func streamClosed(): Unit
}

/**  
 * 回调接口，用于处理处理指令的回调
 */
public interface ProcessingInstructionCallback {
    /**  
     * 当出现处理指令时调用
     *
     * @param processingInstruction 处理指令的内容
     */
    func onProcessingInstruction(processingInstruction: String): Unit
}
