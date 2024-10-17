// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test
// EXEC: ./main

@Test
public class RandomUtilTest {
    @TestCase
    public func testRandomUtil1() {
        let e0: IllegalArgumentException = @AssertThrows[IllegalArgumentException](RandomUtil.nextSecureRandomInt(0))
        @Assert("IllegalArgumentException: Invalid argument", e0.toString())
        let e1: IllegalArgumentException = @AssertThrows[IllegalArgumentException](RandomUtil.nextSecureRandomInt(-10))
        @Assert("IllegalArgumentException: Invalid argument", e1.toString())
        let a2 = RandomUtil.nextSecureRandomInt(10)
        @Assert(true, a2 < 10)
        let a3 = RandomUtil.nextSecureRandomInt(100)
        @Assert(true, a2 < 100)
    }

    @TestCase
    public func testRandomUtil2() {
        let a0 = RandomUtil.nextSecureRandomInt()
        @Assert(true, a0 < Int64.Max)
        let a1 = RandomUtil.nextSecureRandomInt()
        @Assert(true, a1 < Int64.Max)
        let a2 = RandomUtil.nextSecureRandomInt()
        @Assert(true, a2 < Int64.Max)
        let a3 = RandomUtil.nextSecureRandomInt()
        @Assert(true, a3 < Int64.Max)
    }

    @TestCase
    public func testRandomUtil3() {
        let bytes: Array<Byte> = [10, 30, 40, 50]
        let a0 = RandomUtil.fillWithSecureRandom(bytes)
        @Assert(true, a0.size == 4)
        let a1 = RandomUtil.fillWithSecureRandom(bytes)
        @Assert(true, a1.size == 4)
        let a2 = RandomUtil.fillWithSecureRandom(bytes)
        @Assert(true, a2.size == 4)
        let a3 = RandomUtil.fillWithSecureRandom(bytes)
        @Assert(true, a3.size == 4)
    }
}
