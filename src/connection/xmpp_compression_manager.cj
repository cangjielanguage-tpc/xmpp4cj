/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
package xmpp4cj.connection

public open class XmppCompressionManager {
    private static let xmppCompressionFactories = ArrayList<XmppCompressionFactory>(4)
    private static let xmppCompressionFactoriesLock = Monitor()

    public static func registerXmppCompressionFactory(xmppCompressionFactory: XmppCompressionFactory): ?XmppCompressionFactory {
        let method = xmppCompressionFactory.getCompressionMethod()
        var previousFactory: ?XmppCompressionFactory = None
        synchronized(xmppCompressionFactoriesLock) {
            for (i in 0..xmppCompressionFactories.size) {
                let factory = xmppCompressionFactories[i]
                if (factory.getCompressionMethod() == method) {
                    xmppCompressionFactories.remove(i)
                    previousFactory = factory
                    break
                }
            }
            xmppCompressionFactories.append(xmppCompressionFactory)
            xmppCompressionFactories.sort()
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
