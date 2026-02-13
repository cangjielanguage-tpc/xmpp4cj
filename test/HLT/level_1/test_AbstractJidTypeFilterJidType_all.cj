// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjAbstractJidTypeFilterJidType{
    @TestCase
    func test_AbstractJidTypeFilterJidType_operator_1(): Unit {
        @Assert(AbstractJidTypeFilterJidType.entityFull==AbstractJidTypeFilterJidType.entityFull,true)
        @Assert(AbstractJidTypeFilterJidType.entityFull==AbstractJidTypeFilterJidType.entityBare,false)
        @Assert(AbstractJidTypeFilterJidType.entityFull==AbstractJidTypeFilterJidType.domainFull,false)
        @Assert(AbstractJidTypeFilterJidType.entityFull==AbstractJidTypeFilterJidType.domainBare,false)
        @Assert(AbstractJidTypeFilterJidType.entityFull==AbstractJidTypeFilterJidType.any,false)

        @Assert(AbstractJidTypeFilterJidType.entityBare==AbstractJidTypeFilterJidType.entityBare,true)
        @Assert(AbstractJidTypeFilterJidType.entityBare==AbstractJidTypeFilterJidType.domainFull,false)
        @Assert(AbstractJidTypeFilterJidType.entityBare==AbstractJidTypeFilterJidType.domainBare,false)
        @Assert(AbstractJidTypeFilterJidType.entityBare==AbstractJidTypeFilterJidType.any,false)


        @Assert(AbstractJidTypeFilterJidType.domainFull==AbstractJidTypeFilterJidType.domainFull,true)
        @Assert(AbstractJidTypeFilterJidType.domainFull==AbstractJidTypeFilterJidType.domainBare,false)
        @Assert(AbstractJidTypeFilterJidType.domainFull==AbstractJidTypeFilterJidType.any,false)

        @Assert(AbstractJidTypeFilterJidType.domainBare==AbstractJidTypeFilterJidType.domainBare,true)
        @Assert(AbstractJidTypeFilterJidType.domainBare==AbstractJidTypeFilterJidType.any,false)

        @Assert(AbstractJidTypeFilterJidType.any==AbstractJidTypeFilterJidType.any,true)
    }
    @TestCase
    func test_AbstractJidTypeFilterJidType_toString_1(): Unit {
        @Assert(AbstractJidTypeFilterJidType.entityFull.toString(),"entityFull")
        @Assert(AbstractJidTypeFilterJidType.entityBare.toString(),"entityBare")
        @Assert(AbstractJidTypeFilterJidType.domainFull.toString(),"domainFull")
        @Assert(AbstractJidTypeFilterJidType.domainBare.toString(),"domainBare")
        @Assert(AbstractJidTypeFilterJidType.any.toString(),"any")
    }
}
