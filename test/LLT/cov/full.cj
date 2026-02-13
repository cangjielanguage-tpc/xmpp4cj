// DEPENDENCE: ../z_test.cj ../jid_test_util.cj ../log.cj
// EXEC: cjc %import-path %L %l %f z_test.cj log.cj jid_test_util.cj --test -Woff all --error-count-limit all
// EXEC: ./main
import std.collection.concurrent.*
import std.net.*

class AbstractErrorSub <: AbstractError {
    init(map: ?Map<String, String>) {
        super(map)
    }
}

@Test
public func t01(): Unit {
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

class AbstractErrorBuilderSub <: AbstractErrorBuilder {}

@Test
public func builder2(): Unit {
    let obj: AbstractErrorBuilder = AbstractErrorBuilderSub()
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
        builder, other => builder
            .append(qname1.getNamespaceURI(), other.getNamespaceURI())
            .append(qname1.getLocalPart(), other.getLocalPart())
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
    let obj = ErrorIQ
        .builder(stanzaError)
        .to("to: String")
        .to(None)
        .froms(None)
        .froms("None")
        .setLanguage("lan1")
        .addExtension(CompressFeature(["f1"]))
        .addExtensions([CompressFeature(["f2"])])
        .addOptExtensions(None)
        .overrideExtension(CompressFeature(["f4"]))
        .removeExtension("ele-name", "namespace")
        .removeExtension(CompressFeature(["f5"]))
        .build()
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
    let hash = HashCode
        .builder()
        .append([""].iterator())
        .append(true)
        .append(8u8)
        .append(r'r')
        .append(64.0f64)
        .append(64i64)
        .build()
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
    let obj = StanzaBuilder
        .buildIqData(None)
        .to("to: String")
        .to(None)
        .froms(None)
        .froms("None")
        .setLanguage("lan1")
        .addExtension(CompressFeature(["f1"]))
        .addExtensions([CompressFeature(["f2"])])
        .addOptExtensions(None)
        .overrideExtension(CompressFeature(["f4"]))
        .removeExtension("ele-name", "namespace")
        .removeExtension(CompressFeature(["f5"]))
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
    let obj = StanzaBuilder
        .buildMessage(None)
        .to("to: String")
        .to(None)
        .froms(None)
        .froms("None")
        .setLanguage("lan1")
        .addExtension(CompressFeature(["f1"]))
        .addExtensions([CompressFeature(["f2"])])
        .addOptExtensions(None)
        .overrideExtension(CompressFeature(["f4"]))
        .removeExtension("ele-name", "namespace")
        .removeExtension(CompressFeature(["f5"]))
        .setError(stanzaError)
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
    StanzaBuilder
        .buildPresence()
        .to("to: String")
        .to(None)
        .froms(None)
        .froms("None")
        .setLanguage("lan1")
        .addExtension(CompressFeature(["f1"]))
        .addExtensions([CompressFeature(["f2"])])
        .addOptExtensions(None)
        .overrideExtension(CompressFeature(["f4"]))
        .removeExtension("ele-name", "namespace")
        .removeExtension(CompressFeature(["f5"]))
        .setError(stanzaError)
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
    let obj2 = StandardExtensionElement
        .builder("name2", "ns2")
        .addAttribute("key3", "value3")
        .addAttributes(map2)
        .setText("text")
        .addElement("e3", "ev3")
        .build()

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
    builder2
        .copyFrom(obj)
        .setType(StanzaErrorType.CONTINUE)
        .setConditionText("conditionText2")
        .setErrorGenerator("errorGenerator2")
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
    let input = ByteBuffer()
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
    let io = ByteBuffer()
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
    let input = ByteBuffer()
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

/* // 内部化导致部分用例不可运行，跑覆盖率时可放开。

@Test
public func XmlEvent_1(): Unit {
    @Assert(XmlEvent.Decl.toString(),"Decl")
    @Assert(XmlEvent.Comment.toString(),"Comment")
    @Assert(XmlEvent.ProcInst.toString(),"ProcInst")
    @Assert(XmlEvent.DTD.toString(),"DTD")
    @Assert(XmlEvent.ElementStart.toString(),"ElementStart")
    @Assert(XmlEvent.ElementEnd.toString(),"ElementEnd")
    @Assert(XmlEvent.Attribute.toString(),"Attribute")
    @Assert(XmlEvent.Namespace.toString(),"Namespace")
    @Assert(XmlEvent.Text.toString(),"Text")
    @Assert(XmlEvent.CData.toString(),"CData")
    @Assert(XmlEvent.EntityRef.toString(),"EntityRef")
}

@Test
public func XmlReader_1(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteBuffer()
    input.write("<element/>".toArray())
    let obj = XmlReader(input)
    @AssertThrows[UnsupportedException](obj.getCurrentPosition())
    @AssertThrows[UnsupportedException](obj.getCurrentNamespace())
    @AssertThrows[UnsupportedException](obj.readComment())
    @AssertThrows[UnsupportedException](obj.readProcInst())
    @AssertThrows[UnsupportedException](obj.readDTD())
    @AssertThrows[UnsupportedException](obj.readAttribute(""))
    @AssertThrows[Exception](obj.readCData())
    @AssertThrows[Exception](obj.readDecl())
    obj.skip()
    obj.readElementEnd()
}

@Test
public func XmlReader_2(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteBuffer()
    input.write("<element/>".toArray())
    let obj = XmlReader(input)
    obj.peek()
    obj.skip()
    obj.readElementEnd("element")
} */
@Test
public func XmppXmlParser_1(): Unit {
    let staxXmlPullParserFactory = StaxXmlPullParserFactory()
    let input = ByteBuffer()
    input.write("<element/>".toArray())
    XmppXmlParser.getXmlPullParserFactory()
    XmppXmlParser.setXmlPullParserFactory(staxXmlPullParserFactory)
    XmppXmlParser.newXmlParser(input)
}

let conn = {
    =>
    let config = XMPPTCPConnectionConfiguration
        .builder()
        .setXmppDomain(XmppTestServerHostName)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .build()
    let conn = XMPPTCPConnection(config)
    conn.connect()
    conn.login()
    conn
}()

@Test
public func covIQReplyFilter(): Unit {
    let emptyResultIQ = EmptyResultIQ()
    let domainBareJid = JidCreate.domainBareFromOrThrowUnchecked("juliet@shakespeare.lit/balcony")
    @AssertThrows[IllegalArgumentException](IQReplyFilter(emptyResultIQ, None, domainBareJid))

    let session = Session()
    let user = JidCreate.entityFullFromOrThrowUnchecked("juliet@shakespeare.lit/asd")
    session.setTo(user)

    let local: ?EntityFullJid = user
    let jid = local?.asBareJid()
    println(jid)
    println(session.getTo())
    println(jid.getOrThrow() == session.getTo().getOrThrow())

    session.setTo(conn.getUser().getOrThrow())
    let iqReplyFilter = IQReplyFilter(session, conn.getUser(), conn.getXMPPServiceDomain())

    @AssertThrows[IllegalArgumentException](ErrorIQ.builder(None).build())

    let stanzaError = StanzaError(StanzaErrorCondition.gone, Some("conditionTextString"), Some("errorGenerator"),
        StanzaErrorType.WAIT, HashMap<String, String>(), Array<ExtensionElement>())
    let err = ErrorIQ.builder(stanzaError).build()
    err.setStanzaId(session.getStanzaId())

    println(iqReplyFilter.accept(err))
    println(session.getStanzaId())
    println(iqReplyFilter.toString())
}

@Test
public func covIQResultReplyFilter(): Unit {
    let iqPacket = Session()
    let obj = IQResultReplyFilter(iqPacket, conn.getUser(), conn.getXMPPServiceDomain())
    println(obj.toString())
    obj.accept(EmptyResultIQ())
}

@Test
public func test_AbstractXMPPConnection1(): Unit {
    let syncPointState1 = SyncPointState.initial
    let syncPointState2 = SyncPointState.request_sent
    let syncPointState3 = SyncPointState.successful
    @Assert(true, syncPointState1 == syncPointState1)
    @Assert(true, syncPointState2 == syncPointState2)
    @Assert(true, syncPointState3 == syncPointState3)
    @Assert(false, syncPointState3 == syncPointState2)
}

@Test
public func test_ArrayBlockingQueueWithShutdown1(): Unit {
    let arrayBlockingQueueWithShutdownTryTakeResultCode1 = ArrayBlockingQueueWithShutdownTryTakeResultCode.couldNotLock
    let arrayBlockingQueueWithShutdownTryTakeResultCode2 = ArrayBlockingQueueWithShutdownTryTakeResultCode
        .queueWasShutDown
    let arrayBlockingQueueWithShutdownTryTakeResultCode3 = ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasEmpty
    let arrayBlockingQueueWithShutdownTryTakeResultCode4 = ArrayBlockingQueueWithShutdownTryTakeResultCode
        .takeSuccessful
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode1 == arrayBlockingQueueWithShutdownTryTakeResultCode1)
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode2 == arrayBlockingQueueWithShutdownTryTakeResultCode2)
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode3 == arrayBlockingQueueWithShutdownTryTakeResultCode3)
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode4 == arrayBlockingQueueWithShutdownTryTakeResultCode4)
    @Assert("couldNotLock", arrayBlockingQueueWithShutdownTryTakeResultCode1.toString())
    @Assert("queueWasShutDown", arrayBlockingQueueWithShutdownTryTakeResultCode2.toString())
    @Assert("queueWasEmpty", arrayBlockingQueueWithShutdownTryTakeResultCode3.toString())
    @Assert("takeSuccessful", arrayBlockingQueueWithShutdownTryTakeResultCode4.toString())
    @Assert(false, arrayBlockingQueueWithShutdownTryTakeResultCode2 == arrayBlockingQueueWithShutdownTryTakeResultCode3)
}

@Test
public func test_ArrayBlockingQueueWithShutdown2(): Unit {
    let arrayBlockingQueueWithShutdownTryPutResult1 = ArrayBlockingQueueWithShutdownTryPutResult.couldNotLock
    let arrayBlockingQueueWithShutdownTryPutResult2 = ArrayBlockingQueueWithShutdownTryPutResult.queueWasShutDown
    let arrayBlockingQueueWithShutdownTryPutResult3 = ArrayBlockingQueueWithShutdownTryPutResult.queueWasFull
    let arrayBlockingQueueWithShutdownTryPutResult4 = ArrayBlockingQueueWithShutdownTryPutResult.putSuccessful
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult1 == arrayBlockingQueueWithShutdownTryPutResult1)
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult2 == arrayBlockingQueueWithShutdownTryPutResult2)
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult3 == arrayBlockingQueueWithShutdownTryPutResult3)
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult4 == arrayBlockingQueueWithShutdownTryPutResult4)
    @Assert("couldNotLock", arrayBlockingQueueWithShutdownTryPutResult1.toString())
    @Assert("queueWasShutDown", arrayBlockingQueueWithShutdownTryPutResult2.toString())
    @Assert("queueWasFull", arrayBlockingQueueWithShutdownTryPutResult3.toString())
    @Assert("putSuccessful", arrayBlockingQueueWithShutdownTryPutResult4.toString())
    @Assert(false, arrayBlockingQueueWithShutdownTryPutResult4 == arrayBlockingQueueWithShutdownTryPutResult3)
}

@Test
public func t11(): Unit {
    @AssertThrows[IllegalArgumentException](ArrayBlockingQueueWithShutdown<Int>(0,false))
    let q = ArrayBlockingQueueWithShutdown<Int>(1)
    @Assert(q.isEmpty(),true)
    @Assert(q.peek().isNone())
    @Assert(q.offer(0))
    @Assert(q.peek(),0)
    @Assert(q.offer(1),false)
    @Assert(q.offer(1,Duration.Zero),false)

    let fur = spawn {
        q.offer(1, Duration.second)
    }
    let res = q.tryTake()
    @Assert(res.getResultCode(),ArrayBlockingQueueWithShutdownTryTakeResultCode.takeSuccessful)
    @Assert(res.getElement(),0)

    @Assert(fur.get())
    println(q.size)
    for (i in q) {
        @Assert(i,1)
    }

    @Assert(q.offerAndShutdown(2),false)
    @Assert(q.start())

    let f2 = spawn {q.putAll([3])}
    @Assert(q.poll(Duration.second),1)
    f2.get()

    @Assert(q.tryPut(4),ArrayBlockingQueueWithShutdownTryPutResult.queueWasFull)
    q.shutdown()
    @Assert(q.tryPut(4),ArrayBlockingQueueWithShutdownTryPutResult.queueWasShutDown)
    @Assert(q.start())
    @Assert(q.take(),3)
    @Assert(q.tryPut(4),ArrayBlockingQueueWithShutdownTryPutResult.putSuccessful)

    let f3 = spawn {q.offer(5, Duration.second * 5)}
    sleep(Duration.millisecond * 50)
    @Assert(q.take(),4)
    @Assert(f3.get())

    q.shutdown()
    @Assert(q.tryTake().getResultCode(),ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasShutDown)

    q.start()
    @Assert(q.tryTake().getElement(),5)
    @Assert(q.tryTake().getResultCode(),ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasEmpty)

    let f4 = spawn {q.poll(Duration.second * 2)}
    sleep(Duration.millisecond * 50)
    q.put(6)
    @Assert(f4.get(),6)

    @Assert(q.remainingCapacity(),1)

    let arr = ArrayList<Int>()
    @Assert(q.drainTo(arr,10),0)

    q.put(7)
    @Assert(q.drainTo(arr,10),1)

    q.put(8)
    let f5 = spawn {q.put(9)}
    @Assert(q.take(),8)
    f5.get()
}

@Test
public func t2(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    q.put(0)
    q.put(1)
    let f1 = spawn {q.put(2)}
    sleep(Duration.millisecond * 50)
    @Assert(q.take(),0)
    f1.get()

    let f2 = spawn {q.offer(3, Duration.second * 5)}
    sleep(Duration.millisecond * 50)
    q.shutdown()
    @AssertThrows[IllegalStateException](f2.get())
}

@Test
public func t3(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    @Assert(q.poll(Duration.Zero).isNone())

    let f2 = spawn {q.poll(Duration.second * 5)}
    sleep(Duration.millisecond * 50)
    q.shutdown()
    @AssertThrows[IllegalStateException](f2.get())
}

@Test
public func t4(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    @Assert(q.drainTo(ArrayList<Int>(), 0),0)
}

@Test
public func t5(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    q.put(0)
    q.clear()
    for (i in q) {
        println(i)
    }
    q.put(0)
    q.put(1)
    let iter = q.iterator()
    q.clear()
    @Assert(iter.next(),0)
}

@Test
public func t6(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    let f1 = spawn {
        sleep(Duration.millisecond * 500)
        q.put(0)
    }
    f1.cancel()
    @AssertThrows[IllegalStateException](f1.get())
}

@Test
public func t7(): Unit {
    let q = ArrayBlockingQueueWithShutdown<Int>(2)
    @AssertThrows[NoSuchElementException](q.remove())
}

@Test
public func test_CompressFeature1(): Unit {
    let compressFeature0: CompressFeature = CompressFeature(ArrayList<String>())
    @Assert(compressFeature0.getMethods().size, 0)
    let compressFeature1: CompressFeature = CompressFeature(ArrayList<String>(["", ""]))
    @Assert(compressFeature1.getMethods().size, 2)
}

@Test
public func test_Compressed1(): Unit {
    let compressed: Compressed = Compressed.INSTANCE
    @Assert(compressed.getElementName(), "compressed")
    @Assert(compressed.getNamespace(), "http://jabber.org/protocol/compress")
    @Assert(compressed.toXML(None).toString(), "<compressed xmlns='http://jabber.org/protocol/compress'/>")
}

@Test
public func test_CompressedProvider1(): Unit {
    let compressedProvider: CompressedProvider = CompressedProvider.INSTANCE
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let compressed: Compressed = compressedProvider.parse(staxXmlPullParserFactory.newXmlPullParser(ByteBuffer()), 0,
        None)
    @Assert(compressed.getElementName(), "compressed")
    @Assert(compressed.getNamespace(), "http://jabber.org/protocol/compress")
    @Assert(compressed.toXML(None).toString(), "<compressed xmlns='http://jabber.org/protocol/compress'/>")
}

@Test
public func test_FailureCompressFailureError1(): Unit {
    let failureCompressFailureError0: ?FailureCompressFailureError = FailureCompressFailureError.fromString(
        "unsupported_method")
    @Assert(failureCompressFailureError0, FailureCompressFailureError.unsupported_method)
    let failureCompressFailureError1: ?FailureCompressFailureError = FailureCompressFailureError.fromString("method")
    @Assert(failureCompressFailureError1, None)
    let bool0: Bool = FailureCompressFailureError.unsupported_method == FailureCompressFailureError.unsupported_method
    @Assert(bool0, true)
    let bool1: Bool = FailureCompressFailureError.setup_failed == FailureCompressFailureError.unsupported_method
    @Assert(bool1, false)
}

@Test
public func test_parseCompressionFeature1(): Unit {
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let e0: Exception = @AssertThrows[Exception](parseCompressionFeature(staxXmlPullParserFactory.newXmlPullParser(ByteBuffer())))
    // @Assert("Exception: AssertionError", e0.toString())
    let xmppXmlString: Array<Byte> = """
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>
<presence/>
<message to='william_duan@jabber.org' from='test_account@jabber.org' type='chat'><body>Hello</body></message>
<presence type='unavailable'/>"""
        .toArray()
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write(xmppXmlString)
    let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
    // let e1: Exception = @AssertThrows[Exception](parseCompressionFeature(staxXmlPullParser))
    // @Assert("Exception: AssertionError", e1.toString())
}
//--filter=*.*

class ConnectionListener0 <: ConnectionListener {
    public override func connectionClosed(): Unit {}

    public override func authenticated(connection: XMPPConnection, resumed: Bool): Unit {}

    public override func connectionClosedOnError(e: Exception): Unit {}
}

public class TestIQ <: SimpleIQ {
    public init() {
        this("test-iq", XmppConfiguration.XMPP_URL_STRING)
    }

    public init(element: String, namespace: String) {
        super(StanzaBuilder.buildIqData("42"), element, namespace)
    }

    protected func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        return super.getIQChildElementBuilder(xml)
    }
}

public class StanzaListener0 <: StanzaListener {
    public func processStanza(packet: Stanza): Unit {}
}

class PingRequestHandler <: AbstractIqRequestHandler {
    init() {
        super("ping", "urn:xmpp:ping", IQType.get, IQRequestHandlerMode.async)
    }
    public func handleIQRequest(iqRequest: IQ): ?IQ {
        // Ping ping = (Ping) iqRequest
        // return ping.getPong()
        None
    }
}

class IqSetRequestHandler <: AbstractIqRequestHandler {
    init() {
        super("ping", "urn:xmpp:ping", IQType.set, IQRequestHandlerMode.async)
    }
    public func handleIQRequest(iqRequest: IQ): ?IQ {
        // Ping ping = (Ping) iqRequest
        // return ping.getPong()
        None
    }
}

class ParsingExceptionCallback0 <: ParsingExceptionCallback {
    public func handleUnparsableStanza(stanzaData: UnparseableStanza): Unit {}
}

class StanzaFilter0 <: StanzaFilter {
    public func accept(stanza: Stanza): Bool {
        return true
    }
    public func toString(): String {
        "StanzaFilter0"
    }
}

@Test
func conn1(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)

    connection.removeConnectionListener(ConnectionListener0())

    connection.connect()
    try {
        @AssertThrows[IllegalArgumentException](connection.sendIqRequestAndWaitForResponse(TestIQ()))
        let iq = connection.sendIqRequestAndWaitForResponse(TestIQ())
    } catch (e: IllegalArgumentException) {
        @Assert(e.message,"Must have a local (user) JID set. Either you didn't configure one or you where not connected at least once")
    }
    connection.login()
    try {
        let iq = connection.sendIqRequestAndWaitForResponse(Bind.newSet(Resourcepart.froms("asdasdas")))
        println(iq)
    } catch (e: XMPPErrorException) {
        println(e.getMessage())
    }

    connection.addStanzaListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeStanzaListener(StanzaListener0())
    connection.addSyncStanzaListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeSyncStanzaListener(StanzaListener0())
    connection.addAsyncStanzaListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeAsyncStanzaListener(StanzaListener0())
    connection.addStanzaSendingListener(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))
    connection.removeStanzaSendingListener(StanzaListener0())

    connection.addMessageInterceptor(HashableConsumer {_ => ()}, None)
    connection.removeMessageInterceptor(HashableConsumer {_ => ()})

    connection.addPresenceInterceptor(HashableConsumer {_ => ()}, None)
    connection.removePresenceInterceptor(HashableConsumer {_ => ()})

    connection.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.doNotReply)

    let iq1 = connection.sendIqRequestAndWaitForResponse(Bind.newSet(Resourcepart.froms("aaa")))
    let iq2 = connection.sendIqRequestAsync(Bind.newSet(Resourcepart.froms("aaa")))
    let iq3 = connection.sendIqRequestAsync(Bind.newSet(Resourcepart.froms("aaa")), Duration.second)
    let request4 = Bind.newSet(Resourcepart.froms("aaa"))
    let filter4 = IQReplyFilter(request4, connection.getUser(), connection.getXMPPServiceDomain())
    let iq4 = connection.sendAsync(request4, filter4)
    let iq5 = connection.sendAsync(request4, filter4, Duration.second)
    // let iq6 = connection.sendAsyncGeneric(request4, filter4, Duration.second)
    // iq6.getOrThrow()

    connection.addOneTimeSyncCallback(StanzaListener0(), StanzaTypeFilter<Stanza>("Stanza"))

    let iqRequestHandler1 = connection.registerIQRequestHandler(PingRequestHandler())
    let iqRequestHandler2 = connection.registerIQRequestHandler(IqSetRequestHandler())
    let iqRequestHandler3 = connection.unregisterIQRequestHandler(PingRequestHandler())
    let iqRequestHandler4 = connection.unregisterIQRequestHandler("Ping1", "urn:xmpp:ping", IQType.get)
    let iqRequestHandler5 = connection.unregisterIQRequestHandler("Ping2", "urn:xmpp:ping", IQType.set)

    let dur1 = connection.getLastStanzaReceived()
    let dur2 = connection.getAuthenticatedConnectionInitiallyEstablishedTimestamp()

    connection.setParsingExceptionCallback(ParsingExceptionCallback0())
    let parsingExceptionCallback = connection.getParsingExceptionCallback()

    connection.setMaxAsyncOperations(128)

    @Assert(AbstractXMPPConnection.getClassId(), "AbstractXmppConnection")
    @Assert(connection==connection)

    connection.sendIqRequestAsync(Bind.newSet(Resourcepart.froms("asdasdas")))
}

@Test
func conn2(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        // .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)
    connection.connect()
    @AssertThrows[SASLErrorException](connection.login("1","1sknvosn"))
}

class ErrStanza <: Stanza {
    let msg: Message = StanzaBuilder.buildMessage().build();

    public func toString(): String {
        return msg.toString();
    }

    public func getElementName(): String {
        return msg.getElementName();
    }

    public func toXML(xmlEnvironment: ?XmlEnvironment): ToString {
        throw Exception("stop")
    }
}

@Test
func conn3(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        // .performSaslAnonymousAuthentication()
        .build()
    let connection = XMPPTCPConnection(config)
    @Assert(connection.getStreamId().isNone())
    @AssertThrows[NotConnectedException](connection.login("1","1sknvosn"))

    connection.connect()
    @AssertThrows[AlreadyConnectedException](connection.connect())

    connection.login("1", "123456")
    @AssertThrows[AlreadyLoggedInException](connection.login("1","123456"))

    connection.disconnect()
    connection.disconnect()
    connection.disconnect(None)

    // connection.notifyConnectionError(Exception())
    connection.connect()
    connection.sendStanza(ErrStanza())
    // connection.waitForClosingStreamTagFromServer()
    sleep(Duration.second)

    connection.createStanzaCollector(StanzaFilter0())

    connection.addMessageInterceptor(HashableConsumer {_ => ()}, LambdaPredicate {_ => true})
    connection.addPresenceInterceptor(HashableConsumer {_ => ()}, LambdaPredicate {_ => true})
    connection.connect()
    connection.login("1", "123456")

    @AssertThrows[IllegalArgumentException](connection.setReplyTimeout(Duration.millisecond*Int64.Max))
}

@Test
func conn4(): Unit {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write("<a/>".toArray())
    let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
    parser.next()

    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    // connection.parseAndProcessNonza(parser)
}

@Test
func conn5(): Unit {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write("<compressed xmlns='${Compress.NAMESPACE}'/>".toArray())
    let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
    parser.next()

    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    // connection.parseAndProcessNonza(parser)
}

public class Nonza0 <: Nonza {
    static init() {
        ELEMENT_MAPPING.add("Nonza0", "Nonza0")
        NAMESPACE_MAPPING.add("Nonza0", "Nonza0ns")
        QNAME_MAPPING.add("Nonza0", QName("Nonza0ns", "Nonza0"))
    }
    public override func getElementName(): String {
        return "Nonza0"
    }
    public override func getNamespace(): String {
        return "Nonza0ns"
    }
    public override func toXML(enclosingNamespace: ?XmlEnvironment): XmlStringBuilder {
        let xml: XmlStringBuilder = XmlStringBuilder(this, enclosingNamespace)
        xml.rightAngleBracket()
        xml.emptyElement("Nonza0")
        xml.closeElement(this)
        return xml
    }
}

public class NonzaProvider0 <: NonzaProvider<Nonza0> {
    init() {
        super("Nonza0")
    }
    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): Nonza0 {
        Nonza0()
    }
}

@Test
func conn6(): Unit {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write("<Nonza0 xmlns='Nonza0ns'/>".toArray())
    let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
    parser.next()

    ProviderManager.addNonzaProvider(NonzaProvider0())

    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    // connection.parseAndProcessNonza(parser)
}

class VersionRequestHandler <: AbstractIqRequestHandler {
    let latch = SyncCounter(1)
    init() {
        super("query", "jabber:iq:version", IQType.get, IQRequestHandlerMode.sync)
    }
    public func handleIQRequest(iqRequest: IQ): ?IQ {
        latch.dec()
        Version.createResultFor(iqRequest)
    }
}

public class Version <: IQ {
    public static let ELEMENT: String = QUERY_ELEMENT
    public static let NAMESPACE: String = "jabber:iq:version"
    private let name: String
    private let version: String
    private let os: String
    public Version(name: String, version: String, os: String) {
        super(ELEMENT, NAMESPACE)
        this.name = name
        this.version = version
        this.os = os
        this.setType(IQType.result)
    }

    protected func getIQChildElementBuilder(xml: IQChildElementXmlStringBuilder): ?IQChildElementXmlStringBuilder {
        xml.rightAngleBracket()
        xml.element("name", name)
        xml.element("version", version)
        xml.element("os", os)
        return xml
    }

    public static func createResultFor(request: Stanza): Version {
        let result = Version("xmpp4cj", "0.0.1", "linux")
        result.setStanzaId(request.getStanzaId())
        result.setTo(request.getFrom())
        return result
    }
}

@Test
func conn7(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .build()
    let connection = XMPPTCPConnection(config)

    let handler = VersionRequestHandler()
    connection.registerIQRequestHandler(handler)

    connection.connect()
    connection.login()

    handler.latch.waitUntilZero(timeout: Duration.second * 5)
}

class VerListener <: StanzaListener {
    let counter = SyncCounter(1)
    public override func processStanza(packet: Stanza): Unit {
        match (packet) {
            case iq: IQ where iq.getType() == IQType.get => counter.dec()
            case _ => ()
        }
    }
}

@Test
func conn8(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .build()
    let connection = XMPPTCPConnection(config)

    connection.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.doNotReply)
    let ver = VerListener()
    connection.addSyncStanzaListener(ver, StanzaTypeFilter<Stanza>("Stanza"))

    connection.connect()
    connection.login()

    ver.counter.waitUntilZero(timeout: Duration.second * 5)
}

@Test
func conn9(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .build()
    let connection = XMPPTCPConnection(config)

    connection.setUnknownIqRequestReplyMode(XmppConfigurationUnknownIqRequestReplyMode.replyServiceUnavailable)
    let ver = VerListener()
    connection.addSyncStanzaListener(ver, StanzaTypeFilter<Stanza>("Stanza"))

    connection.connect()
    connection.login()

    ver.counter.waitUntilZero(timeout: Duration.second * 5)
}

@Test
func conn10(): Unit {
    let obj = HashableConsumer<Int> {_ => ()}
    obj.accept(0)
}

@Test
func conn11(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)

    @AssertThrows[IllegalArgumentException](connection.setMaxAsyncOperations(0))

    if (true) {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write("<a xmlns='jabber:client' id='123' from='from@sss'>sdf</a>".toArray())
        let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
        parser.next()

        // connection.onStreamOpen(parser)
    }

    if (true) {
        let byteArrayStream: ByteBuffer = ByteBuffer()
        byteArrayStream.write("<a xmlns='jabber:client' id='123' from='123@'>sdf</a>".toArray())
        let parser = StaxXmlPullParserFactory().newXmlPullParser(byteArrayStream)
        parser.next()

        // connection.onStreamOpen(parser)
    }
}

@Test
func conn12(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)
    let connection2 = XMPPTCPConnection(config)

    @Assert(connection!=connection2)
}

@Test
public func test_ConnectionConfiguration1(): Unit {
    let connectionConfigurationSecurityMode1 = ConnectionConfigurationSecurityMode.required
    let connectionConfigurationSecurityMode2 = ConnectionConfigurationSecurityMode.ifpossible
    let connectionConfigurationSecurityMode3 = ConnectionConfigurationSecurityMode.disabled
    @Assert(true, connectionConfigurationSecurityMode1 == connectionConfigurationSecurityMode1)
    @Assert(true, connectionConfigurationSecurityMode2 == connectionConfigurationSecurityMode2)
    @Assert(true, connectionConfigurationSecurityMode3 == connectionConfigurationSecurityMode3)
    @Assert("required", connectionConfigurationSecurityMode1.toString())
    @Assert("ifpossible", connectionConfigurationSecurityMode2.toString())
    @Assert("disabled", connectionConfigurationSecurityMode3.toString())
    @Assert(false, connectionConfigurationSecurityMode1 == connectionConfigurationSecurityMode3)
}

class SASLMechanismExternal <: SASLMechanism {
    protected func authenticateInternal(cbh: ?CallbackHandler): Unit {
        throw Exception()
    }
    protected func getAuthenticationText(): ?Array<Byte> {
        throw Exception()
    }
    public func getName(): String {
        return SASLMechanism.EXTERNAL
    }
    public func getPriority(): Int {
        return 0
    }
    protected func checkIfSuccessfulOrThrow(): Unit {
    }
    protected func newInstance(): SASLMechanism {
        throw Exception()
    }
}

@Test
public func test2(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    config.getTlsClientConfig()
    config.getEnabledSaslMechanisms()
    XmppConfiguration.DEBUG = true
    let c1 = XMPPTCPConnectionConfiguration.builder()
    c1.setCallbackHandler({a => ()})
    c1.setTlsClientConfig(TlsClientConfig())
    c1.setSocketFactory(SocketFactory.DEFAULT)
    @AssertThrows[IllegalArgumentException](c1.performSaslExternalAuthentication(TlsClientConfig()))

    let mechanism = SASLMechanismExternal()
    SASLAuthentication.registerSASLMechanism(mechanism)
    c1.performSaslExternalAuthentication(TlsClientConfig())
}

@Test
public func t02(): Unit {
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder.setXmppDomain("asd").build()
    let connection = XMPPTCPConnection(config)
    let d = ConsoleDebuggerFactory.INSTANCE.create(connection)
    AbstractDebugger.printInterpreted = true
    d.onIncomingStreamElement(Compressed())
    // d.authenticated(connection,true)
    // d.connectionClosedOnError(Exception())
}

class NonzaErr <: Nonza {
    public func getNamespace(): String {
        throw Exception("1.1")
    }
    public func getElementName(): String {
        throw Exception("1.2")
    }
    public func toXML(xmlEnvironment: ?XmlEnvironment): CharSequence {
        throw Exception("1.3")
    }
}

@Test
public func t12(): Unit {
    ReconnectionManager.setEnabledPerDefault(true)
    let configBuilder = XMPPTCPConnectionConfiguration.builder()
    let config = configBuilder
        .setXmppDomain(XmppTestServerHostName)
        .performSaslAnonymousAuthentication()
        .enableDefaultDebugger()
        .setTlsClientConfig(TLS_TRUST_ALL)
        .build()
    let connection = XMPPTCPConnection(config)

    connection.connect()
    connection.login()
    connection.disconnect(None)
    connection.connect()
    connection.sendNonza(NonzaErr())
    for (_ in 0..10) {
        sleep(Duration.millisecond * 500)
        if (connection.isConnected()) {
            break
        }
    }
    println(connection.isConnected())
    // let d = ConsoleDebuggerFactory.INSTANCE.create(connection)
    // d.connected(connection)
    // d.authenticated(connection,true)
    // d.connectionClosedOnError(Exception())
}

@Test
public func test_Xmpp4cjException1(): Unit {
    let xmpp4cjException0: TestXmpp4cjException = TestXmpp4cjException(TestXmpp4cjException())
    @Assert("Xmpp4cjException", xmpp4cjException0.toString())

    let xmpp4cjException1: TestXmpp4cjException = TestXmpp4cjException("ERROR")
    @Assert("Xmpp4cjException: ERROR", xmpp4cjException1.toString())

    let xmpp4cjException2: TestXmpp4cjException = TestXmpp4cjException("ERROR", TestXmpp4cjException())
    @Assert("Xmpp4cjException: ERROR", xmpp4cjException2.toString())

    let xmpp4cjException3: TestXmpp4cjException = TestXmpp4cjException()
    @Assert("Xmpp4cjException", xmpp4cjException3.toString())
}

class TestXmpp4cjException <: Xmpp4cjException {
    init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }

    init(message: String) {
        super(message)
    }

    init(message: String, wrappedThrowable: ?Exception) {
        super(message, wrappedThrowable)
    }

    init() {
        super()
    }
}

@Test
public func test_NotLoggedInException1(): Unit {
    let notLoggedInException: NotLoggedInException = NotLoggedInException()
    @Assert("NotLoggedInException: Client is not logged in", notLoggedInException.toString())
}

@Test
public func test_AlreadyLoggedInException1(): Unit {
    let alreadyLoggedInException: AlreadyLoggedInException = AlreadyLoggedInException()
    @Assert("AlreadyLoggedInException: Client is already logged in", alreadyLoggedInException.toString())
}

@Test
public func test_AlreadyConnectedException1(): Unit {
    let alreadyConnectedException: AlreadyConnectedException = AlreadyConnectedException()
    @Assert("AlreadyConnectedException: Client is already connected", alreadyConnectedException.toString())
}

@Test
public func test_IllegalStateChangeException1(): Unit {
    let illegalStateChangeException: IllegalStateChangeException = IllegalStateChangeException()
    @Assert("IllegalStateChangeException", illegalStateChangeException.toString())
}

@Test
public func test_SecurityRequiredException1(): Unit {
    let securityRequiredException: TestSecurityRequiredException = TestSecurityRequiredException("ERROR")
    @Assert("SecurityRequiredException: ERROR", securityRequiredException.toString())
}

class TestSecurityRequiredException <: SecurityRequiredException {
    init(message: String) {
        super(message)
    }
}

@Test
public func test_SecurityRequiredByClientException1(): Unit {
    let securityRequiredByClientException: SecurityRequiredByClientException = SecurityRequiredByClientException()
    @Assert("SecurityRequiredByClientException: SSL/TLS required by client but not supported by server", securityRequiredByClientException.toString())
}

@Test
public func test_SecurityRequiredByServerException1(): Unit {
    let securityRequiredByServerException: SecurityRequiredByServerException = SecurityRequiredByServerException()
    @Assert("SecurityRequiredByServerException: SSL/TLS required by server but disabled in client", securityRequiredByServerException.toString())
}

@Test
public func test_SecurityNotPossibleException1(): Unit {
    let securityNotPossibleException: SecurityNotPossibleException = SecurityNotPossibleException("ERROR")
    @Assert("SecurityNotPossibleException: ERROR", securityNotPossibleException.toString())
}

@Test
public func test_ConnectionException1(): Unit {
    let connectionException0: TestConnectionException = TestConnectionException(TestConnectionException("ERROR"))
    @Assert("ConnectionException: ERROR", connectionException0.toString())
    let connectionException1: TestConnectionException = TestConnectionException("ERROR")
    @Assert("ConnectionException: ERROR", connectionException1.toString())
}

class TestConnectionException <: ConnectionException {
    init(wrappedThrowable: Exception) {
        super(wrappedThrowable)
    }

    init(message: String) {
        super(message)
    }
}

@Test
public func test_GenericConnectionException1(): Unit {
    let genericConnectionException: GenericConnectionException = GenericConnectionException(
        SecurityNotPossibleException("ERROR"))
    @Assert("GenericConnectionException: ERROR", genericConnectionException.toString())
}

@Test
public func test_EndpointConnectionException1(): Unit {
    let e0 = EndpointConnectionException.comefrom(
        ArrayList<RemoteConnectionEndpointLookupFailure>(),
        ArrayList<RemoteConnectionException<RemoteConnectionEndpoint>>()
    )
}

@Test
public func test_FeatureNotSupportedException1(): Unit {
    let featureNotSupportedException0: FeatureNotSupportedException = FeatureNotSupportedException("ERROR")
    @Assert("FeatureNotSupportedException: ERROR not supported", featureNotSupportedException0.toString())
    @Assert("ERROR", featureNotSupportedException0.getFeature())
    @Assert(None, featureNotSupportedException0.getJid())
    let featureNotSupportedException1: FeatureNotSupportedException = FeatureNotSupportedException("ERROR", None)
    @Assert("FeatureNotSupportedException: ERROR not supported", featureNotSupportedException1.toString())
    @Assert("ERROR", featureNotSupportedException1.getFeature())
    @Assert(None, featureNotSupportedException1.getJid())
    let domain = "foo.bar."
    let jid = JidCreate.domainBareFrom(domain)
    let featureNotSupportedException2: FeatureNotSupportedException = FeatureNotSupportedException("ERROR", jid)
    @Assert("ERROR", featureNotSupportedException2.getFeature())
    @Assert("foo.bar.", featureNotSupportedException2.getJid().getOrThrow().toString())
}

@Test
public func test_ResourceBindingNotOfferedException1(): Unit {
    let resourceBindingNotOfferedException: ResourceBindingNotOfferedException = ResourceBindingNotOfferedException()
    @Assert("ResourceBindingNotOfferedException: Resource binding was not offered by server", resourceBindingNotOfferedException.toString())
}

@Test
public func test_XmppWrappedException1(): Unit {
    let xmppWrappedException0: XmppWrappedException = XmppWrappedException(FeatureNotSupportedException("ERROR"))
    @Assert("XmppWrappedException: ERROR not supported", xmppWrappedException0.toString())
    let xmppWrappedException1: XmppWrappedException = XmppWrappedException("ERROR",
        FeatureNotSupportedException("ERROR"))
    @Assert("XmppWrappedException: ERROR", xmppWrappedException1.toString())
}

@Test
public func test_XmppMessageException1(): Unit {
    let xmppMessageException: XmppMessageException = XmppMessageException("ERROR")
    @Assert("XmppMessageException: ERROR", xmppMessageException.toString())
}

@Test
public func test_XmppSaslException1(): Unit {
    let xmppSaslException0: XmppSaslException = XmppSaslException(XmppMessageException("ERROR"))
    @Assert("XmppSaslException: ERROR", xmppSaslException0.toString())
    let xmppSaslException1: XmppSaslException = XmppSaslException("ERROR", XmppMessageException("ERROR"))
    @Assert("XmppSaslException: ERROR", xmppSaslException1.toString())
    @Assert("XmppMessageException: ERROR", xmppSaslException1.getCause().getOrThrow().toString())
    let xmppSaslException2: XmppSaslException = XmppSaslException("ERROR")
    @Assert("XmppSaslException: ERROR", xmppSaslException2.toString())
}

@Test
public func test_XmppCertificateException1(): Unit {
    let certificateException: CertificateException = CertificateException("CertificateException")
    let xmppCertificateException: XmppCertificateException = XmppCertificateException(certificateException)
    @Assert("XmppCertificateException", xmppCertificateException.toString())
}

@Test
public func test_XMPPException1(): Unit {
    let xmppException0: TestXMPPException = TestXMPPException()
    @Assert("XMPPException", xmppException0.toString())
    @Assert("", xmppException0.getMessage())
    let xmppException1: TestXMPPException = TestXMPPException("ERROR")
    @Assert("XMPPException: ERROR", xmppException1.toString())
    @Assert("ERROR", xmppException1.getMessage())
    let xmppException2: TestXMPPException = TestXMPPException("ERROR", TestXMPPException())
    @Assert("XMPPException: ERROR", xmppException2.toString())
    @Assert("ERROR", xmppException2.getMessage())
}

class TestXMPPException <: XMPPException {
    init() {
        super()
    }

    init(message: String) {
        super(message)
    }

    init(message: String, wrappedThrowable: ?Exception) {
        super(message, wrappedThrowable)
    }
}

@Test
public func test_XMPPErrorException1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let error: StanzaError = StanzaError.getBuilder().setCondition(StanzaErrorCondition.bad_request).build()
    let xmppErrorException0: XMPPErrorException = XMPPErrorException(packet, error)
    @Assert(None, xmppErrorException0.getStanzaError().getErrorGenerator())
    match (xmppErrorException0.getStanza()) {
        case None => @Assert(false)
        case _ => @Assert(true)
    }
    match (xmppErrorException0.getRequest()) {
        case None => @Assert(true)
        case _ => @Assert(false)
    }
    @Assert("XMPPError: bad-request - modify", xmppErrorException0.getMessage())
    @Assert("XMPPErrorException", xmppErrorException0.toString())
    XMPPErrorException.ifHasErrorThenThrow(packet)

    let xmppErrorException1: XMPPErrorException = XMPPErrorException(packet, error, packet)
    @Assert("XMPPError: bad-request - modify as result of the following request: Message Stanza []", xmppErrorException1.getMessage())
    @Assert("XMPPErrorException", xmppErrorException1.toString())

    XMPPErrorException.ifHasErrorThenThrow(packet, packet)
}

@Test
public func test_FailedNonzaException1(): Unit {
    let failedNonzaException0: FailedNonzaException = FailedNonzaException(Compress("Compress"))
    @Assert("FailedNonzaException", failedNonzaException0.toString())
    @Assert(None, failedNonzaException0.getCondition())
    @Assert("compress", failedNonzaException0.getNonza().getElementName())
    let failedNonzaException1: FailedNonzaException = FailedNonzaException(Compress("Compress"), None)
    @Assert("FailedNonzaException", failedNonzaException1.toString())
    @Assert(None, failedNonzaException1.getCondition())
    @Assert("compress", failedNonzaException1.getNonza().getElementName())
}

@Test
public func test_StreamErrorException1(): Unit {
    let streamErrorException: StreamErrorException = StreamErrorException(
        StreamError(None, None, None, ArrayList<ExtensionElement>()))
    @Assert("StreamErrorException: None You can read more about the meaning of this stream error at http://xmpp.org/rfcs/rfc6120.html#streams-error-conditions\n<stream:error><None xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error>", streamErrorException.toString())
    @Assert("<stream:error><None xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error>", streamErrorException.getStreamError().toString())
}

let BASE_JID1: Jid = JidCreate.entityBareFrom("one@exampleOne.org")
let FULL_JID1_R1: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceOne")
let FULL_JID1_R2: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceTwo")
let BASE_JID2: Jid = JidCreate.entityBareFrom("one@exampleTwo.org")
let FULL_JID2: Jid = JidCreate.entityFullFrom("two@exampleTwo.org/resourceOne")
let BASE_JID3: Jid = JidCreate.entityBareFrom("dummy@example.org")
let SERVICE_JID1: Jid = JidCreate.domainBareFrom("muc.example.org")
let SERVICE_JID2: Jid = JidCreate.domainBareFrom("pubsub.example.org")

@Test
public func test_AbstractExactJidTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()

    let abstractExactJidTypeFilter0: TestAbstractExactJidTypeFilter = TestAbstractExactJidTypeFilter(
        AbstractJidTypeFilterJidType.entityFull)
    @Assert(false, abstractExactJidTypeFilter0.accept(packet))
    @Assert("AbstractExactJidTypeFilter: entityFull", abstractExactJidTypeFilter0.toString())

    let abstractExactJidTypeFilter1: TestAbstractExactJidTypeFilter = TestAbstractExactJidTypeFilter(
        AbstractJidTypeFilterJidType.entityBare)
    @Assert("AbstractExactJidTypeFilter: entityBare", abstractExactJidTypeFilter1.toString())
    @Assert(false, abstractExactJidTypeFilter1.accept(packet))

    let abstractExactJidTypeFilter2: TestAbstractExactJidTypeFilter = TestAbstractExactJidTypeFilter(
        AbstractJidTypeFilterJidType.domainFull)
    @Assert("AbstractExactJidTypeFilter: domainFull", abstractExactJidTypeFilter2.toString())
    @Assert(false, abstractExactJidTypeFilter2.accept(packet))

    let abstractExactJidTypeFilter3: TestAbstractExactJidTypeFilter = TestAbstractExactJidTypeFilter(
        AbstractJidTypeFilterJidType.domainBare)
    @Assert("AbstractExactJidTypeFilter: domainBare", abstractExactJidTypeFilter3.toString())
    @Assert(false, abstractExactJidTypeFilter3.accept(packet))

    let abstractExactJidTypeFilter4: TestAbstractExactJidTypeFilter = TestAbstractExactJidTypeFilter(
        AbstractJidTypeFilterJidType.any)
    @Assert("AbstractExactJidTypeFilter: any", abstractExactJidTypeFilter4.toString())
    @Assert(false, abstractExactJidTypeFilter4.accept(packet))

    let abstractExactJidTypeFilter5: TestAbstractExactJidTypeFilter1 = TestAbstractExactJidTypeFilter1(
        AbstractJidTypeFilterJidType.entityFull)
    @Assert(false, abstractExactJidTypeFilter5.accept(packet))
    @Assert("AbstractExactJidTypeFilter: entityFull", abstractExactJidTypeFilter5.toString())

    let abstractExactJidTypeFilter6: TestAbstractExactJidTypeFilter1 = TestAbstractExactJidTypeFilter1(
        AbstractJidTypeFilterJidType.entityBare)
    @Assert("AbstractExactJidTypeFilter: entityBare", abstractExactJidTypeFilter6.toString())
    @Assert(true, abstractExactJidTypeFilter6.accept(packet))

    let abstractExactJidTypeFilter7: TestAbstractExactJidTypeFilter1 = TestAbstractExactJidTypeFilter1(
        AbstractJidTypeFilterJidType.domainFull)
    @Assert("AbstractExactJidTypeFilter: domainFull", abstractExactJidTypeFilter7.toString())
    @Assert(false, abstractExactJidTypeFilter7.accept(packet))

    let abstractExactJidTypeFilter8: TestAbstractExactJidTypeFilter1 = TestAbstractExactJidTypeFilter1(
        AbstractJidTypeFilterJidType.domainBare)
    @Assert("AbstractExactJidTypeFilter: domainBare", abstractExactJidTypeFilter8.toString())
    @Assert(false, abstractExactJidTypeFilter8.accept(packet))

    let abstractExactJidTypeFilter9: TestAbstractExactJidTypeFilter1 = TestAbstractExactJidTypeFilter1(
        AbstractJidTypeFilterJidType.any)
    @Assert("AbstractExactJidTypeFilter: any", abstractExactJidTypeFilter9.toString())
    @Assert(true, abstractExactJidTypeFilter9.accept(packet))
}

class TestAbstractExactJidTypeFilter <: AbstractExactJidTypeFilter {
    init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return stanza.getFrom()
    }
}

class TestAbstractExactJidTypeFilter1 <: AbstractExactJidTypeFilter {
    init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return BASE_JID1
    }
}

@Test
public func test_AbstractFromToMatchesFilter1(): Unit {
    let abstractFromToMatchesFilter0: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(BASE_JID1, false
    )
    @Assert("AbstractFromToMatchesFilter (full): one@exampleone.org", abstractFromToMatchesFilter0.toString())

    let abstractFromToMatchesFilter1: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(FULL_JID1_R1,
        false)
    @Assert("AbstractFromToMatchesFilter (full): one@exampleone.org/resourceOne", abstractFromToMatchesFilter1.toString())

    let abstractFromToMatchesFilter2: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(FULL_JID1_R2,
        false)
    @Assert("AbstractFromToMatchesFilter (full): one@exampleone.org/resourceTwo", abstractFromToMatchesFilter2.toString())

    let abstractFromToMatchesFilter3: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(BASE_JID2, false
    )
    @Assert("AbstractFromToMatchesFilter (full): one@exampletwo.org", abstractFromToMatchesFilter3.toString())

    let abstractFromToMatchesFilter4: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(FULL_JID2, false
    )
    @Assert("AbstractFromToMatchesFilter (full): two@exampletwo.org/resourceOne", abstractFromToMatchesFilter4.toString())

    let abstractFromToMatchesFilter5: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(BASE_JID3, false
    )
    @Assert("AbstractFromToMatchesFilter (full): dummy@example.org", abstractFromToMatchesFilter5.toString())

    let abstractFromToMatchesFilter6: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(SERVICE_JID1,
        false)
    @Assert("AbstractFromToMatchesFilter (full): muc.example.org", abstractFromToMatchesFilter6.toString())

    let abstractFromToMatchesFilter7: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(SERVICE_JID2,
        false)
    @Assert("AbstractFromToMatchesFilter (full): pubsub.example.org", abstractFromToMatchesFilter7.toString())

    let abstractFromToMatchesFilter8: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(BASE_JID1, true)
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): one@exampleone.org", abstractFromToMatchesFilter8.toString())

    let abstractFromToMatchesFilter9: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(FULL_JID1_R1,
        true)
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): one@exampleone.org", abstractFromToMatchesFilter9.toString())

    let abstractFromToMatchesFilter10: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(FULL_JID1_R2,
        true)
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): one@exampleone.org", abstractFromToMatchesFilter10.toString())

    let abstractFromToMatchesFilter11: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(BASE_JID2, true
    )
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): one@exampletwo.org", abstractFromToMatchesFilter11.toString())

    let abstractFromToMatchesFilter12: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(FULL_JID2, true
    )
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): two@exampletwo.org", abstractFromToMatchesFilter12.toString())

    let abstractFromToMatchesFilter13: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(BASE_JID3, true
    )
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): dummy@example.org", abstractFromToMatchesFilter13.toString())

    let abstractFromToMatchesFilter14: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(SERVICE_JID1,
        true)
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): muc.example.org", abstractFromToMatchesFilter14.toString())

    let abstractFromToMatchesFilter15: TestAbstractFromToMatchesFilter = TestAbstractFromToMatchesFilter(SERVICE_JID2,
        true)
    @Assert("AbstractFromToMatchesFilter (ignoreResourcepart): pubsub.example.org", abstractFromToMatchesFilter15.toString())
}

class TestAbstractFromToMatchesFilter <: AbstractFromToMatchesFilter {
    protected init(address: ?Jid, ignoreResourcepart: Bool) {
        super(address, ignoreResourcepart)
    }

    protected override func getAddressToCompare(stanza: Stanza): ?Jid {
        return stanza.getFrom()
    }
}

@Test
public func test_AbstractJidTypeFilter1(): Unit {
    let abstractJidTypeFilter0: TestAbstractJidTypeFilter = TestAbstractJidTypeFilter(
        AbstractJidTypeFilterJidType.entityFull)
    @Assert("AbstractJidTypeFilter: entityFull", abstractJidTypeFilter0.toString())

    let abstractJidTypeFilter1: TestAbstractJidTypeFilter = TestAbstractJidTypeFilter(
        AbstractJidTypeFilterJidType.entityBare)
    @Assert("AbstractJidTypeFilter: entityBare", abstractJidTypeFilter1.toString())

    let abstractJidTypeFilter2: TestAbstractJidTypeFilter = TestAbstractJidTypeFilter(
        AbstractJidTypeFilterJidType.domainFull)
    @Assert("AbstractJidTypeFilter: domainFull", abstractJidTypeFilter2.toString())

    let abstractJidTypeFilter3: TestAbstractJidTypeFilter = TestAbstractJidTypeFilter(
        AbstractJidTypeFilterJidType.domainBare)
    @Assert("AbstractJidTypeFilter: domainBare", abstractJidTypeFilter3.toString())

    let abstractJidTypeFilter4: TestAbstractJidTypeFilter = TestAbstractJidTypeFilter(AbstractJidTypeFilterJidType.any)
    @Assert("AbstractJidTypeFilter: any", abstractJidTypeFilter4.toString())
}

class TestAbstractJidTypeFilter <: AbstractJidTypeFilter {
    protected init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return stanza.getFrom()
    }

    public override func accept(stanza: Stanza): Bool {
        let jid: ?Jid = getJidToInspect(stanza)
        if (let Some(v) <- jid) {
            match (jidType) {
                case Some(AbstractJidTypeFilterJidType.entityFull) => return v.isEntityFullJid()
                case Some(AbstractJidTypeFilterJidType.entityBare) => return v.isEntityBareJid()
                case Some(AbstractJidTypeFilterJidType.domainFull) => return v.isDomainFullJid()
                case Some(AbstractJidTypeFilterJidType.domainBare) => return v.isDomainBareJid()
                case Some(AbstractJidTypeFilterJidType.any) => return true
                case _ => return false
            }
        } else {
            return false
        }
    }
}

@Test
public func test_AbstractJidTypeFilterJidType1(): Unit {
    let abstractJidTypeFilterJidType0: AbstractJidTypeFilterJidType = AbstractJidTypeFilterJidType.entityFull
    let abstractJidTypeFilterJidType1: AbstractJidTypeFilterJidType = AbstractJidTypeFilterJidType.entityBare
    let abstractJidTypeFilterJidType2: AbstractJidTypeFilterJidType = AbstractJidTypeFilterJidType.domainFull
    let abstractJidTypeFilterJidType3: AbstractJidTypeFilterJidType = AbstractJidTypeFilterJidType.domainBare
    let abstractJidTypeFilterJidType4: AbstractJidTypeFilterJidType = AbstractJidTypeFilterJidType.any
    @Assert(true, abstractJidTypeFilterJidType0 == abstractJidTypeFilterJidType0)
    @Assert(true, abstractJidTypeFilterJidType1 == abstractJidTypeFilterJidType1)
    @Assert(true, abstractJidTypeFilterJidType2 == abstractJidTypeFilterJidType2)
    @Assert(true, abstractJidTypeFilterJidType3 == abstractJidTypeFilterJidType3)
    @Assert(true, abstractJidTypeFilterJidType4 == abstractJidTypeFilterJidType4)
    @Assert(false, abstractJidTypeFilterJidType1 == abstractJidTypeFilterJidType4)
    @Assert("entityFull", abstractJidTypeFilterJidType0.toString())
    @Assert("entityBare", abstractJidTypeFilterJidType1.toString())
    @Assert("domainFull", abstractJidTypeFilterJidType2.toString())
    @Assert("domainBare", abstractJidTypeFilterJidType3.toString())
    @Assert("any", abstractJidTypeFilterJidType4.toString())
}

@Test
public func test_AbstractListFilter1(): Unit {
    let abstractListFilter0: TestAbstractListFilter = TestAbstractListFilter()
    @Assert("AbstractListFilter: ()", abstractListFilter0.toString())
}

class TestAbstractListFilter <: AbstractListFilter {
    init() {
        super()
    }

    public override func accept(stanza: Stanza): Bool {
        return false
    }
}

@Test
public func test_AbstractPossibleJidTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()

    let abstractPossibleJidTypeFilter0: TestAbstractPossibleJidTypeFilter = TestAbstractPossibleJidTypeFilter(
        AbstractJidTypeFilterJidType.entityFull)
    @Assert(false, abstractPossibleJidTypeFilter0.accept(packet))
    @Assert("AbstractPossibleJidTypeFilter: entityFull", abstractPossibleJidTypeFilter0.toString())

    let abstractPossibleJidTypeFilter1: TestAbstractPossibleJidTypeFilter = TestAbstractPossibleJidTypeFilter(
        AbstractJidTypeFilterJidType.entityBare)
    @Assert("AbstractPossibleJidTypeFilter: entityBare", abstractPossibleJidTypeFilter1.toString())
    @Assert(false, abstractPossibleJidTypeFilter1.accept(packet))

    let abstractPossibleJidTypeFilter2: TestAbstractPossibleJidTypeFilter = TestAbstractPossibleJidTypeFilter(
        AbstractJidTypeFilterJidType.domainFull)
    @Assert("AbstractPossibleJidTypeFilter: domainFull", abstractPossibleJidTypeFilter2.toString())
    @Assert(false, abstractPossibleJidTypeFilter2.accept(packet))

    let abstractPossibleJidTypeFilter3: TestAbstractPossibleJidTypeFilter = TestAbstractPossibleJidTypeFilter(
        AbstractJidTypeFilterJidType.domainBare)
    @Assert("AbstractPossibleJidTypeFilter: domainBare", abstractPossibleJidTypeFilter3.toString())
    @Assert(false, abstractPossibleJidTypeFilter3.accept(packet))

    let abstractPossibleJidTypeFilter4: TestAbstractPossibleJidTypeFilter = TestAbstractPossibleJidTypeFilter(
        AbstractJidTypeFilterJidType.any)
    @Assert("AbstractPossibleJidTypeFilter: any", abstractPossibleJidTypeFilter4.toString())
    @Assert(false, abstractPossibleJidTypeFilter4.accept(packet))

    let abstractPossibleJidTypeFilter5: TestAbstractPossibleJidTypeFilter1 = TestAbstractPossibleJidTypeFilter1(
        AbstractJidTypeFilterJidType.entityFull)
    @Assert(false, abstractPossibleJidTypeFilter5.accept(packet))
    @Assert("AbstractPossibleJidTypeFilter: entityFull", abstractPossibleJidTypeFilter5.toString())

    let abstractPossibleJidTypeFilter6: TestAbstractPossibleJidTypeFilter1 = TestAbstractPossibleJidTypeFilter1(
        AbstractJidTypeFilterJidType.entityBare)
    @Assert("AbstractPossibleJidTypeFilter: entityBare", abstractPossibleJidTypeFilter6.toString())
    @Assert(true, abstractPossibleJidTypeFilter6.accept(packet))

    let abstractPossibleJidTypeFilter7: TestAbstractPossibleJidTypeFilter1 = TestAbstractPossibleJidTypeFilter1(
        AbstractJidTypeFilterJidType.domainFull)
    @Assert("AbstractPossibleJidTypeFilter: domainFull", abstractPossibleJidTypeFilter7.toString())
    @Assert(false, abstractPossibleJidTypeFilter7.accept(packet))

    let abstractPossibleJidTypeFilter8: TestAbstractPossibleJidTypeFilter1 = TestAbstractPossibleJidTypeFilter1(
        AbstractJidTypeFilterJidType.domainBare)
    @Assert("AbstractPossibleJidTypeFilter: domainBare", abstractPossibleJidTypeFilter8.toString())
    @Assert(true, abstractPossibleJidTypeFilter8.accept(packet))

    let abstractPossibleJidTypeFilter9: TestAbstractPossibleJidTypeFilter1 = TestAbstractPossibleJidTypeFilter1(
        AbstractJidTypeFilterJidType.any)
    @Assert("AbstractPossibleJidTypeFilter: any", abstractPossibleJidTypeFilter9.toString())
    @Assert(true, abstractPossibleJidTypeFilter9.accept(packet))
}

class TestAbstractPossibleJidTypeFilter <: AbstractPossibleJidTypeFilter {
    protected init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return stanza.getFrom()
    }
}

class TestAbstractPossibleJidTypeFilter1 <: AbstractPossibleJidTypeFilter {
    protected init(jidType: AbstractJidTypeFilterJidType) {
        super(jidType)
    }

    protected override func getJidToInspect(stanza: Stanza): ?Jid {
        return BASE_JID1
    }
}

@Test
public func test_AndFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let arr: ArrayList<StanzaFilter> = ArrayList<StanzaFilter>()
    let andFilter0: AndFilter = AndFilter()
    @Assert(true, andFilter0.accept(packet))
    let andFilter1: AndFilter = AndFilter(arr)
    @Assert(true, andFilter1.accept(packet))
}

@Test
public func test_EmptyToMatcher1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let arr: ArrayList<StanzaFilter> = ArrayList<StanzaFilter>()
    let emptyToMatcher0: EmptyToMatcher = EmptyToMatcher.INSTANCE
    @Assert("EmptyToMatcher", emptyToMatcher0.toString())
    @Assert(true, emptyToMatcher0.accept(packet))
}

@Test
public func test_FlexibleStanzaTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let flexibleStanzaTypeFilter0: TestFlexibleStanzaTypeFilter = TestFlexibleStanzaTypeFilter()
    @Assert("FlexibleStanzaTypeFilter: Stanza", flexibleStanzaTypeFilter0.toString())
    @Assert(false, flexibleStanzaTypeFilter0.accept(packet))
}

public class TestFlexibleStanzaTypeFilter <: FlexibleStanzaTypeFilter<IQ> {
    protected init() {
        super()
    }

    protected init(iqType: IQType) {
        super("IQ")
    }

    protected override func acceptSpecific(iq: IQ): Bool {
        return false
    }
}

@Test
public func test_FromJidTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let fromJidTypeFilter0: FromJidTypeFilter = FromJidTypeFilter.ENTITY_BARE_JID
    @Assert("FromJidTypeFilter: EntityBareJid", fromJidTypeFilter0.toString())
    @Assert(false, fromJidTypeFilter0.accept(packet))
}

@Test
public func test_FromMatchesFilter1(): Unit {
    let filter0: FromMatchesFilter = FromMatchesFilter.create(FULL_JID1_R1)
    @Assert("FromMatchesFilter (full): one@exampleone.org/resourceOne", filter0.toString())
    let filter1: FromMatchesFilter = FromMatchesFilter.createBare(FULL_JID1_R1)
    @Assert("FromMatchesFilter (ignoreResourcepart): one@exampleone.org", filter1.toString())
}

@Test
public func test_FromTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let fromTypeFilter0: FromTypeFilter = FromTypeFilter.ENTITY_FULL_JID
    @Assert("FromTypeFilter: entityFull", fromTypeFilter0.toString())
    // @Assert(true, fromTypeFilter0.getJidToInspect(packet).isNone())

    let fromTypeFilter1: FromTypeFilter = FromTypeFilter.ENTITY_BARE_JID
    @Assert("FromTypeFilter: entityBare", fromTypeFilter1.toString())
    // @Assert(true, fromTypeFilter1.getJidToInspect(packet).isNone())

    let fromTypeFilter2: FromTypeFilter = FromTypeFilter.DOMAIN_FULL_JID
    @Assert("FromTypeFilter: domainFull", fromTypeFilter2.toString())
    // @Assert(true, fromTypeFilter2.getJidToInspect(packet).isNone())

    let fromTypeFilter3: FromTypeFilter = FromTypeFilter.DOMAIN_BARE_JID
    @Assert("FromTypeFilter: domainBare", fromTypeFilter3.toString())
    // @Assert(true, fromTypeFilter3.getJidToInspect(packet).isNone())

    let fromTypeFilter4: FromTypeFilter = FromTypeFilter.FROM_ANY_JID
    @Assert("FromTypeFilter: any", fromTypeFilter4.toString())
    // @Assert(true, fromTypeFilter4.getJidToInspect(packet).isNone())
}

@Test
public func test_IQReplyFilter1(): Unit {
    // let messageSubject: String = "This is a test of the emergency broadcast system."
    // let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    // let iqReplyFilter :IQReplyFilter  = IQReplyFilter(message, None, )
}

@Test
public func test_IQResultReplyFilter1(): Unit {
    // let IQResultReplyFilter :IQResultReplyFilter  =IQResultReplyFilter ()
}

@Test
public func test_IQTypeFilter1(): Unit {
    let FULL_JID_1_RESOURCE_1: EntityFullJid = JidCreate.entityFullFrom("one@exampleOne.org/resourceOne")
    let obj: Bind = Bind.newResult(FULL_JID_1_RESOURCE_1)
    let iqTypeFilter0: StanzaFilter = IQTypeFilter.GET
    @Assert("IQTypeFilter: type=get", iqTypeFilter0.toString())
    // @Assert(true, (iqTypeFilter0 as IQTypeFilter).getOrThrow().acceptSpecific(obj))
}

@Test
public func test_JidTypeAbstractJidTypeFilter1(): Unit {
    let jidTypeAbstractJidTypeFilter0: TestJidTypeAbstractJidTypeFilter = TestJidTypeAbstractJidTypeFilter(
        JidTypeAbstractJidTypeFilterJidType.BareJid)
    @Assert("JidTypeAbstractJidTypeFilter: BareJid", jidTypeAbstractJidTypeFilter0.toString())
}

class TestJidTypeAbstractJidTypeFilter <: JidTypeAbstractJidTypeFilter {
    protected init(jidType: JidTypeAbstractJidTypeFilterJidType) {
        super(jidType)
    }

    protected override func getJidToMatchFrom(stanza: Stanza): ?Jid {
        return None
    }
}

@Test
public func test_JidTypeAbstractJidTypeFilterJidType1(): Unit {
    let jidTypeAbstractJidTypeFilterJidType0: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .BareJid
    let jidTypeAbstractJidTypeFilterJidType1: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .DomainBareJid
    let jidTypeAbstractJidTypeFilterJidType2: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .DomainFullJid
    let jidTypeAbstractJidTypeFilterJidType3: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .DomainJid
    let jidTypeAbstractJidTypeFilterJidType4: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .EntityBareJid
    let jidTypeAbstractJidTypeFilterJidType5: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .EntityFullJid
    let jidTypeAbstractJidTypeFilterJidType6: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .EntityJid
    let jidTypeAbstractJidTypeFilterJidType7: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType
        .FullJid

    @Assert(true, jidTypeAbstractJidTypeFilterJidType0 == jidTypeAbstractJidTypeFilterJidType0)
    @Assert(true, jidTypeAbstractJidTypeFilterJidType1 == jidTypeAbstractJidTypeFilterJidType1)
    @Assert(true, jidTypeAbstractJidTypeFilterJidType2 == jidTypeAbstractJidTypeFilterJidType2)
    @Assert(true, jidTypeAbstractJidTypeFilterJidType3 == jidTypeAbstractJidTypeFilterJidType3)
    @Assert(true, jidTypeAbstractJidTypeFilterJidType4 == jidTypeAbstractJidTypeFilterJidType4)
    @Assert(true, jidTypeAbstractJidTypeFilterJidType5 == jidTypeAbstractJidTypeFilterJidType5)
    @Assert(true, jidTypeAbstractJidTypeFilterJidType6 == jidTypeAbstractJidTypeFilterJidType6)
    @Assert(true, jidTypeAbstractJidTypeFilterJidType7 == jidTypeAbstractJidTypeFilterJidType7)
    @Assert(false, jidTypeAbstractJidTypeFilterJidType1 == jidTypeAbstractJidTypeFilterJidType7)

    @Assert("BareJid", jidTypeAbstractJidTypeFilterJidType0.toString())
    @Assert("DomainBareJid", jidTypeAbstractJidTypeFilterJidType1.toString())
    @Assert("DomainFullJid", jidTypeAbstractJidTypeFilterJidType2.toString())
    @Assert("DomainJid", jidTypeAbstractJidTypeFilterJidType3.toString())
    @Assert("EntityBareJid", jidTypeAbstractJidTypeFilterJidType4.toString())
    @Assert("EntityFullJid", jidTypeAbstractJidTypeFilterJidType5.toString())
    @Assert("EntityJid", jidTypeAbstractJidTypeFilterJidType6.toString())
    @Assert("FullJid", jidTypeAbstractJidTypeFilterJidType7.toString())

    @Assert(true, jidTypeAbstractJidTypeFilterJidType0.isTypeOf(BASE_JID1))
    @Assert(false, jidTypeAbstractJidTypeFilterJidType1.isTypeOf(BASE_JID1))
    @Assert(false, jidTypeAbstractJidTypeFilterJidType2.isTypeOf(BASE_JID1))
    let e0: IllegalStateException = @AssertThrows[IllegalStateException](jidTypeAbstractJidTypeFilterJidType3.isTypeOf(BASE_JID1))
    @Assert("IllegalStateException", e0.toString())
    @Assert(true, jidTypeAbstractJidTypeFilterJidType4.isTypeOf(BASE_JID1))
    @Assert(false, jidTypeAbstractJidTypeFilterJidType5.isTypeOf(BASE_JID1))
    @Assert(true, jidTypeAbstractJidTypeFilterJidType6.isTypeOf(BASE_JID1))
    @Assert(false, jidTypeAbstractJidTypeFilterJidType7.isTypeOf(BASE_JID1))
}

@Test
public func test_MessageTypeFilter1(): Unit {
    let messageSubject: String = "This is a test of the emergency broadcast system."
    let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    let messageTypeFilter0: StanzaFilter = MessageTypeFilter.NORMAL
    @Assert("MessageTypeFilter: type=normal", messageTypeFilter0.toString())
    // @Assert(true, (messageTypeFilter0 as MessageTypeFilter).getOrThrow().acceptSpecific(message))
}

@Test
public func test_MessageWithBodiesFilter1(): Unit {
    let messageSubject: String = "This is a test of the emergency broadcast system."
    let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    let messageWithBodiesFilter0: StanzaFilter = MessageWithBodiesFilter.INSTANCE
    @Assert("MessageWithBodiesFilter", messageWithBodiesFilter0.toString())
    // @Assert(false, (messageWithBodiesFilter0 as MessageWithBodiesFilter).getOrThrow().acceptSpecific(message))
}

@Test
public func test_MessageWithSubjectFilter1(): Unit {
    let messageSubject: String = "This is a test of the emergency broadcast system."
    let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    let messageWithSubjectFilter0: StanzaFilter = MessageWithSubjectFilter.INSTANCE
    @Assert("MessageWithSubjectFilter", messageWithSubjectFilter0.toString())
    // @Assert(true, (messageWithSubjectFilter0 as MessageWithSubjectFilter).getOrThrow().acceptSpecific(message))
}

@Test
public func test_MessageWithThreadFilter1(): Unit {
    let messageSubject: String = "This is a test of the emergency broadcast system."
    let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    let messageWithThreadFilter0: StanzaFilter = MessageWithThreadFilter.INSTANCE
    @Assert("MessageWithThreadFilter", messageWithThreadFilter0.toString())
    // @Assert(false, (messageWithThreadFilter0 as MessageWithThreadFilter).getOrThrow().acceptSpecific(message))
}

@Test
public func test_NotFilter1(): Unit {
    let messageWithThreadFilter0: StanzaFilter = MessageWithThreadFilter.INSTANCE
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let notFilter0: NotFilter = NotFilter(messageWithThreadFilter0)
    @Assert("NotFilter", notFilter0.toString())
    @Assert(true, notFilter0.accept(packet))
}

@Test
public func test_OrFilter1(): Unit {
    let messageWithThreadFilter0: StanzaFilter = MessageWithThreadFilter.INSTANCE
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let orFilter0: OrFilter = OrFilter()
    @Assert("OrFilter: ()", orFilter0.toString())
    @Assert(false, orFilter0.accept(packet))
    let orFilter1: OrFilter = OrFilter(messageWithThreadFilter0)
    @Assert("OrFilter: (MessageWithThreadFilter)", orFilter1.toString())
    @Assert(false, orFilter1.accept(packet))
}

@Test
public func test_PossibleFromTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let possibleFromTypeFilter0: PossibleFromTypeFilter = PossibleFromTypeFilter.ENTITY_FULL_JID
    let possibleFromTypeFilter1: PossibleFromTypeFilter = PossibleFromTypeFilter.ENTITY_BARE_JID
    let possibleFromTypeFilter2: PossibleFromTypeFilter = PossibleFromTypeFilter.DOMAIN_FULL_JID
    let possibleFromTypeFilter3: PossibleFromTypeFilter = PossibleFromTypeFilter.DOMAIN_BARE_JID
    let possibleFromTypeFilter4: PossibleFromTypeFilter = PossibleFromTypeFilter.FROM_ANY_JID
    @Assert("PossibleFromTypeFilter: entityFull", possibleFromTypeFilter0.toString())
    // @Assert(true, possibleFromTypeFilter0.getJidToInspect(packet).isNone())
    @Assert("PossibleFromTypeFilter: entityBare", possibleFromTypeFilter1.toString())
    // @Assert(true, possibleFromTypeFilter1.getJidToInspect(packet).isNone())
    @Assert("PossibleFromTypeFilter: domainFull", possibleFromTypeFilter2.toString())
    // @Assert(true, possibleFromTypeFilter2.getJidToInspect(packet).isNone())
    @Assert("PossibleFromTypeFilter: domainBare", possibleFromTypeFilter3.toString())
    // @Assert(true, possibleFromTypeFilter3.getJidToInspect(packet).isNone())
    @Assert("PossibleFromTypeFilter: any", possibleFromTypeFilter4.toString())
    // @Assert(true, possibleFromTypeFilter4.getJidToInspect(packet).isNone())
}

@Test
public func test_PossibleToTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let possibleToTypeFilter0: PossibleToTypeFilter = PossibleToTypeFilter.ENTITY_FULL_JID
    let possibleToTypeFilter1: PossibleToTypeFilter = PossibleToTypeFilter.ENTITY_BARE_JID
    let possibleToTypeFilter2: PossibleToTypeFilter = PossibleToTypeFilter.DOMAIN_FULL_JID
    let possibleToTypeFilter3: PossibleToTypeFilter = PossibleToTypeFilter.DOMAIN_BARE_JID
    let possibleToTypeFilter4: PossibleToTypeFilter = PossibleToTypeFilter.TO_ANY_JID
    @Assert("PossibleToTypeFilter: entityFull", possibleToTypeFilter0.toString())
    // @Assert(true, possibleToTypeFilter0.getJidToInspect(packet).isNone())
    @Assert("PossibleToTypeFilter: entityBare", possibleToTypeFilter1.toString())
    // @Assert(true, possibleToTypeFilter1.getJidToInspect(packet).isNone())
    @Assert("PossibleToTypeFilter: domainFull", possibleToTypeFilter2.toString())
    // @Assert(true, possibleToTypeFilter2.getJidToInspect(packet).isNone())
    @Assert("PossibleToTypeFilter: domainBare", possibleToTypeFilter3.toString())
    // @Assert(true, possibleToTypeFilter3.getJidToInspect(packet).isNone())
    @Assert("PossibleToTypeFilter: any", possibleToTypeFilter4.toString())
    // @Assert(true, possibleToTypeFilter4.getJidToInspect(packet).isNone())
}

@Test
public func test_PresenceTypeFilter1(): Unit {
    let stanza: String = "<presence from='juliet@example.com/balcony' to='romeo@example.net'/>"
    let presence: Presence = PacketParserUtils.parsePresence(PacketParserUtils.getParserFor(stanza))
    let presenceTypeFilter0: PresenceTypeFilter = PresenceTypeFilter.AVAILABLE
    let presenceTypeFilter1: PresenceTypeFilter = PresenceTypeFilter.UNAVAILABLE
    let presenceTypeFilter2: PresenceTypeFilter = PresenceTypeFilter.SUBSCRIBE
    let presenceTypeFilter3: PresenceTypeFilter = PresenceTypeFilter.SUBSCRIBED
    let presenceTypeFilter4: PresenceTypeFilter = PresenceTypeFilter.UNSUBSCRIBE
    let presenceTypeFilter5: PresenceTypeFilter = PresenceTypeFilter.UNSUBSCRIBED
    let presenceTypeFilter6: PresenceTypeFilter = PresenceTypeFilter.ERROR
    let presenceTypeFilter7: PresenceTypeFilter = PresenceTypeFilter.PROBE
    @Assert("PresenceTypeFilter: type=available", presenceTypeFilter0.toString())
    // @Assert(true, presenceTypeFilter0.acceptSpecific(presence))
    @Assert("PresenceTypeFilter: type=unavailable", presenceTypeFilter1.toString())
    // @Assert(false, presenceTypeFilter1.acceptSpecific(presence))
    @Assert("PresenceTypeFilter: type=subscribe", presenceTypeFilter2.toString())
    // @Assert(false, presenceTypeFilter2.acceptSpecific(presence))
    @Assert("PresenceTypeFilter: type=subscribed", presenceTypeFilter3.toString())
    // @Assert(false, presenceTypeFilter3.acceptSpecific(presence))
    @Assert("PresenceTypeFilter: type=unsubscribe", presenceTypeFilter4.toString())
    // @Assert(false, presenceTypeFilter4.acceptSpecific(presence))
    @Assert("PresenceTypeFilter: type=unsubscribed", presenceTypeFilter5.toString())
    // @Assert(false, presenceTypeFilter5.acceptSpecific(presence))
    @Assert("PresenceTypeFilter: type=error", presenceTypeFilter6.toString())
    // @Assert(false, presenceTypeFilter6.acceptSpecific(presence))
    @Assert("PresenceTypeFilter: type=probe", presenceTypeFilter7.toString())
    // @Assert(false, presenceTypeFilter7.acceptSpecific(presence))
}

@Test
public func test_StanzaExtensionFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let appSpecificElement: ExtensionElement = CompressFeature(ArrayList<String>())
    let stanzaExtensionFilter0: StanzaExtensionFilter = StanzaExtensionFilter(None, "namespace")
    let stanzaExtensionFilter1: StanzaExtensionFilter = StanzaExtensionFilter("elementName", "namespace")
    let stanzaExtensionFilter2: StanzaExtensionFilter = StanzaExtensionFilter("namespace")
    let stanzaExtensionFilter3: StanzaExtensionFilter = StanzaExtensionFilter(appSpecificElement)
    @Assert("StanzaExtensionFilter: element=None namespace=namespace", stanzaExtensionFilter0.toString())
    @Assert(false, stanzaExtensionFilter0.accept(packet))
    @Assert("StanzaExtensionFilter: element=elementName namespace=namespace", stanzaExtensionFilter1.toString())
    @Assert(false, stanzaExtensionFilter1.accept(packet))
    @Assert("StanzaExtensionFilter: element=None namespace=namespace", stanzaExtensionFilter2.toString())
    @Assert(false, stanzaExtensionFilter2.accept(packet))
    @Assert("StanzaExtensionFilter: element=compression namespace=http://jabber.org/protocol/compress", stanzaExtensionFilter3.toString())
    @Assert(false, stanzaExtensionFilter3.accept(packet))
}

@Test
public func test_StanzaFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let testStanzaFilter0: TestStanzaFilter = TestStanzaFilter()
    let testStanzaFilter1: TestStanzaFilter = TestStanzaFilter()
    @Assert(false, testStanzaFilter0 == testStanzaFilter1)
    @Assert(false, testStanzaFilter0.test(packet))
    @Assert(false, testStanzaFilter1.test(packet))
    @Assert(false, testStanzaFilter0.hashCode() == 0)
    @Assert(false, testStanzaFilter1.hashCode() == 0)
}

class TestStanzaFilter <: StanzaFilter {
    init() {
    }

    public override func accept(stanza: Stanza): Bool {
        return false
    }

    public override func toString(): String {
        "TestStanzaFilter"
    }
}

@Test
public func test_StanzaIdFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let e1: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaIdFilter(packet))
    @Assert("IllegalArgumentException: Stanza ID must not be null nor empty.", e1.toString())
    let stanzaIdFilter1: StanzaIdFilter = StanzaIdFilter("stanzaId")
    @Assert(false, stanzaIdFilter1.accept(packet))
}

@Test
public func test_StanzaTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let stanzaTypeFilter0: StanzaTypeFilter<Presence> = StanzaTypeFilter<Presence>.PRESENCE
    let stanzaTypeFilter1: StanzaTypeFilter<Message> = StanzaTypeFilter<Message>.MESSAGE
    let stanzaTypeFilter2: StanzaTypeFilter<IQ> = StanzaTypeFilter<IQ>.IQ
    @Assert("StanzaTypeFilter: Presence", stanzaTypeFilter0.toString())
    @Assert(false, stanzaTypeFilter0.accept(packet))
    @Assert("StanzaTypeFilter: Message", stanzaTypeFilter1.toString())
    @Assert(true, stanzaTypeFilter1.accept(packet))
    @Assert("StanzaTypeFilter: IQ", stanzaTypeFilter2.toString())
    @Assert(false, stanzaTypeFilter2.accept(packet))
}

@Test
public func test_ThreadFilter1(): Unit {
    let messageSubject: String = "This is a test of the emergency broadcast system."
    let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    let threadFilter0: ThreadFilter = ThreadFilter("thread")
    // @Assert(false, threadFilter0.acceptSpecific(message))
}

@Test
public func test_toMatchesFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let toMatchesFilter0: ToMatchesFilter = ToMatchesFilter.MATCH_NO_TO_SET
    let toMatchesFilter1: ToMatchesFilter = ToMatchesFilter.createBare(None)
    let toMatchesFilter2: ToMatchesFilter = ToMatchesFilter.createFull(None)
    @Assert("ToMatchesFilter (full): None", toMatchesFilter0.toString())
    @Assert("ToMatchesFilter (ignoreResourcepart): None", toMatchesFilter1.toString())
    @Assert("ToMatchesFilter (full): None", toMatchesFilter2.toString())
    // @Assert(true, toMatchesFilter0.getAddressToCompare(packet).isNone())
}

@Test
public func test_ToTypeFilter1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let toTypeFilter0: ToTypeFilter = ToTypeFilter.ENTITY_FULL_JID
    let toTypeFilter1: ToTypeFilter = ToTypeFilter.ENTITY_BARE_JID
    let toTypeFilter2: ToTypeFilter = ToTypeFilter.DOMAIN_FULL_JID
    let toTypeFilter3: ToTypeFilter = ToTypeFilter.DOMAIN_BARE_JID
    let toTypeFilter4: ToTypeFilter = ToTypeFilter.TO_ANY_JID
    @Assert("ToTypeFilter: entityFull", toTypeFilter0.toString())
    // @Assert(true, toTypeFilter0.getJidToInspect(packet).isNone())
    @Assert("ToTypeFilter: entityBare", toTypeFilter1.toString())
    // @Assert(true, toTypeFilter1.getJidToInspect(packet).isNone())
    @Assert("ToTypeFilter: domainFull", toTypeFilter2.toString())
    // @Assert(true, toTypeFilter2.getJidToInspect(packet).isNone())
    @Assert("ToTypeFilter: domainBare", toTypeFilter3.toString())
    // @Assert(true, toTypeFilter3.getJidToInspect(packet).isNone())
    @Assert("ToTypeFilter: any", toTypeFilter4.toString())
    // @Assert(true, toTypeFilter4.getJidToInspect(packet).isNone())
}

@Test
public func test_XmppInputOutputFilterOutputResult1(): Unit {
    let packet: Stanza = StanzaBuilder.buildMessage().build()
    let xmppInputOutputFilterOutputResult0: XmppInputOutputFilterOutputResult = XmppInputOutputFilterOutputResult(
        ByteBuffer())
    @Assert(false, xmppInputOutputFilterOutputResult0.pendingFilterData)
}
//--filter=*.*

@Test
func modtcp_test1(): Unit {
    let configBuilder = C2sConnectionConfiguration.builder()
    configBuilder
        .setUsernameAndPassword("user1", "user1")
        // .setResource("jtest")
        .setXmppDomain(XmppTestServerHostName)
        // .setHost("10.56.237.54")
        .setHost(XmppTestServerHostName)
        .setPort(5222)
        // .setConnectTimeout(1000)
        // .setDebuggerFactory(ConsoleDebuggerFactory.INSTANCE)
        // .setSendPresence(false)
        .setCompressionEnabled(true)
        // .setSslContextFactory(() -> { return context; })
        // .setCustomX509TrustManager(new SparkTrustManager())
        .enableDefaultDebugger()
        .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    let connection = C2sConnection(configBuilder.build())

    @Assert(connection.isUsingCompression(), false)

    let logger = getGlobalLogger("")
    let stateHistory = StringBuilder()
    let stateMachineListener: ConnectionStateMachineListener = ConnectionStateMachineListener {
        e, c =>
        let sd: StateDescriptor = e.getStateDescriptor()
        let str = """
${e.getTimestamp()} 当前状态:${e}
    ${sd.getSuccessors().toArray()}
    ${sd.getPredeccessors().toArray()}
    ${sd.getSubordinates().toArray()}
    ${sd.getSuperiors().toArray()}
    ${sd.getStateName()}
    ${sd.getFullStateName(true)}
    ${sd.getFullStateName(false)}
    ${sd.getReference()}
    ${sd.getStateClass()}
    ${sd.isMultiVisitState()}
    ${sd.isNotImplemented()}
    ${sd.isFinalState()}
    ${sd.toString()}
    ${sd.getClass()}
    ${sd.hashCode()}
"""
        stateHistory.append(str)
    }

    connection.addConnectionStateMachineListener(stateMachineListener)
    connection.removeConnectionStateMachineListener(ConnectionStateMachineListener {_, _ => ()})

    let stats1: Stats = connection.getStats()

    connection.connect()
    connection.login()
    connection.instantShutdown()
    connection.disconnect()

    connection.instantShutdown()
    connection.disconnect()

    logger.info(stateHistory.toString())

    logger.info(stats1.toString())
    let stats2: Stats = connection.getStats()
    logger.info(stats2.toString())
}

/*     let appendable = StringBuilder()
    let transportsStats = stas.transportsStats
    let filtersStats = stas.filtersStats
    StringUtils.appendHeading(appendable, "Connection stats", r'#').append(r'\n')
    for ((transportClass, stats) in transportsStats) {
        StringUtils.appendHeading(appendable, transportClass)
        appendable.append(anyToString1(stats))
        // var str = match(stats){
        //     // case  =>
        //     case _ => "()"
        // }
        var str = if (stats is ToString) {
            (stats as ToString).getOrThrow().toString()
        } else {
            "None"
        }
        while (str.startsWith("Some(")) {
            str = str[5..str.size - 1]
        }
        appendable.append(str)
        appendable.append(r'\n')
    }
    // for ((filterName, filterStats) in filtersStats) {
    //     StringUtils.appendHeading(appendable, filterName)
    //     appendable.append(anyToString(filterStats))
    //     appendable.append(r'\n')
    // }
    // stas.appendStatsTo(appendable)
    // logger.info(appendable.toString()) */
class AbstractStats0 <: AbstractStats {
    public override func appendStatsTo(str: StringBuilder): Unit {
        str.append("AbstractStats0")
    }
}

@Test
public func test_AbstractStats(): Unit {
    let obj = AbstractStats0()
    @Assert(obj.toString(),"AbstractStats0")
    @Assert(obj.toString(),"AbstractStats0")
}

@Test
public func test_ExceptionThrowingCallback1(): Unit {
    let unparseableStanza: UnparseableStanza = UnparseableStanza("UnparseableStanza",
        IllegalArgumentException("IllegalArgumentException"))
    let exceptionThrowingCallback: ExceptionThrowingCallback = ExceptionThrowingCallback()
    let e0: IOException = @AssertThrows[IOException](exceptionThrowingCallback.handleUnparsableStanza(unparseableStanza))
    @Assert("IOException", e0.toString())
}

@Test
public func test_UnparseableStanza1(): Unit {
    let unparseableStanza: UnparseableStanza = UnparseableStanza("UnparseableStanza",
        IllegalArgumentException("IllegalArgumentException"))
    let e0: Exception = unparseableStanza.getParsingException()
    let s: String = unparseableStanza.getContent()
    @Assert("IllegalArgumentException: IllegalArgumentException", e0.toString())
    @Assert("UnparseableStanza", s)
}

@Test
public func test_AbstractProviderInfo1(): Unit {
    let messageSubject: String = "This is a test of the emergency broadcast system."
    let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    let testAbstractProviderInfo: TestAbstractProviderInfo = TestAbstractProviderInfo("elementName", "namespace",
        message)
    @Assert("elementName", testAbstractProviderInfo.getElementName())
    @Assert("namespace", testAbstractProviderInfo.getNamespace())
    @Assert(true, testAbstractProviderInfo.getProvider() is Message)
}

class TestAbstractProviderInfo <: AbstractProviderInfo {
    init(elementName: String, namespace: String, iqOrExtProvider: Object) {
        super(elementName, namespace, iqOrExtProvider)
    }
}

@Test
public func test_BindIQProvider1(): Unit {
    let oriIqData = StanzaBuilder.buildIqData(Some("IqData stanzaId"))
    let actSB: IqData = StanzaBuilder.buildResponse<IqData>(oriIqData, getIqData)
    let bindIQProvider: BindIQProvider = BindIQProvider()
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let e0: Exception = @AssertThrows[Exception](bindIQProvider.parse(staxXmlPullParserFactory.newXmlPullParser(ByteBuffer()), 0, actSB, None))
    @Assert("XmlException: Failed to read data, idx: 0 out of size: 0.", e0.toString())
}

public func getIqData(stanzaId: ?String): IqData {
    return StanzaBuilder.buildIqData(stanzaId)
}

@Test
public func test_BodyElementProvider1(): Unit {
    let bodyElementProvider: BodyElementProvider = BodyElementProvider()
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let e0: Exception = @AssertThrows[Exception](bodyElementProvider.parse(staxXmlPullParserFactory.newXmlPullParser(ByteBuffer()), 0, None))
}

@Test
public func test_ExtensionProviderInfo1(): Unit {
    let extensionProviderInfo: ExtensionProviderInfo = ExtensionProviderInfo("elementName", "namespace",
        ExtensionElementProvider01())
    extensionProviderInfo.getProvider()
}

class ExtensionElementProvider01 <: ExtensionElementProvider<ExtensionElement> {
    init() {
        super("ExtensionElement")
    }
    public func parse(parser: XmlPullParser, initialDepth: Int64, xmlEnvironment: ?XmlEnvironment): ExtensionElement {
        throw Exception()
    }
}

@Test
public func test_IntrospectionProvider1(): Unit {
}

@Test
public func test_TlsProceedProvider1(): Unit {
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let byteArrayStream = ByteBuffer()
    let staxXmlPullParser: XmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
    let tlsProceedProvider: TlsProceedProvider = TlsProceedProvider.INSTANCE
    @Assert("failure", tlsProceedProvider.parse(staxXmlPullParser, 0, None).getElementName())
}

@Test
public func test_ReconnectionManager1(): Unit {
    let reconnectionPolicy1 = ReconnectionPolicy.RANDOM_INCREASING_DELAY
    let reconnectionPolicy2 = ReconnectionPolicy.FIXED_DELAY
    @Assert("RANDOM_INCREASING_DELAY", reconnectionPolicy1.toString())
    @Assert("FIXED_DELAY", reconnectionPolicy2.toString())
}

@Test
public func test_SASLError1(): Unit {
    let saslError1 = SASLError.aborted
    let saslError2 = SASLError.account_disabled
    let saslError3 = SASLError.credentials_expired
    let saslError4 = SASLError.encryption_required
    let saslError5 = SASLError.incorrect_encoding
    let saslError6 = SASLError.invalid_authzid
    let saslError7 = SASLError.invalid_mechanism
    let saslError8 = SASLError.malformed_request
    let saslError9 = SASLError.mechanism_too_weak
    let saslError10 = SASLError.not_authorized
    let saslError11 = SASLError.temporary_auth_failure
    // @Assert(true, saslError1 == saslError1)
    // @Assert(true, saslError2 == saslError2)
    // @Assert(true, saslError3 == saslError3)
    // @Assert(true, saslError4 == saslError4)
    // @Assert(true, saslError5 == saslError5)
    // @Assert(true, saslError6 == saslError6)
    // @Assert(true, saslError7 == saslError7)
    // @Assert(true, saslError8 == saslError8)
    // @Assert(true, saslError9 == saslError9)
    // @Assert(true, saslError10 == saslError10)
    // @Assert(true, saslError11 == saslError11)
    // @Assert(false, saslError11 == saslError1)
    @Assert("aborted", saslError1.toString())
    @Assert("account-disabled", saslError2.toString())
    @Assert("credentials-expired", saslError3.toString())
    @Assert("encryption-required", saslError4.toString())
    @Assert("incorrect-encoding", saslError5.toString())
    @Assert("invalid-authzid", saslError6.toString())
    @Assert("invalid-mechanism", saslError7.toString())
    @Assert("malformed-request", saslError8.toString())
    @Assert("mechanism-too-weak", saslError9.toString())
    @Assert("not-authorized", saslError10.toString())
    @Assert("temporary-auth-failure", saslError11.toString())
    @Assert(saslError1.toString(), SASLError.fromString(saslError1.toString()).getOrThrow().toString())
    @Assert(saslError2.toString(), SASLError.fromString(saslError2.toString()).getOrThrow().toString())
    @Assert(saslError3.toString(), SASLError.fromString(saslError3.toString()).getOrThrow().toString())
    @Assert(saslError4.toString(), SASLError.fromString(saslError4.toString()).getOrThrow().toString())
    @Assert(saslError5.toString(), SASLError.fromString(saslError5.toString()).getOrThrow().toString())
    @Assert(saslError6.toString(), SASLError.fromString(saslError6.toString()).getOrThrow().toString())
    @Assert(saslError7.toString(), SASLError.fromString(saslError7.toString()).getOrThrow().toString())
    @Assert(saslError8.toString(), SASLError.fromString(saslError8.toString()).getOrThrow().toString())
    @Assert(saslError9.toString(), SASLError.fromString(saslError9.toString()).getOrThrow().toString())
    @Assert(saslError10.toString(), SASLError.fromString(saslError10.toString()).getOrThrow().toString())
    @Assert(saslError11.toString(), SASLError.fromString(saslError11.toString()).getOrThrow().toString())
    @Assert(false, SASLError.fromString("saslError11.toString()").isSome())
}

@Test
public func test_ScheduledAction1(): Unit {
    let reconnectionPolicy1 = ScheduledActionKind.NonBlocking
    let reconnectionPolicy2 = ScheduledActionKind.Blocking
}

/* @Test
public func test_ScramMechanism1(): Unit {
    let scramMechanismState1 = ScramMechanismState.INITIAL
    let scramMechanismState2 = ScramMechanismState.AUTH_TEXT_SENT
    let scramMechanismState3 = ScramMechanismState.RESPONSE_SENT
    let scramMechanismState4 = ScramMechanismState.VALID_SERVER_RESPONSE
    @Assert(true, scramMechanismState1 == scramMechanismState1)
    @Assert(true, scramMechanismState2 == scramMechanismState2)
    @Assert(true, scramMechanismState3 == scramMechanismState3)
    @Assert(true, scramMechanismState4 == scramMechanismState4)
    @Assert(false, scramMechanismState1 == scramMechanismState2)
} */
@Test
public func test_SSLEngine1(): Unit {
    let sslStatus1 = SSLStatus.BUFFER_UNDERFLOW
    let sslStatus2 = SSLStatus.BUFFER_OVERFLOW
    let sslStatus3 = SSLStatus.OK
    let sslStatus4 = SSLStatus.CLOSED
    @Assert(true, sslStatus1 == sslStatus1)
    @Assert(true, sslStatus2 == sslStatus2)
    @Assert(true, sslStatus3 == sslStatus3)
    @Assert(true, sslStatus4 == sslStatus4)
    @Assert(false, sslStatus4 == sslStatus3)
    @Assert("BUFFER_UNDERFLOW", sslStatus1.toString())
    @Assert("BUFFER_OVERFLOW", sslStatus2.toString())
    @Assert("OK", sslStatus3.toString())
    @Assert("CLOSED", sslStatus4.toString())
}

@Test
public func test_SSLEngine2(): Unit {
    let handshakeStatus1 = HandshakeStatus.NOT_HANDSHAKING
    let handshakeStatus2 = HandshakeStatus.FINISHED
    let handshakeStatus3 = HandshakeStatus.NEED_TASK
    let handshakeStatus4 = HandshakeStatus.NEED_WRAP
    let handshakeStatus5 = HandshakeStatus.NEED_UNWRAP
    let handshakeStatus6 = HandshakeStatus.NEED_UNWRAP_AGAIN
    @Assert(true, handshakeStatus1 == handshakeStatus1)
    @Assert(true, handshakeStatus2 == handshakeStatus2)
    @Assert(true, handshakeStatus3 == handshakeStatus3)
    @Assert(true, handshakeStatus4 == handshakeStatus4)
    @Assert(true, handshakeStatus5 == handshakeStatus5)
    @Assert(true, handshakeStatus6 == handshakeStatus6)
    @Assert(false, handshakeStatus1 == handshakeStatus6)
    @Assert("NOT_HANDSHAKING", handshakeStatus1.toString())
    @Assert("FINISHED", handshakeStatus2.toString())
    @Assert("NEED_TASK", handshakeStatus3.toString())
    @Assert("NEED_WRAP", handshakeStatus4.toString())
    @Assert("NEED_WRAP", handshakeStatus5.toString())
    @Assert("NEED_UNWRAP_AGAIN", handshakeStatus6.toString())
}

@Test
public func test_SSLEngine3(): Unit {
    let sslException: SSLException = SSLException()
}

@Test
public func test_SHA1Util1(): Unit {
    let sha1Util: SHA1Util = SHA1Util()
    let arr: Array<UInt8> = SHA1Util.bytes("0123456789")
    let arr1: Array<UInt8> = [135, 172, 236, 23, 205, 157, 205, 32, 167, 22, 204, 44, 246, 116, 23, 183, 28, 138, 112,
        22]
    @Assert(arr1, arr)
}

@Test
public func test_RandomUtil1(): Unit {
    let randomUtil1: RandomUtil = RandomUtil()
}

@Test
public func test_MAC1(): Unit {
    let mac: MAC = MAC()
}

@Test
public func test_HashCode1(): Unit {
    let hashCode: HashCode = HashCode()
}

@Test
public func test_StringUtils1(): Unit {
    let stringUtils: StringUtils = StringUtils()
    let s1: String = StringUtils.escapeForXmlAttribute("")
    @Assert("", s1)
    let s2: String = StringUtils.escapeForXmlAttribute("0123456789")
    @Assert("0123456789", s2)
    let s3: String = StringUtils.secureOnlineAttackSafeRandomString()
    @Assert(true, s3.size > 0)
    let s4: String = StringUtils.secureUniqueRandomString()
    @Assert(true, s4.size > 0)
    let s5: String = StringUtils.secureOfflineAttackSafeRandomString()
    @Assert(true, s5.size > 0)
    let css1: Array<CharSequence> = ["1", "2"]
    let b1: Bool = StringUtils.isNotEmpty(css1)
    @Assert(true, b1)
    let css2: Array<CharSequence> = []
    let b2: Bool = StringUtils.isNotEmpty(css2)
    @Assert(true, b2)
    let b3: Bool = StringUtils.isNullOrEmpty(css1)
    @Assert(false, b3)
    let b4: Bool = StringUtils.isNullOrEmpty(css2)
    @Assert(true, b4)
    let s6: String = StringUtils.returnIfNotEmptyTrimmed(" 0123456789 ").getOrThrow()
    @Assert("0123456789", s6)
    let e0: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StringUtils.requireNotNullNorEmpty(None, " 0123456789 "))
    @Assert("IllegalArgumentException:  0123456789 ", e0.toString())
    let arr1: ArrayList<String> = StringUtils.splitLinesPortable("0123456789")
    @Assert(true, arr1.size == 1)
    let arr2: ArrayList<String> = StringUtils.toStrings(["0123456789"])
    @Assert(true, arr2.size == 1)
}

@Test
public func test_byteList2String1(): Unit {
    let arr1: ArrayList<Byte> = ArrayList<Byte>([100, 40, 60])
    let s1: String = byteList2String(arr1)
    @Assert("d(<", s1)
}

@Test
public func test_Async(): Unit {
    let arr = [0]
    let fur = Async.go {
        => arr[0] = 1
    }
    fur.get()
    @Assert(arr[0], 1)
    let fur1 = Async.daemonThreadFrom {
        => arr[0] = 2
    }
    fur1.get()
    @Assert(arr[0], 2)
}

@Test
public func test_ByteUtils(): Unit {
    let arr = [0u8]
    let arr1 = [1u8]
    let arr2 = ByteUtils.concat(arr, arr1)
    @Assert(arr2[0], 0)
    @Assert(arr2[1], 1)
}

@Test
public func test_anyClassId(): Unit {
    let obj = CompressionStateDescriptor()
    let classid = anyClassId(obj)
    @Assert(classid, "CompressionStateDescriptor")
}

class ExceptionCloseable <: Resource {
    public func isClosed(): Bool {
        false
    }
    public func close(): Unit {
        throw Exception("error")
    }
}

@Test
public func test_CloseableUtil(): Unit {
    let obj = ExceptionCloseable()
    CloseableUtil.maybeClose(obj)
}

@Test
public func test_CollectionBlockingQueue(): Unit {
    var obj = CollectionBlockingQueue<String>(1)
    @Assert(obj.size, 0)
    @Assert(obj.isEmpty(), true)
    let arr = ArrayBlockingQueue<String>(5)
    obj = CollectionBlockingQueue<String>(arr)
    arr.enqueue("1")
    @Assert(obj.iterator().next(), "1")
}

@Test
public func test_CollectionUtil(): Unit {
    let arr: Array<String> = []
    @AssertThrows[IllegalArgumentException](CollectionUtil.requireNotEmpty(arr,"arr"))
}

@Test
public func test_Collections(): Unit {
    let m = HashMap<String, String>([("0", "0")])
    let obj = Collections.unmodifiableMap(m)
    @Assert(obj.get("0"),"0")
    @Assert(obj.contains("0"))
    @Assert(obj.contains(all:["0"]))
    @AssertThrows[UnsupportedException](obj.add("1","1"))
    @AssertThrows[UnsupportedException](obj.add(all:[("1","1")]))
    @AssertThrows[UnsupportedException](obj.remove("1"))
    @AssertThrows[UnsupportedException](obj.remove(all:["1"]))
    @AssertThrows[UnsupportedException](obj.removeIf{_,_ => true})
    @AssertThrows[UnsupportedException](obj.clear())
    // @AssertThrows[UnsupportedException](obj.clone())
    @Assert(obj["0"],"0")
    @AssertThrows[UnsupportedException](obj["0"] = "1")
    @Assert(obj.keys().size, 1)
    @Assert(obj.values().size, 1)
    @Assert(obj.size, 1)
    @Assert(obj.isEmpty(), false)
    @Assert(obj.iterator().next()?[0], "0")
}

@Test
public func test_Collections1(): Unit {
    let obj = Collections.EMPTY_STRING_MAP
    @Assert(obj.get("0"),None)
    @Assert(obj.contains("0"), false)
    @Assert(obj.contains(all:["0"]), false)
    @AssertThrows[UnsupportedException](obj.add("1","1"))
    @AssertThrows[UnsupportedException](obj.add(all:[("1","1")]))
    @AssertThrows[UnsupportedException](obj.remove("1"))
    @AssertThrows[UnsupportedException](obj.remove(all:["1"]))
    @AssertThrows[UnsupportedException](obj.removeIf{_,_ => true})
    obj.clear()
    // @AssertThrows[UnsupportedException](obj.clone())
    @AssertThrows[UnsupportedException](obj["0"])
    @AssertThrows[UnsupportedException](obj["0"] = "1")
    @Assert(obj.keys().size, 0)
    @Assert(obj.values().size, 0)
    @Assert(obj.size, 0)
    @Assert(obj.isEmpty(), true)
    @Assert(obj.iterator().next().isNone())
}

@Test
public func test_ConcurrentLinkedQueue(): Unit {
    let obj = ConcurrentLinkedList<String>()
    obj.append("0")
    // synchronized(obj.lock) {
    //     obj.list.prepend("0")
    // }
    @Assert(obj.size,1)
    // synchronized(obj.lock) {
    //     var node = obj.list.nodeAt(0)
    //     if (let Some(n) <- node) {
    //         obj.list.remove(n)
    //         // return n.value
    //     }
    //     // return None
    // }
    // obj.remove(0)
    @Assert(obj.remove(0),'0')
    obj.prepend('1')
    obj.clear()
    @Assert(obj.size,0)
    obj.append("3")
    obj.prepend('4')
    @Assert(obj.reverseIterator().next(),'3')
}

@Test
public func test_ConcurrentSet(): Unit {
    let obj = ConcurrentSet<Int64>()
    obj.put(0)
    obj.put(0)
    @Assert(obj.size, 1)
    obj.clear()
    @Assert(obj.size, 0)
    obj.put(1)
    obj.remove(0)
    @Assert(obj.size, 1)
    obj.remove(1)
    @Assert(obj.size, 0)
}

class Delayable <: Delayed & Comparable<Delayable> {
    Delayable(let id: Int64, let deadline: DateTime) {}
    public override func getDelay(): Duration {
        deadline - DateTime.now()
    }
    public override func compare(that: Delayable): Ordering {
        deadline.compare(that.deadline)
    }
}

@Test
public func test_DelayQueue(): Unit {
    let obj = DelayQueue<Delayable>()
    let now = DateTime.now()
    let item2 = Delayable(2, now + Duration.second * 2)
    obj.append(item2)
    obj.append(Delayable(1, now + Duration.second))
    obj.append(Delayable(3, now + Duration.second * 3))
    @Assert(obj.poll().isNone())
    @Assert(obj.take()?.id,1)

    let remove1 = obj.remove(Delayable(2, now + Duration.second * 2))
    @Assert(remove1, false)
    @Assert(obj.peek()?.id, 2)
    let remove2 = obj.remove(item2)
    @Assert(remove2, true)
    @Assert(obj.peek()?.id, 3)

    let item = obj.peek().getOrThrow()
    sleep(item.getDelay())
    @Assert(obj.poll().getOrThrow().id, 3)
}

@Test
public func test_ExceptionUtil(): Unit {
    var e = InterruptedException()
    @Assert(e.getClassName(), "InterruptedException")
    e = InterruptedException(Exception("123"))
    @Assert(e.message, "123")
    e = InterruptedException("test2", e)
    @Assert(e.message, "test2")
    @Assert(e.getCause()?.message, "123")
    @Assert(e.getCauseStackTrace()[..30], "cause by: InterruptedException")
}

class Appendable01 <: Appendable {
    let str = StringBuilder()
    public override func append(s: ToString): Appendable01 {
        this.str.append(s.toString())
        this
    }
}

@Test
public func test_Appendable(): Unit {
    let a1 = Appendable01()
    let a2 = ExtendedAppendable(a1)
    a2.append("123")
    @Assert(a1.str.toString(), "123")
}

@Test
public func test_SimpleHashMap(): Unit {
    let obj = SimpleHashMap<Object, Object>()
    @AssertThrows[UnsupportedException](obj.containsAll([Object()]))

    let arr = [(Object(), Object()), (Object(), Object())]
    obj.putAll(arr)
    @Assert(obj.size, 2)

    obj.removeAll([Object()])
    @Assert(obj.size, 2)

    obj.removeIf {_, v => refEq(v, arr[1][1])}
    @Assert(obj.size, 1)

    obj[arr[0][0]]
    obj[arr[0][0]] = Object()

    obj.keys().iterator().next().getOrThrow()
    @Assert(obj.values().size, 1)

    @Assert(obj.isEmpty() , false)

    obj.iterator().next().getOrThrow()

    obj.clear()
    @Assert(obj.size, 0)

    let obj1 = SimpleHashMap<StringBuilder, StringBuilder>()
    obj1.put(StringBuilder(), StringBuilder())

    let obj2 = SimpleHashMap<Int, Int>()
    obj2.put(1, 11)
}

@Test
public func test_LinkedHashMap(): Unit {
    let obj = LinkedHashMap<Byte, Byte>()
    // @AssertThrows[UnsupportedException](obj.clone())
    obj.add(1, 11)
    obj.add(2, 2)
    obj.add(2, 22)
    obj.add(3, 33)

    @Assert(obj[1][1], 22)

    // obj.set(1, 111)
    // @Assert(obj.get(1), 111)

    @Assert(obj.contains(all:[1,3]),true)

    obj.add(all:[(4, 44)])
    @Assert(obj.size, 4)

    @Assert(obj.remove(0).isNone())
    @Assert(obj.size, 4)
    @Assert(obj.remove(1), 11)
    @Assert(obj.size, 3)

    obj.remove(all:[2])
    @Assert(obj.size, 2)

    @Assert(obj[3u8], 33)
    obj[3u8] = 3u8
    @Assert(obj[3u8], 3u8)

    @Assert(obj.keys().iterator().next(),3)
    @Assert(obj.isEmpty(),false)
    obj.iterator().next()
    @Assert(obj.iterator().next().getOrThrow()[1], 3)

    obj.clear()
    @Assert(obj.isEmpty())
}

@Test
public func test_ListIterator(): Unit {
    let iter = ListIterator([1, 2, 3].iterator())
    @Assert(iter.previous().isNone())
    @Assert(iter.next(),1)
    @Assert(iter.next(),2)
    @Assert(iter.next(),3)
    @Assert(iter.next().isNone())
    @Assert(iter.previous(),3)
    @Assert(iter.previous(),2)
    @Assert(iter.previous(),1)
    @Assert(iter.previous().isNone())
    @Assert(iter.next(),1)
}

@Test
public func test_ObservableReader(): Unit {
    let f = File("test_ObservableReader", Write)
    let reader1 = ObservableReader(f)
    let reader2 = ObservableReader(reader1)

    reader1.addReaderListener(ReaderListener {_ => ()})
    reader1.removeReaderListener(ReaderListener {_ => ()})

    @Assert(reader2.isClosed(), false)
    reader2.close()
    @Assert(reader2.isClosed(), true)
}

@Test
public func test_ObservableWriter(): Unit {
    let f = File("test_ObservableWriter", Write)
    let writer1 = ObservableWriter(f)
    let writer2 = ObservableWriter(writer1)

    writer1.addWriterListener(WriterListener {_ => ()})
    writer1.removeWriterListener(WriterListener {_ => ()})

    writer2.write("asd".toArray())

    @Assert(writer2.isClosed(), false)
    writer2.close()
    @Assert(writer2.isClosed(), true)
}

@Test
public func test_OutputStreamUtil(): Unit {
    let buf = ByteBuffer()
    @AssertThrows[IOException](OutputStreamUtil.writeByteSafe(buf,-1,"test"))
    OutputStreamUtil.writeByteSafe(buf, 1, "test1")
}

@Test
public func test_AssertionError(): Unit {
    var e = AssertionError()
    @Assert(e.message,"")
    e = AssertionError("msg")
    @Assert(e.toString(),"AssertionError: msg")
    e = AssertionError(Exception("2"))
    @Assert(e.toString()[..14],"AssertionError")

    // @AssertThrows[Exception](assert(false))
}

@Test
public func test_MultiMap(): Unit {
    let map = MultiMap<String, String>()
    map.put("1", "11")
    map.put("1", "12")
    // @Assert(map.get("1")[0], "11")
    @Assert(map.isEmpty() , false)
    map.putFirst("1", "10")
    @Assert(map.getFirst("1"), "10")
    @Assert(map.removeOne("11","12"),false)
    @Assert(map.remove("1", 10)?.size, 3)
    // @Assert(map.get("1"), "")

    map.putAll(HashMap<String, String>([("2", "22")]))
    map.clear()
    @Assert(map.isEmpty() , true)
}

@Test
public func test_ToStringUtil(): Unit {
    let builder = ToStringUtil.builderFor("asd")
    builder.addValue("k1", "v1")
    builder.addValue("k2", "v2")
    builder.add("k3", ["v3"])
    builder.addValue("k4", "v4")
    builder.add("k5", ["v51", "v52"])
    let str = builder.build()
    @Assert(str,"asd(k1='v1' k2='v2' k3[v3] k4='v4' k5[v51, v52])")
}

@Test
public func test_XmppXmlParser1(): Unit {
    let xmppXmlParser: XmppXmlParser = XmppXmlParser()
    let xmlPullParserFactory1: XmlPullParserFactory = StaxXmlPullParserFactory()
    XmppXmlParser.setXmlPullParserFactory(xmlPullParserFactory1)
    let xmlPullParserFactory2: XmlPullParserFactory = XmppXmlParser.getXmlPullParserFactory()
}

@Test
public func test_XmppConfiguration1(): Unit {
    let xmppConfigurationUnknownIqRequestReplyMode1 = XmppConfigurationUnknownIqRequestReplyMode.doNotReply
    let xmppConfigurationUnknownIqRequestReplyMode2 = XmppConfigurationUnknownIqRequestReplyMode
        .replyFeatureNotImplemented
    let xmppConfigurationUnknownIqRequestReplyMode3 = XmppConfigurationUnknownIqRequestReplyMode.replyServiceUnavailable
    @Assert(true, xmppConfigurationUnknownIqRequestReplyMode1 == xmppConfigurationUnknownIqRequestReplyMode1)
    @Assert(true, xmppConfigurationUnknownIqRequestReplyMode2 == xmppConfigurationUnknownIqRequestReplyMode2)
    @Assert(true, xmppConfigurationUnknownIqRequestReplyMode3 == xmppConfigurationUnknownIqRequestReplyMode3)
    @Assert("doNotReply", xmppConfigurationUnknownIqRequestReplyMode1.toString())
    @Assert("replyFeatureNotImplemented", xmppConfigurationUnknownIqRequestReplyMode2.toString())
    @Assert("replyServiceUnavailable", xmppConfigurationUnknownIqRequestReplyMode3.toString())
    @Assert(false, xmppConfigurationUnknownIqRequestReplyMode1 == xmppConfigurationUnknownIqRequestReplyMode3)
}

@Test
public func test_XMPPConnection1(): Unit {
    let xmppConnectionFromMode1 = XMPPConnectionFromMode.UNCHANGED
    let xmppConnectionFromMode2 = XMPPConnectionFromMode.OMITTED
    let xmppConnectionFromMode3 = XMPPConnectionFromMode.USER
    @Assert(true, xmppConnectionFromMode1 == xmppConnectionFromMode1)
    @Assert(true, xmppConnectionFromMode2 == xmppConnectionFromMode2)
    @Assert(true, xmppConnectionFromMode3 == xmppConnectionFromMode3)
    @Assert("UNCHANGED", xmppConnectionFromMode1.toString())
    @Assert("OMITTED", xmppConnectionFromMode2.toString())
    @Assert("USER", xmppConnectionFromMode3.toString())
    @Assert(false, xmppConnectionFromMode2 == xmppConnectionFromMode3)
}

@Test
public func covXmppTlsContext(): Unit {
    let obj = XmppTlsContext(TlsClientConfig(), None)
    try {
        obj.createSSLEngine("", 5222)
    } catch (_) {}
}

@Test
public func covCertificateException(): Unit {
    @Assert(CertificateException("asd").toString(),"CertificateException: asd")
}

@Test
public func covXMPPInputOutputStream(): Unit {
    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    @Assert(XMPPInputOutputStream.getFlushMethod(),XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
}

@Test
public func covXMPPInputOutputStreamFlushMethod(): Unit {
    @Assert(XMPPInputOutputStreamFlushMethod.FULL_FLUSH,XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    @Assert(XMPPInputOutputStreamFlushMethod.SYNC_FLUSH,XMPPInputOutputStreamFlushMethod.SYNC_FLUSH)
    @Assert(XMPPInputOutputStreamFlushMethod.FULL_FLUSH!=XMPPInputOutputStreamFlushMethod.SYNC_FLUSH)
}

class RemoteConnectionEndpoint1 <: RemoteConnectionEndpoint {
    public func getHost(): String {
        "host"
    }
    public func getPort(): UInt16 {
        0
    }
    public func getInetAddresses(): Collection<IPSocketAddress> {
        []
    }
    public func getDescription(): String {
        "desc"
    }
}

@Test
public func covEndpointConnectionException(): Unit {
    let fails: Collection<RemoteConnectionEndpointLookupFailure> = [DnsLookupFailure("asd", Exception("e"))]
    let es: Collection<RemoteConnectionException<RemoteConnectionEndpoint>> = [RemoteConnectionException(
        RemoteConnectionEndpoint1(), None, Exception("2"))]
    let obj = EndpointConnectionException.comefrom(fails, es)

    obj.getLookupFailures()
    obj.getConnectionExceptions()
    obj.toString()
}

@Test
public func covFeatureNotSupportedException(): Unit {
    let e = FeatureNotSupportedException("asd", None)
}

@Test
public func covXmppSaslException(): Unit {
    let e = XmppSaslException("asd").toString()
}

@Test
public func covXmppCertificateException(): Unit {
    let e = XmppCertificateException(CertificateException("cer"))
    e.toString()
    e.getCertificateException()
}

struct StanzaListenerStruct <: StanzaListener {
    public func processStanza(packet: Stanza): Unit {}
}

@Test
public func covStanzaListener(): Unit {
    let e = SimpleStanzaListener {_, _ => ()}
    let obj = StanzaListenerStruct()
    try {
        obj == e
    } catch (_) {}
}

@Test
public func covInetSocketAddressCoupling(): Unit {
    let rce = RemoteConnectionEndpoint1()
    let obj = InetSocketAddressCoupling(rce, None)
    obj.getRemoteConnectionEndpoint()
}

@Test
public func covRemoteConnectionEndpointLookupFailure(): Unit {
    let obj: RemoteConnectionEndpointLookupFailure = DnsLookupFailure("asd", Exception("e"))
    obj.getDescription()
    obj.getException()
    obj.getErrorMessage()
}

@Test
public func covDnsLookupFailure(): Unit {
    let o = DnsLookupFailure("asd", Exception("e"))
    @Assert(o.getDnsName(), "asd")
}

@Test
public func covRemoteConnectionException(): Unit {
    let o = RemoteConnectionException(RemoteConnectionEndpoint1(), None, Exception("2"))
    o.getAddress()
    o.getException()
    o.getErrorMessage()
    o.toString()
}

@Test
public func covIQRequestHandlerMode(): Unit {
    @Assert(IQRequestHandlerMode.sync.toString(), "sync")
    @Assert(IQRequestHandlerMode.async.toString(), "async")
    @Assert(IQRequestHandlerMode.sync,IQRequestHandlerMode.sync)
    @Assert(IQRequestHandlerMode.async, IQRequestHandlerMode.async)
    @Assert(IQRequestHandlerMode.async!=IQRequestHandlerMode.sync)
}

@Test
public func covDnssecMode(): Unit {
    DnssecMode.needsDnssec.toString()
    @Assert(DnssecMode.needsDnssec, DnssecMode.needsDnssec)
    DnssecMode.needsDnssecAndDane.toString()
    @Assert(DnssecMode.needsDnssecAndDane, DnssecMode.needsDnssecAndDane)
}

class DNSResolver0 <: DNSResolver {
    init(b: Bool) {
        super(b)
    }
    protected open func lookupHostAddress0(
        name: DnsName,
        lookupFailures: ArrayList<RemoteConnectionEndpointLookupFailure>,
        dnssecMode: DnssecMode
    ): ?Collection<IPAddress> {
        super.lookupHostAddress0(name, lookupFailures, dnssecMode)
    }
    protected static func shouldContinue(name: String, hostname: String, hostAddresses: ?Collection<IPAddress>): Bool {
        DNSResolver.shouldContinue(name, hostname, hostAddresses)
    }
}

@Test
public func covDNSResolver(): Unit {
    let o = DNSResolver0(false)
    @AssertThrows[UnsupportedException](o.lookupHostAddress0("asd",ArrayList(),DnssecMode.needsDnssec))
    @AssertThrows[UnsupportedException](o.lookupHostAddress("asd",ArrayList(),DnssecMode.needsDnssec))
    o.lookupHostAddress0("127.0.0", ArrayList(), DnssecMode.disabled)

    let arr: Collection<IPAddress> = []
    @Assert(DNSResolver0.shouldContinue("","", None))
    @Assert(DNSResolver0.shouldContinue("","", arr))
    @Assert(DNSResolver0.shouldContinue("","", IPAddress.resolve("localhost")),false)
}

@Test
public func covDNSUtil(): Unit {
    DNSUtil.setDNSResolver(DNSResolver0(true))
    DNSUtil.setDaneProvider({=> None})
    DNSUtil.getDaneProvider()
}

let config = XMPPTCPConnectionConfiguration
    .builder()
    .setXmppDomain(XmppTestServerHostName)
    .setSecurityMode(ConnectionConfigurationSecurityMode.disabled)
    .performSaslAnonymousAuthentication()
    .build()

@Test
public func covZlibXmppInputOutputFilter(): Unit {
    let zlibXmppInputOutputFilter = ZlibXmppCompressionFactory.INSTANCE.fabricate(config)

    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.SYNC_FLUSH)
    zlibXmppInputOutputFilter.output(None, true, false, true) // XmppInputOutputFilterOutputResult.NO_OUTPUT
    zlibXmppInputOutputFilter.output(None, true, true, true) // XmppInputOutputFilterOutputResult.NO_OUTPUT

    XMPPInputOutputStream.setFlushMethod(XMPPInputOutputStreamFlushMethod.FULL_FLUSH)
    @AssertThrows[Exception](zlibXmppInputOutputFilter.output(None, true, true, true))

    @Assert(zlibXmppInputOutputFilter.input(ByteBuffer()).isNone())
    @Assert(zlibXmppInputOutputFilter.getFilterName(),"Compression (zlib)")

    let stats = (zlibXmppInputOutputFilter.getStats() as ZlibXmppCompressionFactoryStats).getOrThrow()
    stats.toString()
    stats.toString()
    @Assert(stats==stats)
}

class AbstractXMPPConnection0 <: AbstractXMPPConnection {
    init(config: ConnectionConfiguration) {
        super(config)
    }
    public override func isSecureConnection(): Bool {
        return false;
    }
    protected override func sendStanzaInternal(packet: Stanza): Unit {
    }
    public override func sendNonza(element: Nonza): Unit {
    }
    public override func isUsingCompression(): Bool {
        return false;
    }
    protected override func connectInternal(): Unit {
    }
    protected override func loginInternal(username: ?String, password: ?String, resource: ?Resourcepart): Unit {
    }
    public override func instantShutdown(): Unit {
    }
    protected override func shutdown(): Unit {
    }
    public func getClass(): String {
        "AbstractXMPPConnection0"
    }
    protected func getReactor0(): XmppReactor {
        return super.getReactor()
    }
    protected func throwCurrentConnectionException1(): Unit {
        super.throwCurrentConnectionException()
    }
    protected func setCurrentConnectionExceptionAndNotify1(exception: Exception): Unit {
        super.setCurrentConnectionExceptionAndNotify(exception)
    }
    protected func getConnectionLock1(): Monitor {
        super.getConnectionLock()
    }
    protected func initDebugger1(): Unit {
        super.initDebugger()
    }
    protected func parseAndProcessNonza1(parser: XmlPullParser): Unit {
        super.parseAndProcessNonza(parser)
    }
    protected func parseAndProcessStanza1(parser: XmlPullParser): Unit {
        super.parseAndProcessStanza(parser)
    }
    protected func onStreamOpen1(parser: XmlPullParser): Unit {
        super.onStreamOpen(parser)
    }
}

@Test
public func covReactor(): Unit {
    let o = AbstractXMPPConnection0(config)
    let reactor = o.getReactor0()
    @AssertThrows[IllegalArgumentException](reactor.setReactorThreadCount(-1))
}

class XmppInitializer0 <: XmppInitializer {}

@Test
public func covXmppInitializer(): Unit {
    let o = XmppInitializer0()
    @AssertThrows[UnsupportedException](o.initialize())
}

class XmppInitializer1 <: XmppInitializer {
    XmppInitializer1(let c: Int) {}
    public func initialize(): Collection<Exception> {
        let arr = ArrayList<Exception>()
        for (_ in 0..c) {
            arr.add(Exception("e"))
        }
        arr
    }
}

@Test
public func covXmppInitialization(): Unit {
    XMPP_CONFIG_STARTUP_CLASSES.add(("1", {=> Object()}))
    XMPP_CONFIG_OPTIONAL_STARTUP_CLASSES.add(("2", {=> Object()}))

    XmppInitialization.processConfigFile(ArrayList())

    XmppConfiguration.addDisabledXmppClass("3")
    XMPP_CONFIG_OPTIONAL_STARTUP_CLASSES.add(("3", {=> Object()}))
    XmppInitialization.processConfigFile(None)

    XMPP_CONFIG_STARTUP_CLASSES.add(("4", {=> throw Exception()}))
    XmppInitialization.processConfigFile(ArrayList())
    @AssertThrows[Exception](XmppInitialization.processConfigFile(None))

    XMPP_CONFIG_STARTUP_CLASSES.clear()
    XMPP_CONFIG_STARTUP_CLASSES.add(("5", {=> XmppInitializer1(0)}))
    XmppInitialization.processConfigFile(None)

    XMPP_CONFIG_STARTUP_CLASSES.clear()
    XMPP_CONFIG_STARTUP_CLASSES.add(("6", {=> XmppInitializer1(1)}))
    XmppInitialization.processConfigFile(None)
}

class ExceptionCallback0 <: ExceptionCallback<Exception> {
    public func processException(e: Exception): Unit {
        e.printStackTrace()
    }
}

@Test
public func covXmppFuture(): Unit {
    let f = InternalXmppFuture<Int, Exception>()
    @Assert(f.isCancelled(),false)
    @Assert(f.isDone(),false)
    f.onSuccess({_ => println(1)})
    f.onError(ExceptionCallback0())
    spawn {
        f.setResult(1)
    }
    @Assert(f.get(),1)

    let f2 = XmppFuture.comefrom(2)
    @Assert(f2.cancel(true),false)

    let f3 = InternalXmppFuture<Int, Exception>()
    @Assert(f3.cancel(true))
    @AssertThrows[CancellationException](f3.get())
    @AssertThrows[CancellationException](f3.getOrThrow())
    // @AssertThrows[CancellationException](f3.get(Duration.second))

    f3.setException(Exception())
    @AssertThrows[Exception](f3.get())
    @AssertThrows[Exception](f3.get(Duration.second))

    @AssertThrows[Exception](f3.get(Duration.second*-5))

    f3.setResult(3)
    @AssertThrows[Exception](f3.get(Duration.second))
}

@Test
public func covStanzaCollector(): Unit {
    let c = conn.createStanzaCollector(StanzaCollector.newConfiguration())
    c.getStanzaFilter()
    c.pollResult()
    c.nextResult()
    c.toString()
    spawn{c.pollResultOrThrow()}
    spawn{c.nextResultBlockForever()}
    c.getCollectedCount()
    c.close()
}

@Test
public func covStanzaCollectorConfiguration(): Unit {
    let c = StanzaCollector.newConfiguration()
    c.setSize(10)
    
    let c1 = conn.createStanzaCollector(StanzaCollector.newConfiguration())
    c.setCollectorToReset(c1)
}
func getParser(xml: String): XmlPullParser {
    let byteArrayStream: ByteBuffer = ByteBuffer()
    byteArrayStream.write(xml.toArray())
    let staxXmlPullParserFactory: StaxXmlPullParserFactory = StaxXmlPullParserFactory()
    let staxXmlPullParser = staxXmlPullParserFactory.newXmlPullParser(byteArrayStream)
    staxXmlPullParser
}

@Test
public func covParserUtils(): Unit {
    var parser = getParser("<p/>")
    parser.next()
    ParserUtils.assertAtStartTag(parser, "p")

    parser = getParser("<p jid='a@asd/res'/>")
    parser.next()
    ParserUtils.getJidAttribute(parser)
    ParserUtils.getBareJidAttribute(parser)
    ParserUtils.getFullJidAttribute(parser)
    ParserUtils.getEntityJidAttribute(parser, "jid")
    ParserUtils.getResourcepartAttribute(parser, "jid")

    ParserUtils.parseXmlBool("0")
    ParserUtils.parseXmlBool("false")
    @AssertThrows[IllegalArgumentException](ParserUtils.parseXmlBool("f"))

    parser = getParser("<p i='1'/>")
    parser.next()
    @Assert(ParserUtils.getIntegerAttributeOrThrow(parser, "i", "asd"),1)
    @Assert(ParserUtils.getUInt16Attribute(parser, "i"),1)
    @Assert(ParserUtils.getRequiredUInt16Attribute(parser, "i"),1)
    @Assert(ParserUtils.getLongAttribute(parser, "i", 3),1)
    @Assert(ParserUtils.getUIntAttribute(parser, "i"),1)
    @Assert(ParserUtils.getDoubleAttribute(parser, "i"),1.0)
    @Assert(ParserUtils.getDoubleAttribute(parser, "i", 2),1.0)
    @Assert(ParserUtils.getShortAttribute(parser, "i"),1)
    @Assert(ParserUtils.getShortAttribute(parser, "i",16),1)

    parser = getParser("<p i='1'>2</p>")
    parser.next()
    @Assert(ParserUtils.getIntegerFromNextText(parser),2)

    parser = getParser("<p i='1'>2.1</p>")
    parser.next()
    @Assert(ParserUtils.getDoubleFromNextText(parser),2.1)

    ParserUtils.getDateFromOptionalXep82String("1969-07-21T02:56:15Z")
    ParserUtils.getDateFromXep82String("1969-07-20T21:56:15-05:00")
    ParserUtils.getDateFromString("1969-07-20T21:56:15-05:00")

    parser = getParser("<p i='1'>1969-07-21T02:56:15Z</p>")
    parser.next()
    ParserUtils.getDateFromNextText(parser)

    parser = getParser("<p i='1'>http://qwe.com</p>")
    parser.next()
    ParserUtils.getUriFromNextText(parser)

    parser = getParser("<p i='1'>http://qwe.com</p>")
    parser.next()
    ParserUtils.getRequiredAttribute(parser, "i")
    ParserUtils.getRequiredNextText(parser)

    parser = getParser("<p i='127.0.0.1'>http://qwe.com</p>")
    parser.next()
    ParserUtils.getInternetAddressIngoringZoneIdAttribute(parser, "i")
}

@Test
public func covConnectionListenerBuilder(): Unit {
    let builder = ConnectionListenerBuilder()
    builder.connecting {_ =>}
    builder.connected {_ =>}
    builder.authenticated {_, _ =>}
    builder.connectionClosed {=>}

    @Assert(ConnectionCreationListener({_=>})==ConnectionCreationListener({_=>}), false)
}

@Test
public func covLambdaDebuggerFactory(): Unit {
    LambdaDebuggerFactory.setDebuggerClass(None)
    LambdaDebuggerFactory.setDebuggerClass("None")
    LambdaDebuggerFactory.getDebuggerClass()
}

@Test
public func covSASLXOauth2Mechanism(): Unit {
    let sasl = SASLXOauth2Mechanism()
    sasl.newInstance()
    sasl.checkIfSuccessfulOrThrow()
}

@Test
public func covScheduledAction(): Unit {
    let o = AbstractXMPPConnection0(config)
    let reactor = o.getReactor0()
    let scheduledAction = reactor.schedule({=>}, Duration.Zero, ScheduledActionKind.NonBlocking)
    scheduledAction.cancel()
    scheduledAction.isDue()
    scheduledAction.compare(reactor.schedule({=>}, Duration.Zero, ScheduledActionKind.NonBlocking))
}

@Test
public func covXmpp(): Unit {
    Xmpp.getVersion()
    try{
        Xmpp.getNoticeStream()
    }catch(_){}
    Xmpp.ensureInitialized()
}

@Test
public func covXmpp4cjException(): Unit {
    let c = conn.createStanzaCollector(StanzaCollector.newConfiguration())
    c.getStanzaFilter()
    NoResponseException.newWith(Duration.Zero, c, true)
    let e = NoResponseException.newWith(conn, None)
    e.getFilter()

    NotConnectedException()
    NotConnectedException(conn, None, Exception())
}

@Test
public func covXmppCompressionManager(): Unit {
    XmppCompressionManager.registerXmppCompressionFactory(ZlibXmppCompressionFactory.INSTANCE)
    XmppCompressionManager.registerXmppCompressionFactory(ZlibXmppCompressionFactory.INSTANCE)
}

@Test
public func covXMPPConnectionRegistry(): Unit {
    let obj = ConnectionCreationListener({_=>})
    XMPPConnectionRegistry.removeConnectionCreationListener(obj)
}

@Test
public func covSocketFuture(): Unit {
    let addr = IPAddress.resolve("localhost")[0]
    let saddr = IPSocketAddress(addr, 80)
    let obj = SocketFuture(SocketFactory.DEFAULT, saddr)
    obj.closeSocket()
}

@Test
public func covExecutionException(): Unit {
    var e = ExecutionException(Exception())
    e.toString()
    var e1 = CancellationException()
    e1.toString()
}

@Test
public func covC2sConnectionConfiguration(): Unit {
    var builder = C2sConnectionConfiguration.builder()
    builder.removeModule("asd")
    builder.removeAllModules()

    builder = C2sConnectionConfiguration.builder()
    builder.setXmppDomain("asd")
    let obj = builder.build()
    obj.getStateGraphInDotFormat()
}

public class ModuleDescriptor0 <: ModuleDescriptor {
    protected func getStateDescriptors(): Set<StateDescriptor> {
        HashSet<StateDescriptor>()
    }
    protected func constructXmppConnectionModule(connectionInternal: C2sConnectionInternal): C2sConnectionModule {
        throw Exception()
    }
    public func getClass(): ClassId {
        "ModuleDescriptor0"
    }
}

public class ModuleDescriptorBuilder0 <: ModuleDescriptorBuilder {
    protected init(connectionConfigurationBuilder: C2sConnectionConfigurationBuilder) {
        super(connectionConfigurationBuilder)
    }
    protected func build(): ModuleDescriptor {
        ModuleDescriptor0()
    }
}

@Test
public func covModuleDescriptor(): Unit {
    ModuleDescriptor.getClassId()

    let builder = ModuleDescriptorBuilder0(C2sConnectionConfiguration.builder())
    builder.buildModule()
    let d = builder.build()
    let d1 = builder.build()
    @Assert(d,d1)
}

@Test
public func covClassInfo(): Unit {
    let info = ClassInfo<String>("String", {_ => ""})
    info.hashCode()
    info.toString()
    @Assert(info==ClassInfo<String>("String", {_ => "asd"}))
}

@Test
public func covStateDescriptor(): Unit {
    StateDescriptor.getClassId()
}

@Test
public func covStateMachineException(): Unit {
    XmppMandatoryStateFailedException(unsafe { zeroValue<State>() }, None)
}

@Test
public func covStateTransitionResult(): Unit {
    StateTransitionResultFailure("")
    let e = FailureCausedByException<Exception>(Exception())
    e.getException()
    FailureCausedByTimeout("")
}

class LookupConnectionEndpointsFailed0 <: LookupConnectionEndpointsFailed {}

@Test
public func covNoEndpointsDiscoveredException(): Unit {
    NoEndpointsDiscoveredException.comefrom([])
    NoEndpointsDiscoveredException.comefrom([LookupConnectionEndpointsFailed0()])
}

@Test
public func covExceptionLoggingCallback(): Unit {
    let e = ExceptionLoggingCallback()
    e.handleUnparsableStanza(UnparseableStanza("", Exception()))
}

@Test
public func covExceptionThrowingCallbackWithHint(): Unit {
    let e = ExceptionThrowingCallbackWithHint()
    @AssertThrows[Exception](e.handleUnparsableStanza(UnparseableStanza("", Exception())))
}

@Test
public func covXmlStringBuilder(): Unit {
    let e = XmlStringBuilder()
    let dt: ?DateTime = DateTime.now()
    e.optElement("dt", dt)
    e.optAttribute("dt", dt)
    let i: Int = 4
    e.optElement("i", i)
    e.optIntAttribute("i", i)
    let b: Bool = true
    e.attribute("b", b)
    e.optBooleanAttribute("b", b)
    let tostring: ToString = "Some(asdasd)"
    e.attribute("tostring", tostring)
    let oi: ?Int64 = 7
    e.optAttribute("oi", oi)
    let os: ?String = "aad"
    e.xmlnsAttribute(os)
    let ots: ?ToString = None
    e.optEscape(ots)
}

class ExtensionElement3 <: ExtensionElement & ClassIdentify {
    public static func getClassId(): ClassId {
        "ExtensionElement3"
    }
    public func getClass(): ClassId {
        "ExtensionElement3"
    }
    public func getElementName(): String {
        ""
    }
    public func getNamespace(): String {
        ""
    }
    public func toXML(env: ?XmlEnvironment): ToString {
        ""
    }
}

@Test
public func covXmppElementUtil(): Unit {
    @AssertThrows[Exception](XmppElementUtil.getQNameFor("aaa"))

    let appSpecificElement: ExtensionElement = CompressFeature(ArrayList<String>())
    @AssertThrows[Exception](XmppElementUtil.castOrThrow<ExtensionElement3>(appSpecificElement))
}

@Test
public func covXmppParsingException(): Unit {
    XmppParsingException("asd").toString()
    XmppUriSyntaxParsingException(Exception()).toString()
    XmppRequiredValueMissingException("").toString()
    XmppRequiredAttributeMissingException("").toString()
}

@Test
public func covIntrospectionProvider(): Unit {
    IntrospectionProvider.parseWithIntrospection<Element>
}

@Test
public func covIQProviderInfo(): Unit {
    let o = IQProviderInfo("", "", unsafe { zeroValue<IqProvider<IQ>>() })
    o.getProvider()
}

@Test
public func covProxyException(): Unit {
    let o = ProxyException(ProxyInfoProxyType.HTTP, "")
    ProxyException(ProxyInfoProxyType.SOCKS5)
    o.toString()
}

@Test
public func covProxyInfo(): Unit {
    ProxyInfo.forHttpProxy("asd", 80, "", "")
    let o = ProxyInfo.forSocks5Proxy("asd", 80, "", "")
    o.getProxyType()
    o.getProxyAddress()
    o.getProxyPort()
    o.getProxyUsername()
    o.getProxyPassword()
}

@Test
public func covProxyInfoProxyType(): Unit {
    @Assert(ProxyInfoProxyType.HTTP.toString(),"HTTP")
    @Assert(ProxyInfoProxyType.SOCKS4.toString(),"SOCKS4")
    @Assert(ProxyInfoProxyType.SOCKS5.toString(),"SOCKS5")
    @Assert(ProxyInfoProxyType.HTTP,ProxyInfoProxyType.HTTP)
    @Assert(ProxyInfoProxyType.SOCKS4,ProxyInfoProxyType.SOCKS4)
    @Assert(ProxyInfoProxyType.SOCKS5,ProxyInfoProxyType.SOCKS5)
    @Assert(ProxyInfoProxyType.SOCKS5!=ProxyInfoProxyType.SOCKS4)
}

@Test
public func covProxyType(): Unit {
    @Assert(ProxyType.HTTP.toString(),"HTTP")
    @Assert(ProxyType.SOCKS.toString(),"SOCKS")
    @Assert(ProxyType.DIRECT.toString(),"DIRECT")
    @Assert(ProxyType.HTTP,ProxyType.HTTP)
    @Assert(ProxyType.SOCKS,ProxyType.SOCKS)
    @Assert(ProxyType.DIRECT,ProxyType.DIRECT)
    @Assert(ProxyType.DIRECT!=ProxyType.SOCKS)
}

@Test
public func covSASLErrorException(): Unit {
    let o = SASLErrorException("", SaslNonzaSASLFailure(""), HashMap<String, String>())
    o.getSASLFailure()
    o.getMechanism()
    o.getTexts()
}

@Test
public func covAfterXStanzas(): Unit {
    let o = AfterXStanzas(2)
    o.toString()
}

@Test
public func covForEveryMessage(): Unit {
    ForEveryMessage.INSTANCE.toString()
}

@Test
public func covForEveryStanza(): Unit {
    let o = ForEveryStanza.INSTANCE
    o.accept(unsafe { zeroValue<Stanza>() })
    o.toString()
}

@Test
public func covForMatchingPredicateOrAfterXStanzas(): Unit {
    let o = ForMatchingPredicateOrAfterXStanzas(unsafe { zeroValue<StanzaFilter>() }, 2)
    o.toString()
}

@Test
public func covStreamPredicate(): Unit {
    let o = StreamPredicate.after5Stanzas()
}

@Test
public func covShortcutPredicates(): Unit {
    let o = ShortcutPredicates([])
    o.toString()
    o.addPredicate(StanzaIdFilter("asd"))
    o.removePredicate(StanzaIdFilter("zxc"))
    o.accept(StanzaBuilder.buildMessage().build())
}

@Test
public func covStreamManagementFeature(): Unit {
    let o = StreamManagementFeature.INSTANCE
    o.toXML(None)
}

@Test
public func covStreamManagementEnabled(): Unit {
    let o = StreamManagementEnabled("", true)
    o.getLocation()
    o.getElementName()
    o.toXML(None)
}

@Test
public func covStreamManagementFailed(): Unit {
    let o = StreamManagementFailed()
    o.getStanzaErrorCondition()
    o.getElementName()
    o.getNamespace()
    o.toXML(None)
}

@Test
public func covStreamManagementResumed(): Unit {
    let o = StreamManagementResumed(2, "")
    o.getElementName()
    o.getHandledCount()
    o.getPrevId()
}

@Test
public func covStreamManagementAckRequest(): Unit {
    let o = StreamManagementAckRequest.INSTANCE
    o.getElementName()
    o.getNamespace()
}

@Test
public func covStreamManagementException(): Unit {
    // StreamManagementException()
    // StreamManagementException("")

    StreamManagementNotEnabledException().toString()
    StreamIdDoesNotMatchException("", "").toString()

    let o = StreamManagementCounterError(1, 1, 1, ArrayList<Stanza>())
    o.toString()
    o.getHandledCount()
    o.getPreviousServerHandledCount()
    o.getAckedStanzaCount()
    o.getOutstandingStanzasCount()
    o.getAckedStanzas()
    o.getClassName()

    let q = StreamManagementUnacknowledgedQueueFullException.newWith(1, ArrayList<Element>(),
        CollectionBlockingQueue<Stanza>(1))
    q.toString()
    q.getOverflowElementNum()
    q.getDroppedElements()
    q.getElements()
    q.getUnacknowledgesStanzas()
    q.getClassName()
}

@Test
public func covOnceForThisStanza(): Unit {
    let o = OnceForThisStanza.setup(conn, StanzaBuilder.buildMessage("asd").build())
    // o.toString()
    // o.accept(StanzaBuilder.buildMessage().build())
}

@Test
public func covRemoteXmppTcpConnectionEndpointsDomainType(): Unit {
    // let server = RemoteXmppTcpConnectionEndpointsDomainType.server
    // let client = RemoteXmppTcpConnectionEndpointsDomainType.client
    // @Assert(server,server)
    // @Assert(client,client)
    // @Assert(server!=client)
    // server.fromString()
    // client.fromString()
    // server.toString()
    // client.toString()
}

@Test
public func covRemoteXmppTcpConnectionEndpoints(): Unit {
    let o = RemoteXmppTcpConnectionEndpoints.resolveXmppServerDomain("",
        ArrayList<RemoteConnectionEndpointLookupFailure>(), DnssecMode.disabled)
}

@Test
public func covPacketParserUtils(): Unit {
    var parser = getParser("<p/>")
    parser.next()
    @AssertThrows[IllegalArgumentException](PacketParserUtils.parseStanza(parser, XmlEnvironment.EMPTY))

    PacketParserUtils.parseElementText(parser)

    parser = getParser("<p><p>")
    parser.next()
    @AssertThrows[XmlPullParserException](PacketParserUtils.parseElementText(parser))

    parser = getParser("<p>asd<p>")
    parser.next()
    @AssertThrows[XmlPullParserException](PacketParserUtils.parseElementText(parser))

    parser = getParser("<p>asd</p>")
    PacketParserUtils.parseContentDepth(parser, 1)

    parser = getParser("<body>asd</body>")
    parser.next()
    PacketParserUtils.parseExtensionElement(MessageBody.ELEMENT, MessageBody.NAMESPACE, parser, None)

    parser = getParser("<body>asd</body>")
    parser.next()
    PacketParserUtils.parseExtensionElement("", "", parser, None)

    parser = getParser('<required xmlns="urn:ietf:params:xml:ns:xmpp-tls"><a>asd</a></required>')
    parser.next()
    PacketParserUtils.parseStartTlsFeature(parser)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage(), parser, None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage(), parser, "", "", None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage().build(), parser, None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(StanzaBuilder.buildMessage().build(), parser, "", "", None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(ArrayList<ExtensionElement>(), parser, None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.addExtensionElement(ArrayList<ExtensionElement>(), parser, "", "", None)

    parser = getParser("<p/>")
    parser.next()
    PacketParserUtils.parseDescriptiveTexts(parser, HashMap<String, String>())
}

@Test
public func covConn3(): Unit {
    let conn = AbstractXMPPConnection0(config)
    conn.trySendStanza(StanzaBuilder.buildMessage().build())
    @AssertThrows[AssertionError](conn.throwCurrentConnectionException1())
    conn.setCurrentConnectionExceptionAndNotify1(FailedNonzaException(Compressed.INSTANCE))
    @AssertThrows[FailedNonzaException](conn.throwCurrentConnectionException1())
    conn.getConnectionLock1()
    @AssertThrows[NoneValueException](conn.initDebugger1())
    
    var parser = getParser("<p/>")
    parser.next()
    conn.parseAndProcessNonza1(parser)
    @AssertThrows[Exception](conn.parseAndProcessStanza1(parser))
}
