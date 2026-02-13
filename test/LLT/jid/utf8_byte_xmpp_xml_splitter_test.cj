// DEPENDENCE: z_test.cj xml_splitter_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_splitter_test_util.cj --test
// EXEC: ./main 

@Test
public class Utf8ByteXmppXmlSplitterTest {
    @TestCase
    public func simpleTest0to7f(): Unit {
        let stanza = "<message from=\'foo\' to=\'bar\'><body>Hi</body></message>"
        testUtf8ByteSplitter([stanza])
    }

    @TestCase
    public func simpleTest80to7ff(): Unit {
        let stanza = "<message from=\'foo\' to=\'bar\'><body>Section Sign (0xA7): \u{00a7}</body></message>"
        testUtf8ByteSplitter([stanza])
    }

    @TestCase
    public func simpleTest800toffff(): Unit {
        let stanza = "<message from=\'foo\' to=\'bar\'><body>Euro Sign (0x20AC): \u{20ac}</body></message>"
        testUtf8ByteSplitter([stanza])
    }

    @TestCase
    public func simpleTest10000to1fffff(): Unit {
        let greekAcrophonicAtticOneHalf = forCodepoint(0x10141)
        let stanza: String = "<message from=\'foo\' to=\'bar\'><body>GREEK ACROPHONIC ATTIC ONE HALF (0x10141): " + (greekAcrophonicAtticOneHalf) +
            "</body></message>"
        testUtf8ByteSplitter([stanza])
    }

    private static func testUtf8ByteSplitter(elements: Array<String>): Unit {
        let queue: LinkedList<String> = LinkedList<String>()
        let bytesArray = ArrayList<UInt8>()
        for (element in elements) {
            queue.addLast(element)
            let utf8bytes = element.toArray()
            for (b in utf8bytes) {
                bytesArray.add(b)
            }
        }
        let utf8bytes = Array<UInt8>(bytesArray.size) {_ => 0}
        var i = 0
        while (i < Int64(bytesArray.size)) {
            utf8bytes[Int64(i)] = UInt8(bytesArray[Int64(i)])
            i++
        }
        let splitter = Utf8ByteXmppXmlSplitter(XmlSplitterTestUtil.transform(Utf8ByteXmppXmlSplitterTest_1(queue)))
        // splitter.resetWriteBuffer(1)
        splitter.write(utf8bytes)
        Assert.assertTrue(queue.isEmpty())
    }

    @TestCase
    public func simpleByteBufferArrayWriteTest(): Unit {
        let stanza1 = "<message from=\'foo\' to=\'bar\'><body>Hi there</body></message>"
        let stanza2 = "<message from=\'foo\' to=\'bar\'><body>My name is John</body></message>"
        testUtf8ByteSplitterByteBufferArray([stanza1, stanza2])
    }

    private static func testUtf8ByteSplitterByteBufferArray(elements: Array<String>): Unit {
        let queue: LinkedList<String> = LinkedList<String>()
        let byteBufferArray = ArrayList<ByteBuffer>()
        for (element in elements) {
            queue.addLast(element)
            let utf8bytes = element.toArray()
            let byteBuffer = ByteBuffer()
            byteBuffer.write(utf8bytes)
            byteBufferArray.add(byteBuffer)
        }
        let splitter = Utf8ByteXmppXmlSplitter(XmlSplitterTestUtil.transform(Utf8ByteXmppXmlSplitterTest_2(queue)))
        // splitter.resetWriteBuffer(1)
        splitter.write(byteBufferArray.toArray())
        Assert.assertTrue(queue.isEmpty())
    }

    private static func forCodepoint(codepoint: Int64): String {
        return Rune(codepoint).toString()
    }
}

class Utf8ByteXmppXmlSplitterTest_1 <: CompleteElementCallback {
    let val_queue: LinkedList<String>

    init(val_queue: LinkedList<String>) {
        this.val_queue = val_queue
    }

    public override func onCompleteElement(completeElement: String): Unit {
        let nextElement = val_queue.removeFirst()
        Assert.assertEquals(nextElement, completeElement)
    }
}

class Utf8ByteXmppXmlSplitterTest_2 <: CompleteElementCallback {
    let val_queue: LinkedList<String>

    init(val_queue: LinkedList<String>) {
        this.val_queue = val_queue
    }

    public override func onCompleteElement(completeElement: String): Unit {
        let nextElement = val_queue.removeFirst()
        Assert.assertEquals(nextElement, completeElement)
    }
}
