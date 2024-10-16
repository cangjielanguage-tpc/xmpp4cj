// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class FilterToStringTest {
    @TestCase
    func abstractListFilterToStringTest() {
        let andFilter: AndFilter = AndFilter()
        andFilter.addFilter(StanzaIdFilter("foo"))
        andFilter.addFilter(ThreadFilter("42"))
        andFilter.addFilter(MessageWithBodiesFilter.INSTANCE)
        let res: String = andFilter.toString()
        @Assert(res,"AndFilter: (StanzaIdFilter: id=foo, ThreadFilter: thread=42, MessageWithBodiesFilter)")
    }
}
