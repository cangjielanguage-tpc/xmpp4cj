// DEPENDENCE: z_test.cj jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main

@Test
public class JidUtilTest {
    @TestCase
    public func testEquals(): Unit {
        Assert.assertTrue(JidUtil.equals(None, None))
        Assert.assertFalse(JidUtil.equals(None, JidTestUtil.BARE_JID_1))
        Assert.assertFalse(JidUtil.equals(JidTestUtil.BARE_JID_1, None))
        Assert.assertTrue(JidUtil.equals(JidTestUtil.BARE_JID_1, JidTestUtil.BARE_JID_1))
        Assert.assertFalse(JidUtil.equals(JidTestUtil.BARE_JID_1, JidTestUtil.BARE_JID_2))
    }
}
