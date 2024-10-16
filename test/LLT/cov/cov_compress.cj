// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

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
    let compressed: Compressed = compressedProvider.parse(StaxXmlPullParser(ByteArrayStream()), 0, None)
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
    let e0: Exception = @AssertThrows[Exception](parseCompressionFeature(StaxXmlPullParser(ByteArrayStream())))
    @Assert("Exception: AssertionError", e0.toString())
    let xmppXmlString: Array<Byte> = """
<iq type='get'><query xmlns='jabber:iq:roster'/></iq>
<presence/>
<message to='william_duan@jabber.org' from='test_account@jabber.org' type='chat'><body>Hello</body></message>
<presence type='unavailable'/>""".
        toArray()
    let byteArrayStream: ByteArrayStream = ByteArrayStream()
    byteArrayStream.write(xmppXmlString)
    let staxXmlPullParser: StaxXmlPullParser = StaxXmlPullParser(byteArrayStream)
    let e1: Exception = @AssertThrows[Exception](parseCompressionFeature(staxXmlPullParser))
    @Assert("Exception: AssertionError", e1.toString())
}
