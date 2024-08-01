// DEPENDENCE: z_test.cj strings_test_frame_work.cj
// EXEC: cjc %import-path %L %l %f z_test.cj strings_test_frame_work.cj --test
// EXEC: ./main 

@Test
public class StringsTestframeworkTest {
    private static let VALID_JID_CORPUS_SIZE = 22
    private static let INVALID_JID_CORPUS_SIZE = 24

    @TestCase
    public func testStringsTestframeworkIsSuccessful(): Unit {
        var state = XmppStringPrepperState(SimpleXmppStringprep.getInstance(), ValidJids.size)
        for (jid in ValidJids) {
            // println("${jid.toString()}")
            testValidJids(state, jid)
        }
        // for (jid in state.validJidFailedTestresults) {
        //     println("${jid.jid} ${jid.e} ${jid.jid.jid}")
        // }
        @Assert(state.validJidFailedTestresults.size+state.validJidSuccessfulTestresults.size, ValidJids.size)
        KnownFailures.checkAgainstWhitelist(state.validJidFailedTestresults)
        @Assert(state.validJidFailedTestresults.size, 0)

        state = XmppStringPrepperState(SimpleXmppStringprep.getInstance(), InvalidJids.size)
        for (jid in InvalidJids) {
            testInvalidJids(state, jid)
        }
        @Assert(state.invalidJidFailedTestresults.size+state.invalidJidSuccessfulTestresults.size, state.jidCorpusSize)
        KnownFailures.checkAgainstWhitelist(state.invalidJidFailedTestresults)
        @Assert(state.invalidJidFailedTestresults.size, 0)
    }
    @TestCase
    public func testValidJidCorpusSize(): Unit {
        // let validJids = StringsTestframework.parseValidJids()
        @Assert(VALID_JID_CORPUS_SIZE, ValidJids.size)
    }
    @TestCase
    public func testInvalidJidCorpusSize(): Unit {
        // let invalidJids = StringsTestframework.parseInvalidJids()
        @Assert(INVALID_JID_CORPUS_SIZE, InvalidJids.size)
    }
}
