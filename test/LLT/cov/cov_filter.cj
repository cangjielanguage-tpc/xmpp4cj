// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test
// EXEC: ./main

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
    let jidTypeAbstractJidTypeFilterJidType0: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        BareJid
    let jidTypeAbstractJidTypeFilterJidType1: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        DomainBareJid
    let jidTypeAbstractJidTypeFilterJidType2: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        DomainFullJid
    let jidTypeAbstractJidTypeFilterJidType3: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        DomainJid
    let jidTypeAbstractJidTypeFilterJidType4: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        EntityBareJid
    let jidTypeAbstractJidTypeFilterJidType5: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        EntityFullJid
    let jidTypeAbstractJidTypeFilterJidType6: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        EntityJid
    let jidTypeAbstractJidTypeFilterJidType7: JidTypeAbstractJidTypeFilterJidType = JidTypeAbstractJidTypeFilterJidType.
        FullJid

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
        ByteArrayStream())
    @Assert(false, xmppInputOutputFilterOutputResult0.pendingFilterData)
}
