// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_SASLError1(): Unit {
    let saslError1 = SASLError.aborted
    let saslError2 = SASLError.account_disabled
    let saslError3 = SASLError.credentials_expired
    let saslError4 = SASLError.encryption_required
    let saslError5 = SASLError.incorrect_encoding
    let saslError6 = SASLError.invalid_authzid
    let saslError7 = SASLError.invalid_mechanism
    let saslError8 = SASLError.malformed_request
    let saslError9 = SASLError.mechanism_too_weak
    let saslError10 = SASLError.not_authorized
    let saslError11 = SASLError.temporary_auth_failure
    // @Assert(true, saslError1 == saslError1)
    // @Assert(true, saslError2 == saslError2)
    // @Assert(true, saslError3 == saslError3)
    // @Assert(true, saslError4 == saslError4)
    // @Assert(true, saslError5 == saslError5)
    // @Assert(true, saslError6 == saslError6)
    // @Assert(true, saslError7 == saslError7)
    // @Assert(true, saslError8 == saslError8)
    // @Assert(true, saslError9 == saslError9)
    // @Assert(true, saslError10 == saslError10)
    // @Assert(true, saslError11 == saslError11)
    // @Assert(false, saslError11 == saslError1)
    @Assert("aborted", saslError1.toString())
    @Assert("account-disabled", saslError2.toString())
    @Assert("credentials-expired", saslError3.toString())
    @Assert("encryption-required", saslError4.toString())
    @Assert("incorrect-encoding", saslError5.toString())
    @Assert("invalid-authzid", saslError6.toString())
    @Assert("invalid-mechanism", saslError7.toString())
    @Assert("malformed-request", saslError8.toString())
    @Assert("mechanism-too-weak", saslError9.toString())
    @Assert("not-authorized", saslError10.toString())
    @Assert("temporary-auth-failure", saslError11.toString())
    @Assert(saslError1.toString(), SASLError.fromString(saslError1.toString()).getOrThrow().toString())
    @Assert(saslError2.toString(), SASLError.fromString(saslError2.toString()).getOrThrow().toString())
    @Assert(saslError3.toString(), SASLError.fromString(saslError3.toString()).getOrThrow().toString())
    @Assert(saslError4.toString(), SASLError.fromString(saslError4.toString()).getOrThrow().toString())
    @Assert(saslError5.toString(), SASLError.fromString(saslError5.toString()).getOrThrow().toString())
    @Assert(saslError6.toString(), SASLError.fromString(saslError6.toString()).getOrThrow().toString())
    @Assert(saslError7.toString(), SASLError.fromString(saslError7.toString()).getOrThrow().toString())
    @Assert(saslError8.toString(), SASLError.fromString(saslError8.toString()).getOrThrow().toString())
    @Assert(saslError9.toString(), SASLError.fromString(saslError9.toString()).getOrThrow().toString())
    @Assert(saslError10.toString(), SASLError.fromString(saslError10.toString()).getOrThrow().toString())
    @Assert(saslError11.toString(), SASLError.fromString(saslError11.toString()).getOrThrow().toString())
    @Assert(false, SASLError.fromString("saslError11.toString()").isSome())
}
