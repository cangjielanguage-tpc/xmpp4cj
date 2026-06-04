package xmpp4cj.modular

/**
 * 将一部分模块化的配置定义在modular包中
 * 继承了XmppConfiguration以表其关联性
 */
public class C2sXmppConfiguration <: XmppConfiguration {
    private static let KNOWN_MODULES: Set<ModuleDescriptor> = HashSet()
    private static let KNOWN_MODULES_LOCK: Mutex = Mutex()

    public static func addModule(moduleDescriptor: ModuleDescriptor): Bool {
        synchronized(KNOWN_MODULES_LOCK) {
            return KNOWN_MODULES.add(moduleDescriptor)
        }
    }

    public static func addAllKnownModulesTo(builder: C2sConnectionConfigurationBuilder): Unit {
        synchronized(KNOWN_MODULES_LOCK) {
            for (moduleDescriptor in KNOWN_MODULES) {
                builder.addModule(moduleDescriptor)
            }
        }
    }
}
