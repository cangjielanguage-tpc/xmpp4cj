// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../xml_test_utils.cj
// EXEC: cjc %import-path %L %l %f z_test.cj xml_test_utils.cj --test
// EXEC: ./main

internal import xmpp4cj.packet.*
internal import encoding.hex.*

/**
 * A test case for the StringUtils class.
 */
@Test
public class StringUtilsTest {
    @TestCase
    public func testEscapeForXml(): Unit {
        // assertNull(StringUtils.escapeForXml(None))

        var input: String = "<b>"
        assertCharSequenceEquals("&lt;b&gt;", StringUtils.escapeForXml(input))

        input = "\""
        assertCharSequenceEquals("&quot;", StringUtils.escapeForXml(input))

        input = "&"
        assertCharSequenceEquals("&amp;", StringUtils.escapeForXml(input))

        input = "<b>\n\t\r</b>"
        assertCharSequenceEquals("&lt;b&gt;\n\t\r&lt;/b&gt;", StringUtils.escapeForXml(input))

        input = "   &   "
        assertCharSequenceEquals("   &amp;   ", StringUtils.escapeForXml(input))

        input = "   \"   "
        assertCharSequenceEquals("   &quot;   ", StringUtils.escapeForXml(input))

        input = "> of me <"
        assertCharSequenceEquals("&gt; of me &lt;", StringUtils.escapeForXml(input))

        input = "> of me & you<"
        assertCharSequenceEquals("&gt; of me &amp; you&lt;", StringUtils.escapeForXml(input))

        input = "& <"
        assertCharSequenceEquals("&amp; &lt;", StringUtils.escapeForXml(input))

        input = "&"
        assertCharSequenceEquals("&amp;", StringUtils.escapeForXml(input))

        input = "It's a good day today"
        assertCharSequenceEquals("It&apos;s a good day today", StringUtils.escapeForXml(input))
    }

    public static func assertCharSequenceEquals(expected: CharSequence, actual: CharSequence): Unit {
        assertEquals(expected.toString(), actual.toString())
    }

    @TestCase
    public func testEncodeHex(): Unit {
        var input: String = ""
        var output: String = ""
        assertEquals(toHexString(input.toArray()), output)

        input = "foo bar 123"
        output = "666f6f2062617220313233"
        assertEquals(toHexString(input.toArray()), output)
    }

    @TestCase
    public func testRandomString(): Unit {
        var result: String

        // Test various lengths - make sure the same length is returned
        result = StringUtils.randomString(4)
        assertTrue(result.size == 4)
        result = StringUtils.randomString(16)
        assertTrue(result.size == 16)
        result = StringUtils.randomString(128)
        assertTrue(result.size == 128)
    }

    @TestCase
    public func testNegativeArraySizeException(): Unit {
        // Boundary test
        @AssertThrows[NegativeArraySizeException](StringUtils.randomString(-1))
    }

    @TestCase
    public func testZeroLengthRandomString(): Unit {
        // Zero length string test
        let result: String = StringUtils.randomString(0)
        assertEquals("", result)
    }

    @TestCase
    public func testeDeleteXmlWhitespace(): Unit {
        var noWhitespace: String = StringUtils.deleteXmlWhitespace(" foo\nbar ")
        assertEquals("foobar", noWhitespace)

        noWhitespace = StringUtils.deleteXmlWhitespace(" \tbaz\rbarz\t ")
        assertEquals("bazbarz", noWhitespace)

        noWhitespace = StringUtils.deleteXmlWhitespace("SNAFU")
        assertEquals("SNAFU", noWhitespace)
    }
}
