/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

/**  
 * 允许实现类调试 XML 传输的接口，即显示 XML 传输的 GUI 窗口。<p>
 * 每个该接口的实现 <b>必须</b> 有一个公共构造函数，接受以下参数：XMPPConnection、Writer、Reader。
 */
public abstract class XmppDebugger {
    /**  
     *  XMPP 连接。
     */
    public let connection: XMPPConnection

    private var outgoingStreamSplitterForPrettyPrinting: ?XmppXmlSplitter = None

    private var incomingStreamSplitterForPrettyPrinting: ?XmppXmlSplitter = None

    /**
     * 通过XMPPConnection初始化XmppDebugger
     *
     * @param connection XMPPConnection
     */
    protected init(connection: XMPPConnection) {
        this.connection = connection
    }

    /**  
     * 当用户登录到服务器时调用。用户可以是匿名用户，即用户的形式为 host/resource，而不是 user@host/resource。
     *
     * @param user 登录的用户 @ host/resource
     */
    public func userHasLogged(user: EntityFullJid): Unit

    /**  
     * 注意字符序列可能会被格式化为可读的形式。
     *
     * @param outgoingCharSequence 出站字符序列
     */
    public func outgoingStreamSink(outgoingCharSequence: ToString): Unit

    /**  
     * 可以在此处理出站元素完成后的逻辑。
     */
    public open func onOutgoingElementCompleted(): Unit {}

    /**  
     * 处理入站字符序列。
     *
     * @param incomingCharSequence 入站字符序列
     */
    public func incomingStreamSink(incomingCharSequence: ToString): Unit

    /**  
     * 可以在此处理入站元素完成后的逻辑。
     */
    public open func onIncomingElementCompleted(): Unit {}

    /**  
     * 返回一个新的特殊 Reader，包装新的连接 Reader。连接已被安全化，因此连接正在使用新的读取器和写入器。
     * 调试器需要包装新的读取器和写入器，以便继续接收连接流量的通知。
     *
     * @param reader 连接的读取器
     * @return 包装新的连接读取器的特殊 Reader
     */
    public func newConnectionReader(reader: ObservableReader): ObservableReader {
        let xmlPrettyPrinter = XmlPrettyPrinter.builder().setPrettyWriter(
            PrettyPrintedXmlChunkSink {sb => incomingStreamSink(sb)}).build()
        incomingStreamSplitterForPrettyPrinting = XmppXmlSplitter(xmlPrettyPrinter)

        let observableReader = ObservableReader(reader)
        observableReader.addReaderListener(
            ReaderListener {
            readString => try {
                incomingStreamSplitterForPrettyPrinting?.write(readString.toString().toRuneArray())
            } catch (e: IOException) {
                throw AssertionError(e)
            }
        })

        return observableReader
    }

    /**  
     * 返回一个新的特殊 Writer，包装新的连接 Writer。连接已被安全化，因此连接正在使用新的读取器和写入器。
     * 调试器需要包装新的读取器和写入器，以便继续接收连接流量的通知。
     *
     * @param writer 连接的写入器
     * @return 包装新的连接写入器的特殊 Writer
     */
    public func newConnectionWriter(writer: ObservableWriter): ObservableWriter {
        let xmlPrettyPrinter = XmlPrettyPrinter.builder().setPrettyWriter(
            PrettyPrintedXmlChunkSink {sb => outgoingStreamSink(sb)}).build()
        outgoingStreamSplitterForPrettyPrinting = XmppXmlSplitter(xmlPrettyPrinter)

        let observableWriter = ObservableWriter(writer)
        observableWriter.addWriterListener(
            WriterListener {
            writtenString => try {
                outgoingStreamSplitterForPrettyPrinting?.write(writtenString.toString().toRuneArray())
            } catch (e: IOException) {
                throw AssertionError(e)
            }
        })
        return observableWriter
    }

    /**  
     * 由连接用于通知关于传入的顶层流元素。
     * <p>
     * 此方法在解析入站流后立即调用。
     * </p>
     *
     * @param streamElement 传入的顶层流元素
     */
    public func onIncomingStreamElement(streamElement: TopLevelStreamElement): Unit

    /**  
     * 由连接用于通知关于传出的顶层流元素。
     * <p>
     * 此方法在元素被序列化为 XML 并放入出站流之前调用。
     * </p>
     *
     * @param streamElement 传出的顶层流元素
     */
    public func onOutgoingStreamElement(streamElement: TopLevelStreamElement): Unit
}
