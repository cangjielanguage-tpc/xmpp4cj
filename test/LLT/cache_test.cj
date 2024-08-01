// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class CacheTest {
    @TestCase
    public func testMaxCacheSize(): Unit {
        let cache = LruCache<Int32, Object>(3)
        cache.put(1, Object())
        cache.put(2, Object())
        cache.put(3, Object())
        cache.put(4, Object())
        var object = cache.lookup(4)
        Assert.assertNotNull(object)
        object = cache.lookup(1)
        Assert.assertNull(object)
        object = cache.lookup(2)
        Assert.assertNotNull(object)
        object = cache.lookup(3)
        Assert.assertNotNull(object)
    }
}
