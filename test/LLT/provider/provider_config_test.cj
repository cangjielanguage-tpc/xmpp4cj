/// DEPENDENCE: ../z_test.cj
/// DEPENDENCE: ../test_utils.cj ../xml_test_utils.cj  ../smack_test_util.cj
/// EXEC: cjc %import-path %L %l %f z_test.cj test_utils.cj xml_test_utils.cj smack_test_util.cj --test
/// EXEC: ./main 
///--filter=*.*
/* TODO */

// IQProvider 的 parse方法返回值不为None

@Test
public class ProviderConfigTest {
    @TestCase
    public func addGenericLoaderProvider(): Unit {
        ProviderManager.addLoader(ProviderLoader1())

        Assert.assertNotNull(ProviderManager.getIQProvider("provider", "test:provider"))
    }

    // throws Exception 
    @TestCase
    public func addClasspathFileLoaderProvider(): Unit {
        ProviderManager.addLoader(ProviderSimpleLoader(FileUtils.getStreamForClasspathFile("test.providers", None)))
        Assert.assertNotNull(ProviderManager.getIQProvider("provider", "test:file_provider"))
    }
}

public class TestIQProvider <: IQProvider<IQ> {

    // @Override
    public func parse(parser: XmlPullParser, initialDepth: Int, xmlEnvironment: ?XmlEnvironment): IQ {
        return None
    }
}

class ProviderLoader1 <: ProviderLoader {

    // @Override
    public func getIQProviderInfo(): Collection<IQProviderInfo> {
        let l = ArrayList<IQProviderInfo>(1)
        l.add(IQProviderInfo("provider", "test:provider", TestIQProvider()))
        return l
    }

    // @Override
    public func getExtensionProviderInfo(): Collection<ExtensionProviderInfo> {
        return None
    }

    // @Override
    public func getStreamFeatureProviderInfo(): Collection<StreamFeatureProviderInfo> {
        return None
    }
}
