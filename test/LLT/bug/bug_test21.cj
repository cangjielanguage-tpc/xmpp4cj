// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

internal import stdx.encoding.url.{URL, Form}

@Test
public class TestXmpp4cjJidCreateFroms {
    @TestCase
    func test_JidCreate_fromUrlEncoded_01(): Unit {
        let jid = JidCreate.fromUrlEncoded("http://www.baidu.com/index")
        @Assert("http:", jid.getDomain().toString())
        @Assert("/www.baidu.com/index", jid.getResourceOrThrow().toString())
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.getLocalpartOrThrow())
        @Assert("IllegalStateException: The JID 'http://www.baidu.com/index' has no localpart", e.toString())
    }

    @TestCase
    func test_JidCreate_fromUrlEncoded_02(): Unit {
        let jid = JidCreate.fromUrlEncoded("http://www.baidu.com/index?name=kitty&age=12")
        @Assert("http:", jid.getDomain().toString())
        @Assert("/www.baidu.com/index?name=kitty&age=12", jid.getResourceOrThrow().toString())
        let e: IllegalStateException = @AssertThrows[IllegalStateException](jid.getLocalpartOrThrow())
        @Assert("IllegalStateException: The JID 'http://www.baidu.com/index?name=kitty&age=12' has no localpart", e.toString())
    }
}
