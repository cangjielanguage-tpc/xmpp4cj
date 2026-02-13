// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// dependence: ../commonHLT.cj

@Test
public class TestXmpp4cjStanzaIdFilter{

    @TestCase
    func test_StanzaIdFilter_test_8(): Unit {
        let e:IllegalArgumentException=@AssertThrows[IllegalArgumentException](StanzaIdFilter(None<String>))
        @Assert(e.toString(),"IllegalArgumentException: Stanza ID must not be null nor empty.")
    }
}
