// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test
// EXEC: ./main

@Test
public class HashCodeTest {
    @TestCase
    public func testHashCode1() {
        let hashCodeBuilder: HashCodeBuilder = HashCode.builder()
        hashCodeBuilder.append(false)
        @Assert(630, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        hashCodeBuilder.append(true)
        @Assert(23310, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        let a1: UInt8 = 10
        hashCodeBuilder.append(a1)
        @Assert(862480, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        let a2: Rune = r'B'
        hashCodeBuilder.append(a2)
        @Assert(31911826, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        let a3: Float64 = 100.0
        hashCodeBuilder.append(a3)
        @Assert(4636737292535373850, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        let a4: Int64 = 200
        hashCodeBuilder.append(a4)
        @Assert(5538583160422868106, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        let a5: TestHashCode = TestHashCode()
        hashCodeBuilder.append(a5)
        @Assert(2013392124841052246, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        hashCodeBuilder.append(None)
        @Assert(708532324280726638, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
        let a6: Array<TestHashCode> = [TestHashCode(), TestHashCode()]
        hashCodeBuilder.append(a6)
        @Assert(-7696683966291464426, hashCodeBuilder.build())
        println(hashCodeBuilder.build())
    }
}

class TestHashCode <: Hashable {
    public override func hashCode(): Int64 {
        return 100
    }
}
