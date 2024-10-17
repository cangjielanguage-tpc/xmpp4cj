// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_AbstractProviderInfo1(): Unit {
    let messageSubject: String = "This is a test of the emergency broadcast system."
    let message: Message = StanzaBuilder.buildMessage().setSubject(messageSubject).build()
    let testAbstractProviderInfo: TestAbstractProviderInfo = TestAbstractProviderInfo("elementName", "namespace",
        message)
    @Assert("elementName", testAbstractProviderInfo.getElementName())
    @Assert("namespace", testAbstractProviderInfo.getNamespace())
    @Assert(true, testAbstractProviderInfo.getProvider() is Message)
}

class TestAbstractProviderInfo <: AbstractProviderInfo {
    init(elementName: String, namespace: String, iqOrExtProvider: Object) {
        super(elementName, namespace, iqOrExtProvider)
    }
}

@Test
public func test_BindIQProvider1(): Unit {
    let oriIqData = StanzaBuilder.buildIqData(Some("IqData stanzaId"))
    let actSB: IqData = StanzaBuilder.buildResponse<IqData>(oriIqData, getIqData)
    let bindIQProvider: BindIQProvider = BindIQProvider()
    let e0: IndexOutOfBoundsException = @AssertThrows[IndexOutOfBoundsException](bindIQProvider.parse(StaxXmlPullParser(ByteArrayStream()), 0, actSB, None))
    @Assert("IndexOutOfBoundsException", e0.toString())
}

public func getIqData(stanzaId: ?String): IqData {
    return StanzaBuilder.buildIqData(stanzaId)
}

@Test
public func test_BodyElementProvider1(): Unit {
    let bodyElementProvider: BodyElementProvider = BodyElementProvider()
    let e0: Exception = @AssertThrows[Exception](bodyElementProvider.parse(StaxXmlPullParser(ByteArrayStream()), 0, None))
    @Assert("Exception: AssertionError", e0.toString())
}

@Test
public func test_ExtensionProviderInfo1(): Unit {
    let extensionProviderInfo: ExtensionProviderInfo = ExtensionProviderInfo("elementName", "namespace",
        ExtensionElementProvider01())
    extensionProviderInfo.getProvider()
}

class ExtensionElementProvider01 <: ExtensionElementProvider<ExtensionElement> {
    init() {
        super("ExtensionElement")
    }
    public func parse(parser: XmlPullParser, initialDepth: Int64, xmlEnvironment: ?XmlEnvironment): ExtensionElement {
        throw Exception()
    }
}

@Test
public func test_IntrospectionProvider1(): Unit {
}

@Test
public func test_TlsProceedProvider1(): Unit {
    let staxXmlPullParser: StaxXmlPullParser = StaxXmlPullParser(ByteArrayStream())
    let tlsProceedProvider: TlsProceedProvider = TlsProceedProvider.INSTANCE
    @Assert("failure", tlsProceedProvider.parse(staxXmlPullParser, 0, None).getElementName())
}
