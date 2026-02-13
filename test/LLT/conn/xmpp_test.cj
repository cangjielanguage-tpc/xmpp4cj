// DEPENDENCE: ../z_test.cj ../jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main 

@Test
public class XmppTest {
    @TestCase
    public func getNoticeStreamTest() {
        let expectedStrings: Set<String> = HashSet(
            "Florian Schmaus",
            "Paul Schaub"
        )
        var maxLineLength: Int64 = 0
        // TODO
        // let inputStream: InputStream = Xmpp.getNoticeStream()
        // let stringReader: StringReader<InputStream> = StringReader<InputStream>(inputStream)
        // var iteratorString: Iterator<String> = stringReader.lines()
        // var str: ?String = iteratorString.next()
        // while (str.isNone()) {
        //     let str0 = str.getOrThrow()
        //     let lineLength = str0.size
        //     maxLineLength = if (maxLineLength > lineLength) {
        //         maxLineLength
        //     } else {
        //         lineLength
        //     }
        //     expectedStrings.removeIf({
        //         s => return str0 == s
        //     })
        //     str = iteratorString.next()
        // }
        // assertTrue(expectedStrings.isEmpty())
        // assertTrue(maxLineLength < 60)
    }
}
