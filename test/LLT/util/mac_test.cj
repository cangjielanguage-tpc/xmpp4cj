// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test --debug-macro
// EXEC: ./main

import stdx.crypto.digest.*
import stdx.crypto.common.*

@Test
public class MACTest {
    @TestCase
    public func testMAC1() {
        let arr1: Array<UInt8> = "0123456789".toArray()
        let arr2: Array<UInt8> = "0123456789".toArray()
        let arr3: Array<UInt8> = MAC.hmacsha1(arr1, arr2)
        let arr4: Array<UInt8> = [203, 7, 8, 151, 221, 120, 149, 124, 42, 41, 118, 16, 91, 75, 56, 237, 228, 60, 179,
            228]
        @Assert(arr4, arr3)
    }

    @TestCase
    public func testMAC2() {
        let arr1: Array<UInt8> = "1".toArray()
        let arr2: Array<UInt8> = "1".toArray()
        let arr3: Array<UInt8> = MAC.hmacsha1(arr1, arr2)
        println(arr3)
        let arr4: Array<UInt8> = [91, 12, 21, 125, 78, 118, 114, 68, 76, 65, 3, 53, 97, 85, 72, 57, 237, 31, 210, 214]
        @Assert(arr4, arr3)
    }

    @TestCase
    public func testMAC3() {
        let arr1: Array<UInt8> = "".toArray()
        let arr2: Array<UInt8> = "".toArray()
        let e0: CryptoException = @AssertThrows[CryptoException](MAC.hmacsha1(arr1, arr2))
        @Assert("CryptoException: The key cannot be empty.", e0.toString())
    }
}
