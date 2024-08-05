// DEPENDENCE: z_test.cj 
// EXEC: cjc %import-path %L %l %f z_test.cj  --test
// EXEC: ./main
@Test
public class XmlPrettyPrinterTest {
    @TestCase
    public func simplePrettyPrintTest(): Unit {
        let inputXml = "<o><i a=\'v\'>t</i></o>"
        let expectedPrettyPrintedXml = "<o>\n  <i a=\'v\'>\n    t\n  </i>\n</o>"
        let xmlPrettyPrinterBuilder = XmlPrettyPrinter.builder()
        xmlPrettyPrintTest(expectedPrettyPrintedXml, inputXml, xmlPrettyPrinterBuilder)
    }
    @TestCase
    public func simplePrettyPrintTestAttributeIndent(): Unit {
        let inputXml = "<o><i a=\'v\'>t</i></o>"
        let expectedPrettyPrintedXml = "<o>\n  <i \n   a=\'v\'>\n    t\n  </i>\n</o>"
        let xmlPrettyPrinterBuilder = XmlPrettyPrinter.builder().setAttributeIndent(1)
        xmlPrettyPrintTest(expectedPrettyPrintedXml, inputXml, xmlPrettyPrinterBuilder)
    }
    @TestCase
    public func simplePrettyPrintTestTabIndent(): Unit {
        let inputXml = "<o><i a=\'v\'>t</i></o>"
        let expectedPrettyPrintedXml = "<o>\n\t<i a=\'v\'>\n\t\tt\n\t</i>\n</o>"
        let xmlPrettyPrinterBuilder = XmlPrettyPrinter.builder().setTabWidth(2)
        xmlPrettyPrintTest(expectedPrettyPrintedXml, inputXml, xmlPrettyPrinterBuilder)
    }

    private static func xmlPrettyPrintTest(expectedPrettyPrintedXml: String, inputXml: String,
        xmlPrettyPrinterBuilder: XmlPrettyPrinter_Builder): Unit {
        let stringHolder = XmlPrettyPrinterTest_StringHolder()
        let xmlPrettyPrinter = xmlPrettyPrinterBuilder.setPartCallback(XmlPrettyPrinterTest_1(stringHolder)).build()
        let xmlSplitter = XmlSplitter(1024, XmlPrettyPrinterTest_2(), xmlPrettyPrinter)
        try {
            xmlSplitter.write(inputXml.toRuneArray())
        } finally {
            xmlSplitter.close()
        }
        Assert.assertEquals(expectedPrettyPrintedXml, stringHolder.string)
    }
}

class XmlPrettyPrinterTest_StringHolder {
    public var string: String = ""
}

class XmlPrettyPrinterTest_1 <: XmlPrettyPrinter_PrettyPrintedXmlPartCallback {
    let val_stringHolder: XmlPrettyPrinterTest_StringHolder

    init(val_stringHolder: XmlPrettyPrinterTest_StringHolder) {
        this.val_stringHolder = val_stringHolder
    }

    public override func onPrettyPrintedXmlPart(part: StringBuilder): Unit {
        val_stringHolder.string = part.toString()
    }
}

class XmlPrettyPrinterTest_2 <: CompleteElementCallback {
    public override func onCompleteElement(completeElement: String): Unit {}
}
