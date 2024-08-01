// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class PartTest {
    @TestCase
    public func testPartEqualsNullIsFalse(): Unit {
        Assert.assertNotNull(PartTest_1(this, "something"))
    }
}

class PartTest_1 <: Part {
    let this_0: PartTest

    init(this_0: PartTest, part: String) {
        super(part)
        this.this_0 = this_0
    }

    private static let serialVersionUID = 0
}
