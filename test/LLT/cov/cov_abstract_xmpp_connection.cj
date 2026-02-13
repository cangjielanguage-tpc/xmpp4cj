// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_AbstractXMPPConnection1(): Unit {
    let syncPointState1 = SyncPointState.initial
    let syncPointState2 = SyncPointState.request_sent
    let syncPointState3 = SyncPointState.successful
    @Assert(true, syncPointState1 == syncPointState1)
    @Assert(true, syncPointState2 == syncPointState2)
    @Assert(true, syncPointState3 == syncPointState3)
    @Assert(false, syncPointState3 == syncPointState2)
}
