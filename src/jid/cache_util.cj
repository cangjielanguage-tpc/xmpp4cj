package xmpp4cj.jid

/**
 * 缓存接口。
 *
 * @param <K> 此缓存的键的类型。
 * @param <V> 此缓存缓存的值的类型。
 */
public interface Cache<K, V> {
    /**
     * 在缓存中放置一个值。
     *
     * @param key 键。
     * @param value 值。
     * @return 上一个值或{@code None}。
     */
    func put(key: K, value: V): ?V

    /**
     * 返回指定键的值，或{@code None}。
     *
     * @param key 键。
     * @return 缓存中找到的值，或{@code None}。
     */
    func lookup(key: K): ?V

    /**
     * 返回最大缓存大小。
     *
     * @return 最大缓存大小。
     */
    func getMaxCacheSize(): Int

    /**
     * 设置最大缓存大小。
     *
     * @param size 最大缓存大小。
     */
    func setMaxCacheSize(size: Int): Unit
}

/**
 * 值过期的缓存。
 *
 * @param <K> 此缓存的键的类型。
 * @param <V> 此缓存缓存的值的类型。
 */
public class ExpirationCache<K, V> <: Cache<K, V> where K <: Hashable & Equatable<K> {
    private let cache: LruCache<K, ExpireElement<V>>

    private var defaultExpirationTime: Duration = Duration.nanosecond

    /**
     * 构建过期缓存。
     *
     * @param maxSize 最大大小。
     * @param defaultExpirationTime 默认过期时间（毫秒）。
     */
    public ExpirationCache(maxSize: Int, defaultExpirationTime: Duration) {
        cache = LruCache<K, ExpireElement<V>>(maxSize)
        setDefaultExpirationTime(defaultExpirationTime)
    }

    /**
     * 设置默认过期时间（毫秒）。
     *
     * @param defaultExpirationTime 默认过期时间。
     */
    public func setDefaultExpirationTime(defaultExpirationTime: Duration): Unit {
        this.defaultExpirationTime = defaultExpirationTime
    }

    /**
     * 插入键值对。
     *
     * @param key 键。
     * @param value 值。
     * @return 值。
     */
    public override func put(key: K, value: V): ?V {
        return put(key, value, defaultExpirationTime)
    }

    /**
     * 将具有指定过期时间（毫秒）的值放入缓存中。
     *
     * @param key 键。
     * @param value 值。
     * @param expirationTime 过期时间（毫秒）。
     * @return 上一个值或{@code None}。
     */
    public func put(key: K, value: V, expirationTime: Duration): ?V {
        let eOld: ?ExpireElement<V> = cache.put(key, ExpireElement<V>(value, expirationTime))
        return eOld?.element
    }

    public override func lookup(key: K): ?V {
        return get(key)
    }

    /**
     * 通过键获取值。
     *
     * @param key 键。
     * @return 值。
     */
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

    /**
     * 获取缓存大小。
     *
     * @return 缓存大小。
     */
    public override func getMaxCacheSize(): Int {
        return cache.getMaxCacheSize()
    }

    /**
     * 设置缓存大小。
     *
     * @param maxCacheSize 缓存大小。
     */
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
 * 一种大小有限的专用Map（使用LRU算法）。Map是线程安全。
 *
 * @param <K> 此缓存的键的类型。
 * @param <V> 此缓存缓存的值的类型。
 */
public class LruCache<K, V> <: Cache<K, V> where K <: Hashable & Equatable<K> {
    private let lock: Mutex = Mutex()

    /**
     * 所用数据结构的默认初始值。
     */
    private static let DEFAULT_INITIAL_SIZE: Int = 50

    /**
     * 缓存将容纳的最大项目数。
     */
    private var maxCacheSize: Int = 0

    /**
     * 保持缓存命中和未命中的次数。每次都会发生缓存命中
     * 调用get方法并且缓存包含所请求的
     * 对象。缓存未命中表示相反的情况。
     * 跟踪缓存命中和未命中可以衡量效率
     * 缓存是；命中率越高，效率越高。
     */
    private let cacheHits: AtomicInt64 = AtomicInt64(0)

    private let cacheMisses: AtomicInt64 = AtomicInt64(0)

    private let map: HashMap<K, V>

    private let arr: LinkedList<K>

    /**
     * 在中创建缓存并指定缓存的最大大小。
     * 字节数和对象的最大生存期。
     *
     * @param maxSize 缓存将容纳的最大对象数-1表示缓存没有最大大小。
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
            let oldValue: ?V = map.add(key, value)
            arr.addLast(key)
            while (map.size > maxCacheSize) {
                if (let Some(k) <- arr.removeFirst()) {
                    map.remove(k)
                }
            }
            return oldValue
        }
    }

    public override func lookup(key: K): ?V {
        return map.get(key)
    }

    /**
     * 通过键获取值。
     *
     * @param key 键。
     * @return 值。
     */
    public func get(key: K): ?V {
        let cacheObject: ?V = synchronized(lock) {
            map.get(key)
        }
        if (cacheObject.isNone()) {
            // 缓存中不存在该对象，因此增量缓存未命中。
            cacheMisses.fetchAdd(1)
            return None
        }

        // 对象存在于缓存中，因此缓存命中率会增加。此外，增加对象的读取计数。
        cacheHits.fetchAdd(1)

        return cacheObject
    }

    /**
     * 通过键删除数据。
     *
     * @param key 键。
     * @return 值。
     */
    public func remove(key: K): ?V {
        synchronized(lock) {
            arr.removeIf {k => k == key}
            return map.remove(key)
        }
    }

    /**
     * 获取缓存命中次数。
     *
     * @return 缓存命中次数。
     */
    public func getCacheHits(): Int {
        return cacheHits.load()
    }

    /**
     * 获取缓存未命中次数。
     *
     * @return 缓存未命中的次数。
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
