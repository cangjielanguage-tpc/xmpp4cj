/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.filter

/**
 * XMPP（可扩展消息和存在协议）中的输入输出过滤接口。
 * 此接口提供了处理输出数据和输入数据的方法，同时允许对过滤器行为进行额外控制。
 */
public interface XmppInputOutputFilter {
    /**  
     * 处理和过滤输出数据。
     *
     * @param outputData 要作为ByteBuffer过滤的数据。
     * @param isFinalDataOfElement 指示这是否是正在处理的元素的最终数据。
     * @param destinationAddressChanged 指示目标地址是否已更改。
     * @param moreDataAvailable 表示是否有更多数据可供处理。
     * @return 一个OutputResult，指示过滤后的输出和任何待处理的数据。
     * @throws IOException 如果在输出处理过程中发生错误。
     */
    func output(outputData: ByteArrayStream, isFinalDataOfElement: Bool, destinationAddressChanged: Bool,
        moreDataAvailable: Bool): XmppInputOutputFilterOutputResult

    /**  
     * 处理输入数据并返回修改后的数据。
     *
     * @param inputData 要作为ByteBuffer过滤的输入数据。
     * @return 过滤后的输入数据作为ByteBuffer。
     * @throws IOException 如果在输入处理过程中发生错误。
     */
    func input(inputData: ByteArrayStream): ByteArrayStream

    /**  
     * 关闭输入输出过滤器，释放所有相关资源。
     */
    func closeInputOutput(): Unit {}

    /**  
     * 等待输入输出过滤器关闭。
     *
     * @throws IOException 如果在等待过程中发生错误。
     * @throws 如果没有响应，则抛出NoResponseException。
     * @throws CertificateException如果发生证书错误。
     * @throws InterruptedException如果等待进程被中断。
     * @throws SmackException如果发生与Smack相关的错误。
     * @throws 如果发生与XMPP相关的错误，则抛出XMPPException。
     */
    func waitUntilInputOutputClosed(): Unit {}

    /**  
     * 检索与筛选器相关的统计信息。
     *
     * @return 表示统计信息的对象。
     */
    func getStats(): Object

    /**  
     * 检索筛选器的名称。
     *
     * @return 过滤器的名称为字符串。
     */
    func getFilterName(): String
}

/**  
 * 表示处理输出数据的结果。
 */
public class XmppInputOutputFilterOutputResult {
    /**
     * 表示无输出的常数。
     */
    public static let NO_OUTPUT = XmppInputOutputFilterOutputResult(false, None)

    /**
     * 指示是否有待处理的筛选器数据。
     */
    public let pendingFilterData: Bool

    /**
     * 过滤后的输出数据。
     */
    public let filteredOutputData: ?ByteArrayStream

    /**  
     * 使用指定的筛选数据构造OutputResult。
     *
     * @param filteredOutputData 过滤后的输出数据为ByteBuffer。
     */
    public init(filteredOutputData: ByteArrayStream) {
        this(false, filteredOutputData)
    }

    /**  
     * 构造一个具有指定挂起状态和筛选数据的OutputResult。
     *
     * @param pendingFilterData 指示是否存在待处理的筛选器数据。
     * @param filteredOutputData 过滤后的输出数据为ByteBuffer。
     */
    public init(pendingFilterData: Bool, filteredOutputData: ?ByteArrayStream) {
        this.pendingFilterData = pendingFilterData
        this.filteredOutputData = filteredOutputData
    }
}
