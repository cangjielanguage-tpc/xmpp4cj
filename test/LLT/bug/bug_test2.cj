// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class TestXmpp4cjIqBuilder {
    @TestCase
    func test_IqBuilder_ofType_01(): Unit {
        let e: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StanzaError(StanzaErrorCondition.internal_server_error,"conditionTextString","errorGenerator",StanzaErrorType.MODIFY,HashMap<String,String>(),Array<ExtensionElement>()))
        @Assert("IllegalArgumentException: StanzaErrorCondition text can only be set with condtion types 'gone' and 'redirect', not internal-server-error", e.toString())
    }
}
