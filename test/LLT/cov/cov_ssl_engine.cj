// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_SSLEngine1(): Unit {
    let sslStatus1 = SSLStatus.BUFFER_UNDERFLOW
    let sslStatus2 = SSLStatus.BUFFER_OVERFLOW
    let sslStatus3 = SSLStatus.OK
    let sslStatus4 = SSLStatus.CLOSED
    @Assert(true, sslStatus1 == sslStatus1)
    @Assert(true, sslStatus2 == sslStatus2)
    @Assert(true, sslStatus3 == sslStatus3)
    @Assert(true, sslStatus4 == sslStatus4)
    @Assert(false, sslStatus4 == sslStatus3)
    @Assert("BUFFER_UNDERFLOW", sslStatus1.toString())
    @Assert("BUFFER_OVERFLOW", sslStatus2.toString())
    @Assert("OK", sslStatus3.toString())
    @Assert("CLOSED", sslStatus4.toString())
}

@Test
public func test_SSLEngine2(): Unit {
    let handshakeStatus1 = HandshakeStatus.NOT_HANDSHAKING
    let handshakeStatus2 = HandshakeStatus.FINISHED
    let handshakeStatus3 = HandshakeStatus.NEED_TASK
    let handshakeStatus4 = HandshakeStatus.NEED_WRAP
    let handshakeStatus5 = HandshakeStatus.NEED_UNWRAP
    let handshakeStatus6 = HandshakeStatus.NEED_UNWRAP_AGAIN
    @Assert(true, handshakeStatus1 == handshakeStatus1)
    @Assert(true, handshakeStatus2 == handshakeStatus2)
    @Assert(true, handshakeStatus3 == handshakeStatus3)
    @Assert(true, handshakeStatus4 == handshakeStatus4)
    @Assert(true, handshakeStatus5 == handshakeStatus5)
    @Assert(true, handshakeStatus6 == handshakeStatus6)
    @Assert(false, handshakeStatus1 == handshakeStatus6)
    @Assert("NOT_HANDSHAKING", handshakeStatus1.toString())
    @Assert("FINISHED", handshakeStatus2.toString())
    @Assert("NEED_TASK", handshakeStatus3.toString())
    @Assert("NEED_WRAP", handshakeStatus4.toString())
    @Assert("NEED_WRAP", handshakeStatus5.toString())
    @Assert("NEED_UNWRAP_AGAIN", handshakeStatus6.toString())
}

@Test
public func test_SSLEngine3(): Unit {
    let sslException: SSLException = SSLException()
}
