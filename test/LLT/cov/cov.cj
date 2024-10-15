// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main
import xmpp4cj.packet.*
import std.unittest.testmacro.*
import std.collection.*

class AbstractErrorSub <: AbstractError {
    init(map: ?Map<String, String>) {
        super(map)
    }
}

@Test
public func t0(): Unit {
    let obj = AbstractErrorSub(None)
    @Assert(None,obj.getDescriptiveText())
    let obj1 = AbstractErrorSub(HashMap<String, String>([("k", "v")]))
    @Assert("v",obj1.getDescriptiveText())
}

@Test
public func builder1(): Unit {
    let obj = StanzaError.getBuilder()
    obj.setDescriptiveTexts(HashMap<String, String>([("k", "v")]))
    obj.setDescriptiveTexts(None)
    obj.setDescriptiveTexts(HashMap<String, String>([("k1", "v1")]))
    obj.setDescriptiveEnText("enstr")
    obj.setDescriptiveEnText("enstr1", Exception("ex"))
    obj.addExtension(CompressFeature(["f1"]))
    obj.setExtensions([])
    obj.addExtension(CompressFeature(["f2"]))
}

class AbstractErrorBuilderSub <: AbstractErrorBuilder<AbstractErrorBuilderSub> {
    public override func getThis(): AbstractErrorBuilderSub {
        this
    }
}

@Test
public func builder2(): Unit {
    let obj: AbstractErrorBuilder<AbstractErrorBuilderSub> = AbstractErrorBuilderSub()
    obj.setDescriptiveTexts(HashMap<String, String>([("k", "v")]))
    obj.setDescriptiveTexts(None)
    obj.setDescriptiveTexts(HashMap<String, String>([("k1", "v1")]))
    obj.setDescriptiveEnText("enstr")
    obj.setDescriptiveEnText("enstr1", Exception("ex"))
    obj.addExtension(CompressFeature(["f1"]))
    obj.setExtensions([])
    obj.addExtension(CompressFeature(["f2"]))
}
// class  AbstractIqBuilderSub<: AbstractIqBuilder{
//     public init(other: IQ, stanzaId: String){
//         super(other,stanzaId)
//     }
//     public override func getThis(): AbstractIqBuilderSub {
//         this
//     }
//     public override func build(): IQ {
//         return IQ()
//     }
// }
@Test
public func AbstractIqBuilder1(): Unit {
    // let obj:AbstractIqBuilder
    // obj.addS
}

@Test
public func Bind1(): Unit {
    let FULL_JID_1_RESOURCE_1: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceOne")
    let obj: Bind = Bind.newResult(FULL_JID_1_RESOURCE_1)
    @Assert(obj.getResource().isNone())
    @Assert(obj.getJid()==FULL_JID_1_RESOURCE_1)
}

@Test
public func Bind2(): Unit {
    let FULL_JID_1_RESOURCE_1: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceOne")
    let obj1: Bind = Bind.newSet(FULL_JID_1_RESOURCE_1.getResourcepart())
    @Assert(obj1.getResource()?.toString(),"resourceOne")
    @Assert(obj1.getJid().isNone())
}

@Test
public func BindFeature1(): Unit {
    let obj = BindFeature.INSTANCE
    @Assert(obj.getElementName(),Bind.ELEMENT)
    @Assert(obj.getNamespace(),Bind.NAMESPACE)
    @Assert(obj.toXML().toString(),"<${Bind.ELEMENT} xmlns='${Bind.NAMESPACE}'/>")
}

@Test
public func Compress1(): Unit {
    let obj = Compress("method1")
    @Assert(obj.getElementName(),Compress.ELEMENT)
    @Assert(obj.getNamespace(),Compress.NAMESPACE)
    @Assert(obj.toXML(None).toString(),"<compress xmlns='http://jabber.org/protocol/compress'><method>method1</method></compress>")
}

@Test
public func CompressFeature1(): Unit {
    let obj = CompressFeature(["ns1"])
    @Assert(obj.getElementName(),CompressFeature.ELEMENT)
    @Assert(obj.getNamespace(),Compress.NAMESPACE)
    @Assert(obj.toXML(None).toString(),"<compression xmlns='http://jabber.org/protocol/compress'><method>ns1</method></compression>")
}

@Test
public func CompressFeature2(): Unit {
    let obj1 = CompressFeature(["f1", "f2"])
    @Assert(obj1.toXML(None).toString(),"<compression xmlns='http://jabber.org/protocol/compress'><method>f1</method><method>f2</method></compression>")
}

@Test
public func FullyQualifiedElement1(): Unit {
    let obj = CompressFeature(["ns1"])
    @Assert(obj.getQName(),QName(Compress.NAMESPACE,CompressFeature.ELEMENT))
    println(obj.toXML(""))
}

class ElementSub <: Element {
    public func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        "ElementSub"
    }
}

@Test
public func Element1(): Unit {
    let obj = ElementSub()
    @Assert(obj.toXML("").toString(),"ElementSub")
}

@Test
public func StanzaErrorTextElement1(): Unit {
    let obj = StanzaErrorTextElement("text1", "lang1")
    @Assert(obj.getNamespace(),StanzaErrorTextElement.NAMESPACE)
    @Assert(obj.getElementName(),AbstractTextElement.ELEMENT)
    @Assert(obj.getText(),"text1")
    @Assert(obj.getLanguage(),"lang1")
    @Assert(obj.toXML(None).toString(),"<text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' xml:lang='lang1'>text1</text>")
}

@Test
public func EmptyResultIQ1(): Unit {
    let obj = EmptyResultIQ()
    @Assert(obj.getChildElementXML().toString(),"")
}

enum enum1 {
    A | B
}

@Test
public func EqualsUtil1(): Unit {
    let qname1 = QName("ns1", "localPart1")
    let qname2 = QName("ns1", "localPart2")
    let res = EqualsUtil.equals(qname1, qname2) {
        builder, other => builder.append(qname1.getNamespaceURI(), other.getNamespaceURI()).append(
            qname1.getLocalPart(), other.getLocalPart())
    }
    @Assert(res,false)
}

@Test
public func EqualsUtil2(): Unit {
    let builder = EqualsBuilder()
    builder.append("left: Option<String>", "right: Option<String>")

    @Assert(EqualsUtil.equals(Object(),Object()),false)
    @Assert(EqualsUtil.equals("Object()","Object()"),true)
    @AssertThrows[UnsupportedException](EqualsUtil.equals(enum1.A,enum1.A))
}

@Test
public func ErrorIQ1(): Unit {
    let stanzaErrorBuilder = StanzaError.getBuilder()
    let stanzaError = stanzaErrorBuilder.setCondition(StanzaErrorCondition.gone).build()
    let obj = ErrorIQ.builder(stanzaError).to("to: String").to(None).froms(None).froms("None").setLanguage("lan1").
        addExtension(CompressFeature(["f1"])).addExtensions([CompressFeature(["f2"])]).addOptExtensions(None).
        overrideExtension(CompressFeature(["f4"])).removeExtension("ele-name", "namespace").removeExtension(
        CompressFeature(["f5"])).build()
    @AssertThrows[IllegalArgumentException](ErrorIQ.builder(stanzaError,StanzaBuilder.buildIqData("stanzaId")))
}

@Test
public func ExceptionUtil1(): Unit {
    let ex = Exception()
    let str = ExceptionUtil.getStackTrace(ex)
    @Assert(str.startsWith(ex.toString()+"\n"))
}

@Test
public func Failure1(): Unit {
    let obj = Failure(FailureCompressFailureError.unsupported_method)
    // let str = ExceptionUtil.getStackTrace(ex)
    @Assert(obj.getFailureCompressFailureError().toString(),"unsupported-method")
    @Assert(obj.getStanzaError().isNone())
}

@Test
public func FormField1(): Unit {
    @Assert(FormFieldType.fromString("boolean"),FormFieldType.boolean)
    @Assert(FormFieldType.fromString("fixed"),FormFieldType.fixed)
    @Assert(FormFieldType.fromString("hidden"),FormFieldType.hidden)
    @Assert(FormFieldType.fromString("jid-multi"),FormFieldType.jid_multi)
    @Assert(FormFieldType.fromString("jid-single"),FormFieldType.jid_single)
    @Assert(FormFieldType.fromString("list-multi"),FormFieldType.list_multi)
    @Assert(FormFieldType.fromString("list-single"),FormFieldType.list_single)
    @Assert(FormFieldType.fromString("text-multi"),FormFieldType.text_multi)
    @Assert(FormFieldType.fromString("text-private"),FormFieldType.text_private)
    @Assert(FormFieldType.fromString("text-single"),FormFieldType.text_single)
    @Assert((FormFieldType.fromString("")??FormFieldType.boolean)!=FormFieldType.text_single)
}

@Test
public func HashCode1(): Unit {
    let hash = HashCode.builder().append([""].iterator()).append(true).append(8u8).append(r'r').append(64.0f64).append(
        64i64).build()
    println(hash)
    @Assert(hash!=0)
}

@Test
public func IQ1(): Unit {
    let iq: IQ = UnparsedIQ("element1", "ns1", "content1")
    iq.setType(IQType.error)
    @Assert(iq.isResponseIQ())
    @AssertThrows[IllegalArgumentException](IQ.createErrorResponse(iq, StanzaErrorCondition.forbidden))
    // println(obj.getChildElementXML().toString())
}

@Test
public func IQType1(): Unit {
    @Assert(IQType.fromString("get"),IQType.get)
    @Assert(IQType.fromString("set").toString(),IQType.set.toString())
    @Assert(IQType.fromString("result"),IQType.result)
    @Assert(IQType.fromString("error"),IQType.error)
    @AssertThrows[IllegalArgumentException](IQType.fromString("get-"))
}

@Test
public func IQResponseType1(): Unit {
    @Assert(IQResponseType.result.toString(),"result")
    @Assert(IQResponseType.error.toString(),"error")
    @Assert(IQResponseType.result,IQResponseType.result)
    @Assert(IQResponseType.error,IQResponseType.error)
    @Assert(IQResponseType.result!=IQResponseType.error)
}

@Test
public func IQ2(): Unit {
    let obj1 = IQChildElementXmlStringBuilder(MessageBody("lan1", "msg1"), None)
}

class IqBuilderSub1 <: IqBuilder {
    let iq: IQ = EmptyResultIQ()
    init() {
        super(iq, "stanzaId1")
    }
    init(stanzaId: String) {
        super(stanzaId)
    }
    public func build(): IQ {
        iq
    }
    public func getThis(): IqBuilderSub1 {
        this
    }
}

@Test
public func IqBuilder1(): Unit {
    let obj = IqBuilderSub1()
    obj.ofType(IQType.set) // except useless
    @Assert(obj.build().isRequestIQ(),false)

    let obj2 = IqBuilderSub1("stanzaId2")
    @Assert(obj2.build().isResponseIQ())
}

@Test
public func IqData1(): Unit {
    let obj = StanzaBuilder.buildIqData(None).to("to: String").to(None).froms(None).froms("None").setLanguage("lan1").
        addExtension(CompressFeature(["f1"])).addExtensions([CompressFeature(["f2"])]).addOptExtensions(None).
        overrideExtension(CompressFeature(["f4"])).removeExtension("ele-name", "namespace").removeExtension(
        CompressFeature(["f5"]))
    let stanzaErrorBuilder = StanzaError.getBuilder()
    let stanzaError = stanzaErrorBuilder.setCondition(StanzaErrorCondition.gone).build()
    let obj2 = StanzaBuilder.buildIqData("stanzaId")
    obj2.setError(stanzaError)
    @Assert(obj!=obj2)
    @AssertThrows[UnsupportedException](obj2.build())
}

@Test
public func LazyStringBuilder1(): Unit {
    let obj = LazyStringBuilder()
    obj.append("left: String")
    @Assert(obj.size,12)
    @Assert(obj.getAsList().size,1)
}

@Test
public func Mechanisms1(): Unit {
    let obj = Mechanisms("mechanisms1")
    @Assert(obj.getElementName(),Mechanisms.ELEMENT)
    @Assert(obj.getNamespace(),Mechanisms.NAMESPACE)
}

@Test
public func Mechanisms2(): Unit {
    let obj1 = Mechanisms(["mechanisms1", "mechanisms2"].iterator())
    @Assert(obj1.getMechanisms().size,2)
    let str = "<mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><mechanism>mechanisms1</mechanism><mechanism>mechanisms2</mechanism></mechanisms>"
    @Assert(obj1.toXML(None).toString(),str)
}

@Test
public func MessageType1(): Unit {
    @Assert(MessageType.fromString("normal"),MessageType.normal)
    @Assert(MessageType.fromString("chat")!=MessageType.chat, false)
    @Assert(MessageType.fromString("groupchat"),MessageType.groupchat)
    @Assert(MessageType.fromString("headline"),MessageType.headline)
    @Assert(MessageType.fromString("error"),MessageType.error)
}

@Test
public func MessageType2(): Unit {
    @AssertThrows[IllegalArgumentException](MessageType.fromString(""))
    @Assert(MessageType.fromString("normal").toString(),"normal")
    @Assert(MessageType.fromString("groupchat").toString(),"groupchat")
    @Assert(MessageType.fromString("error").toString(),"error")
}

@Test
public func MessageSubject1(): Unit {
    @Assert(MessageSubject("",""),MessageSubject("",""))
    @Assert(MessageSubject("","")!=MessageSubject(None,""))
}

@Test
public func MessageBody1(): Unit {
    @Assert(MessageBody("",""),MessageBody("",""))
    @Assert(MessageBody("","")!=MessageBody(None,""))
}

@Test
public func MessageThread1(): Unit {
    @Assert(MessageThread("1").getParent().isNone())
}

@Test
public func MessageBuilder_1(): Unit {
    // StanzaBuilder.buildMessageFrom("message: Message", "stanzaId: Option<String>")
    let stanzaErrorBuilder = StanzaError.getBuilder()
    let stanzaError = stanzaErrorBuilder.setCondition(StanzaErrorCondition.gone).build()
    StanzaBuilder.buildMessage()
    let obj = StanzaBuilder.buildMessage(None).to("to: String").to(None).froms(None).froms("None").setLanguage("lan1").
        addExtension(CompressFeature(["f1"])).addExtensions([CompressFeature(["f2"])]).addOptExtensions(None).
        overrideExtension(CompressFeature(["f4"])).removeExtension("ele-name", "namespace").removeExtension(
        CompressFeature(["f5"])).setError(stanzaError)
    @Assert(obj.getType().isNone())
}

@Test
public func MessageView_1(): Unit {
    let obj = StanzaBuilder.buildMessage().build()
    for (m in obj.getSubjectLanguages()) {
        println(m)
    }
}

@Test
public func MultiMap_1(): Unit {
    let obj = MultiMap<String, String>()
    obj.put("key1", "value1")
    obj.put("key2", "value2")
    @Assert(obj.isEmpty(),false)
    @Assert(obj.containsKey("key1"),true)
    @Assert(obj.getFirst("").isNone())
    @Assert(obj.putFirst("key2","v2"))
    @Assert(obj.removeOne("key2","v2"))
    @Assert(obj.removeOne("key2","v2"),false)
    @Assert(obj.getAll("key2").size,1)
    @Assert(obj.remove("key2",1)?.size??0,1)
    obj.putAll(HashMap<String, String>([("1", "11")]))
    @Assert(obj.size,3)
    obj.clear()
    @Assert(obj.keySet().size,0)
}

@Test
public func Presence_1(): Unit {
    let obj = StanzaBuilder.buildPresence().build()
    let obj2 = Presence(obj)
    @Assert(obj.getStatus().isNone())
    @Assert(obj.getPriority(),0)
    obj.setPriority(10)
    @Assert(obj.getPriorityByte(),10)
    obj.asBuilder()
    obj.asBuilder("id1")
}

@Test
public func PresenceType_1(): Unit {
    @Assert(PresenceType.fromString("available"),PresenceType.available)
    @Assert(PresenceType.fromString("unavailable"),PresenceType.unavailable)
    @Assert(PresenceType.fromString("subscribe"),PresenceType.subscribe)
    @Assert(PresenceType.fromString("subscribed"),PresenceType.subscribed)
    @Assert(PresenceType.fromString("unsubscribe"),PresenceType.unsubscribe)
    @Assert(PresenceType.fromString("unsubscribed"),PresenceType.unsubscribed)
    @Assert(PresenceType.fromString("error"),PresenceType.error)
    @Assert(PresenceType.fromString("probe"),PresenceType.probe)
}

@Test
public func PresenceType_2(): Unit {
    @Assert(PresenceType.fromString("available").toString(),"available")
    @Assert(PresenceType.fromString("unavailable").toString(),"unavailable")
    @Assert(PresenceType.fromString("subscribe").toString(),"subscribe")
    @Assert(PresenceType.fromString("subscribed").toString(),"subscribed")
    @Assert(PresenceType.fromString("unsubscribe").toString(),"unsubscribe")
    @Assert(PresenceType.fromString("unsubscribed").toString(),"unsubscribed")
    @Assert(PresenceType.fromString("error").toString(),"error")
    @Assert(PresenceType.fromString("probe").toString(),"probe")
}

@Test
public func PresenceType_3(): Unit {
    @AssertThrows[IllegalArgumentException](PresenceType.fromString(""))
}

@Test
public func PresenceMode_1(): Unit {
    @Assert(PresenceMode.fromString("chat"),PresenceMode.chat)
    @Assert(PresenceMode.fromString("available"),PresenceMode.available)
    @Assert(PresenceMode.fromString("away"),PresenceMode.away)
    @Assert(PresenceMode.fromString("xa"),PresenceMode.xa)
    @Assert(PresenceMode.fromString("dnd"),PresenceMode.dnd)
}

@Test
public func PresenceMode_2(): Unit {
    @Assert(PresenceMode.fromString("chat").toString(),"chat")
    @Assert(PresenceMode.fromString("available").toString(),"available")
    @Assert(PresenceMode.fromString("away").toString(),"away")
    @Assert(PresenceMode.fromString("xa").toString(),"xa")
    @Assert(PresenceMode.fromString("dnd").toString(),"dnd")
}

@Test
public func PresenceMode_3(): Unit {
    @AssertThrows[IllegalArgumentException](PresenceMode.fromString(""))
}

@Test
public func PresenceBuilder_1(): Unit {
    let stanzaErrorBuilder = StanzaError.getBuilder()
    let stanzaError = stanzaErrorBuilder.setCondition(StanzaErrorCondition.gone).build()
    StanzaBuilder.buildPresence().to("to: String").to(None).froms(None).froms("None").setLanguage("lan1").addExtension(
        CompressFeature(["f1"])).addExtensions([CompressFeature(["f2"])]).addOptExtensions(None).overrideExtension(
        CompressFeature(["f4"])).removeExtension("ele-name", "namespace").removeExtension(CompressFeature(["f5"])).
        setError(stanzaError)
}

@Test
public func XmlField_1(): Unit {
    let messageSubject = MessageSubject("1", "2")
    @Assert(messageSubject.QNAME_FIELD,MessageSubject.QNAME)
    @Assert(messageSubject.ELEMENT_FIELD,MessageSubject.ELEMENT)
    @Assert(messageSubject.NAMESPACE_FIELD,MessageSubject.NAMESPACE)
    @Assert(messageSubject.getClass(),MessageSubject.getClassId())
}

@Test
public func XmlField_2(): Unit {
    let messageThread = MessageThread("3", "4")
    @Assert(messageThread.QNAME_FIELD,MessageThread.QNAME)
    @Assert(messageThread.ELEMENT_FIELD,MessageThread.ELEMENT)
    @Assert(messageThread.NAMESPACE_FIELD,MessageThread.NAMESPACE)
    @Assert(messageThread.getClass(),MessageThread.getClassId())
}

@Test
public func XmlField_3(): Unit {
    let messageBody = MessageBody("5", "6")
    @Assert(messageBody.QNAME_FIELD,MessageBody.QNAME)
    @Assert(messageBody.ELEMENT_FIELD,MessageBody.ELEMENT)
    @Assert(messageBody.NAMESPACE_FIELD,MessageBody.NAMESPACE)
    @Assert(messageBody.getClass(),MessageBody.getClassId())
}

@Test
public func RandomUtil_1(): Unit {
    RandomUtil.nextSecureRandomInt(100)
    RandomUtil.nextSecureRandomInt()
    RandomUtil.fillWithSecureRandom("100".toArray())
}

@Test
public func Session_1(): Unit {
    Session()
    let obj = SessionFeature(false)
    @Assert(obj.isOptional(),false)
    @Assert(obj.getElementName(),Session.ELEMENT)
    @Assert(obj.getNamespace(),Session.NAMESPACE)
    println(obj.toXML(None).toString())
    println(SessionFeature(true).toXML(None).toString())
}

@Test
public func StandardExtensionElement_1(): Unit {
    let obj = StandardExtensionElement("name1", "namespace1")
    @Assert(obj.getAttributeValue("").isNone())
    @Assert(obj.getAttributes().size,0)
    @Assert(obj.getFirstElement("").isNone())
    @Assert(obj.getElements("","").isNone())
    @Assert(obj.getElements("").isNone())
    @Assert(obj.getElements().size,0)
    @Assert(obj.getText().isNone())
}

@Test
public func StandardExtensionElement_2(): Unit {
    let obj = StandardExtensionElement("name1", "namespace1")
    let map2: Map<String, String> = HashMap<String, String>([("key4", "value4")])
    let obj2 = StandardExtensionElement.builder("name2", "ns2").addAttribute("key3", "value3").addAttributes(map2).
        setText("text").addElement("e3", "ev3").build()

    @Assert(obj==obj2,false)
    @Assert(obj!=obj2)
}

@Test
public func StanzaBuilder_1(): Unit {
    let obj = StanzaBuilder.buildMessageFrom(StanzaBuilder.buildMessage().build(), None)
    @Assert(obj.getStanzaId().isNone())
    @Assert(obj.getTo().isNone())
    @Assert(obj.getFrom().isNone())
    @Assert(obj.getLanguage().isNone())
    @Assert(obj.getExtension(MessageBody.QNAME).isNone())
    @Assert(obj.getExtensions().size,0)
    @Assert(obj.getExtensions(MessageBody.QNAME).size,0)
    @Assert(obj.willBuildStanzaWithId(),false)
    @AssertThrows[Exception](obj.throwIfNoStanzaId())
    obj.toString()
    @Assert(obj.hasExtension("ns2"),false)

    StanzaBuilder.buildMessageFrom(StanzaBuilder.buildMessage().build(), StandardStanzaIdSource())
    StanzaBuilder.buildPresenceFrom(StanzaBuilder.buildPresence().build(), StandardStanzaIdSource())
}

@Test
public func Stanza_1(): Unit {
    let obj: Stanza = StanzaBuilder.buildMessage().build()
    @AssertThrows[IllegalArgumentException](obj.throwIfNoStanzaId())
    @Assert(obj.getExtensionsMap().size,0)
    @Assert(obj.getExtensions("1","2").size,0)
    @Assert(obj.getExtension("").isNone())
    @Assert(obj.getExtensionElement("","").isNone())
}

@Test
public func Stanza_2(): Unit {
    let obj: Stanza = StanzaBuilder.buildMessage().build()
    obj.addExtension(None)
    obj.addExtension(StandardExtensionElement("name1", "namespace1"))
    obj.overrideExtension(None)
    obj.overrideExtension(StandardExtensionElement("name2", "namespace2"))
    obj.addExtensions([StandardExtensionElement("name3", "namespace3")])
    @Assert(obj.hasExtension("name1","namespace1"))
    @Assert(obj.hasExtension("namespace2"))
    @Assert(obj.removeExtension("name3", "namespace3").isSome())
    @Assert(Stanza.getDefaultLanguage(),"en")
    @Assert(obj.hasExtension(QName("","")),false)
    @Assert(obj.hasExtensionByType("MessageSubject"),false)
}

@Test
public func StanzaError_1(): Unit {
    let descriptiveTexts = HashMap<String, String>([("key1", "value1"), ("key2", "value2")])
    let extensions = ArrayList<ExtensionElement>([StandardExtensionElement("name1", "namespace1")])
    let obj = StanzaError(StanzaErrorCondition.gone, "conditionTextString1", "errorGenerator1", StanzaErrorType.AUTH,
        descriptiveTexts, extensions)
    @Assert(obj.getCondition()!=StanzaErrorCondition.conflict)
    @Assert(obj.getType().toString(),StanzaErrorType.AUTH.toString())
    @Assert(obj.getErrorGenerator(),"errorGenerator1")
    @Assert(obj.getConditionText(),"conditionTextString1")
    @Assert(obj.toString().size>0)
    @Assert(obj.toXML(None).toString().size>0)

    let builder1 = StanzaError.froms(StanzaErrorCondition.redirect, "descriptiveText1")
    let builder2 = StanzaError.getBuilder(obj)
    builder2.copyFrom(obj).setType(StanzaErrorType.CONTINUE).setConditionText("conditionText2").setErrorGenerator(
        "errorGenerator2")
}

@Test
public func StanzaErrorType_1(): Unit {
    @Assert(StanzaErrorType.fromString("wait").toString(),"wait")
    @Assert(StanzaErrorType.fromString("cancel").toString(),"cancel")
    @Assert(StanzaErrorType.fromString("modify").toString(),"modify")
    @Assert(StanzaErrorType.fromString("auth").toString(),"auth")
    @Assert(StanzaErrorType.fromString("continue").toString(),"continue")
    @AssertThrows[IllegalArgumentException](StanzaErrorType.fromString(""))
}

@Test
public func StanzaErrorCondition_1(): Unit {
    @Assert(StanzaErrorCondition.fromString("bad-request").toString(),"bad-request")
    @Assert(StanzaErrorCondition.fromString("conflict").toString(),"conflict")
    @Assert(StanzaErrorCondition.fromString("feature-not-implemented").toString(),"feature-not-implemented")
    @Assert(StanzaErrorCondition.fromString("forbidden").toString(),"forbidden")
    @Assert(StanzaErrorCondition.fromString("gone").toString(),"gone")
    @Assert(StanzaErrorCondition.fromString("internal-server-error").toString(),"internal-server-error")
    @Assert(StanzaErrorCondition.fromString("item-not-found").toString(),"item-not-found")
    @Assert(StanzaErrorCondition.fromString("jid-malformed").toString(),"jid-malformed")
    @Assert(StanzaErrorCondition.fromString("not-acceptable").toString(),"not-acceptable")
    @Assert(StanzaErrorCondition.fromString("not-allowed").toString(),"not-allowed")
    @Assert(StanzaErrorCondition.fromString("not-authorized").toString(),"not-authorized")
    @Assert(StanzaErrorCondition.fromString("policy-violation").toString(),"policy-violation")
    @Assert(StanzaErrorCondition.fromString("recipient-unavailable").toString(),"recipient-unavailable")
    @Assert(StanzaErrorCondition.fromString("redirect").toString(),"redirect")
    @Assert(StanzaErrorCondition.fromString("registration-required").toString(),"registration-required")
    @Assert(StanzaErrorCondition.fromString("remote-server-not-found").toString(),"remote-server-not-found")
    @Assert(StanzaErrorCondition.fromString("remote-server-timeout").toString(),"remote-server-timeout")
    @Assert(StanzaErrorCondition.fromString("resource-constraint").toString(),"resource-constraint")
    @Assert(StanzaErrorCondition.fromString("service-unavailable").toString(),"service-unavailable")
    @Assert(StanzaErrorCondition.fromString("subscription-required").toString(),"subscription-required")
    @Assert(StanzaErrorCondition.fromString("undefined-condition").toString(),"undefined-condition")
    @Assert(StanzaErrorCondition.fromString("unexpected-request").toString(),"unexpected-request")
    @AssertThrows[IllegalArgumentException](StanzaErrorCondition.fromString(""))
}

@Test
public func StanzaFactory_1(): Unit {
    let f = StanzaFactory(StandardStanzaIdSource())
    f.getStanzaIdSource()
    f.buildMessageStanza()
    f.buildMessageStanzaFrom(StanzaBuilder.buildMessage().build())
    f.buildPresenceStanza()
    f.buildPresenceStanzaFrom(StanzaBuilder.buildPresence().build())
    f.buildIqData()
}

@Test
public func UuidStanzaIdSource_1(): Unit {
    @Assert(UuidStanzaIdSourceFactory().constructStanzaIdSource().getNewStanzaId()?.size,36)
    @Assert(RandomStringStanzaIdSourceFactory(10,false).constructStanzaIdSource().getNewStanzaId()?.size,10)
    @Assert(RandomStringStanzaIdSourceFactory(11,true).constructStanzaIdSource().getNewStanzaId()?.size,11)
    @AssertThrows[IllegalArgumentException](RandomStringStanzaIdSourceFactory(9,true))
    @Assert(StandardStanzaIdSourceFactory ().constructStanzaIdSource().getNewStanzaId()?.size,7)
}

@Test
public func StartTls_1(): Unit {
    let obj = StartTls()
    @Assert(obj.requiredMethod(),false)
    @Assert(obj.getElementName(),StartTls.ELEMENT)
    @Assert(obj.getNamespace(),StartTls.NAMESPACE)
    obj.toXML(None)
    StartTls(true).toXML(None)
}

@Test
public func StreamClose_1(): Unit {
    let obj = StreamClose.INSTANCE
    obj.toXML(None)
    @Assert(obj.getElementName(),StreamOpen.ELEMENT)
    @Assert(obj.getNamespace(),"(none)")
}

@Test
public func StreamError_1(): Unit {
    let descriptiveTexts = HashMap<String, String>([("key1", "value1"), ("key2", "value2")])
    let extensions = ArrayList<ExtensionElement>([StandardExtensionElement("name1", "namespace1")])
    let obj = StreamError(StreamErrorCondition.see_other_host, "conditionTextStr1", descriptiveTexts, extensions)
    @Assert(obj.toString(),obj.toXML(None).toString())
    @Assert(obj.getCondition(),StreamErrorCondition.see_other_host)
    @Assert(obj.getConditionText(),"conditionTextStr1")
    @Assert(obj.getElementName(),StreamError.ELEMENT)
    @Assert(obj.getNamespace(),StreamError.NAMESPACE)
}

@Test
public func StreamErrorCondition_1(): Unit {
    @Assert(StreamErrorCondition.fromString("bad_format"),StreamErrorCondition.bad_format)
    @Assert(StreamErrorCondition.fromString("bad_namespace_prefix"),StreamErrorCondition.bad_namespace_prefix)
    @Assert(StreamErrorCondition.fromString("conflict"),StreamErrorCondition.conflict)
    @Assert(StreamErrorCondition.fromString("connection_timeout"),StreamErrorCondition.connection_timeout)
    @Assert(StreamErrorCondition.fromString("host_gone"),StreamErrorCondition.host_gone)
    @Assert(StreamErrorCondition.fromString("host_unknown"),StreamErrorCondition.host_unknown)
    @Assert(StreamErrorCondition.fromString("improper_addressing"),StreamErrorCondition.improper_addressing)
    @Assert(StreamErrorCondition.fromString("internal_server_error"),StreamErrorCondition.internal_server_error)
    @Assert(StreamErrorCondition.fromString("invalid_from"),StreamErrorCondition.invalid_from)
    @Assert(StreamErrorCondition.fromString("invalid_namespace"),StreamErrorCondition.invalid_namespace)
    @Assert(StreamErrorCondition.fromString("invalid_xml"),StreamErrorCondition.invalid_xml)
    @Assert(StreamErrorCondition.fromString("not_authorized"),StreamErrorCondition.not_authorized)
    @Assert(StreamErrorCondition.fromString("not_well_formed"),StreamErrorCondition.not_well_formed)
    @Assert(StreamErrorCondition.fromString("policy_violation"),StreamErrorCondition.policy_violation)
    @Assert(StreamErrorCondition.fromString("remote_connection_failed"),StreamErrorCondition.remote_connection_failed)
    @Assert(StreamErrorCondition.fromString("reset"),StreamErrorCondition.reset)
    @Assert(StreamErrorCondition.fromString("resource_constraint"),StreamErrorCondition.resource_constraint)
    @Assert(StreamErrorCondition.fromString("restricted_xml"),StreamErrorCondition.restricted_xml)
    @Assert(StreamErrorCondition.fromString("see_other_host"),StreamErrorCondition.see_other_host)
    @Assert(StreamErrorCondition.fromString("system_shutdown"),StreamErrorCondition.system_shutdown)
    @Assert(StreamErrorCondition.fromString("undefined_condition"),StreamErrorCondition.undefined_condition)
    @Assert(StreamErrorCondition.fromString("unsupported_encoding"),StreamErrorCondition.unsupported_encoding)
    @Assert(StreamErrorCondition.fromString("unsupported_feature"),StreamErrorCondition.unsupported_feature)
    @Assert(StreamErrorCondition.fromString("unsupported_stanza_type"),StreamErrorCondition.unsupported_stanza_type)
    @Assert(StreamErrorCondition.fromString("unsupported_version"),StreamErrorCondition.unsupported_version)
    @Assert(StreamErrorCondition.fromString("unsupported_version")!=StreamErrorCondition.conflict)
    @AssertThrows[IllegalArgumentException](StreamErrorCondition.fromString(""))
}

@Test
public func StreamOpen_1(): Unit {
    StreamOpen("to1")
    StreamOpen("to2", "from2", "id2")
    let obj = StreamOpen("to3", "from3", "id3", "lang3", StreamOpenStreamContentNamespace.client)
    @Assert(obj.getElementName(),StreamOpen.ELEMENT)
    @Assert(obj.getNamespace(),StreamOpen.CLIENT_NAMESPACE)
    obj.toXML(None)
}

@Test
public func TlsFailure_1(): Unit {
    let obj = TlsFailure.INSTANCE
    let str = "<${TlsFailure.ELEMENT} xmlns='${TlsFailure.NAMESPACE}'/>"
    @Assert(obj.toXML(None).toString(),str)
    @Assert(obj.getElementName(),TlsFailure.ELEMENT)
    @Assert(obj.getNamespace(),TlsFailure.NAMESPACE)
}

@Test
public func TlsProceed_1(): Unit {
    let obj = TlsProceed.INSTANCE
    let str = "<${TlsProceed.ELEMENT} xmlns='${TlsProceed.NAMESPACE}'/>"
    @Assert(obj.toXML(None).toString(),str)
    @Assert(obj.getElementName(),TlsProceed.ELEMENT)
    @Assert(obj.getNamespace(),TlsProceed.NAMESPACE)
}

@Test
public func ToStringUtil_1(): Unit {
    let obj = ToStringUtil.builderFor("clazz1")
    obj.addValue("key1", "value1")
    obj.add<String>("key2", ["value21", "value22", "value23"])
    println(obj.build())
}

@Test
public func UnparsedIQ_1(): Unit {
    let obj = UnparsedIQ("element1", "namespace1", "content1")
    println(obj.getChildElementXML().toString())
    @Assert(obj.getContent(),"content1")
}

// @Test
// public func UUID_1(): Unit {
//     @Assert(UUID.nilUUID().toString().size,36)
//     @AssertThrows[IllegalArgumentException](UUID([0u8]))
// }

@Test
public func XmlEnvironment_1(): Unit {
    let obj = XmlEnvironment("ns1", "lang1", None)
    @Assert(obj.getNamespace(),"ns1")
    @Assert(obj.getLanguage(),"lang1")
    obj.toString()
    @Assert(obj.getEffectiveNamespaceOrUse("ns2"),"ns1")
}

@Test
public func XmlEnvironment_2(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteArrayStream()
    input.write("<element/>".toArray())
    let parser = staxXmlPullParserFactory.newXmlPullParser(input)
    XmlEnvironment.froms(parser)
    XmlEnvironment.builder().withs(StreamOpen("to2", "from2", "id2"))
}

@Test
public func XmlStringBuilder_1(): Unit {
    let obj = XmlStringBuilder(EmptyResultIQ())
    obj.escapedElement("name1", "escapedContent1")
    obj.element("name2", DateTime.now())
    obj.optElement("name3", Option<DateTime>.None)
    obj.optElement("name4", 64)
    obj.halfOpenElement(EmptyResultIQ())
    obj.attribute("name5", DateTime.now())
    obj.attribute("name6", 128)
    obj.optAttribute("name7", Option<Int>.None)
    obj.optAttribute("name8", Option<DateTime>.None)
    obj.optAttributeCs("name9", Option<ToString>.None)
    obj.optIntAttribute("name10", 0)
    obj.optIntAttribute("name11", Option<Int>.None)
    obj.optBooleanAttribute("name12", false)
    obj.optBooleanAttributeDefaultTrue("name13", false)
    obj.optEscape("text14")
    // .prelude(CompressFeature(["ns1"]))
    // .prelude("name16", CompressFeature(["ns2"]))
    obj.optAppend(CompressFeature(["ns1"]))
    obj.optTextChild("sqc", CompressFeature(["ns1"]))
    obj.condEmptyElement(true, "element1")
    obj.condAttribute(false, "name17", "value17")
    let arre: Array<Element> = [CompressFeature(["ns1"])]
    let itere: Iterator<Element> = arre.iterator()
    obj.optAppend(arre)
    let io = ByteArrayStream()
    let writer = ObservableWriter(io)
    obj.write(writer, XmlEnvironment("ns1", "lang1", None))
    obj.toList(XmlEnvironment("ns1", "lang1", None))
}

@Test
public func qname_1(): Unit {
    let qname = QName("", "ele", "")
    @Assert(qname.toString(),qname.getFullName())
}

@Test
public func StaxXmlPullParser_1(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteArrayStream()
    input.write("<element/>".toArray())
    let parser = staxXmlPullParserFactory.newXmlPullParser(input)
    @AssertThrows[UnsupportedException](parser.getProperty(""))
    @Assert(parser.getInputEncoding(),"UTF-8")
    @Assert(parser.getNamespaceCount(),0)
    @AssertThrows[Exception](parser.getNamespacePrefix(0))
    @AssertThrows[Exception](parser.getNamespaceUri(0))
    @Assert(parser.getDepth(),0)
    @AssertThrows[UnsupportedException](parser.getPositionDescription())
    @AssertThrows[UnsupportedException](parser.getLineNumber())
    @AssertThrows[UnsupportedException](parser.getColumnNumber())
    @AssertThrows[UnsupportedException](parser.isWhiteSpace())
    @Assert(parser.getText(),"")
    parser.nextTag()
    @Assert(parser.supportsRoundtrip(),false)
}

@Test
public func XmlPullParser_1(): Unit {
    @Assert(XmlPullParserEvent.PROCESSING_INSTRUCTION.toString(),"PROCESSING_INSTRUCTION")
    @Assert(XmlPullParserEvent.COMMENT.toString(),"COMMENT")
    @Assert(XmlPullParserEvent.IGNORABLE_WHITESPACE.toString(),"IGNORABLE_WHITESPACE")
    @Assert(XmlPullParserEvent.ENTITY_REFERENCE.toString(),"ENTITY_REFERENCE")
    @Assert(XmlPullParserEvent.OTHER.toString(),"OTHER")

    XmlPullParserException(Exception())
}

@Test
public func LruCache_1(): Unit {
    @AssertThrows[IllegalArgumentException](LruCache<String,Int>(0))
    let obj = LruCache<String, Int>(2)
    obj.put("1", 1)
    obj.put("2", 2)
    obj.put("3", 3)
    obj.remove("1")
    println("LruCache_1: ${obj.lookup("1")} ${obj.lookup("2")} ${obj.lookup("3")}")
    @Assert(obj.get("2"),2)
    @Assert(obj.getCacheHits(),1)
    obj.get("1")
    @Assert(obj.getCacheMisses(),1)
    obj.setMaxCacheSize(1)
    @Assert(obj.getMaxCacheSize(),1)
}
