/**
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.xmpp

/**
 * cache interface.
 *
 * @param <K> the type of the keys of this cache.
 * @param <V> the type of the values this cache caches.
 */
public interface Cache<K, V> {

    /**
     * Put a value in the cache.
     *
     * @param key the key of the value.
     * @param value the value.
     * @return the previous value or {@code None}.
     */
    func put(key: K, value: V): ?V

    /**
     * Returns the value of the specified key, or {@code None}.
     *
     * @param key the key.
     * @return the value found in the cache, or {@code None}.
     */
    func lookup(key: K): ?V

    /**
     * Return the maximum cache Size.
     *
     * @return the maximum cache size.
     */
    func getMaxCacheSize(): Int

    /**
     * Set the maximum cache size.
     * @param size the maximum cache size.
     */
    func setMaxCacheSize(size: Int): Unit
}

/**
 * A cache which expires its values.
 *
 * @param <K> the type of the keys of this cache.
 * @param <V> the type of the values this cache caches.
 */
public class ExpirationCache<K, V> <: Cache<K, V> where K <: Hashable & Equatable<K> {
    private let cache: LruCache<K, ExpireElement<V>>

    private var defaultExpirationTime: Duration = Duration.nanosecond

    /**
     * Construct a expiration cache.
     *
     * @param maxSize the maximum size.
     * @param defaultExpirationTime the default expiration time in milliseconds.
     */
    public ExpirationCache(maxSize: Int, defaultExpirationTime: Duration) {
        cache = LruCache<K, ExpireElement<V>>(maxSize)
        setDefaultExpirationTime(defaultExpirationTime)
    }

    /**
     * Set the default expiration time in milliseconds.
     *
     * @param defaultExpirationTime the default expiration time.
     */
    public func setDefaultExpirationTime(defaultExpirationTime: Duration): Unit {
        this.defaultExpirationTime = defaultExpirationTime
    }

    public override func put(key: K, value: V): ?V {
        return put(key, value, defaultExpirationTime)
    }

    /**
     * Put a value in the cache with the specified expiration time in milliseconds.
     *
     * @param key the key of the value.
     * @param value the value.
     * @param expirationTime the expiration time in milliseconds.
     * @return the previous value or {@code None}.
     */
    public func put(key: K, value: V, expirationTime: Duration): ?V {
        let eOld: ?ExpireElement<V> = cache.put(key, ExpireElement<V>(value, expirationTime))
        return eOld?.element
    }

    public override func lookup(key: K): ?V {
        return get(key)
    }

    public func get(key: K): ?V {
        if (let Some(v: ExpireElement<V>) <- cache.get(key)) {
            if (v.isExpired()) {
                cache.remove(key)
                return None
            }
            return v.element
        }
        return None
    }

    public override func getMaxCacheSize(): Int {
        return cache.getMaxCacheSize()
    }

    public override func setMaxCacheSize(maxCacheSize: Int): Unit {
        cache.setMaxCacheSize(maxCacheSize)
    }
}

class EntryImpl<K, V> {
    private let key: K
    private var value: V

    EntryImpl(key: K, value: V) {
        this.key = key
        this.value = value
    }
    public func getKey(): K {
        return key
    }

    public func getValue(): V {
        return value
    }

    public func setValue(value: V): V {
        let oldValue: V = this.value
        this.value = value
        return oldValue
    }
}

class ExpireElement<V> {
    let element: V
    let expirationTimestamp: DateTime

    ExpireElement(element: V, expirationTime: Duration) {
        this.element = element
        this.expirationTimestamp = DateTime.now() + expirationTime
    }

    func isExpired(): Bool {
        return DateTime.now() > expirationTimestamp
    }
}

/**
 * A specialized Map that is size-limited (using an LRU algorithm). The Map is
 * thread-safe.
 *
 * @param <K> the type of the keys of this cache.
 * @param <V> the type of the values this cache caches.
 */
public class LruCache<K, V> <: Cache<K, V> where K <: Hashable & Equatable<K> {
    private let lock: ReentrantMutex = ReentrantMutex()

    /**
     * The default initial value for the used data structures.
     */
    private static let DEFAULT_INITIAL_SIZE: Int = 50

    /**
     * Maximum number of items the cache will hold.
     */
    private var maxCacheSize: Int = 0

    /**
     * Maintain the number of cache hits and misses. A cache hit occurs every
     * time the get method is called and the cache contains the requested
     * object. A cache miss represents the opposite occurrence.
     * <p>
     * Keeping track of cache hits and misses lets one measure how efficient
     * the cache is; the higher the percentage of hits, the more efficient.
     */
    private let cacheHits: AtomicInt64 = AtomicInt64(0)
    private let cacheMisses: AtomicInt64 = AtomicInt64(0)
    private let map: HashMap<K, V>
    private let arr: LinkedList<K>

    /**
     * Create a cache and specify the maximum size of for the cache in
     * bytes, and the maximum lifetime of objects.
     *
     * @param maxSize the maximum number of objects the cache will hold. -1
     *      means the cache has no max size.
     */
    public LruCache(maxSize: Int) {
        if (maxSize < 1) {
            throw IllegalArgumentException("Max cache size must be positive.")
        }
        let size = if (maxSize < DEFAULT_INITIAL_SIZE) {
            maxSize
        } else {
            DEFAULT_INITIAL_SIZE
        }
        this.map = HashMap<K, V>(size)
        this.arr = LinkedList<K>()
        this.maxCacheSize = maxSize
    }

    public override func put(key: K, value: V): ?V {
        synchronized(lock) {
            let oldValue: ?V = map.put(key, value)
            arr.append(key)
            while (map.size > maxCacheSize) {
                if (let Some(k) <- arr.popFirst()) {
                    map.remove(k)
                }
            }
            return oldValue
        }
    }

    public override func lookup(key: K): ?V {
        return map.get(key)
    }

    public func get(key: K): ?V {
        let cacheObject: ?V = synchronized(lock) {
            map.get(key)
        }
        if (cacheObject.isNone()) {
            // The object didn't exist in cache, so increment cache misses.
            cacheMisses.fetchAdd(1)
            return None
        }

        // The object exists in cache, so increment cache hits. Also, increment
        // the object's read count.
        cacheHits.fetchAdd(1)

        return cacheObject
    }

    public func remove(key: K): ?V {
        synchronized(lock) {
            arr.removeIf {k => k == key}
            return map.remove(key)
        }
    }

    /**
     * Get the number of cache hits.
     *
     * @return the number of cache hits.
     */
    public func getCacheHits(): Int {
        return cacheHits.load()
    }

    /**
     * Get the number of cache misses.
     *
     * @return the number of cache misses.
     */
    public func getCacheMisses(): Int {
        return cacheMisses.load()
    }

    public override func getMaxCacheSize(): Int {
        return maxCacheSize
    }

    public override func setMaxCacheSize(maxCacheSize: Int): Unit {
        this.maxCacheSize = maxCacheSize
    }
}
