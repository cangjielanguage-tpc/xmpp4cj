/// DEPENDENCE: ../z_test.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj --test
/// EXEC: ./main

@Test
public func test_ScramMechanism1(): Unit {
    let scramMechanismState1 = ScramMechanismState.INITIAL
    let scramMechanismState2 = ScramMechanismState.AUTH_TEXT_SENT
    let scramMechanismState3 = ScramMechanismState.RESPONSE_SENT
    let scramMechanismState4 = ScramMechanismState.VALID_SERVER_RESPONSE
    @Assert(true, scramMechanismState1 == scramMechanismState1)
    @Assert(true, scramMechanismState2 == scramMechanismState2)
    @Assert(true, scramMechanismState3 == scramMechanismState3)
    @Assert(true, scramMechanismState4 == scramMechanismState4)
    @Assert(false, scramMechanismState1 == scramMechanismState2)
}
