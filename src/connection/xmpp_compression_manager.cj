package xmpp4cj.connection

public open class XmppCompressionManager {
    private static let xmppCompressionFactories = ArrayList<XmppCompressionFactory>(4)
    private static let xmppCompressionFactoriesLock = Mutex()

    public static func registerXmppCompressionFactory(xmppCompressionFactory: XmppCompressionFactory): ?XmppCompressionFactory {
        let method = xmppCompressionFactory.getCompressionMethod()
        var previousFactory: ?XmppCompressionFactory = None
        synchronized(xmppCompressionFactoriesLock) {
            for (i in 0..xmppCompressionFactories.size) {
                let factory = xmppCompressionFactories[i]
                if (factory.getCompressionMethod() == method) {
                    xmppCompressionFactories.remove(at: i)
                    previousFactory = factory
                    break
                }
            }
            xmppCompressionFactories.add(xmppCompressionFactory)
            sort(xmppCompressionFactories)
        }
        return previousFactory
    }

    public static func getBestFactory(compressFeature: CompressFeature): ?XmppCompressionFactory {
        let announcedMethods = compressFeature.getMethods()
        synchronized(xmppCompressionFactoriesLock) {
            for (factory in xmppCompressionFactories) {
                if (announcedMethods |> any {v => v == factory.getCompressionMethod()}) {
                    return factory
                }
            }
        }
        return None
    }
}
