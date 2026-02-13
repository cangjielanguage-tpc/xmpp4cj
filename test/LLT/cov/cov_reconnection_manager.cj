// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_ReconnectionManager1(): Unit {
    let reconnectionPolicy1 = ReconnectionPolicy.RANDOM_INCREASING_DELAY
    let reconnectionPolicy2 = ReconnectionPolicy.FIXED_DELAY
    @Assert("RANDOM_INCREASING_DELAY", reconnectionPolicy1.toString())
    @Assert("FIXED_DELAY", reconnectionPolicy2.toString())
}
