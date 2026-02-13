// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_ScheduledAction1(): Unit {
    let reconnectionPolicy1 = ScheduledActionKind.NonBlocking
    let reconnectionPolicy2 = ScheduledActionKind.Blocking
}
