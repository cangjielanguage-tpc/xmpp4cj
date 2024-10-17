// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test
// EXEC: ./main

@Test
public func test_ExceptionThrowingCallback1(): Unit {
    let unparseableStanza: UnparseableStanza = UnparseableStanza("UnparseableStanza",
        IllegalArgumentException("IllegalArgumentException"))
    let exceptionThrowingCallback: ExceptionThrowingCallback = ExceptionThrowingCallback()
    let e0: IOException = @AssertThrows[IOException](exceptionThrowingCallback.handleUnparsableStanza(unparseableStanza))
    @Assert("IOException", e0.toString()) 
}

@Test
public func test_UnparseableStanza1(): Unit {
    let unparseableStanza: UnparseableStanza = UnparseableStanza("UnparseableStanza",
        IllegalArgumentException("IllegalArgumentException"))
    let e0: Exception = unparseableStanza.getParsingException()
    let s :String = unparseableStanza.getContent()
    @Assert("IllegalArgumentException: IllegalArgumentException", e0.toString()) 
    @Assert("UnparseableStanza", s) 
}
