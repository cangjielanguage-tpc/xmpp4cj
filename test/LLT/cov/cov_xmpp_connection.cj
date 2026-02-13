// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_XMPPConnection1(): Unit {
    let xmppConnectionFromMode1 = XMPPConnectionFromMode.UNCHANGED
    let xmppConnectionFromMode2 = XMPPConnectionFromMode.OMITTED
    let xmppConnectionFromMode3 = XMPPConnectionFromMode.USER
    @Assert(true, xmppConnectionFromMode1 == xmppConnectionFromMode1)
    @Assert(true, xmppConnectionFromMode2 == xmppConnectionFromMode2)
    @Assert(true, xmppConnectionFromMode3 == xmppConnectionFromMode3)
    @Assert("UNCHANGED", xmppConnectionFromMode1.toString())
    @Assert("OMITTED", xmppConnectionFromMode2.toString())
    @Assert("USER", xmppConnectionFromMode3.toString())
    @Assert(false, xmppConnectionFromMode2 == xmppConnectionFromMode3)
}
