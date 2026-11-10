let STREAM_OPEN_SUBSTITUTE = "<stream>"
let STREAM_CLOSE_SUBSTITUTE = "</stream>"

public abstract class SplittedPart {
    let part: String

    protected init(part: String) {
        this.part = part
    }

    public func toString(): String {
        return part
    }
}

public class Declaration <: SplittedPart {
    init(part: String) {
        super(part)
    }
}

public class ProcessingInstruction <: SplittedPart {
    init(part: String) {
        super(part)
    }
}

public class Element <: SplittedPart {
    init(part: String) {
        super(part)
    }
}

public interface XmlSplitterFactory {

    /**
     * Returns a new {@link XmlSplitter} configured with the given callback.
     *
     * @param callback the complete element callback.
     * @param declarationCallback a optional callback for the XML declaration.
     * @param processingInstructionCallback a optional callback for Processing Instructions.
     * @return a new splitter.
     */
    func createXmlSplitter(
        callback: CompleteElementCallback,
        declarationCallback: DeclarationCallback,
        processingInstructionCallback: ProcessingInstructionCallback
    ): XmlSplitter
}

class XmlSplitterFactoryDefault <: XmlSplitterFactory {
    XmlSplitterFactoryDefault(
        let f: (CompleteElementCallback, DeclarationCallback, ProcessingInstructionCallback) -> XmlSplitter) {}
    public func createXmlSplitter(
        callback: CompleteElementCallback,
        declarationCallback: DeclarationCallback,
        processingInstructionCallback: ProcessingInstructionCallback
    ): XmlSplitter {
        f(callback, declarationCallback, processingInstructionCallback)
    }
}

class XmppElementCallbackDefault <: XmppElementCallback {
    XmppElementCallbackDefault(let completeElementCallback: CompleteElementCallback) {}
    public func onCompleteElement(completeElement: String): Unit {
        completeElementCallback.onCompleteElement(completeElement)
    }
    public func streamOpened(prefix: String, attributes: Map<String, String>): Unit {
        onCompleteElement(STREAM_OPEN_SUBSTITUTE)
    }
    public func streamClosed(): Unit {
        onCompleteElement(STREAM_CLOSE_SUBSTITUTE)
    }
}

public class CompleteElementCallback1 <: CompleteElementCallback {
    CompleteElementCallback1(let callback: CompleteElementCallback) {}
    public override func onCompleteElement(completeElement: String): Unit {
        callback.onCompleteElement(completeElement)
    }
}

public class CompleteElementCallback2 <: CompleteElementCallback {
    CompleteElementCallback2(let queue: LinkedList<SplittedPart>, let invoked: AtomicBool) {}
    public override func onCompleteElement(completeElement: String): Unit {
        invoked.store(true)

        let element: Element = XmlSplitterTestUtil.getExpectedPartAndAssertType(queue)
        var stanza: String = element.part

        // This assumes that all stream open and close elements use
        // 'stream' as xmlns prefix. Which may not be true for all real
        // world XMPP cases.
        if (stanza.startsWith("<stream:stream")) {
            stanza = STREAM_OPEN_SUBSTITUTE
        } else if (stanza.startsWith("</stream:stream")) {
            stanza = STREAM_CLOSE_SUBSTITUTE
        }

        assertEquals(stanza, completeElement)
    }
}

public class DeclarationCallback2 <: DeclarationCallback {
    DeclarationCallback2(let queue: LinkedList<SplittedPart>, let declarationCallbackInvoked: AtomicBool) {}
    public override func onDeclaration(declaration: String): Unit {
        declarationCallbackInvoked.store(true)

        let expectedDeclaration: Declaration = XmlSplitterTestUtil.getExpectedPartAndAssertType(queue)

        assertEquals(expectedDeclaration.part, declaration)
    }
}

public class ProcessingInstructionCallback2 <: ProcessingInstructionCallback {
    ProcessingInstructionCallback2(
        let queue: LinkedList<SplittedPart>,
        let processingInstructionCallbackInvoked: AtomicBool
    ) {}
    public override func onProcessingInstruction(processingInstruction: String): Unit {
        processingInstructionCallbackInvoked.store(true)

        let expectedProcessingInstruction: ProcessingInstruction = XmlSplitterTestUtil.getExpectedPartAndAssertType(
            queue)

        assertEquals(expectedProcessingInstruction.part, processingInstruction)
    }
}

public class XmlSplitterTestUtil {
    public static func xmlSplitterTest(elements: Array<String>): Unit {
        let elementParts: Array<Element> = elementsFrom(elements)

        splitterTest(
            XmlSplitterFactoryDefault(
                {
                callback: CompleteElementCallback, declarationCallback: DeclarationCallback, 
                processingInstructionCallback: ProcessingInstructionCallback => return XmlSplitter(4096, callback)
            }),
            elementParts
        )
    }

    public static func xmppSplitterTest(elements: Array<String>): Unit {
        let elementParts: Array<Element> = elementsFrom(elements)
        xmppSplitterTest(elementParts)
    }

    public static func xmppSplitterTest<T>(splittedParts: Array<T>): Unit where T <: SplittedPart {
        splitterTest(
            XmlSplitterFactoryDefault(
                {
                callback: CompleteElementCallback, declarationCallback: DeclarationCallback, 
                processingInstructionCallback: ProcessingInstructionCallback => XmppXmlSplitter(
                    transform(CompleteElementCallback1(callback)))
            }),
            splittedParts
        )
    }

    public static func transform(completeElementCallback: CompleteElementCallback): XmppElementCallback {
        return XmppElementCallbackDefault(completeElementCallback)
    }

    public static func splitterTest<T>(xmlSplitterFactory: XmlSplitterFactory, parts: Array<T>): Unit where T <: SplittedPart {
        let queue: LinkedList<SplittedPart> = LinkedList<SplittedPart>()
        let xml: StringBuilder = StringBuilder()

        var hasDeclarationPart = false
        var hasProcessingInstructionPart = false
        var hasElementPart = false

        for (part in parts) {
            if (part is Declaration) {
                hasDeclarationPart = true
            } else if (part is ProcessingInstruction) {
                hasProcessingInstructionPart = true
            } else if (part is Element) {
                hasElementPart = true
            }

            queue.addLast(part)
            xml.append(part.part)
        }

        let invoked: AtomicBool = AtomicBool(false)
        let declarationCallbackInvoked: AtomicBool = AtomicBool(false)
        let processingInstructionCallbackInvoked: AtomicBool = AtomicBool(false)

        try (splitter = xmlSplitterFactory.createXmlSplitter(
            CompleteElementCallback2(queue, invoked),
            DeclarationCallback2(queue, declarationCallbackInvoked),
            ProcessingInstructionCallback2(queue, processingInstructionCallbackInvoked)
        )) {
            splitter.write(xml.toString().toRuneArray())
        }

        assertTrue(queue.isEmpty())

        assertEquals(hasElementPart, invoked.load())
        assertEquals(hasDeclarationPart, declarationCallbackInvoked.load())
        assertEquals(hasProcessingInstructionPart, processingInstructionCallbackInvoked.load())
    }

    static func getExpectedPartAndAssertType<P>(queue: LinkedList<SplittedPart>): P where P <: SplittedPart {
        let part: ?SplittedPart = queue.removeFirst()
        assertNotNull(part)
        assertTrue("The part ${part?.toString()} is not an instance of P", part.getOrThrow() is P)

        return (part.getOrThrow() as P).getOrThrow()
    }

    public static func decl(declaration: String): Declaration {
        return Declaration(declaration)
    }

    public static func pi(processingInstruction: String): ProcessingInstruction {
        return ProcessingInstruction(processingInstruction)
    }

    public static func elem(element: String): Element {
        return Element(element)
    }

    public static func elementsFrom(elements: Array<String>): Array<Element> {
        let elementParts: Array<Element> = Array<Element>(elements.size) {
            i => elem(elements[i])
        }
        return elementParts
    }
}
