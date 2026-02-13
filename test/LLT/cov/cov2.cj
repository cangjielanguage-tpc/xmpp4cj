// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main
import cangjie_tpc::xmpp4cj.packet.*
import std.unittest.testmacro.*
import std.collection.*

@Test
public func jid_1(): Unit {
    // XmppContext.setDefaultXmppStringprep(SimpleXmppStringprep.getInstance())
    // let context = XmppContext.getDefaultContext()

    let obj = JidCreate.froms("localpart1", "domainpart1", "resource1")
    @Assert(obj.isEntityJid())
    obj.asEntityJidOrThrow()
    @Assert(obj.isEntityBareJid(),false)
    obj.asEntityBareJidOrThrow() // 对标库结果一样
    @Assert(obj.isEntityFullJid())
    obj.asEntityFullJidOrThrow()
    obj.asFullJidOrThrow()
    @Assert(obj.isDomainBareJid(),false)
    @Assert(obj.isDomainFullJid(),false)
    @AssertThrows[IllegalStateException](obj.asDomainFullJidOrThrow())
    @Assert(obj.hasResource())
    obj.getResourceOrEmpty()
    obj.hashCode()
    obj.asUrlEncodedString()

    let obj2 = (obj as LocalDomainAndResourcepartJid).getOrThrow()
    obj2.asUnescapedString()
    obj2.asEntityBareJidString()
    obj2.asDomainBareJid()
    obj2.asFullJidIfPossible()
}

@Test
public func jid_2(): Unit {
    let obj = JidCreate.froms("localpart1", "domainpart1", None)
    // println(TypeInfo.of(obj).toString())
    let obj2 = (obj as LocalAndDomainpartJid).getOrThrow()
    obj2.asDomainFullJidIfPossible()
    obj2.asBareJid()
    obj2.hasNoResource()
    obj2.asEntityJidIfPossible()
    obj2.asFullJidIfPossible()
    obj2.asEntityBareJid()
    obj2.getResourceOrNull()
    obj2.asEntityBareJidString()
}

@Test
public func jid_3(): Unit {
    let obj = JidCreate.froms(None, "domainpart1", None)
    // println(TypeInfo.of(obj).toString())
    let obj2 = (obj as DomainpartJid).getOrThrow()
    obj2.asUnescapedString()
    obj2.hasNoResource()
    obj2.asBareJid()
    obj2.asEntityJidIfPossible()
    obj2.asFullJidIfPossible()
    obj2.getResourceOrNull()
    obj2.getLocalpartOrNull()
}

@Test
public func jid_4(): Unit {
    let obj = JidCreate.froms(None, "domainpart1", "resource1")
    // println(TypeInfo.of(obj).toString())
    let obj2 = (obj as DomainAndResourcepartJid).getOrThrow()
    obj2.toString()
    obj2.asDomainBareJid()
    obj2.asBareJid()
    obj2.asUnescapedString()
    obj2.asEntityJidIfPossible()
    obj2.asFullJidIfPossible()
    obj2.getLocalpartOrNull()
}

@Test
public func JidCreate_1(): Unit {
    @AssertThrows[IllegalArgumentException](JidCreate.fromOrThrowUnchecked("@noCachedJidTest.org"))
    @Assert(JidCreate.fromOrNull("@noCachedJidTest.org").isNone())
    @AssertThrows[IllegalArgumentException](JidCreate.fromUnescapedOrThrowUnchecked("@noCachedJidTest.org"))
    @AssertThrows[XmppStringprepException](JidCreate.fromUnescaped("@noCachedJidTest.org/"))
    @Assert(JidCreate.fromUnescapedOrNull("@noCachedJidTest.org").isNone())
    JidCreate.fromUrlEncoded("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](JidCreate.bareFromOrThrowUnchecked(""))
    @Assert(JidCreate.bareFromOrNull("").isNone())
    JidCreate.bareFromUrlEncoded("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](JidCreate.fullFromOrThrowUnchecked(""))
}

let fullJid = JidCreate.fullFrom("juliet@shakespeare.lit/balcony")
let domainBareJid = JidCreate.domainBareFromOrThrowUnchecked("juliet@shakespeare.lit/balcony")

@Test
public func JidCreate_2(): Unit {
    let fullJid = JidCreate.fullFrom("juliet@shakespeare.lit/balcony")
    JidCreate.fullFrom(fullJid.getLocalpartOrThrow(), fullJid.getDomain(), fullJid.getResourceOrThrow())
}

@Test
public func JidCreate_3(): Unit {
    JidCreate.bareFrom("juliet@shakespeare.lit")
    JidCreate.bareFrom(fullJid.getLocalpartOrThrow(), fullJid.getDomain())
}

@Test
public func JidCreate_4(): Unit {
    @AssertThrows[IllegalArgumentException](JidCreate.domainBareFromOrThrowUnchecked(""))
    let domainBareJid = JidCreate.domainBareFromOrThrowUnchecked("juliet@shakespeare.lit/balcony")
}

@Test
public func JidCreate_5(): Unit {
    JidCreate.bareFrom(fullJid.getLocalpartOrThrow(), domainBareJid)
    JidCreate.fullFrom(fullJid.getLocalpartOrThrow(), domainBareJid, fullJid.getResourceOrThrow())
}

@Test
public func JidCreate_6(): Unit {
    @Assert(JidCreate.fullFromOrNull("").isNone())
    JidCreate.fullFromUrlEncoded("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](JidCreate.entityFromOrThrowUnchecked(""))
}

@Test
public func JidCreate_7(): Unit {
    JidCreate.entityFrom("juliet@shakespeare.lit/balcony")
    JidCreate.entityFrom("juliet@shakespeare.lit/balcony", XmppContext.getDefaultContext())
    @AssertThrows[IllegalArgumentException](JidCreate.entityFromUnescapedOrThrowUnchecked(""))
}

@Test
public func JidCreate_8(): Unit {
    @Assert(JidCreate.entityFromUnescapedOrNull("").isNone())
    @Assert(JidCreate.entityFromOrNull("").isNone())
    JidCreate.entityFromUrlEncoded("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](JidCreate.entityBareFromOrThrowUnchecked(""))
    @AssertThrows[IllegalArgumentException](JidCreate.entityBareFromUnescapedOrThrowUnchecked(""))
    // @AssertThrows[XmppStringprepException](JidCreate.entityBareFromUnescapedOrNull(""))
}

@Test
public func JidCreate_9(): Unit {
    JidCreate.entityBareFrom(fullJid.getLocalpartOrThrow(), domainBareJid)
    @Assert(JidCreate.entityBareFromOrNull("").isNone())
    JidCreate.entityBareFromUrlEncoded("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](JidCreate.entityFullFromOrThrowUnchecked(""))
}

@Test
public func JidCreate_10(): Unit {
    @Assert(JidCreate.entityFullFromOrNull("").isNone())
    @AssertThrows[IllegalArgumentException](JidCreate.entityFullFromUnescapedOrThrowUnchecked(""))
    @Assert(JidCreate.entityFullFromUnescapedOrNull("").isNone())
    JidCreate.entityFullFrom(fullJid.getLocalpartOrThrow(), domainBareJid, fullJid.getResourceOrThrow())
    JidCreate.entityFullFromUrlEncoded("juliet@shakespeare.lit/balcony")
}

@Test
public func JidCreate_11(): Unit {
    JidCreate.domainBareFrom(fullJid.getDomain())
    @Assert(JidCreate.domainBareFromOrNull("").isNone())
    JidCreate.domainBareFromUrlEncoded("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](JidCreate.domainFullFromOrThrowUnchecked(""))
    JidCreate.domainFullFrom(fullJid.getDomain(), fullJid.getResourceOrThrow())
    JidCreate.domainFullFrom(domainBareJid, fullJid.getResourceOrThrow())
    @Assert(JidCreate.domainFullFromOrNull("").isNone())
    JidCreate.domainFullFromUrlEncoded("juliet@shakespeare.lit/balcony")
}

@Test
public func XmppContext_5(): Unit {
    XmppContext.setDefaultXmppStringprep(SimpleXmppStringprep.getInstance())
    let context = XmppContext.getDefaultContext()
}

@Test
public func JidUtil_1(): Unit {
    @Assert(JidUtil.isTypicalValidEntityBareJid(""),false)
    @Assert(JidUtil.isTypicalValidEntityBareJid("juliet@shakespeare.lit/balcony"))
    @Assert(JidUtil.isValidEntityBareJid(""),false)
    @Assert(JidUtil.isValidEntityBareJid("juliet@shakespeare.lit/balcony"))
}

@Test
public func JidUtil_2(): Unit {
    let arr: Array<Jid> = [JidCreate.froms(None, "domainpart1", "resource1")]
    JidUtil.filterEntityBareJid(arr, {_ => ()})
    JidUtil.filterEntityBareJidSet(arr)
    JidUtil.filterEntityBareJidList(arr)
    JidUtil.filterEntityFullJid(arr, {_ => ()})
    JidUtil.filterEntityFullJidSet(arr)
    JidUtil.filterEntityFullJidList(arr)
    JidUtil.filterDomainFullJid(arr, {_ => ()})
    JidUtil.filterDomainFullJidSet(arr)
    JidUtil.filterDomainFullJidList(arr)
}

@Test
public func JidUtil_3(): Unit {
    let arr2: Array<String> = ["juliet@shakespeare.lit/balcony"]
    JidUtil.entityBareJidSetFrom(arr2)
    JidUtil.entityBareJidsFrom(arr2, {_ => ()}, None)

    JidUtil.jidSetFrom("juliet@shakespeare.lit/balcony")
    JidUtil.jidSetFrom(arr2)
    JidUtil.jidsFrom(arr2, {_ => ()}, None)
}

@Test
public func JidUtil_4(): Unit {
    let arr: Array<Jid> = [JidCreate.froms(None, "domainpart1", "resource1")]
    JidUtil.toStringList(arr)
    JidUtil.toStringSet(arr)
    JidUtil.toStrings(arr, {_ => ()})
}

@Test
public func Localpart_1(): Unit {
    @AssertThrows[IllegalArgumentException](Localpart.fromOrThrowUnchecked(""))
    @AssertThrows[IllegalArgumentException](Localpart.fromUnescapedOrThrowUnchecked(""))
    @Assert(Localpart.formUnescapedOrNull("").isNone())
    @Assert(Localpart.fromOrNull("").isNone())
}

@Test
public func Resourcepart_1(): Unit {
    @AssertThrows[IllegalArgumentException](Resourcepart.fromOrThrowUnchecked(""))
    @Assert(Resourcepart.fromOrNull("").isNone())
}

@Test
public func Domainpart_1(): Unit {
    @AssertThrows[IllegalArgumentException](Domainpart.fromOrThrowUnchecked(""))
    @Assert(Domainpart.fromOrNull("").isNone())
}

@Test
public func XmlException_1(): Unit {
    let obj = InvalidEmptyTagException.create(r'r', "xmlString")
    @Assert(obj.getUnexpectedChar(),r'r')
    @Assert(obj.getParsedXmlSoFar(),"xmlString")
    let obj2 = InvalidAttributeDeclarationException.create(r'r', "xmlString")
    @Assert(obj2.getUnexpectedChar(),r'r')
    @Assert(obj2.getParsedXmlSoFar(),"xmlString")
}

@Test
public func XmlSplitter_1(): Unit {
    @Assert(XmlSplitterState.START.toString(),"START")
    @Assert(XmlSplitterState.TAG_LEFT_ANGLE_BRACKET.toString(),"TAG_LEFT_ANGLE_BRACKET")
    @Assert(XmlSplitterState.TAG_RIGHT_ANGLE_BRACKET.toString(),"TAG_RIGHT_ANGLE_BRACKET")
    @Assert(XmlSplitterState.END_TAG_SOLIDUS.toString(),"END_TAG_SOLIDUS")
    @Assert(XmlSplitterState.IN_TAG_NAME.toString(),"IN_TAG_NAME")
    @Assert(XmlSplitterState.IN_END_TAG.toString(),"IN_END_TAG")
    @Assert(XmlSplitterState.AFTER_START_NAME.toString(),"AFTER_START_NAME")
    @Assert(XmlSplitterState.IN_EMPTY_TAG.toString(),"IN_EMPTY_TAG")
    @Assert(XmlSplitterState.IN_ATTRIBUTE_NAME.toString(),"IN_ATTRIBUTE_NAME")
    @Assert(XmlSplitterState.AFTER_ATTRIBUTE_EQUALS.toString(),"AFTER_ATTRIBUTE_EQUALS")
    @Assert(XmlSplitterState.IN_ATTRIBUTE_VALUE.toString(),"IN_ATTRIBUTE_VALUE")
    @Assert(XmlSplitterState.AFTER_COMMENT_BANG.toString(),"AFTER_COMMENT_BANG")
    @Assert(XmlSplitterState.AFTER_COMMENT_DASH1.toString(),"AFTER_COMMENT_DASH1")
    @Assert(XmlSplitterState.AFTER_COMMENT_DASH2.toString(),"AFTER_COMMENT_DASH2")
    @Assert(XmlSplitterState.AFTER_COMMENT.toString(),"AFTER_COMMENT")
    @Assert(XmlSplitterState.AFTER_COMMENT_CLOSING_DASH1.toString(),"AFTER_COMMENT_CLOSING_DASH1")
    @Assert(XmlSplitterState.AFTER_COMMENT_CLOSING_DASH2.toString(),"AFTER_COMMENT_CLOSING_DASH2")
    @Assert(XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION.toString(),"IN_PROCESSING_INSTRUCTION_OR_DECLARATION")
    @Assert(XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE.toString(),"IN_PROCESSING_INSTRUCTION_OR_DECLARATION_PSEUDO_ATTRIBUTE_VALUE")
    @Assert(XmlSplitterState.IN_PROCESSING_INSTRUCTION_OR_DECLARATION_QUESTION_MARK.toString(),"IN_PROCESSING_INSTRUCTION_OR_DECLARATION_QUESTION_MARK")
}

@Test
public func XmlSplitter_2(): Unit {
    XmppXmlSplitter(None, None, None)
    XmppXmlSplitter(Option<XmlPrinter>.None)
    XmppXmlSplitter(64, None, None)
}

class callback1 <: PrettyPrintedXmlPartCallback {
    init() {
        super({_ =>})
    }
    public func onPrettyPrintedXmlPart(part: StringBuilder): Unit {}
}

class callback2 <: PrettyPrintedXmlChunkSink {
    init() {
        super {_ =>}
    }
    public func sink(part: StringBuilder): Unit {}
}

class callback3 <: PrettyPrintedXmlChunkWithCurrentPartCallback {
    public func onPrettyPrintedXmlChunk(part: StringBuilder): Unit {}
}

@Test
public func XmlPrinter_2(): Unit {
    XmlPrettyPrinter(callback1())
    XmlPrettyPrinter(callback2())
    XmlPrettyPrinterBuilder().setIndent(4).setChunkCallback(callback3()).setPrettyWriter(callback2())
    @AssertThrows[IllegalArgumentException](XmlPrettyPrinterBuilder().setIndent(-1))
}

@Test
public func _1(): Unit {
}
