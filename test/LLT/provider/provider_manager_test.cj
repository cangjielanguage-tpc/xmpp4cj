/// DEPENDENCE: ../z_test.cj
/// DEPENDENCE: ../test_utils.cj  ../xml_test_utils.cj  ../smack_test_util.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj test_utils.cj  xml_test_utils.cj smack_test_util.cj --test
/// EXEC: ./main 
///--filter=*.*
/* TODO */

// IQProvider 的 parse方法返回值不为None
@Test
public class ProviderManagerTest {
    /**
     * This test should be run in a clean (e.g. forked) VM
     * @throws Exception if exception.
     */
    @TestCase
    public func shouldInitializeSmackTest(): Unit {
        ProviderManager.addIQProvider("foo", "bar", TestIQProvider(TestIQProvider))
        @Assert(XmppConfiguration.isSmackInitialized())
    }
}

public class TestIQProvider <: IQProvider<IQ> {
    public init(elementClass: ClassId) {
        super(elementClass)
    }

    public override func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): IQ {
        return None
    }
}
