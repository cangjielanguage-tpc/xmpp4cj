// DEPENDENCE: ../z_test.cj ../jid_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj jid_test_util.cj --test
// EXEC: ./main 

@Test
public class XmppConfigurationTest {
    /**
     * 测试是Xmpp能够在不抛出Throwable的情况下初始化自己
     */
    @TestCase
    public func testXmppConfiguration() {
        XmppConfiguration.getDefaultReplyTimeout()
    }

    @TestCase
    public func xmppConfigurationShouldNotCauseInitializationTest() {
        XmppConfiguration.getDefaultReplyTimeout()
        // 对标库和仓颉特性不同，仓颉不需要初始化，java需要初始化
        assertTrue(XmppConfiguration.isXmppInitialized())
    }

    @TestCase
    public func xmppEnsureInitializedShouldInitialzieXmpptTest() {
        Xmpp.ensureInitialized()
        assertTrue(XmppConfiguration.isXmppInitialized())
    }
}
