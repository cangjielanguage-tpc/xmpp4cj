// DEPENDENCE: xml_test_utils.cj
// DEPENDENCE: smack_test_util.cj
/// EXEC: cjc %import-path %L %l %f  --test
/// EXEC: ./main 
//--filter=*.*
/* TODO */

public class ProviderManagerTest {

    /**
     * This test should be run in a clean (e.g. forked) VM
     * @throws Exception if exception.
     */
    @TestCase
    public func shouldInitializeSmackTest(): Unit {
        ProviderManager.addIQProvider("foo", "bar", TestIQProvider())
        @Assert(SmackConfiguration.isSmackInitialized())
    }
}

public class TestIQProvider <: IQProvider<IQ> {

    // @Override
    public func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): IQ {
        return None
    }
}
