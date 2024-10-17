// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test
// EXEC: ./main

@Test
public class SHA1UtilTest {
    @TestCase
    public func testHash1() {
        let result: String = SHA1Util.hex("")
        @Assert("da39a3ee5e6b4b0d3255bfef95601890afd80709", result)
    }

    @TestCase
    public func testHash2() {
        let adminInHash: String = "d033e22ae348aeb5660fc2140aec35850c4da997"
        let result: String = SHA1Util.hex("admin")
        @Assert(adminInHash, result)
    }

    @TestCase
    public func testHash3() {
        let random: String = "jive software blah and stuff this is pretty cool"
        let result: String = SHA1Util.hex(random)
        @Assert(isValidHash(result))
    }

    @TestCase
    public func testHash4() {
        let junk: String = "\n\n\t\b\r!@(!)^(#)@+_-r'\u{2031}'r'\u{09291}'r'\u{00A9}'r'\u{00BD}'r'\u{0394}'r'\u{00F8}'"
        let result: String = SHA1Util.hex("")
        @Assert(isValidHash(result))
    }

    private let HASH_CHARS: String = "0123456789abcdef"

    private func isValidHash(result: String): Bool {
        var valid: Bool = true
        for (i in 0..result.size) {
            let c: Byte = result[i]
            if (HASH_CHARS.indexOf(c).getOrThrow() < 0) {
                valid = false
            }
        }
        return valid;
    }
}
