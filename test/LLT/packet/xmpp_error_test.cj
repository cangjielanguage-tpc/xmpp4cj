// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../jid_test_util.cj
// DEPENDENCE: ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj xml_test_utils.cj --test
// EXEC: ./main 
//--filter=*.setPresenceModeTest

@Test
public class XMPPErrorTest {
    @TestCase
    public func testConditionHasDefaultTypeMapping(): Unit {
        // let conditionToTypeMap: Map<StanzaErrorCondition, StanzaErrorType> = StanzaError.CONDITION_TO_TYPE
        // assertEquals(
        //     "CONDITION_TO_TYPE map is likely out of sync with Condition enum",
        //     22, // StanzaErrorCondition.values().length
        //     conditionToTypeMap.size
        // )
    }
}
