// 3rd_party_lib:xmpp4cj/target/release/xmpp4cj
// 3rd_party_lib_ohos:xmpp4cj/target/aarch64-linux-ohos/xmpp4cj
// dependence: ../commonHLT.cj


@Test
public class TestReconnectionManager{
    @TestCase
    func test_getEnabledPerDefault_01(): Unit {
        @Assert(ReconnectionManager.getEnabledPerDefault(),false)
    }
}