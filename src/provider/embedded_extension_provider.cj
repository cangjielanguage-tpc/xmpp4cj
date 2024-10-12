/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.provider

/**
 *
 * This class simplifies parsing of embedded elements by using the
 * <a href="http/en/wikipedia/org/wiki/Template_method_pattern">Template Method Pattern</a>.
 * After extracting the current element attributes and content of any child elements, the template method
 * ({@link #createReturnExtension(String, String, Map, List)} is called.  Subclasses
 * then override this method to create the specific return type.
 *
 * <p>To use this class, you simply register your subclasses as extension providers in the
 * <b>xmpp.properties</b> file.  Then they will be automatically picked up and used to parse
 * any child elements.
 *
 * <pre>
 * For example, given the following message
 *
 * &lt;message from='pubsub.shakespeare.lit' to='francisco@denmark.lit' id='foo&gt;
 *    &lt;event xmlns='http://jabber.org/protocol/pubsub#event&gt;
 *       &lt;items node='princely_musings'&gt;
 *          &lt;item id='asdjkwei3i34234n356'&gt;
 *             &lt;entry xmlns='http://www.w3.org/2005/Atom'&gt;
 *                &lt;title&gt;Soliloquy&lt;/title&gt;
 *                &lt;link rel='alternative' type='text/html'/&gt;
 *                &lt;id&gt;tag:denmark.lit,2003:entry-32397&lt;/id&gt;
 *             &lt;/entry&gt;
 *          &lt;/item&gt;
 *       &lt;/items&gt;
 *    &lt;/event&gt;
 * &lt;/message&gt;
 *
 * I would have a classes
 * <code>ItemsProvider</code> extends {@link EmbeddedExtensionProvider}
 * <code>ItemProvider</code> extends {@link EmbeddedExtensionProvider}
 * and
 * AtomProvider extends {@link ExtensionElementProvider}
 *
 * These classes are then registered in the meta-inf/xmpp.providers file
 * as follows.
 *
 *   &lt;extensionProvider&gt;
 *      &lt;elementName&gt;items&lt;/elementName&gt;
 *      &lt;namespace&gt;http://jabber.org/protocol/pubsub#event&lt;/namespace&gt;
 *      &lt;className&gt;xmpp4cj.provider.ItemsEventProvider&lt;/className&gt;
 *   &lt;/extensionProvider&gt;
 *   &lt;extensionProvider&gt;
 *       &lt;elementName&gt;item&lt;/elementName&gt;
 *       &lt;namespace&gt;http://jabber.org/protocol/pubsub#event&lt;/namespace&gt;
 *       &lt;className&gt;xmpp4cj.provider.ItemProvider&lt;/className&gt;
 *   &lt;/extensionProvider&gt;
 *
 * </pre>
 */
public abstract class EmbeddedExtensionProvider<PE> <: ExtensionElementProvider<PE> where PE <: ExtensionElement {
    /**  
     * 构造函数，初始化 EmbeddedExtensionProvider 实例。
     */
    public init() {
        super()
    }

    /**  
     * 解析 XML pull 解析器中的嵌入式扩展元素。
     *
     * @param parser XmlPullParser 实例，用于解析 XML 数据
     * @param initialDepth 解析时的初始深度，用于跟踪 XML 文档的层次结构
     * @param xmlEnvironment XML 环境设置
     * @return 解析得到的扩展元素 PE
     * @throws XmlPullParserException 解析 XML 时抛出的异常
     * @throws IOException 读写过程中的异常
     * @throws XmppParsingException 特定于 Xmpp 的解析异常
     */
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): PE {
        let namespace = parser.getNamespace()
        let name = parser.getName()
        let attributeCount = parser.getAttributeCount()
        let attMap: Map<String, String> = HashMap<String, String>(Int64(attributeCount))
        var i = 0
        while (i < attributeCount) {
            attMap.put(parser.getAttributeName(i), parser.getAttributeValue(i))
            i++
        }
        let extensions = ArrayList<ExtensionElement>()
        var event: XmlPullParserEvent
        do {
            event = parser.next()
            if (event == XmlPullParserEvent.START_ELEMENT) {
                PacketParserUtils.addExtensionElement(extensions, parser, xmlEnvironment)
            }
        } while (!(event == XmlPullParserEvent.END_ELEMENT && parser.getDepth() == initialDepth))
        return createReturnExtension(name, namespace, attMap, extensions)
    }

    /**  
     * 创建返回的扩展元素。
     * 这个方法应由子类实现，根据解析的内容创建具体的扩展元素实例。
     *
     * @param currentElement 扩展元素的名称
     * @param currentNamespace 扩展元素的命名空间
     * @param attributeMap 扩展元素的属性映射
     * @param content 嵌入式扩展元素列表
     * @return 创建的扩展元素实例
     */
    protected func createReturnExtension(currentElement: String, currentNamespace: String,
        attributeMap: Map<String, String>, content: ArrayList<ExtensionElement>): PE
}

// extend<> EmbeddedExtensionProvider<> <: Equatable<EmbeddedExtensionProvider<PE>> {
//     public operator func == (that: EmbeddedExtensionProvider<PE>): Bool {
//         return refEq(this, that)
//     }
// }
