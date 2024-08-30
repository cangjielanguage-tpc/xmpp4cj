// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public class ExpirationCacheTest {
    @TestCase
    public func testExpirationTime(): Unit {
        let EXPIRATION_TIME = 500
        let cache = ExpirationCache<Int64, Object>(3, Duration.millisecond * Int64(EXPIRATION_TIME))
        cache.put(1, Object())
        cache.put(2, Object())
        sleep(Duration.millisecond * Int64(EXPIRATION_TIME + 1))
        var object = cache.lookup(1)
        Assert.assertNull(object)
        object = cache.lookup(2)
        Assert.assertNull(object)
        cache.put(3, Object())
        object = cache.lookup(3)
        Assert.assertNotNull(object)
    }
}
